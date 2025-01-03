package com.starship

import groovy.util.logging.Slf4j

import java.nio.file.Files
import java.nio.file.Path

@Slf4j
class BundleManager {

    // Constants
    private static final long DEFAULT_HEARTBEAT_INTERVAL_MS = 1000
    private static final String DEFAULT_SOCKET_PATH = "/tmp/bundlemanager.sock"
    public static final String UTF_8 = "UTF-8"

    static void main(String[] args) {
        log.info("Starting BundleManager process...")

        // Parse arguments for socket path and heartbeat interval
        String socketPath = args.length > 0 ? args[0] : DEFAULT_SOCKET_PATH
        long heartbeatIntervalMs = args.length > 1 ? args[1].toLong() : DEFAULT_HEARTBEAT_INTERVAL_MS

        // Start IPC Server and Heartbeat
        //noinspection GroovyUnusedAssignment
        BundleManager bundleManager = new BundleManager()
        runServer(socketPath, heartbeatIntervalMs)

        log.info("BundleManager process shutting down.")
    }

    static void runServer(String socketPath, long heartbeatIntervalMs) {
        // Ensure the socket path is clean (delete previous file if present)
        Path udsPath = Path.of(socketPath)
        try {
            Files.deleteIfExists(udsPath)
        } catch (Exception e) {
            log.error("Failed to clean previous UDS path: ${e.message}")
        }

        ServerSocket serverSocket = new ServerSocket()
        serverSocket.bind(new InetSocketAddress(socketPath as int))

        log.info("BundleManager started. Listening on: $socketPath")

        while (true) {
            try {
                Socket clientSocket = serverSocket.accept()
                log.debug("Client connected.")

                // Start a thread to handle heartbeats for the client
                Thread.start {
                    sendHeartbeats(clientSocket, heartbeatIntervalMs)
                }
            } catch (Exception e) {
                log.error("Error in server: ${e.message}")
            }
        }
    }

    private static void sendHeartbeats(Socket clientSocket, long intervalMs) {
        try (OutputStreamWriter writer = new OutputStreamWriter(clientSocket.getOutputStream(), UTF_8)) {
            while (!Thread.currentThread().isInterrupted() && clientSocket.isConnected()) {
                writer.write("heartbeat\n")
                writer.flush()
                Thread.sleep(intervalMs)
            }
        } catch (Exception e) {
            log.error("Error while sending heartbeats: ${e.message}")
        } finally {
            try {
                clientSocket.close()
            } catch (Exception e) {
                log.error("Failed to close client socket: ${e.message}")
            }
        }
    }
}
