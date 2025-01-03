# OpenJDK Configure Help

The `configure` script configures OpenJDK to adapt to various kinds of systems.

---

## **Usage**

```bash
/home/rajames/PROJECTS/StarshipOS/java/jdk/configure [OPTION]... [VAR=VALUE]...
```

To assign environment variables (e.g., `CC`, `CFLAGS`...), specify them as `VAR=VALUE`. See below for descriptions of some useful variables.

- **Defaults for the options are specified in brackets.**

---

## **Configuration Options**

### General Options:
- **`-h, --help`**  
  Display this help message and exit.

- **`--help=short`**  
  Display options specific to this package.

- **`--help=recursive`**  
  Display the short help of all the included packages.

- **`-V, --version`**  
  Display version information and exit.

- **`-q, --quiet`, `--silent`**  
  Do not print `checking ...` messages.

- **`--cache-file=FILE`**  
  Cache test results in `FILE` [disabled].

- **`-C, --config-cache`**  
  Alias for `--cache-file=config.cache`.

- **`-n, --no-create`**  
  Do not create output files.

- **`--srcdir=DIR`**  
  Find the sources in `DIR` [configure directory or `..`].

---

## **Installation Directories**

If unspecified, default installation directories are as follows:
- Architecture-independent files: `/usr/local`.
- Architecture-dependent files: `/usr/local/bin`, `/usr/local/lib`, etc.

### Override Installation Directories:
- **`--prefix=PREFIX`**  
  Install architecture-independent files in `PREFIX`.  
  Example: `--prefix=$HOME`.

- **`--exec-prefix=EPREFIX`**  
  Install architecture-dependent files in `EPREFIX` [defaults to `PREFIX`].

---

### Fine-Tuning Directories:
- **`--bindir=DIR`**:  
  User executables [`EPREFIX/bin`].

- **`--sbindir=DIR`**:  
  System administration executables [`EPREFIX/sbin`].

- **`--libexecdir=DIR`**:  
  Program executables [`EPREFIX/libexec`].

- **`--sysconfdir=DIR`**:  
  Read-only single-machine data [`PREFIX/etc`].

- **`--sharedstatedir=DIR`**:  
  Modifiable architecture-independent data [`PREFIX/com`].

- **`--localstatedir=DIR`**:  
  Modifiable single-machine data [`PREFIX/var`].

- **`--runstatedir=DIR`**:  
  Modifiable per-process data [`LOCALSTATEDIR/run`].

- **`--libdir=DIR`**:  
  Object code libraries [`EPREFIX/lib`].

- **`--includedir=DIR`**:  
  C header files [`PREFIX/include`].

- **`--oldincludedir=DIR`**:  
  C header files for non-GCC [`/usr/include`].

- **`--datarootdir=DIR`**, **`--datadir=DIR`**:  
  Read-only architecture-independent data root [`PREFIX/share`].

- **`--infodir=DIR`**:  
  Info documentation [`DATAROOTDIR/info`].

- **`--localedir=DIR`**:  
  Locale-dependent data [`DATAROOTDIR/locale`].

- **`--mandir=DIR`**:  
  Man documentation [`DATAROOTDIR/man`].

- **`--docdir=DIR`**:  
  Documentation root [`DATAROOTDIR/doc/openjdk`].

- **`--htmldir=DIR`**, **`--dvidir=DIR`**, **`--pdfdir=DIR`**, **`--psdir=DIR`**:  
  HTML, DVI, PDF, and PS documentation directories [`DOCDIR`].

---

## **X Features**
- **`--x-includes=DIR`**:  
  Path to X include files.

- **`--x-libraries=DIR`**:  
  Path to X library files.

---

## **System Types**
- **`--build=BUILD`**:  
  Configure for building on the `BUILD` system (guessed if unspecified).

- **`--host=HOST`**:  
  Cross-compile to build programs to run on the `HOST` system (default: `BUILD`).

- **`--target=TARGET`**:  
  Configure for building compilers for the `TARGET` system (default: `HOST`).

---

## **Optional Features**

- **`--disable-option-checking`**  
  Ignore unrecognized `--enable`/`--with` options.

- **`--disable-FEATURE`**  
  Do not include the given `FEATURE` (same as `--enable-FEATURE=no`).

- **`--enable-FEATURE[=ARG]`**  
  Include the given `FEATURE` (`ARG=yes` by default).

- **`--enable-deprecated-ports[=yes/no]`**  
  Suppress the error when configuring for a deprecated port (`[no]` by default).

- **`--enable-openjdk-only`**  
  Suppress building custom source, even if present ([disabled] by default).

- **`--enable-debug`**  
  Enable debugging (shorthand for `--with-debug-level=fastdebug`) ([disabled] by default).

- **`--disable-absolute-paths-in-output`**  
  Prevent absolute paths from appearing in build output.  
  ([disabled in release builds; otherwise enabled]).

- **`--enable-linkable-runtime`**  
  Enable runtimes that can be linked (purpose not described in input).

---
