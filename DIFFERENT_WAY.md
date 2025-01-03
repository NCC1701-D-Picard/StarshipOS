# StarshipOS - A Different Way of Thinking

Our vision is to create a **state-of-the-art operating system** where every component—files, memory management, and more—adheres to object-oriented principles. StarshipOS will support running Java applications directly and provide an interactive `jshell` environment as early as possible during the boot process.

One of our key goals is to develop an *object-oriented filesystem* that leverages virtual memory for enhanced performance and persistence. Welcome to a new way of interacting with your system, built for limitless creativity and efficiency.

---

## No Files.
What, no files? Are you insane? Yes, **no files**. No, I’m not insane.

In StarshipOS, traditional files become irrelevant. Imagine having **LOTS** of memory—so much memory that the size of your heap of objects is practically unlimited. Since everything is an object, you gain **built-in security**. For example:

- If your base `Object` class has access control lists (ACLs), every instantiated object will inherit this ACL trait **transitively**.
- Additional attributes, such as persistence or access flags, can also propagate to every object seamlessly.

And because we have ***LOTS*** of "memory," we eliminate the concept of files entirely. Instead, the size of your **attached mass storage device**, including possible integration with cloud storage, becomes your limit. Objects persist as needed without a filesystem, and storage is managed as part of a unified memory pool.

This brings us to our next innovation...

---

## HDD/SSD Used as Virtual Memory

### Memory Layout in StarshipOS
```plaintext
+------------------------------------------+
|                High Memory               |
| $FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF  |
|   Virtual memory as persistent storage   |     
+------------------------------------------+
|              Storage metadata            |
+------------------------------------------+
|                                          |
|                                          |
|             Java Heap & Stack            |
|                                          |
|                                          |
+------------------------------------------+
|                  Low Memory              |
| $0000 0000 0000 0000 0000 0000 0000 0000 |
|             Working physical RAM         | 
+------------------------------------------+
```

Here’s how it works:  
We create the smallest possible partition, formatted as an `ext4` boot partition, to launch into *Java World* as quickly as possible.

In this Java-driven environment:
- A dedicated partition is treated as **virtual memory** (a block device).
- The entire space on this block device is utilized as memory for the JVM.

The **Garbage Collector (GC)** in StarshipOS will do more than just scavenge unused objects:
1. Objects marked with a `sticky` flag are relocated to **high memory** for persistence.
2. Objects with a `dirty` flag are rewritten when changes occur, ensuring active and consistent state management.

Persistent objects "live" in high memory and are actively managed. These objects will grow or shrink dynamically. At the boundary between high memory and working RAM, a metadata area tracks all persistent objects dynamically. There is always a **fence** between working RAM and the SSD/HDD-extended virtual memory, securing data integrity.

### Choosing a Garbage Collector
The initial candidate for our GC is **ZGC** (Z Garbage Collector) because it offers excellent scalability and efficiency. However, we are open to discussion and may even develop a custom garbage collector tailored for StarshipOS.

### Machine Learning-Driven Optimization
Imagine integrating **machine learning** into the memory management and garbage collection systems. Over time, the system would *learn* to optimize itself.

---

## So, Now I Have a Sea of Objects. What Next?

Use ***your imagination.***

One possibility is a *runner* object—a universal wrapper that can encapsulate legacy Java or Linux (ELF) binaries to function seamlessly in StarshipOS. Such a mechanism would let you import existing applications into your **object world** with ease.

Your objects can be arranged and modeled as you like. Think of it as a **limitless virtual playground**.

---

## Initial Tools and Ecosystem

Your world will come pre-stocked with an initial set of objects offering basic tools. A Maven-like repository system will host additional objects, making it easy to expand functionality. Available objects might include:
- `Wine`
- `LibreOffice`
- `JetBrains IntelliJ IDEA`

Porting existing Linux applications to StarshipOS becomes frictionless—and entirely object-oriented. Arrange and organize objects in a way that best suits your workflow: adapt to **your world**, your way.

---

## A Vision for the Future

### Workflow and User Experience
1. **Command Line**: A highly customized `jshell` environment for interactive scripting and management.
2. **GUI**: A modern **JavaFX-based graphical user interface.**
3. **VR UI**: Picture a VR interface as the gateway to your object-oriented, virtual world.

### Example Vision of My World
In my world, I imagine interacting with concepts like **$\lambda$-CMB** (lambda-Cold Dark Matter) and the Standard Model, starting with quarks, leptons, and hadrons. Armed with a supercomputer and unlimited storage, I would create a **virtual workshop** where I can “build” my ideas.

In this workshop:
- I obtain tools and components from a repository.
- I assemble ideas in a seamless VR environment, transitioning between micro and macro views.

Your world might look completely different—perhaps a chaotic creative space or a meticulously organized engineer’s workspace. **It’s your canvas.**

---

# Closing Thoughts

StarshipOS is more than an operating system—it’s a new way of interacting with your computer. Whether you imagine a world of limitless objects or a structured and efficient digital system, StarshipOS enables you to craft **your** environment in ways traditional OS concepts can’t.

This is **your world,** shaped uniquely to your needs and imagination.
