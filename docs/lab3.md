# Lab 3: CMake, Unit Tests, and Debugging
<hr class="gradient" />

### Objectives

- Learn how to use CMake for building C projects.
- Write and run unit tests using the Unity testing framework.
- Use `valgrind` to detect memory-related issues and pinpoint invalid memory accesses.
- Learn how to use `gdb` to debug logical errors in C programs.
- Practice setting breakpoints, inspecting variables, and stepping through code in `gdb`.

### Provided Files

This lab is a continuation of [lab 2](../lab2). The structure of the project is the same.
A new transformation `rotate_image_90_clockwise`, which you will analyze in the [third part of this lab](#3-debugging-with-gdb-and-valgrind), has been added to the `transformations.h` and `transformations.c` files.

## 1 - CMake

In this first part, you will learn how to write a `CMakeLists.txt` file for a C project, starting from a provided `Makefile`. The goal is to progressively build a robust and maintainable CMake configuration for an HPC project.

### 1. Minimal Build

Create a minimal `CMakeLists.txt` that builds the shared library `libparser.so` and the executable `mytransform`.

#### a) Set the minimum required CMake version and project name

```cmake title="CMakeLists.txt"
cmake_minimum_required(VERSION 3.15)
project(parser LANGUAGES C)
```

#### b) Add include directories

```cmake title="CMakeLists.txt"
include_directories(src include)
```

The `include_directories` command specifies the directories to search for header files during compilation. Here, `include` contains the public header of the parser library, and `src` contains the private headers used internally by the library and the executable.

#### c) Add the shared library target

```cmake title="CMakeLists.txt"
add_library(parser SHARED src/parser.c)
```

In Linux a shared library has the extension `.so` (shared object). The `add_library` command creates a target named `parser` that builds a shared library from the source file `src/parser.c`. The final library will be named `libparser.so` by default.

#### d) Add the executable target

```cmake title="CMakeLists.txt"
add_executable(mytransform src/main.c src/transformation.c src/image.c)
```

The `add_executable` command builds an executable `mytransform` from the specified source files. Header files were included before.

#### e) Link the shared library to the executable

```cmake
target_link_libraries(mytransform PRIVATE parser m)
```

This command ensures that the `mytransform` executable is linked against the `parser` shared library and the math library `m`. 

!!! Note
    The `PRIVATE` keyword indicates that the dependency is only required for building the `mytransform` target and does not propagate to other targets that may link against `mytransform`.

#### f) Generate the build system

```sh
$ cmake -B build .
```

Here `-B` specifies the build directory (a new directory named `build`).

#### g) Build the project

```sh
$ make -C build/
```

!!! Note
    By default, CMake generates a Makefile as the build system on Unix-like systems. Sometimes, it can be useful to call directly the `make` command to build the project.
    You can also use `cmake --build build` to build the project, which is more portable across different platforms and build systems.

#### h) Answer the following questions

- Where are the generated files located?
- Can you find the `libparser.so` library? the `mytransform` executable?
- Can you run the program? 

### 2. Build Configurations

We want to enable different build configurations (e.g., Debug, Release) and set appropriate compiler options.

#### a) Configure the C standard used

```cmake title="CMakeLists.txt"
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
```

This ensures that the C11 standard is used for compiling the project.

#### b) Enable different build types

Define common compiler flags for different build types:

```cmake title="CMakeLists.txt"
set(COMMON_COMPILE_FLAGS
    $<$<CONFIG:Debug>:-Wall -Wextra -g>
    $<$<CONFIG:Release>:-Wall -Wextra -O3 -DNDEBUG>
)
```

Apply the flags to the targets:

```cmake title="CMakeLists.txt"
target_compile_options(parser PRIVATE ${COMMON_COMPILE_FLAGS})
target_compile_options(mytransform PRIVATE ${COMMON_COMPILE_FLAGS})
```

Rebuild the project and test different configurations:

```sh
$ cmake -B build -DCMAKE_BUILD_TYPE=Debug .
```

You can check that the debug symbols are included in the binary using `file`:

```sh
$ file build/mytransform 
build/mytransform: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=0d2cbaa0cf08a42b916e2edffe9940ce828b2bd9, for GNU/Linux 3.2.0, with debug_info, not stripped
```

### 3. Enable Installation

Now we will add installation rules to install the shared library, executable, and headers.

#### a) Give your project a version number

Modify the `project` command as below:

```cmake title="CMakeLists.txt"
project(parser VERSION 1.0.0 LANGUAGES C)
```

#### b) Include the `GNUInstallDirs` module

```cmake title="CMakeLists.txt"
include(GNUInstallDirs)
```

This module provides standard installation directory variables like `CMAKE_INSTALL_BINDIR`, `CMAKE_INSTALL_LIBDIR`, and `CMAKE_INSTALL_INCLUDEDIR`.

#### c) Add installation rules for the shared library

```cmake title="CMakeLists.txt"
install(TARGETS parser
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)
```

#### d) Add installation rules for the executable

```cmake title="CMakeLists.txt"
install(TARGETS mytransform
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
```

#### e) Test the installation

```sh
mkdir install_dir
$ cmake -B build -DCMAKE_INSTALL_PREFIX=install_dir . 
$ make -C build/ install
```

Since `install_dir` is not a standard system directory, you need to set the `LD_LIBRARY_PATH` environment variable to include the path to the installed shared library before running the program.


!!! Note
    We can also call `cmake --install build --prefix <install_directory>` to install the project.

#### f) Install the public header file

As you can see, the public header file `parser.h` is not installed.
To inform CMake about the public headers, you should add the following command:

```cmake title="CMakeLists.txt"
set_target_properties(parser PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
    PUBLIC_HEADER include/parser.h
)
```

Rebuild and install the project again, you should see the `parser.h` file in the `include` directory of the installation prefix. Additionally, the shared library should now have a versioned name like `libparser.so.1.0.0`.

### 3. Better handling of include directories

Our current way of handling include directories is not ideal. We will improve it by using `target_include_directories` which keeps the include directories scoped to each target.

#### a) Remove the global `include_directories` command

#### b) Add the following commands to specify include directories for each target

```cmake title="CMakeLists.txt"
target_include_directories(parser 
    PUBLIC 
        $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
    PRIVATE
        ${PROJECT_SOURCE_DIR}/src
    )

target_include_directories(mytransform PRIVATE ${PROJECT_SOURCE_DIR}/src)
```

The library target disinguishes between `PUBLIC` and `PRIVATE` include directories. `PUBLIC` directories are needed both when building the library and when using it, while `PRIVATE` directories are only needed when building the library itself.

The `BUILD_INTERFACE` generator expression specifies the include directory to use when building the project, while the `INSTALL_INTERFACE` generator expression specifies the include directory to use when the library is installed. This ensures that users of the installed library can include the header files correctly.

## 2 - Unit Tests

In this part, you will learn how to integrate unit tests into your CMake project using the [Unity testing framework](https://www.throwtheswitch.org/unity).

### 1. Fetch the Unity framework

Fetch the Unity framework:

```cmake title="CMakeLists.txt"
# Fetch and build the Unity testing framework
include(FetchContent)
FetchContent_Declare(
    unity
    GIT_REPOSITORY  https://github.com/ThrowTheSwitch/Unity.git
    GIT_TAG         v2.6.1
    GIT_SHALLOW TRUE # Only download the specific tag, not full history
)

# Make Unity available but don't add to ALL target by default
# This is important to avoid installing unity dependencies which are only needed for testing 
# but are not required in the release version of the project
FetchContent_GetProperties(unity)
if(NOT unity_POPULATED)
    FetchContent_Populate(unity)
    add_subdirectory(${unity_SOURCE_DIR} ${unity_BINARY_DIR} EXCLUDE_FROM_ALL)
endif()
```

Set up the Unity include directory and library:

```cmake title="CMakeLists.txt"
set(UNITY_INCLUDE_DIR "${unity_SOURCE_DIR}/src")
set(UNITY_LIBRARY "${unity_BINARY_DIR}/libunity.a")
```

CMake fetches and builds the Unity framework, making it available for use in your project.

### 2. Write a first unit test

We currently have a set of hard-coded tests in `main.c`:

- `check_grayscale`
- `check_rgb` 
- `check_copy`

Read carefully these tests to understand what they do.

To convert them into unit tests, we will create a new source file `tests/test_image.c` and move the test functions there. The `check_memory` function which ran all the files will be replaced by a test runner in `tests/test_runner.c`.

We will start first by writing the test runner.
Create a new file `tests/test_runner.c` with the following content:

```c title="tests/test_runner.c"
#include "unity.h"

extern void test_grayscale_image_creation(void);

void setUp(void) {}
void tearDown(void) {}

int main(void)
{
    UNITY_BEGIN();
    RUN_TEST(test_grayscale_image_creation);
    return UNITY_END();
}
```

!!! Note
    The `setUp` and `tearDown` functions are called before and after each test, respectively. They can be used to set up and clean up test fixtures if needed.

Now create the `tests/test_image.c` file and move the `check_grayscale` function there, renaming it to `test_grayscale_image_creation`:

```c title="tests/test_image.c"
#include "unity.h"
#include "transformation.h"
#include <stdlib.h>
#include <stdio.h>
#include <time.h>

void test_grayscale_image_creation(void)
{
    Image *img = create_image(100, 100, 1);
    TEST_ASSERT_NOT_NULL(img);
    TEST_ASSERT_EQUAL(100, img->width);
    TEST_ASSERT_EQUAL(100, img->height);
    TEST_ASSERT_EQUAL(1, img->channels);
    TEST_ASSERT_NOT_NULL(img->pixels[0]);
    TEST_ASSERT_NULL(img->pixels[1]);
    TEST_ASSERT_NULL(img->pixels[2]);
    free_image(img);
}
```

As you can see, we are using systematically the Unity assertion macros to check conditions.

### 3. Add the test runner executable

To run our tests, we need to create a new executable target for the test runner in our `CMakeLists.txt` file.

```cmake title="CMakeLists.txt"
add_executable(test_runner tests/test_runner.c tests/test_image.c src/transformation.c src/image.c)
target_include_directories(test_runner 
    PRIVATE 
        ${UNITY_INCLUDE_DIR} 
        ${PROJECT_SOURCE_DIR}/src
)
target_link_libraries(test_runner ${UNITY_LIBRARY} m parser)
```

Observe that we link the `test_runner` target against the Unity library, the math library `m`, and our `parser` library.

### 4. Add a custom target to run the tests

To facilitate running the tests, we can add a custom target in our `CMakeLists.txt` file that will execute the `test_runner` executable.

```cmake title="CMakeLists.txt"
add_custom_target(test test_runner 
    DEPENDS $<TARGET_FILE:test_runner>
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Running unit tests..."
)
```

Check that everything works by building the project and running the tests:

```sh
$ cmake --build build
$ make -C build test
```

### 5. Add the remaining tests

*Write unit tests for the `check_rgb` and `check_copy` functions in the `tests/test_image.c` file.* 

!!! Tip 
    For bonus point, separate the logic of the `check_copy` test into two different tests: `test_image_copy`, that check the code validity, and `test_image_copy_performance` that measures and displays the performance.


## 3 - Debugging with GDB and Valgrind

In this last part, you will learn how to debug two types of bugs in a C program using `gdb` and `valgrind`. These bugs are intentionally introduced in the `rotate_image_90_clockwise` function. The goal is to identify, understand, and fix these bugs while reflecting on the debugging process.

### 1. Build the Program with Debug Symbols

Debugging symbols are metadata embedded in a program's binary during compilation, providing detailed information about the source code, such as variable names, function names, and line numbers. These symbols allow tools like gdb and valgrind to map the program's execution back to the original source code, making it easier to inspect variables, set breakpoints, and trace errors. Without debugging symbols, these tools would only display raw memory addresses and machine-level details, making debugging significantly harder.

!!! Note
    To enable debugging symbols, you need to configure CMake to include the `-g` flag in the compilation process. This can be achieved by setting the `CMAKE_BUILD_TYPE` to `Debug`.

#### a) Run the `cmake` command with the `Debug` build type

```sh
$ cmake -B build/ -DCMAKE_BUILD_TYPE=Debug .
```

#### b) Build the project

```sh
$ make -C build/
```

#### c) Run the program using the rotate transformation

```sh
$ build/mytransform pipelines/rotate.pipeline
Loaded image: images/image0.bmp (259x194, 3 channels)
Segmentation fault (core dumped)
```

You should get an error as above.

#### d) Analyze carefully the error message

- What does `Segmentation fault` mean?
- What does `(core dumped)` mean?
- What could be the possible causes of this error?

### 2. Running the program with GDB

GDB is the GNU Project Debugger, a powerful tool for debugging programs. It allows you to run your program step by step, inspect variables, set breakpoints, and analyze the program's flow to identify and fix bugs.

#### a) Start gdb with the program and its arguments

```sh
$ gdb --args build/mytransform pipelines/rotate.pipeline

GNU gdb (Ubuntu 15.0.50.20240403-0ubuntu1) 15.0.50.20240403-git
... [output truncated] ...
(gdb)
```

!!! Note
    The `--args` option allows you to pass the program's arguments directly to gdb, so you don't have to type them again after starting gdb.
    `(gdb)` is the gdb prompt, where you can enter gdb commands.

#### b) Run the program inside gdb

```sh
(gdb) run
Starting program: lab3/build/mytransform pipelines/rotate.pipeline
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/x86_64-linux-gnu/libthread_db.so.1".
Loaded image: images/image0.bmp (259x194, 3 channels)

Program received signal SIGSEGV, Segmentation fault.
rotate_image_90_clockwise (node=0x5555555802f0)
    at lab3/src/transformation.c:105
105 node->output->pixels[c][x * width + (height - y - 1)] = node->input->pixels[c][y * width + x];
```

GDB has caught the segmentation fault and shows you the exact line where the error occurred.

#### c) Backtrace the function calls

You can use the `backtrace` command to see the function call stack leading to the crash:

```sh
(gdb) backtrace
#0  rotate_image_90_clockwise (node=0x5555555802f0)
    at lab3/src/transformation.c:105
#1  0x0000555555577885 in execute_node (node=0x5555555802f0)
    at lab3/src/transformation.c:222
#2  0x00007ffff7fb9c7f in execute_graph (graph=0x5555555802a0)
    at lab3/src/parser.c:174
#3  0x0000555555555e4a in main (argc=2, argv=0x7fffffffdae8)
    at lab3/src/main.c:165

```

Here everything appears normal.

!!! Note
    It's possible to change the frame using `up` and `down` commands to navigate through the call stack and inspect their variables.

#### d) Inspect the variables

You can inspect the values of variables at the point of the crash. For example, to check the values of `x`, `y`, `c`, `width`, and `height`, you can use the `print` command:

```sh
(gdb) print x 
$1 = 0
```

Print each of the variables, do you see anything suspicious at the point of crash?

#### e) Fix and explain the first bug

!!! Tip
    The first bug is a logical error in the loop exit condition at line 109.

Once you have identified and understood the first bug, you can fix it directly in the source code.
Commit the fix to git and explain the bug and how you fixed it in the commit message.

Unfortunately, there is still a second bug that we will fix in the next section.

### 3. Using Valgrind to Detect Memory Issues

#### a) Run the program with GDB again

```sh
(gdb) run
Starting program: lab3/build/mytransform pipelines/rotate.pipeline
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/x86_64-linux-gnu/libthread_db.so.1".
Loaded image: images/image0.bmp (259x194, 3 channels)
malloc(): corrupted top size

Program received signal SIGABRT, Aborted.
__pthread_kill_implementation (no_tid=0, signo=6, threadid=<optimized out>)
    at ./nptl/pthread_kill.c:44
warning: 44	./nptl/pthread_kill.c: No such file or directory
(gdb) backtrace
#0  __pthread_kill_implementation (no_tid=0, signo=6, threadid=<optimized out>)
    at ./nptl/pthread_kill.c:44
#1  __pthread_kill_internal (signo=6, threadid=<optimized out>) at ./nptl/pthread_kill.c:78
#2  __GI___pthread_kill (threadid=<optimized out>, signo=signo@entry=6)
    at ./nptl/pthread_kill.c:89
#3  0x00007ffff7c4527e in __GI_raise (sig=sig@entry=6) at ../sysdeps/posix/raise.c:26
#4  0x00007ffff7c288ff in __GI_abort () at ./stdlib/abort.c:79
#5  0x00007ffff7c297b6 in __libc_message_impl (fmt=fmt@entry=0x7ffff7dce8d7 "%s\n")
    at ../sysdeps/posix/libc_fatal.c:134
#6  0x00007ffff7ca8ff5 in malloc_printerr (
    str=str@entry=0x7ffff7dcc6f7 "malloc(): corrupted top size") at ./malloc/malloc.c:5772
#7  0x00007ffff7cac2fc in _int_malloc (av=av@entry=0x7ffff7e03ac0 <main_arena>, bytes=150738)
    at ./malloc/malloc.c:4447
#8  0x00007ffff7cad7f2 in __GI___libc_malloc (bytes=<optimized out>)
    at ./malloc/malloc.c:3328
#9  0x0000555555576fd3 in save_image (node=0x555555580320)
    at lab3/src/transformation.c:70
#10 0x0)
    at lab3/src/transformation.c:225
#11 0x0a0)
    at lab3/src/parser.c:174
#12 0x0)
    at lab3/src/main.c:165
```

The program crashes again, but this time with a different error message: `malloc(): corrupted top size`. This indicates a memory corruption issue.

**The backtrace does not point to the exact line in your code where the corruption occurred. Why?**

#### b) Use Valgrind to pinpoint the memory issue

Valgrind is a programming tool for memory debugging, memory leak detection, and profiling. It can help you identify memory-related issues in your program, such as invalid memory accesses, memory leaks, and uninitialized memory usage.

```sh
valgrind build/mytransform pipelines/rotate.pipeline

==241843== Memcheck, a memory error detector
==241843== Copyright (C) 2002-2022, and GNU GPL'd, by Julian Seward et al.
==241843== Using Valgrind-3.22.0 and LibVEX; rerun with -h for copyright info
==241843== Command: build/mytransform pipelines/rotate.pipeline
==241843== 
Loaded image: images/image0.bmp (259x194, 3 channels)
==241843== Invalid write of size 1
==241843==    at 0x12B188: rotate_image_90_clockwise (transformation.c:105)
==241843==    by 0x12B87D: execute_node (transformation.c:222)
==241843==    by 0x485BC7E: execute_graph (parser.c:174)
==241843==    by 0x109E49: main (main.c:165)
==241843==  Address 0x4bf26f7 is 119 bytes inside an unallocated block of size 3,729,760 in arena "client"
... [output truncated] ...
```

**How does Valgrind work? Why is it able to provide more detailed information about memory issues than gdb?**

Here valgrind provides a detailed report of the memory error, including the exact line in your code where the invalid write occurred. Now we will use gdb again to inspect the variables at the point of the invalid write.

#### c) Set a breakpoint at the faulty line

```sh
(gdb) break transformation.c:105
(gdb) run
... [output truncated] ...
Breakpoint 1, rotate_image_90_clockwise (node=0x5555555802f0)
    at lab3/src/transformation.c:105
105 node->output->pixels[c][x * width + (height - y - 1)] = node->input->pixels[c][y * width + x];
(gdb) 
```

Observe that gdb stops at the breakpoint you set and allows inspecting the point of the invalid write.

#### d) Inspect the values of `x`, `y`, `width`, `height`, and the computed index:

```sh
print x
print y
print width
print height
print x * width + (height - y - 1)
```
GDB allows you to perform arithmetic operations directly in the `print` command, so you can compute the index and check if it is within bounds. Do you see anything suspicious?

#### e) Set a conditional breakpoint

We start to suspect that the index calculation is incorrect. To catch the invalid memory write, set a conditional breakpoint that triggers when the computed index is out of bounds. Start gdb again and run the following commands:

```sh
(gdb) break transformation.c:105
(gdb) condition 1 x * width + (height - y - 1) >= height * width
```

`condition` 1 sets a condition on breakpoint 1, so it only triggers when the condition is true.
The condition will trigger when the computed index is greater than or equal to the total number of pixels in the image, which indicates an out-of-bounds access.

Run the program again, do you hit the breakpoint?

#### f) Analyze and fix the bug

!!! Tip
    Check carefully that the dimensions used in the index calculation are correct. The bug is a mix-up between `width` and `height`.

As before once you have identified and understood the second bug, you can fix it directly in the source code.
Commit the fix to git and explain the bug and how you fixed it in the commit message.

Check that the program runs correctly now!

### 4. Non-regression tests

Now that you have fixed both bugs, it's important to ensure that the bugs will not reappear in the future. To do this, you will write non-regression tests using the Unity testing framework.

Add tests that specifically target the scenarios that led to the bugs you fixed. For example, you can create tests that rotate images of various sizes and shapes, including non-square images, to ensure that the `rotate_image_90_clockwise` function behaves correctly.

<hr class="gradient" />

<div class="summary-section box-section" markdown>

<h2 class="hidden-title"> 4 - Summary</h2>

Upon completing this third lab, you should know how to:

- [x] Use CMake to build and install a shared library and an executable.
- [x] Configure CMake for different build types and compiler options.
- [x] Integrate and run unit tests using the Unity testing framework.
- [x] Debug segmentation faults and memory issues using GDB and Valgrind.
- [x] Write non-regression tests to prevent reintroducing fixed bugs.

</div>