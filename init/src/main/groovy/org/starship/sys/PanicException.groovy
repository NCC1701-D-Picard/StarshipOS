//file:noinspection unused
package org.starship.sys


import com.sun.jna.Native
import org.starship.jna.CLib

class PanicException extends RuntimeException {


    // Static flag to prevent triggering multiple panics during the same run
    private static boolean panicTriggered = false

    // Constructor: message-only
    PanicException(String message) {
        super(message)
        triggerPanic(message)
    }

    // Constructor: message + cause (with stack trace wrapping)
    PanicException(String message, Throwable cause) {
        super(message, cause)
        triggerPanic(message)
    }

    // Trigger system panic: sync filesystems and reboot
    private synchronized void triggerPanic(String message) {
        //noinspection GroovyAccessToStaticFieldLockedOnInstance
        if (panicTriggered) {
            println "Panic already triggered. Skipping."
            return
        }
        //noinspection GroovyAccessToStaticFieldLockedOnInstance
        panicTriggered = true // Mark panic as triggered

        println "KERNEL PANIC: ${message}"

        try {
            // Load libc dynamically and execute panic-related calls
            //noinspection GroovyAssignabilityCheck
            CLib libc = Native.load("c", CLib)
            libc.sync()                    // Sync filesystems
            libc.reboot(0xfee1dead as int)        // Trigger Linux kernel panic using the magic number

        } catch (Exception e) {
            println "Failed to execute kernel panic: ${e.message}"
            e.printStackTrace()
        }
    }
}

