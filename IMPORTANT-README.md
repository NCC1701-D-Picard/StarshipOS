This project is structured as a multi-module maven project.

You will need Java19 minimum to build the project. I'm using OpenJDK 23.

There's an odd bit of odd and perhaps some very smelly constructs. The reason for
this is there is a bit of C (the Linux kernel/Java OpenJDK/BusyBox) and C++ to build with their build systems.
Given this fact of life the builds are really scripted in bash and maven simply calls
the shell script. I decided I needed a place to gather together all the artefacts
together in order to simplify the overall build process and abstract the assembly process.

This gives us somewhat of an opportunity to add another level of control of the build
process that's not normally available with maven multi-module builds. I have a very
specific script construct. if a `build` directory exists nothing is done and that
module will not be built/rebuilt. Here's the opportunity part I promised. Now `YOU` 
have the ability to control which modules you build or not build. Why?

The kernel takes a few minutes to build. The JDK takes a very long time to build &
BusyBox takes a minute or two. By not rebuilding the JDK because you haven't 
changed anything you'll speed things along significantly. There are four modules
that should be rebuilt with every build as no matter which module you worked on 
you don't have to suffer through a JDK build. To that end when you do a `mvn clean`
these four modules will always delete the `build` directories:

1. grub
2. initramfs
3. live_cd
4. qcow2_image

In the scripts in the root directory can be augmented with your scripts. Feel free
to `git ignore` them. Just keep in mind that initramfs depends on Linux kernel,
BusyBox and Java. qcow2_image and live_cd depend on the same PLUS initramfs.

I hope this gives you a little insight into the build system and provide a coherent
way to merge Java and an operating system kernel. I can see that as things get built
and the project grows The source code of the JDK and the kernel source will be
tinkered with, hopefully in harmony ;) Final thought, my different way of thinking
about how an OS could work in a different way, [different way](DIFFERENT_WAY.md).
