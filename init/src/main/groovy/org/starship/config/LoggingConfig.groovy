//file:noinspection GroovyAssignabilityCheck
//file:noinspection unused
package org.starship.config

import ch.qos.logback.classic.Level
import ch.qos.logback.classic.LoggerContext
import ch.qos.logback.classic.encoder.PatternLayoutEncoder
import ch.qos.logback.core.ConsoleAppender
import ch.qos.logback.core.FileAppender
import ch.qos.logback.core.util.StatusPrinter
import groovy.util.logging.Slf4j
import org.slf4j.Logger
import org.slf4j.LoggerFactory

@Slf4j
class LoggingConfig {
    private static final Logger logger = LoggerFactory.getLogger(LoggingConfig)

    // Initialize early logging using a default Logback configuration
    static void initializeDefaultLogger() {
        try {
            LoggerContext context = (LoggerContext) LoggerFactory.getILoggerFactory()
            context.reset() // Reset existing configuration to start fresh

            // Console appender: Prints logs to stdout by default
            ConsoleAppender consoleAppender = new ConsoleAppender()
            consoleAppender.setContext(context)
            consoleAppender.setName("console")

            // Set log pattern (default format for logs)
            PatternLayoutEncoder encoder = new PatternLayoutEncoder()
            encoder.setContext(context)
            encoder.setPattern("%d{yyyy-MM-dd HH:mm:ss} %-5level [%thread] %logger{36} - %msg%n")
            encoder.start()
            consoleAppender.setEncoder(encoder)
            consoleAppender.start()

            // Attach the appender to the root logger
            ch.qos.logback.classic.Logger rootLogger = context.getLogger("ROOT")
            rootLogger.addAppender(consoleAppender)
            rootLogger.setLevel(Level.INFO) // Default logging level: INFO

            StatusPrinter.print(context) // Print logback's internal status for debugging
        } catch (Exception e) {
            System.err.println("Failed to initialize default logger: " + e.message)
        }
    }

    // Dynamically reconfigure logging from system configuration
    static void configure(Map args) {
        try {
            LoggerContext context = (LoggerContext) LoggerFactory.getILoggerFactory()
            ch.qos.logback.classic.Logger rootLogger = context.getLogger("ROOT")

            if (args.level) {
                rootLogger.setLevel(Level.toLevel(args.level.toUpperCase(), Level.INFO))
                logger.info("Log level set to: ${args.level}")
            }

            if (args.location) {
                // File appender: Saves logs to a file
                FileAppender fileAppender = new FileAppender()
                fileAppender.setName("file")
                fileAppender.setContext(context)
                fileAppender.setFile(args.location)

                // Reuse the pattern layout encoder
                PatternLayoutEncoder encoder = new PatternLayoutEncoder()
                encoder.setContext(context)
                encoder.setPattern("%d{yyyy-MM-dd HH:mm:ss} %-5level [%thread] %logger{36} - %msg%n")
                encoder.start()
                fileAppender.setEncoder(encoder)
                fileAppender.start()

                // Remove all existing appenders and attach only the file appender
                rootLogger.detachAndStopAllAppenders()
                rootLogger.addAppender(fileAppender)
                logger.info("Logging to file: ${args.location}")
            }
        } catch (Exception e) {
            logger.error("Failed to configure logging: ${e.message}", e)
        }
    }
}
