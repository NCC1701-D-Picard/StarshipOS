/*
 * Copyright (c) 2025.
 */

package com.starship.maven

//import com.starship.core.Galaxy
//import com.starship.core.Planet
import org.apache.maven.plugin.AbstractMojo
import org.apache.maven.plugin.MojoExecutionException
import org.apache.maven.plugins.annotations.Mojo

@Mojo(name = "launch")
// Goal name
class LaunchMojo extends AbstractMojo {

    @Override
    void execute() throws MojoExecutionException {
        def galaxy = new Galaxy()

        // Example pre-configured planets (this can later become dynamic)
//        galaxy.addPlanet("redis", new Planet("redisPlanet", "/usr/bin/redis-server"))
//        galaxy.addPlanet("webServer", new Planet("webServerPlanet", "/usr/bin/java -jar webserver.jar"))

        // Perform operations
        galaxy.start()
        galaxy.status()

        // Log success via Maven's logger
        getLog().info("Galaxy launched successfully via Groovy!")
    }
}
