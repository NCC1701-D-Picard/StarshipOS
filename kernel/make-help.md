# StarshipOS kernel Makefile Help

## **Cleaning Targets**
- **`clean`**  
  Remove most generated files but keep the configuration and enough build support to build external modules.

- **`mrproper`**  
  Remove all generated files, configuration, and various backup files.

- **`distclean`**  
  Perform `mrproper` and also remove editor backup and patch files.

---

## **Configuration Targets**

### Updating Configuration:
- **`config`**  
  Update the current configuration using a line-oriented program.

- **`nconfig`**  
  Update the current configuration using an `ncurses`-based menu program.

- **`menuconfig`**  
  Update the current configuration using a menu-based program.

- **`xconfig`**  
  Update the current configuration using a `Qt`-based front end.

- **`gconfig`**  
  Update the current configuration using a `GTK+`-based front end.

- **`oldconfig`**  
  Update the current configuration using a provided `.config` file as the base.

- **`localmodconfig`**  
  Update the current configuration, disabling unused modules unless preserved by the `LMC_KEEP` environment variable.

- **`localyesconfig`**  
  Update the current configuration, converting local modules to core, unless preserved by the `LMC_KEEP` environment variable.

- **`defconfig`**  
  Create a new configuration with default options from the architecture's supplied `defconfig`.

- **`savedefconfig`**  
  Save the current configuration as `./defconfig` (minimal config).

- **`allnoconfig`**  
  Create a new configuration where all options are set to `no`.

- **`allyesconfig`**  
  Create a new configuration where all options are set to `yes`.

- **`allmodconfig`**  
  Create a new configuration that selects modules when possible.

- **`alldefconfig`**  
  Create a new configuration with all symbols set to their default values.

- **`randconfig`**  
  Create a new configuration with random answers to all options.

- **`yes2modconfig`**  
  Change answers from `yes` to `module` where possible.

- **`mod2yesconfig`**  
  Change answers from `module` to `yes` where possible.

- **`mod2noconfig`**  
  Change answers from `module` to `no` where possible.

- **`listnewconfig`**  
  List new configuration options.

- **`helpnewconfig`**  
  List new configuration options with their help text.

- **`olddefconfig`**  
  Like `oldconfig` but sets new symbols to their default value without prompting.

- **`tinyconfig`**  
  Configure the smallest possible kernel.

- **`testconfig`**  
  Run Kconfig unit tests (requires `python3` and `pytest`).

---

## **Configuration Topic Targets**

- **`xen.config`**  
  Create a configuration bootable as a Xen guest.

- **`rust.config`**  
  Enable configurations for Rust.

- **`hardening.config`**  
  Enable basic kernel hardening options.

- **`nopm.config`**  
  Disable power management.

- **`debug.config`**  
  Debugging configuration for CI systems and finding regressions.

- **`kvm_guest.config`**  
  Create a configuration bootable as a KVM guest.

- **`x86_debug.config`**  
  Enable debugging options for tip tree testing.

---

## **Other Generic Targets**

- **`all`**  
  Build all targets marked with `[*]`.

- **`vmlinux`**  
  Build the bare kernel.

- **`modules`**  
  Build all modules.

- **`modules_install`**  
  Install all modules to the `INSTALL_MOD_PATH` (default: `/`).

- **`vdso_install`**  
  Install unstripped `vDSO` to `INSTALL_MOD_PATH` (default: `/`).

- **`dir/`**  
  Build all files in a directory and its subdirectories.

- **`dir/file.[ois]`**  
  Build the specified target file only.

- **`dir/file.ll`**  
  Build the `LLVM` assembly file (requires compiler support for `LLVM` assembly generation).

- **`dir/file.lst`**  
  Build a mixed source/assembly target file (requires a recent `binutils` and the system build file `System.map`).

- **`dir/file.ko`**  
  Build a module including the final link.

- **`modules_prepare`**  
  Prepare for building external modules.

- **`tags/TAGS`**  
  Generate a tags file for code editors.

- **`cscope`**  
  Generate a `cscope` index.

- **`gtags`**  
  Generate a `GNU GLOBAL` code index.

- **`kernelrelease`**  
  Output the release version string (use with `make -s`).

- **`kernelversion`**  
  Output the version stored in the Makefile (use with `make -s`).

- **`image_name`**  
  Output the image name (use with `make -s`).

- **`headers_install`**  
  Install sanitized kernel headers to `INSTALL_HDR_PATH` (default: `./usr`).

---

## **Static Analyzers**

- **`checkstack`**  
  Generate a list of stack hogs by analyzing functions with stack sizes larger than `MINSTACKSIZE` (default: `100`).

- **`versioncheck`**  
  Perform a sanity check on `version.h` usage.

- **`includecheck`**  
  Check for duplicate included header files.

- **`export_report`**  
  List exported symbols (note: the description in the input was truncated).

---
