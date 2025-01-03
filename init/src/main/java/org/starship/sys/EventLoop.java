package org.starship.sys;

import groovy.lang.Closure;
import org.apache.felix.framework.FrameworkFactory;
import org.osgi.framework.Bundle;
import org.osgi.framework.BundleContext;
import org.osgi.framework.launch.Framework;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class EventLoop {

    private final Framework felixFramework;
    private final BundleContext osgiContext;
    private final Map<String, Closure<?>> eventHandlers = new HashMap<>(); // Groovy closures for custom events
    private final List<Bundle> activeBundles = new ArrayList<>(); // Track installed modules (OSGi bundles)

    public EventLoop() throws Exception {
        // Initialize Apache Felix OSGi runtime
        FrameworkFactory frameworkFactory = new FrameworkFactory();
        Map<String, String> config = new HashMap<>();
        config.put("org.osgi.framework.storage", "./felix-cache"); // OSGi cache location
        config.put("org.osgi.framework.storage.clean", "onFirstInit"); /* Only for first-time setup */

        this.felixFramework = frameworkFactory.newFramework(config);
        this.felixFramework.init();
        this.osgiContext = felixFramework.getBundleContext();
        System.out.println("Apache Felix OSGi runtime initialized.");
    }

    public void startOSGi() throws Exception {
        felixFramework.start();
        System.out.println("Apache Felix OSGi runtime started.");
    }

    public void stopOSGi() throws Exception {
        felixFramework.stop();
        System.out.println("Apache Felix OSGi runtime stopped.");
    }

    // Load and start an OSGi bundle dynamically
    public Bundle loadBundle(String bundlePath) throws Exception {
        System.out.println("Loading bundle: " + bundlePath);
        Bundle bundle = osgiContext.installBundle(bundlePath);
        bundle.start();
        activeBundles.add(bundle); // Track loaded bundles
        System.out.println("Bundle loaded and started: " + bundle.getSymbolicName());
        return bundle;
    }

    // Emit a custom event (DSL or runtime-driven)
    public void emit(String eventName, Object data) {
        if (eventHandlers.containsKey(eventName)) {
            eventHandlers.get(eventName).call(data);
        } else {
            System.out.println("No handler registered for event: " + eventName);
        }
    }

    // Register custom event handler
    public void registerEvent(String eventName, Closure<?> handler) {
        eventHandlers.put(eventName, handler);
    }

    // Main event loop (listen for signals, events, etc.)
    public void run() throws InterruptedException {
        System.out.println("Starting event loop...");
        while (true) {
            // Realistically, here you'd handle IPC, signals, or some system-level events
            Thread.sleep(500);
        }
    }
}
