package org.starship.init


import spock.lang.*

class InitSpec extends Specification {

    def "Evaluate valid configuration file"() {
        given:
        def configFile = new File("test-config.groovy")
        configFile.text = '''
            system {
                hostname "test-os"
                log {
                    level "INFO"
                    location "/tmp/test.log"
                }
            }
        '''

        when:
        Init.evaluate(configFile)

        then:
        // Verify that the hostname was set
        1 * Init.setHostname("test-os")
    }

    def "Shutdown cleans up resources properly"() {
        given:
        Init.mountedResources = ["/mnt/test"]
        Init.childProcesses = [Mock(Process) { destroyForcibly() }]
        Init.supervisedServices = ["test-service": new ServiceConfig(name: "test-service")]

        when:
        Init.shutdown()

        then:
        Init.mountedResources.isEmpty()
        Init.childProcesses.isEmpty()
        Init.supervisedServices.isEmpty()
    }
}
