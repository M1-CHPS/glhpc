# Lab 6 - AI Project (1) SGEMM Kernel Optimization
<hr class="gradient" />

## 1 - Implementing a naive SGEMM

We work on multiplication of dense matrices. This algorithm is everywhere (ML, data analysis, 3D engines, physics). 
Here we focus on single-precision floating point SGEMM as used in many ML workloads.

The operation we want to implement is:

$$ \text{RES} = A \times B + C $$

![SGEMM](image/lab6/sgemm.svg)


```c title='sgemm.h'
/**
 * @brief SGEMM (Single-precision General Matrix Multiply)
 *
 * Performs the matrix multiplication operation:
 * RES = A*B + C
 *
 * @param A Input matrix A with dimensions M x K (row-major order)
 * @param B Input matrix B with dimensions K x N
 * @param C Input matrix C with dimensions M x N
 * @param M Number of rows in matrix A and C
 * @param N Number of columns in matrix B and C
 * @param K Number of columns in matrix A and rows in matrix B
 * @param RES Output matrix with dimensions M x N, where the result will be stored
 */
void sgemm(
    const float *A,
    const float *B,
    const float *C,
    float *RES,
    size_t M,
    size_t N,
    size_t K);
```

Matrices are stored in row-major order (C-style). That is, the elements of each row are stored in contiguous memory locations. For example, a 3x3 matrix:

$$ \begin{pmatrix}
a_{11} & a_{12} & a_{13} \\
a_{21} & a_{22} & a_{23} \\
a_{31} & a_{32} & a_{33}
\end{pmatrix} $$

is stored in memory as:

$$ [a_{11}, a_{12}, a_{13}, a_{21}, a_{22}, a_{23}, a_{31}, a_{32}, a_{33}] $$

### 1. Creating random matrices

Inside `src/` you find starter files: `sgemm.h`, `sgemm.c`, `main.c`.
Inside `tests/` you will find `test_runner.c` that contains a starter test harness.

#### a) Implement `random_matrix` inside `sgemm.c` to generate random matrices.
#### b) Add a test in `test_sgemm.c` that checks that `random_matrix` correctly generates matrices with values in the range $[-1.0, 1.0]$. Call the test from `test_runner.c`.
#### c) Create a `CMakeList.txt` 
It should:
- build an executable `gemm` from `main.c` and `sgemm.c`.
- build an executable `test_runner` from `test_runner.c` and `sgemm.c` using the `unity` testing framework as shown in previous labs.
- allow changing the build type (Debug/Release) from the command line with different sets of flags.

Check that your code compiles and that the test passes.

### 2. Naive SGEMM implementation

#### a) Implement the naive version of `sgemm` in `sgemm.c` using three nested loops in the order (i, j, k).
#### b) Add various tests in `test_sgemm.c` that checks that your `sgemm` implementation correctly computes the product of small matrices with variying sizes and shapes (e.g. 1x1, 2x2, 3x1, 1x3, 3x3).
#### c) Check that your tests pass.

Now that you have a working implementation, you can call `sgemm` from `main.c` with random matrices of different sizes passed as command line arguments.

## 2 - Performance measurement harness

Create a new directory `performance/` and add two files: `performance.sh` and `plot.py`.
For both the measurement harness and plotting script follow best practices taught in [lecture 4](lecture4.md).

### 1. Measure performance and energy consumption

We will use `perf` to measure the number of CPU cycles and energy consumption of our SGEMM implementation.

Example command to measure cycles and energy consumption of a run of `sgemm` with M=512, K=512, N=512:
```sh
perf stat -r 3 -e cycles,power/energy-pkg/ ./sgemm sgemm 512 512 512
```

The `-r 3` option tells `perf` to repeat the measurement 3 times and report the mean and variance.

### 2. Write a script `compare-sizes.sh`

The script should:

- run `sgemm` with N=512, K=512 and M with increasing sizes (e.g. 100, 200, 300, ..., 3000).
- measure the number of CPU cycles and energy consumption using `perf stat` for each run.
- define a variable `REPETITIONS` that controls how many times each configuration is repeated. `perf` supports the `-r` option to repeat measurements. It outputs the mean and variance of the measurements, allowing to plot error bars.
- define a variable `EVENTS` to specify the events to measure (e.g. `cycles,power/energy-pkg/`).
- aggregate all measures into a `.json` file or `.csv` file.

!!! Tip
    If you are using `json`, you can use `jq` to process the output of `perf stat` and aggregate the results together with `jq -s 'flatten(1)'`.

### 3. Write a script `plot-sizes.py`

The script should:

- read the output of the previous script and produces a plot with two y-axes:
- left y-axis: number of CPU cycles (with error bars)
- right y-axis: energy consumption (with error bars)

#### a) Run your scripts and produce an initial plot.
#### b) Inspect your plot. Do you see any knee points? Can you explain them? (Hint: consider cache sizes.)

!!! Tip
    You can use the following commands to inspect your CPU and memory topology:
    - `lstopo` to view memory/core topology (if available).
    - `cat /proc/cpuinfo` to inspect core model, cache sizes.

## 3 - Optimizations

!!! Note
    In this section we will implement different optimizations step by step. After each optimization, you should run your performance measurement harness to see the impact of the optimization on performance and energy consumption.
    Each new version of the code should be implemented in a new function (e.g. `sgemm_ikj`, `sgemm_blocked`, `sgemm_omp`), and you should add a command line option to `main.c` to select which version to run.
    Do not forget to add tests for each new version of `sgemm` in `test_sgemm.c`.

### 1. Vectorization

Modern CPUs have SIMD units (SSE/AVX/AVX512). The compiler can generate SIMD code, but the code and data layout must be friendly.

#### a) Compiler flags

1. Compile with `-O3 -march=native` and inspect compiler vectorization reports (GCC/Clang flags to tell whether loops were vectorized: `-fopt-info-vec-optimized` or `-Rpass=loop-vectorize`).
2. Measure runtime/energy after changes. Observe and explain differences.

!!! Tip
    If the compiler does not vectorize your loops, try to understand why. Common reasons include:
    - Data dependencies that prevent reordering.
    - Pointer aliasing (use `restrict` keyword if applicable).
    - Complex control flow inside loops.

#### b) Loop order / stride

Ensure the innermost loop has contiguous memory accesses.

1. Create a new function `sgemm_ikj` and call it from `main.c`. Add a command line option to select which version to run.
2. Change the loop order to (i, k, j).
3. Measure runtime/energy and compare to the naive version. Explain differences.

#### c) Add two new scripts to `performance/`

- `compare-optimizations.sh`: compares the naive and `ikj` implementations for a chosen matrix size.
- `plot-optimizations.py`: plots the performance and energy consumption of each implementation. Include error bars as before.

!!! Tip
    You can use the same structure as `compare-sizes.sh` and `plot-sizes.py`, but modify them to compare different implementations for a fixed matrix size.
    Make the scripts generic enough to easily add new implementations in the future.

### 2. Cache blocking

Access to `B` in the naive algorithm typically strides through columns — poor locality for row-major storage. Blocking (tiling) improves cache reuse.

#### a) Measure last-level-cache events for the naive implementation. 

Use `perf stat` with `LLC-loads` and `LLC-stores` events. Example:

```sh
perf stat -e LLC-loads,LLC-stores ./sgemm sgemm_ikj 1280 512 512
```

#### b) Implement a blocked matrix multiplication

Define a block size `BLOCK_SIZE` and implement `sgemm_blocked` in `sgemm.c`:

```c title='sgemm.h'
#define BLOCK_SIZE 512  /* block size, tune for your CPU cache */
/* sgemm_blocked has the same prototype as sgemm and sgemm_ikj */ 
void sgemm_blocked( ... );
```

Do not forget to call it from `main.c` and add a command line option to select it.

!!! Tip 

    - Ensure `n` is a multiple of `BLOCK` for simplicity; either restrict inputs or pad matrices (padding can be an exercise).

    - Inside blocks, use simple triple loops over block elements (ensure indices map correctly to row-major layout).

#### c) Measure LLC loads/stores for the blocked version and compare to naive.

#### d) Measure energy and time for blocked version and compare.

Modify your `compare-optimizations.sh` script to include the blocked version in the comparisons.

#### e) Why does blocking reduce LLC misses and energy/time?

3. Parallelization

### 3. Parallelization with OpenMP

In this section, we focus on parallelizing the blocked matrix multiplication using OpenMP. While we will only target the CPU for now, other parallel runtimes (e.g., MPI, TBB) could also be explored in the future.

#### a) Implement a parallel version using OpenMP

- Use OpenMP to parallelize the blocked version of `sgemm`.
- Parallelize over blocks of rows for better load balancing.

    Add `#include <omp.h>` at the top of your `sgemm.c` file.
    Use the following pragma to parallelize the outer loop:
    ```c
    #pragma omp parallel for schedule(static)
    ```

!!! Tip
    Static scheduling is often a good choice for matrix multiplication since the
    workload is evenly distributed, but you can experiment with other scheduling
    strategies (e.g., dynamic, guided) to see their impact on performance.

#### b) Compile and measure performance

You can set the number of threads with the `OMP_NUM_THREADS` environment variable. For example, to use 8 threads:

```sh
export OMP_NUM_THREADS=8  # Adjust based on your machine
```

Plot the performance and energy consumption of your OpenMP implementation for different numbers of threads (e.g., 1, 2, 4, 8, 16).
Add your scripts to `performance/` and produce a scalability plot.

#### c) Analyze results

- Compare energy consumption and runtime to the single-threaded version.
- Experiment with different numbers of threads and observe the impact on energy and time.
- Is energy per run higher or lower with more threads? Why?
- How does memory bandwidth affect scaling as more threads are added?

## 5 - Making a Library

Now that you have optimized your SGEMM implementation, you can package it as a library.
In the next lab, we will use your library to implement a simple Neural Network inference engine. 

To do so, modify your `CMakeLists.txt` to build a static library `libsgemm.a` from `sgemm.c` and `sgemm.h`. Ensure the prototypes in the public header `sgemm.h` are well commented in Doxygen style. Modify the `CMakeLists.txt` so that users of the library
know where to find the header files.

## 6 - For further study

The matrix product we have implemented is efficient, but it is possible to push optimizations even further. Here are some references and avenues if this work interests you:

- **Algorithmic improvements** such as Strassen allow to trade multiplications for additions, which in some cases can be beneficial.

- **Cache-oblivious algorithms** (recursive tiling based on space-filling curves).
Instead of using blocking techniques, which must be parameterized by a fixed
block size; it is possible to implement matrix multiplication to preserve
locality regardless of scale. This is called a cache-oblivious algorithm in
English. For matrix multiplication, such an algorithm can be obtained by
reordering the elements according to the order given by the Lebesgue curve.
This allows obtaining very efficient implementations for matrices whose
dimension is a power of two.  

- **Advanced BLAS**. You can compare your implementation with `cblas_sgemm` from
optimized vendor libraries (OpenBLAS, Intel MKL). You can even try using
`cublas` library to target GPUs.

<hr class="gradient" />

<div class="summary-section box-section" markdown>

<h2 class="hidden-title"> 7 - Summary</h2>

Upon completing this lab, you should know how to:

- [x] Write a naive implementation of the SGEMM algorithm.
- [x] Measure performance and energy consumption using `perf`.
- [x] Optimize the SGEMM algorithm using vectorization, loop reordering, cache blocking, and parallelization with OpenMP.
- [x] Analyze the impact of optimizations on performance and energy consumption.
</div>