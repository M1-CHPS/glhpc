# Lab 3: CMake, Unit Tests, and Debugging
<hr class="gradient" />

### Objectives

- Learn how to use CMake for building C projects.
- Write and run unit tests using the Unity testing framework.
- Use `valgrind` to detect memory-related issues and pinpoint invalid memory accesses.
- Learn how to use `gdb` to debug logical errors in C programs.
- Practice setting breakpoints, inspecting variables, and stepping through code in `gdb`.

### Provided Files

This lab is a continuation of [lab 2](/lab2/). The structure of the project is the same.
A new transformation `rotate_image_90_clockwise`, which you will analyse in the [third part of this lab](#C-debugging-with-gdb-and-valgrind), has been added to the `transformations.h` and `transformations.c` files.

## A - CMake

## B - Unit Tests

## C - Debugging with GDB and Valgrind

In this last part, you will learn how to debug two types of bugs in a C program using `gdb` and `valgrind`. These bugs are intentionally introduced in the `rotate_image_90_clockwise` function. The goal is to identify, understand, and fix these bugs while reflecting on the debugging process.

### 1. Build the Program with Debug Symbols

Debugging symbols are metadata embedded in a program's binary during compilation, providing detailed information about the source code, such as variable names, function names, and line numbers. These symbols allow tools like gdb and valgrind to map the program's execution back to the original source code, making it easier to inspect variables, set breakpoints, and trace errors. Without debugging symbols, these tools would only display raw memory addresses and machine-level details, making debugging significantly harder.

!!! Note
    To enable debugging symbols, you need to configure CMake to include the `-g` flag in the compilation process. This can be achieved by setting the `CMAKE_BUILD_TYPE` to `Debug`.

#### a. Run the `cmake` command with the `Debug` build type

```bash
cmake -B build/ -DCMAKE_BUILD_TYPE=Debug .
```

#### b. Build the project

```bash
make -C build/
```

#### c. Run the program using the rotate transformation

```bash
build/mytransform pipelines/rotate.pipeline
Loaded image: images/image0.bmp (259x194, 3 channels)
Segmentation fault (core dumped)
```

You should get an error as above.

#### d. Analyze carefully the error message

- What does `Segmentation fault` mean?
- What does `(core dumped)` mean?
- What could be the possible causes of this error?

### 2. Running the program with GDB

GDB is the GNU Project Debugger, a powerful tool for debugging programs. It allows you to run your program step by step, inspect variables, set breakpoints, and analyze the program's flow to identify and fix bugs.

#### a. Start gdb with the program and its arguments

```bash
gdb --args build/mytransform pipelines/rotate.pipeline

GNU gdb (Ubuntu 15.0.50.20240403-0ubuntu1) 15.0.50.20240403-git
... [output truncated] ...
(gdb)
```

!!! Note
    The `--args` option allows you to pass the program's arguments directly to gdb, so you don't have to type them again after starting gdb.
    `(gdb)` is the gdb prompt, where you can enter gdb commands.

#### b. Run the program inside gdb

```bash
(dgb) run
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


#### c. Backtrace the function calls

You can use the `backtrace` command to see the function call stack leading to the crash:

```bash
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

#### d. Inspect the variables

You can inspect the values of variables at the point of the crash. For example, to check the values of `x`, `y`, `c`, `width`, and `height`, you can use the `print` command:

```bash
(gdb) print x 
$1 = 0
```

Print each of the variables, do you see anything suspicious at the point of crash?


#### e. Fix and explain the first bug

!!! Tip
    The first bug is a logical error in the loop exit condition at line 109.

Once you have identified and understood the first bug, you can fix it directly in the source code.
Commit the fix to git and explain the bug and how you fixed it in the commit message.

Unfortunately, there is still a second bug that we will fix in the next section.

### 3. Using Valgrind to Detect Memory Issues

#### a. Run the program with GDB again

```bash
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

#### b. Use Valgrind to pinpoint the memory issue

Valgrind is a programming tool for memory debugging, memory leak detection, and profiling. It can help you identify memory-related issues in your program, such as invalid memory accesses, memory leaks, and uninitialized memory usage.

```bash
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

#### c. Set a breakpoint at the faulty line

```bash
(gdb) break transformation.c:105
(gdb) run
... [output truncated] ...
Breakpoint 1, rotate_image_90_clockwise (node=0x5555555802f0)
    at lab3/src/transformation.c:105
105 node->output->pixels[c][x * width + (height - y - 1)] = node->input->pixels[c][y * width + x];
(gdb) 
```

Observe that gdb stops at the breakpoint you set and allows inspecting the point of the invalid write.

#### d. Inspect the values of `x`, `y`, `width`, `height`, and the computed index:

```bash
print x
print y
print width
print height
print x * width + (height - y - 1)
```
GDB allows you to perform arithmetic operations directly in the `print` command, so you can compute the index and check if it is within bounds. Do you see anything suspicious?

#### e. Set a conditional breakpoint

We start to suspect that the index calculation is incorrect. To catch the invalid memory write, set a conditional breakpoint that triggers when the computed index is out of bounds. Start gdb again and run the following commands:

```bash
(gdb) break transformation.c:105
(gdb) condition 1 x * width + (height - y - 1) >= height * width
```

`condition` 1 sets a condition on breakpoint 1, so it only triggers when the condition is true.
The condition will trigger when the computed index is greater than or equal to the total number of pixels in the image, which indicates an out-of-bounds access.

Run the program again, do you hit the breakpoint?

#### f. Analyze and fix the bug

!!! Tip
    Check carefully that the dimensions used in the index calculation are correct. The bug is a mix-up between `width` and `height`.

As before once you have identified and understood the second bug, you can fix it directly in the source code.
Commit the fix to git and explain the bug and how you fixed it in the commit message.

Check that the program runs correctly now!

### 4. Non-regression tests

Now that you have fixed both bugs, it's important to ensure that the bugs will not reappear in the future. To do this, you will write non-regression tests using the Unity testing framework.

Add tests that specifically target the scenarios that led to the bugs you fixed. For example, you can create tests that rotate images of various sizes and shapes, including non-square images, to ensure that the `rotate_image_90_clockwise` function behaves correctly.