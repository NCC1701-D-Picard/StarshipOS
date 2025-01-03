//file:noinspection unused
//file:noinspection GroovyAssignabilityCheck
package org.starship.init

import com.sun.jna.Native
import groovy.util.logging.Slf4j
import org.starship.jna.CLib
import org.starship.sys.PanicException
import sun.misc.Signal

import java.lang.management.ManagementFactory
import java.nio.file.Path
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.TimeUnit

@Slf4j
class Init {
    // Configuration paths
    static final long HEARTBEAT_TIMEOUT_MS = 5000 // Time to wait for a heartbeat in ms
    static final int MAX_RETRY_ATTEMPTS = 3      // Retry attempts to start the BundleManager
    static final String BUNDLE_MANAGER_COMMAND = "java -cp /path/to/bundlemanager.jar com.starship.BundleManager"
    static Process bundleManagerProcess = null   // Track the BundleManager process
    static long bundleManagerPid = -1            // Track PID of the BundleManager
    static final String PRIMARY_CONFIG_PATH = "/etc/starship/config.d/default.config"
    static final String FALLBACK_CONFIG_PATH = "resources/default-init.config"

    // Track the last heartbeat time
    static volatile long lastHeartbeatTimestamp = 0

    static final String BUNDLE_MANAGER_SOCKET_PATH = "/tmp/bundlemanager.sock"

    // List of running child processes
    static List<Process> childProcesses = [].asSynchronized() as List<Process>
    static Set<String> mountedResources = ConcurrentHashMap.newKeySet()

    /**
     * Start the BundleManager as a subprocess.
     * Wait for the initial heartbeat within the defined timeout duration.
     * Retry starting the BundleManager if it fails, up to MAX_RETRY_ATTEMPTS.
     */
    static void startBundleManager() {
        int attempts = 0
        boolean started = false

        while (attempts < MAX_RETRY_ATTEMPTS) {
            attempts++
            log.info("Attempting to start BundleManager (attempt ${attempts} of ${MAX_RETRY_ATTEMPTS})...")

            try {
                // Spawn the BundleManager process
                bundleManagerProcess = new ProcessBuilder(BUNDLE_MANAGER_COMMAND.split(" "))
                        .inheritIO() // Redirect output (optional, to log startup issues)
                        .start()

                bundleManagerPid = bundleManagerProcess.pid()
                log.info("Spawned BundleManager with PID: ${bundleManagerPid}")

                // Monitor the first heartbeat
                if (waitForHeartbeat()) {
                    log.info("BundleManager is running and healthy (heartbeat received).")
                    started = true
                    break
                } else {
                    log.warn("No heartbeat received from BundleManager within timeout. Retrying...")
                    stopBundleManager() // Clean up before retrying
                }
            } catch (Exception e) {
                log.error("Failed to start BundleManager: ${e.message}", e)
                stopBundleManager()
            }
        }

        if (!started) {
            log.error("Failed to start BundleManager after ${MAX_RETRY_ATTEMPTS} attempts. Triggering kernel panic.")
            throw new PanicException("BundleManager failed to initialize.")
        }
    }


    /**
     * Stop the BundleManager process if it is running.
     */
    static void stopBundleManager() {
        if (bundleManagerProcess?.isAlive()) {
            log.info("Stopping BundleManager (PID: ${bundleManagerPid})...")
            bundleManagerProcess.destroy()
            if (!bundleManagerProcess.waitFor(5, TimeUnit.SECONDS)) {
                log.warn("Forcefully killing BundleManager (PID: ${bundleManagerPid})...")
                bundleManagerProcess.destroyForcibly()
            }
            bundleManagerProcess = null
            bundleManagerPid = -1
        } else {
            log.info("No active BundleManager process to stop.")
        }
    }

    /**
     * Start listening for heartbeats over a UDS.
     */
    static void startHeartbeatListener() {
        new Thread({
            try {
                // Clean up the socket file if it exists
                Path socketPath = Path.of(BUNDLE_MANAGER_SOCKET_PATH)
                Files.deleteIfExists(socketPath)

                ServerSocket serverSocket = new ServerSocket()
                serverSocket.bind(new InetSocketAddress(BUNDLE_MANAGER_SOCKET_PATH, 0))

                log.info("Listening for heartbeats on UDS: ${BUNDLE_MANAGER_SOCKET_PATH}")

                while (true) {
                    try (Socket clientSocket = serverSocket.accept()) {
                        log.info("Client connected to heartbeat socket.")

                        BufferedReader reader = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()))
                        String message
                        while ((message = reader.readLine()) != null) {
                            if (message.trim() == "heartbeat") {
                                lastHeartbeatTimestamp = System.currentTimeMillis()
                                log.debug("Received heartbeat at ${lastHeartbeatTimestamp}")
                            }
                        }
                    } catch (Exception e) {
                        log.error("Error reading from UDS: ${e.message}", e)
                    }
                }
            } catch (Exception e) {
                log.error("Failed to start heartbeat listener: ${e.message}", e)
                throw new PanicException("Heartbeat listener failed to initialize.")
            }
        }).start()
    }

    /**
     * Wait for a heartbeat from the running BundleManager.
     *
     * @return true if heartbeat is received within the timeout, false otherwise.
     */
    static boolean waitForHeartbeat() {
        long startTime = System.currentTimeMillis()

        while ((System.currentTimeMillis() - startTime) < HEARTBEAT_TIMEOUT_MS) {
            if (isHeartbeatReceived()) {
                return true
            }
            Thread.sleep(500) // Poll every 500ms to reduce CPU usage
        }
        return false
    }

    /**
     * Check if a heartbeat has been received within the timeout period.
     *
     * @return true if a recent heartbeat was received, false otherwise.
     */
    static boolean isHeartbeatReceived() {
        return (System.currentTimeMillis() - lastHeartbeatTimestamp) < HEARTBEAT_TIMEOUT_MS
    }

    // Load a configuration file dynamically
    static void loadConfig(String configPath) {
        try {
            File configFile = new File(configPath)
            if (!configFile.exists()) {
                log.warn("Configuration file not found: ${configPath}. Attempting fallback configuration...")

                // Attempt to load fallback config from the classpath
                URL fallbackConfigUrl = Init.class.getClassLoader().getResource(FALLBACK_CONFIG_PATH)
                if (fallbackConfigUrl == null) {
                    throw new PanicException("Fallback configuration not found in classpath: ${FALLBACK_CONFIG_PATH}")
                } else {
                    log.info("Using fallback configuration from: ${fallbackConfigUrl}")
                    evaluate(new File(fallbackConfigUrl.toURI()))
                }
            } else {
                // Evaluate primary configuration
                log.info("Loading configuration from: ${configPath}")
                evaluate(configFile)
            }
        } catch (Exception e) {
            // Handle unexpected errors and call kernel panic
            throw new PanicException("Failed to load configuration due to an error: ${e.message}", e)
        }
    }

    // Include directive for additional configuration files
    static void include(String path) {
        log.info("Including configuration from: ${path}")
        loadConfig(path) // Recursive call to load the included configuration
    }

    // Reap zombie processes (PID 1 responsibility)
    static void reapZombies() {
        childProcesses.removeIf { process ->
            try {
                // Safeguard to prevent reaping PID 1
                if (process.pid() == 1) {
                    log.warn("Attempted to reap PID 1, ignoring.")
                    return false // Do not remove PID 1 from the childProcesses list
                }

                if (process.waitFor(0, TimeUnit.SECONDS)) {
                    log.info("Reaped zombie process with PID: {} and exit code: {}", process.pid(), process.exitValue())
                    return true // Process successfully reaped and should be removed
                }
            } catch (Exception e) {
                log.error("Error while attempting to reap process (PID: {}): {}", process?.pid(), e.message, e)
            }
            return false // Process was not reaped or encountered an error
        }
    }

    // Shutdown hook for cleanup during SIGTERM or errors
    static void setupShutdownHook() {
        Runtime.runtime.addShutdownHook(new Thread({
            log.info("Shutdown signal received. Cleaning up...")
            childProcesses.each { it.destroy() } // Terminate all child processes
            log.info("All spawned processes terminated. Exiting gracefully.")
        }))
    }

    // Spawn a child process and register it
    static void spawnProcess(String command, String name) {
        try {
            log.info("Spawning process '${name}': ${command}")
            ProcessBuilder builder = new ProcessBuilder(command.split(" "))
            Process process = builder.start()
            childProcesses.add(process)
            log.info("Process '${name}' spawned with PID: ${process.pid()}.")
        } catch (Exception e) {
            log.error("Failed to spawn process '${name}': ${e.message}", e)
        }
    }

    // Evaluate the configuration for the init process
    static void evaluate(File configFile) {
        if (configFile == null || !configFile.exists()) {
            throw new IllegalArgumentException("Configuration file ${configFile?.name} does not exist or is null.")
        }

        try {
            log.info("Evaluating configuration file: ${configFile.absolutePath}")

            // Create a new GroovyShell instance
            GroovyShell shell = new GroovyShell()

            // Execute the DSL config file
            shell.evaluate(configFile)

            log.info("Configuration file evaluated successfully.")
        } catch (Exception e) {
            log.error("Error while evaluating configuration file: ${e.message}", e)
            throw e
        }
    }

    @SuppressWarnings('GroovySynchronizationOnNonFinalField')
    static void unmountResource(String mountPoint, boolean force) {
        synchronized (mountedResources) {
            if (!mountedResources.contains(mountPoint)) {
                log.warn("Attempt to unmount an unknown or already unmounted resource: {}", mountPoint)
                return
            }

            try {
                log.info("Unmounting resource: {} using kernel call{}...",
                        mountPoint, force ? " (forced)" : "")

                // Call the appropriate umount function from libc depending on forced unmount or not
                int result
                if (force) {
                    // Forceful unmount using umount2 with MNT_FORCE flag
                    result = CLib.INSTANCE.umount2(mountPoint, CLib.MNT_FORCE)
                } else {
                    // Regular unmount
                    result = CLib.INSTANCE.umount(mountPoint)
                }

                if (result == 0) {
                    log.info("Successfully unmounted resource: {}", mountPoint)
                    mountedResources.remove(mountPoint) // Remove from tracking
                } else {
                    // Retrieve the errno value for additional error information
                    String errorMessage = Native.getLastError()
                    log.error("Failed to unmount resource {}. Error code: {}", mountPoint, errorMessage)

                    // If regular unmount fails and force is requested, try forced unmount
                    if (!force) {
                        log.warn("Retrying forced unmount for resource: {}", mountPoint)
                        unmountResource(mountPoint, true)
                    }
                }
            } catch (Exception e) {
                log.error("Exception occurred while unmounting resource {}: {}", mountPoint, e.message, e)
            }
        }
    }


    static void shutdown() {
        try {
            log.info("System shutdown initiated...")

            // 1. Stop all spawned child processes
            if (childProcesses.isEmpty()) {
                log.info("No active child processes to terminate.")
            } else {
                childProcesses.each { process ->
                    try {
                        if (process.isAlive()) {
                            log.info("Terminating child process (pid: {})...", process.pid())
                            process.destroy() // Attempt graceful termination
                            if (!process.waitFor(5, TimeUnit.SECONDS)) {
                                log.warn("Forcefully killing process (pid: {})...", process.pid())
                                process.destroyForcibly() // Force termination if it doesn't stop in 5 seconds
                            }
                            log.info("Child process (pid: {}) terminated.", process.pid())
                        }
                    } catch (Exception e) {
                        log.error("Failed to terminate process (pid: {}): {}", process?.pid(), e.message, e)
                    }
                }
                // Clear the list of child processes
                childProcesses.clear()
                log.info("All child processes terminated.")
            }

            // 2. Unmount filesystems (example implementation for mounted resources)
            if (mountedResources.isEmpty()) {
                log.info("No mounted resources to unmount.")
            } else {
                mountedResources.each { mountPoint ->
                    try {
                        log.info("Unmounting resource: {}...", mountPoint)
                        unmountResource(mountPoint)
                        log.info("Resource {} unmounted successfully.", mountPoint)
                    } catch (Exception e) {
                        log.error("Failed to unmount resource {}: {}", mountPoint, e.message, e)
                    }
                }
                mountedResources.clear()
                log.info("All mounted resources unmounted.")
            }

            // 3. Cleanup temporary files or logs (optional)
            log.info("Shutdown completed successfully. Goodbye!")

        } catch (Exception e) {
            log.error("Error during shutdown: {}", e.message, e)
            throw e
        }
    }

    // Main method for initialization
    static void main(String[] args) {
        // Check running as PID 1
        if (ManagementFactory.getRuntimeMXBean().getName().split("@")[0] != "1") {
            log.warn("Warning: This script is not running as PID 1.")
        }

        try {
            log.info("Initializing StarshipOS as PID 1...")
            setupShutdownHook()
            startHeartbeatListener() // Start UDS listener for heartbeats
            startBundleManager()
            loadConfig(PRIMARY_CONFIG_PATH)

            // Signal handlers
            Signal.handle(new Signal("TERM"), signal -> {
                log.info("Caught SIGTERM, shutting down gracefully...")
                shutdown()
            })

            Signal.handle(new Signal("INT"), signal -> {
                log.info("Caught SIGINT, shutting down gracefully...")
                shutdown()
            })

            // Supervision loop
            while (true) {
                try {
                    reapZombies() // Clean up zombie processes

                    // Check if BundleManager is alive and sending heartbeats
                    if (!isBundleManagerAlive()) {
                        log.warn("BundleManager is not running. Attempting to restart...")
                        startBundleManager()
                    }

                    Thread.sleep(1000) // Supervisor polling interval
                } catch (Exception e) {
                    log.error("Error in supervisor loop: ${e.message}", e)
                    throw new PanicException("Fatal error in supervisor loop.")
                }
            }
        } catch (Exception e) {
            log.error("Error in supervisor loop: ${e.message}", e)
            throw new PanicException("Fatal error in supervisor loop.")
        }
    }
}
