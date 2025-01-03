package org.starship.config

import groovy.util.logging.Slf4j

// SystemConfig.groovy: Handles the "system" block in the DSL

@Slf4j
class SystemConfig {
    String hostname                        // Stores the hostname
    List mounts = []                       // Stores mount points
    List tasks = []                        // Stores spawned tasks

    // Set the system hostname
    void hostname(String name) {
        hostname = name
    }

    // Define a mount point
    void mount(String type, Map options) {
        mounts << [type: type, on: options.on]
    }

    // Spawn a task
    void spawn(String command, Map args) {
        tasks << [command: command, name: args.name]
    }

    // Apply all the system configurations
    void apply() {
        if (hostname) {
            log.info "Setting hostname to: ${hostname} (stubbed)"
            // Stub: Simulate hostname change
        }

        mounts.each { mount ->
            log.info "Mounting ${mount.type} on ${mount.on} (stubbed)"
            // Stub: Simulate mounting filesystems
        }

        tasks.each { task ->
            log.info "Spawning task '${task.name}': ${task.command} (stubbed)"
            // Stub: Simulate starting processes
        }
    }
}
