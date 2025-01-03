package org.starship.jna

import com.sun.jna.Library
import com.sun.jna.Native
import com.sun.jna.Pointer

interface CLib extends Library {
    // Load the C library
    CLib INSTANCE = Native.load("c", CLib.class)

    //---------------------------------
    // File System Management
    //---------------------------------

    /**
     * Mount a filesystem.
     *
     * @param source  - The block device or directory to mount
     * @param target  - The mount point
     * @param filesystemType - The type of the file system (e.g., "ext4", "tmpfs")
     * @param mountFlags - Special mount flags (e.g., read-only, noexec)
     * @param data - Additional data passed to the file system
     * @return 0 on success, -1 on failure (errno set appropriately)
     */
    int mount(String source, String target, String filesystemType, long mountFlags, String data)

    /**
     * Unmount a filesystem.
     *
     * @param target - The mount point to unmount
     * @return 0 on success, -1 on failure (errno set appropriately)
     */
    int umount(String target)

    /**
     * Forcefully unmount a filesystem.
     *
     * @param target - The mount point to unmount
     * @param flags - Additional flags for unmounting (e.g., MNT_FORCE)
     * @return 0 on success, -1 on failure (errno set appropriately)
     */
    int umount2(String target, int flags)

    /**
     * Change the hostname of the system.
     *
     * @param name - The new hostname
     * @param len - The length of the hostname
     * @return 0 on success, -1 on failure (errno set appropriately)
     */
    int sethostname(String name, int len)

    //---------------------------------
    // Process and Signal Management
    //---------------------------------

    /**
     * Send a signal to a process.
     *
     * @param pid - The process ID
     * @param sig - The signal to send
     * @return 0 on success, -1 on failure (errno set appropriately)
     */
    int kill(int pid, int sig)

    /**
     * Wait for a child process to change state.
     *
     * @param pid - The process ID to wait for (or -1 for any child process)
     * @param status - A pointer to an int for the child process’s exit status
     * @param options - Options for waitpid behavior (e.g., WNOHANG, WUNTRACED)
     * @return The process ID of the child that changed state, or -1 on failure
     */
    int waitpid(int pid, Pointer status, int options)

    /**
     * Fork the current process.
     *
     * @return The process ID of the child to the parent, or 0 to the child process,
     *         or -1 if the fork failed.
     */
    int fork()

    /**
     * Execute a program (replacing the current process).
     *
     * @param filename - Path to the executable
     * @param argv - Argument list (null-terminated array of strings)
     *               e.g., ["/bin/ls", "-l", NULL]
     * @param envp - Environment list (null-terminated array of strings)
     *               e.g., ["PATH=/usr/bin", NULL]
     * @return Does not return on success, -1 on failure (errno set appropriately)
     */
    int execve(String filename, String[] argv, String[] envp)

    /**
     * Exit the current process.
     *
     * @param status - Exit status
     */
    void _exit(int status)

    //---------------------------------
    // Time & Timing Functions
    //---------------------------------

    /**
     * Sleep for the specified number of seconds.
     *
     * @param seconds - Number of seconds to sleep
     * @return Remaining seconds left to sleep if interrupted, or 0 on success
     */
    int sleep(int seconds)

    /**
     * Get the current time in seconds since the Epoch.
     *
     * @param tloc - Pointer to a long to store the time. (Optional)
     * @return The current time in seconds since the Epoch
     */
    long time(Pointer tloc)

    //---------------------------------
    // System Information
    //---------------------------------

    /**
     * Get the current hostname.
     *
     * @param name - A buffer to store the hostname
     * @param len - The size of the buffer
     * @return 0 on success, -1 on failure (errno set appropriately)
     */
    int gethostname(byte[] name, int len)

    /**
     * Retrieve the system's uptime.
     * This method reads directly from `/proc/uptime` for Linux.
     *
     * @param uptimeBuffer A buffer to store the uptime information.
     * @param len          The size of the buffer.
     * @return 0 on success, -1 on failure.
     */
//    int get_system_uptime(byte[] uptimeBuffer, int len)

    void sync() // Maps the native sync() method

    int reboot(int magic) // Maps the native reboot() method, accepts an integer as the parameter
}
