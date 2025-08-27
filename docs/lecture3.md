---
title: "CM3: Construction, Test et Débogage de Logiciels Scientifiques"
institute: "Master Calcul Haute Performance et Simulation - GLHPC | UVSQ"
author: "P. de Oliveira Castro, M. Jam"
date: \today
theme: metropolis
colortheme: orchid
fonttheme: structurebold
toc: true
toc-depth: 2
header-includes:
  - \metroset{sectionpage=progressbar}
---

# CM3: Construction, Test et Débogage de Logiciels Scientifiques

## Objectives

- Build systems: Advanced Makefiles, introduction to CMake for managing multi-file and multi-platform projects.
- Debugging: GDB, Valgrind for detecting memory errors and leaks.
- Software testing:
  - Principles: Unit testing, integration testing.
  - Test frameworks in C (e.g., Unity).
  - Importance of testing for regression prevention and validation.
- Code documentation: Doxygen.

# Build Systems

## Dependency Management

- How to determine which files have changed?
- **Source dependencies**: `main.cpp` depends on changes in `foo.h`

## Makefile

- A `Makefile` uses a declarative language to describe targets and their dependencies.

- It is executed by the `make` command, which allows building different **targets**.

  - `make` uses timestamps to determine which files have changed.

  - `make` evaluates rules recursively to satisfy dependencies.

## Makefile Rule

```Makefile
prog: main.c lib.c lib.h
  clang-6.0 -o prog main.c lib.c -lm

target: dependencies
\t  command to build the target from the dependencies
```

## Separate Compilation

```Makefile
prog: main.o lib.o
  clang-6.0 -o prog main.o lib.o -lm

main.o: main.c lib.h
  clang-6.0 -c -o main.o main.c

lib.o: lib.c lib.h
  clang-6.0 -c -o lib.o lib.c
```

If `lib.c` is modified, which commands will be executed?

## Phony Targets

You can add targets that do not correspond to a produced file. For example, it is useful to add a `clean` target to clean the project.

```Makefile
clean:
  rm -f *.o prog
.PHONY: clean
```

`.PHONY` specifies that the `clean` rule should always be executed. Declaring all phony targets ensures they are always called (even if a file with the same name is created).

## Default Rule

```bash
$ make clean
$ make prog
$ make
```

- If `make` is called with a rule, that rule is built.
- If `make` is called without arguments, the first rule is built. It is customary to include a default `all:` rule as the first rule.

```Makefile
all: prog

prog: ...
```

## Variables

```Makefile
CC=clang-6.0
CFLAGS=-O2
LDFLAGS=-lm

prog: main.o lib.o
  $(CC) -o prog main.o lib.o $(LDFLAGS)

main.o: main.c lib.h
  $(CC) $(CFLAGS) -c -o main.o main.c

lib.o: lib.c lib.h
  $(CC) $(CFLAGS) -c -o lib.o lib.c
```

Variables can be overridden when calling `make`, e.g.,
```bash
$ make CC=gcc
```

## Special Variables

----  ------------------------
`$@`  target name
`$^`  all dependencies
`$<`  first dependency
----  ------------------------

```Makefile
prog: main.o lib.o
  $(CC)  -o $@ $^ $(LDFLAGS)

main.o: main.c lib.h
  $(CC) $(CFLAGS) -c -o $@ $<

lib.o: lib.c lib.h
  $(CC) $(CFLAGS) -c -o $@ $< 
```

The last two rules are very similar...

## Implicit Rules

### Before
```Makefile
main.o: main.c lib.h
  $(CC) $(CFLAGS) -c -o $@ $<

lib.o: lib.c lib.h
  $(CC) $(CFLAGS) -c -o $@ $< 
```

### With Implicit Rule
```Makefile
%.o: %.c
  $(CC) $(CFLAGS) -c -o $@ $<

main.o: lib.h
lib.o: lib.h
```

## Other Build Systems

- **automake / autoconf**: automatic generation of complex makefiles and management of system-specific configurations.

- **cmake, scons**: successors to Makefile, offering more elegant syntax and new features.
