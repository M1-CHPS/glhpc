# TD5: Experimental Methodology and Scientific Reporting
<hr class="gradient" />

Regression is a classical machine learning problem. It aims at learning to predict a continuous variable from input features.
For example, we could predict the height of a person (label) depending on their age, gender, and country of origin (features).

In this lab, we will focus on two solutions to the regression problem:

- The K-Nearest Neighbors (KNN), where we predict the average value from the K nearest points using euclidean or other distances
- Gradient Boosting Model (GBM) based on decision trees; using the python package LightGBM.

GBM is a very powerful but complex model. Furthermore, it requires the model to be fitted on a training dataset first. Once fitted, predictions are cheap and constant time.
KNN is significantly simpler, does not require model training, but predictions scale with the number of samples in the reference dataset.

In this lab, we will learn how to use and apply low-level profiling tools to quantify the performance of both methods, and apply the experimental design course to present our results.

The provided source code includes:

1. A brute-force C implementation of the K-Nearest Neighbors (KNN) regression method using OpenMP.
2. An incomplete and partially broken experiment that attempts to compare how the KNN and LightGBM model behave with an increasing number of samples

---

### 1. K-Nearest Neighbors implementation

The KNN application can be run like so:
```sh title="Running the KNN"
 # Use cmake to build the application, make sure to be in Release mode
mkdir build && cd build && cmake .. -DCMAKE_BUILD_TYPE=Release && make

# ./build/myknn <samples.csv> <queries.csv> <k> <num_threads> (<output_csv_path>)
./build/myknn ./datasets/samples.csv ./datasets/queries.csv 10 8
```

!!! Danger
    The parser is very basic: both the queries and datasets .csv file must contain exactly the same columns, in the same order.

By default, if no output path is provided, the application will output inside `./results.csv`

---

### 2. Broken Experiment

The script `/scripts/lgbm_vs_knn.py` objective is to measure the timing and accuracy of LightGBM and KNN when increasing the number of training samples.
The gathered data should look something like this:
```csv
model,time,mae,nsamples
lgbm,0.2365,0.0186,2400
lgbm,0.2308,0.0184,2515
lgbm,0.2394,0.0185,2636
knn,0.1604,0.02308,2400
knn,0.1555,0.0243,2515
knn,0.1633,0.0358,2636
...
```

However, the person writing it never finished it. When fixing this script, you should make sure to:

- Keep the same test samples for all runs
- Use `np.linspace` or `np.geomspace` to generate the points
- Have the timing encompass both training and prediction (We only focus on a coarse performance comparison here)
- Make multiple repetitions to control measurement noise.
- You can have one plot for accuracy and one for performance, but having both on the same plot using `ax.twinx` is a very nice bonus.

---

### 3. Provided Files

| Path                       | Description                                               |
|----------------------------|-----------------------------------------------------------|
| `CMakeLists.txt `          | CMake for the C implementation of KNN                     |
| `src/dataset.(c\|h)`       | Contain the logic for parsing a .csv dataset              |
| `src/main.c `              | Contain the implementation of KNN                         |
| `datasets/`                | Contain both the training dataset and a sample query file |
| `scripts/my_experiment.py` | Skeleton of an experiment that you will have to complete  |
| `scripts/lgbm_vs_knn.py`   | An incomplete experiment you will have to finish          |
| `scripts/stability.py`     | A script to check performance and energy measurement stability |

<hr class="gradient" />

## 1 - Measuring Energy, execution time, and cache misses

!!! Warning
    Measuring energy is a significant part of this lab. However, the RAPL energy counter may not be available on your CPU (Mostly Intel/AMD).
    You will have to find a valid machine to run this measurements.

**Linux Perf** is a very powerful tool to collect a variety of performance indicators. Its capable of capturing a list of CPU-events provided by the user, perform automatic meta-repetitions, and aggregate results in a nice JSON format.

### 1. Setup your environment

Run the following to setup your lab:

```sh title="Setup the lab"
source ./setup_env.sh
```

---


### 2. Stabilize your machine

Run `./scripts/stability.py` and check the results in `results/stability.png`. Take the necessary actions to make your machine relatively stable:

- Set the energy governor to performance
    ```sh title="Performance governor"
    sudo cpupower frequency-set -g performance
    ```
    Remember to switch back to `powersave` when you're done !
- If your CPU has heterogeneous cores, set the thread affinity to only use performance cores. 
- If on a laptop, remember to plug your laptop to avoid measurements noise due to the battery governor.
- Kill any background apps

---


### 3. Measuring Energy

What does the following command do ?
```sh title="Idle Energy Consumption"
perf stat -a -j -e power/energy-pkg/,power/energy-cores/ sleep 60
```

Ensure your machine is mostly idle and execute this command.

#### a) What does `energy-pkg` measure, and what's the unit ? What about the other events ?

Compute your machine idle power consumption: $P_{idle} = \frac{\text{energy-pkg}}{T}$.

#### b) Measure the KNN energy consumption

```sh title="Workload Consumption"
time perf stat -r 5 -a -j -e power/energy-pkg/,power/energy-cores/ \
    ./build/myknn ./datasets/samples.csv ./datasets/queries.csv 5 1 
```

Note that the `-r 5` flag causes `perf` to perform 5 meta-repetitions. The `time` command reports the sum of the timings for all runs.
Compute the effective power and energy consumption of the `knn` application. Remember to substract $P_{idle}$.

---


### 4. Measuring performance metrics

What does the following command do ?
```sh title="Measuring performance"
time perf stat -r 5 -e instructions,cycles,cache-references,cache-misses \
    ./build/myknn ./datasets/samples.csv ./datasets/queries.csv 5 1 
```

Execute this command and answer the following questions.

#### a) What's the observed variance in the execution time ?
#### b) What's the mean instructions / cycle ?

A Memory bound application has the CPU waiting for data to be retrieved for memory, meaning the CPU has a low number of instructions / cycle.
A compute bound application is limited by the CPU performance.

Is the application memory bound ?

#### c) What's the percentage of cache misses ?

Memory accesses are reported as "Cache References"

#### d) How does the percentage of cache miss evolve when increasing the number of threads ?
Could you explain why ?

---

### 5. Simple Profiling

Modify the `CMakeLists.txt` to add the `-pg -g` compilation flag, then rerun the application:

!!! Tip
    Cmake does not always detect flag changes and may rebuild with the old flags. Delete `./build/CMakeCache.txt` and rerun `setup_env.sh`

```
./build/myknn ./datasets/samples.csv ./datasets/queries.csv 5 1 
```

You should see that a `gmon.out` file has appeared; this file contains the profile of the application.

Run the following:

```sh title="Running gprof"
gprof ./build/myknn ./gmon.out
```

Where is most of the time spent in the application ?

**Remove the -pg flag as it will slow your application and bias your measurements later on**


<hr class="gradient" />

## 2 - Scientific Report: Model Comparison and Energy Study

You are tasked to write a **maximum three page scientific report** with the following sections:

#### a) Stability and Environment

- Document CPU model, number of cores, Cache(s) size, Ram, OS version, compilers / python version
    - The dataset `datasets/samples.csv` contains $\text{ncols} * \text{nrows}$ floating point values, stored as 32 bits floats in `myknn`.
    Does this dataset fit in your CPU caches ?
- Specify CPU gorvernor and thread affinity settings used during the experiments
- A stability plot generated through `scripts/stability.py`. 
- Make sure to add a table with the mean and standard deviation of each metric.

#### b) A corrected and improved version of the provided experiment comparing KNN regression with LightGBM

- A paragraph describing the goal of the experiment
- A paragraph explaining your protocol
- A plot comparing KNN and LightGBM accuracy and execution time when increasing the number of samples
    - From this plot, we should observe that: Accuracy increases with the number of samples; the execution time of KNN grows linearly with the number of samples;
    LightGBM has good scalability and accuracy, and is faster than KNN.
    - Make sure to include confidence intervals.
- Your observations and conclusions

#### c) An experiment of your choosing

- Formulate a specific question of your choice about energy consumption. Examples:
    - How does the $\text{efficiency} = \frac{E}{\text{# of predictions}}$ scale with the number of threads for both KNN and LightGBM ?
    - How reproducible and stable are RAPL energy measurements for LightGBM and KNN across multiple runs and thread counts?
    - What is the relationship between energy consumption and the number $k$ of nearest neighbors ?
- Formulate a clear hypothesis for your energy experiment (What you expect to see)
- Explain your experimental design
- Provide an informative plot that answers the question
- Present your observations and conclusions

Your report will be evaluated on clarity, conciseness, and scientific rigor. Avoid unnecessary implementation details; focus on producing convincing results.