# Lab 5: Experimental Methodology and Scientific Reporting

<hr class="gradient" />

The [Kepler space telescope](https://en.wikipedia.org/wiki/Kepler_space_telescope) monitors the variation in the luminosity of distant stars using a photometer. The datasets are freely available online, and we will use them as a case study for this lab.


<figure markdown="span">
  ![Processing Example](image/lab5/kepler.png)
  <figcaption>Kepler space telescope shortly after the assembly
  <br>
  (NASA/Troy Cryder)
  </figcaption>
</figure>

Kepler generates relatively simple datasets: a photon flux (the intensity of the received light) at specific dates for a particular stars. However, by carefully preprocessing this data and using specialized signal analysis techniques, we can make major discoveries.

<hr class="gradient" />

## 0 - Report

Take a look at `report.md`. You should complete this report as you go along the lab. Below is a short description on what is expected in each section:

- 1) Environment and context
    - Give details on the machine you used for the experiments: CPU/Memory specifications, compiler version, python version, OS name and version, and any other details that helps characterize your setup.
        - You can use `lscpu`, `free -h`, `python --version`, `gcc --version`, ...
    - A brief description of the context of BLS, the kepler datasets, etc.
- 2) Kepler result
    - Include both a lightcurve plot and a phase-folding plot for Kepler 8.
    - A single figure that includes a periodogram for all the provided Kepler datasets.

- 3) Profiling results
    - Generate stability plots using `./scripts/stability.py` and include them in the report.
    - **If your machine supports RAPL measurement**: Give the approximate energy consumption of the BLS algorithm on the Kepler 8 dataset. 
    - **If your machine does not support RAPL measurement**:
        - State this explicity in your report.
        - Try on another machine if possible
        - ... OR replace this experiment by a weak scaling plot if you can't get RAPL to work.
    - Give the perf results for `instructions,cycles,cache-references,cache-misses` of `bls(...)` on the Kepler-8 dataset.
    - Include the strong scaling plot

---

### Provided files

| Path                | Description                                                                 |
|---------------------|-----------------------------------------------------------------------------|
| `data/`             | Pre-processed Kepler dataset for this lab                                   |
| `libbls/`           | Box Least Square (BLS) Python library for transit detection. (CMake)        |
| `scripts/`          | Python/bash scripts for plotting and data analysis                          |
| `scripts/stability.py`  | Monitors the system usage for 5 minutes to assess measurements stability    |
| `scripts/strong_scaling.py`      | Draft for a strong scaling analysis you will have to complete      |
| `setup_env.sh`      | Helper script to setup the python environment and various env. variables    |
| `build_library.sh`  | Helper script to run CMake for the BLS library                              |

<hr class="gradient" />

## 1 - Plotting and data analysis

Kepler generates time-series, that is data indexed by a timestep. First, look at the data inside `data/Kepler-8_light_curve.csv`. The `time` column denotes the time in days since the satellite reference. The `flux` column is the normalized measured luminosity of the Kepler 8 star at a given date.

#### a) Setup python

Run the following:
```bash title="Setup bash environment"
source ./setup_env.sh
```

#### b) Plot the evolution of luminosity

Write a `scripts/plot_luminosity.py` script that:

- Can be called with `./scripts/plot_luminosity.py ./results kepler-*` where * is an id (i.e., kepler-8, kepler-17, etc.)
- Fetches the corresponding dataset in `data/`
- Plots the dataset using `matplotlib` (x: Time (days), y: Flux)
- Save the plots as `results/luminosity_kepler-*.png`

Ensure the script is executable using `chmod +x <file>` and that the file starts with the shebang `#!/usr/bin/env python3` 

!!! Tip
    Ensure that the `results` folder exists before saving to it. You can use `os.makedirs(<path>, exists_ok=True)` in your script.

#### c) Run the previous script for the Kepler 8 dataset. What do you observe ?
#### d) Refine your previous plot

Make sure that:

- The axes are clearly labeled
- The x and y ticks are easily readable and properly spaced (`np.linspace`)
- The plot includes a title, legend, and uses a `tight` or `constrained` layout.
- The figure has an appropriate aspect ratio (width to height)

The final plot could look something like this:

<figure markdown="span">
  ![Kepler 8 Light curve](image/lab5/luminosity_Kepler-8.png){ style="max-width: 80%; height: auto;" }
  <figcaption>Kepler 8 Light curve
  </figcaption>
</figure>

#### e) Give a possible explanation for the periodic dips in luminosity

On the previous light curve, we observe that the luminosity appears to "dip" sharply at regular intervals.
What could cause this periodic phenomenon ?

!!! Note
    Remember that the "flux" variable is the observed light intensity for a given star, from the telescope point of view.

#### f) Implement phase folding light curve

Phase folding is a simple technique to visualize periodic signals: we fold the data over a given period so that the signals overlap, highlighting patterns.

```python title="Phase Folding"
# Load the data here using pandas, store in a `data` variable
# Period to fold over
period = 0.8

 # We phase by the period, and divide by period to go in the [0, 1] range
phase = (data["time"] % period) / period
phase = phase - 0.5 # Center the phase
sort_idx = np.argsort(phase)
phase_sorted = phase[sort_idx]
flux_sorted = data["flux"].iloc[sort_idx]

phase = np.concatenate([phase_sorted, phase_sorted+1]) # Double plotting to improve visualization
flux = np.concatenate([flux_sorted, flux_sorted])

# Combine everying back to a DataFrame for plotting !
df = pd.DataFrame({"phase": phase, "flux": flux})
```

Implement a `scripts/phase_folding.py` script that plots the phase-folded light curve (x: phase, y: flux). 

It should be used like so:
`./scripts/phase_folding.py ./results kepler-* <period>`.

Optionally, you can also plot a binned mean on top of the phase-folded light curve:

```python title="Phase folding: Binning"
from scipy import stats
bins = 200
# Here, we bin the data using 200 bins. In each bin, we compute the mean flux.
bin_means, bin_edges, _ = stats.binned_statistic(phase, flux, statistic='mean', bins=bins)
# We compute the x coordinate of each bins, by taking the center point
bin_centers = (bin_edges[:-1] + bin_edges[1:]) / 2
ax.plot(bin_centers, bin_means, color="red", lw=1.5)
```
#### h) Run the previous script by phase folding over the Kepler 8b Period (`koi_period`). 

Check the file `data/kepler-8_known_planets.json`. This json contains information about the lonely Kepler 8b exoplanet, in the Kepler 8 star system. This exoplanet orbits its parent star
every 3.52 days.


- What do you observe ? 
- Does the light "dips" overlap or is your plot noisy?
- What can we say about the relationship between the light "dips" and Kepler 8b orbit ?
- Draw a simple diagram describing what's happening during the light dips.
    - (Optionnal) Draw a sad emoji face on Kepler 8b, because she's alone, in a vast, vast universe.

<figure markdown="span">
  ![Phase folded Kepler 8 Light curve](image/lab5/phase_folding_Kepler-8.png){ style="max-width: 80%; height: auto;" }
  <figcaption>Phase folded Kepler 8 Light curve
  </figcaption>
</figure>

<hr class="gradient" />

## 2 - Box Least Square

The Box Least Square (BLS) signal processing algorithm is used to detect the transit of exoplanets in front of their stars by searching for characteristic box-shaped dips in the luminosity at regular frequency.

The provided library implements a Python <-> C interface so that you can call BLS from a Python script. It also simplifies the loading and manipulation of the data, which can be done in Python, while the C code focuses on high-performance analysis.

#### a) Run the provided `build_library.sh` script
#### b) Write a `scripts/run_bls.py` script for kepler data

The BLS library can be used like so:
```python title="run_bls.py"
import bls
# ... Load data here
match = bls.bls(data["time"].values.astype(np.float64), data["flux"].values.astype(np.float64),
    1.0, 4, 250, 0.02, 0.15, 100)
```
BLS is very sensitive to the hyperparameters, so you **must use the ones provided here**.

Ensure that your script can be called with `scripts/run_bls.py kepler-*` where * is an id (i.e., kepler-8, kepler-17, etc.), and that it reports the BLS match.
Check that the BLS output is consistent with the characteristics of the Kepler 8b exoplanet.

#### c) Build a periodogram

The BLS algorithm scans through a range of Orbital Periods, and computes a *Power* score for each candidates. The higher the power, the better the candidate. 

The function `bls.bls_periodogram(...)` returns a 2D array containing all the scores, which allows us to build a **Periodogram**. Pairs are stored as (Power, Period).

- Take a look at `scripts/periodogram.py` and understand the provided code snippets
- Plot a periodogram for Kepler 8, 17, 45 and 785. **You are required to use subplots** so that all periodograms are on the same figure. Feel free to lookup "BLS Periodogram" online to get an idea of the target results.
- Note that you should use the same arguments for `bls.bls_periodogram(...)` that the ones used for `bls.bls(...)`.
- Save the resulting plots as `results/all_periodograms.png`

---

<figure markdown="span">
  ![Principle behind the Kepler exoplanet detection system.](image/lab5/kepler_principle.png){ style="max-width: 80%; height: auto;" }
  <figcaption markdown="span">Principle behind the Kepler exoplanet detection system
  <br>
  Hannah R. Wakeford, Laura C. Mayorga
  <br>
  [Characterizing the Dynamics and Chemistry of Transiting Exoplanets with the Habitable World Observatory (2025)](https://arxiv.org/abs/2506.22839)
  </figcaption>
</figure>

<div class="goingfurther-section box-section" markdown>

#### d) Look at `libbls/src/pybls.c` and try to understand how we are interfacing Python with C code

```C title="py_bls interface"
static PyObject *py_bls(PyObject *self, PyObject *args) {
  PyArrayObject *t_arr, *f_arr;
  double Pmin, Pmax, qmin, qmax;
  int Np, Nq;

  if (!PyArg_ParseTuple(args, "O!O!ddiddi", &PyArray_Type, &t_arr, &PyArray_Type, &f_arr, &Pmin,
                        &Pmax, &Np, &qmin, &qmax, &Nq))
    return NULL;

  int N = (int)PyArray_DIM(t_arr, 0);
  double *t = (double *)PyArray_DATA(t_arr);
  double *f = (double *)PyArray_DATA(f_arr);

  BLSResult res = bls(t, f, N, Pmin, Pmax, Np, qmin, qmax, Nq);

  return Py_BuildValue("{s:d,s:d,s:d,s:d,s:d}", "period", res.period, "duration", res.duration,
                       "phase", res.phase, "depth", res.depth, "power", res.power);
}
```

When we call `bls.bls(...)` from Python, all arguments are redirected to this C function. The `PyObject` self and args pointers
are structures containing the arguments of the function.

The `PyArg_ParseTuple(...)` call is used to "unfold" the Python arguments into C variables. The string `O!O!ddiddi` defines how the arguments should be interpreted:

- `d` for double
- `i` for integers (32bits `int`)
- `O!` for objects (Here numpy arrays). Note that the `!` qualifiers adds a type check: the runtime would raise an error if the received object wasn't a `PyArray_Type`.

`PyArray_DIM` and `PyArray_DATA` are used to convert Python/Numpy arrays to C usable pointers and size pairs.

The `Py_BuildValue(...)` call does the exact inverse process and builds Python values from C variables.

Finally:

```C title="Hooking up C with Python"
static PyMethodDef BlsMethods[] = {
    {"bls", py_bls, METH_VARARGS, "Run the BLS algorithm."},
    {"bls_periodogram", py_periodogram_bls, METH_VARARGS, "Compute the BLS periodogram."},
    {NULL, NULL, 0, NULL}};

static struct PyModuleDef blsmodule = {PyModuleDef_HEAD_INIT, "pybls", NULL, -1, BlsMethods};

PyMODINIT_FUNC PyInit_bls(void) {
  import_array();
  return PyModule_Create(&blsmodule);
}
```

Here, we create an array containing all the functions we want to make available from python. We then declare a Python module and a 
`PyInit_bls(void)` function, that will be called by Python to load/initialize the module at runtime.


</div>

<hr class="gradient" />

## 3 - Profiling for energy and performance characterization

### 1. Measuring Energy


#### a) Check the value of perf event paranoid

By default, the Linux kernel restricts access to some perf counters to prevent malicious usage.
Check the value of the paranoid flag:

```bash title="Perf event paranoid"
cat /proc/sys/kernel/perf_event_paranoid
```

Possible values are:

- -1 -> unrestricted. All counters can be used system-wise.
- 0 -> All counters can be used on your own processes
- 1 -> Limited access to CPU counters
- 2 -> Only basic access

For this lab, we want `perf_event_paranoid` to be set to -1 so we can access the RAPL counters.

#### b) Disable perf event paranoid

The following command will set `perf_event_paranoid` to be set to -1.

However, you need `sudo` (admin rights) on your machine.

```bash title="Perf event paranoid"
sudo sh -c 'echo -1 > /proc/sys/kernel/perf_event_paranoid'
```

If the command fails (because you don't have sudo permissions) and `perf_event_paranoid` is not set to -1, you will not be able to proceed in this section. **Skip to section 3.2 (Measuring performance metrics)**.


#### c) Checking availability of RAPL counters

Run the following:
```sh title="Checking for RAPL perf events"
perf list | grep "energy-pkg"
  power/energy-pkg/                                  [Kernel PMU event]
```

If you don't see the `power/energy-pkg` line, this probably means that RAPL energy measurement isn't supported on your machine.
 **Skip to section 3.2 (Measuring performance metrics)**.

#### c) First energy measure

What does the following command do ?
```sh title="Idle Energy Consumption"
perf stat -a -j -e power/energy-pkg/,power/energy-cores/ sleep 60
```

Ensure your machine is mostly idle and execute this command.

!!! Danger
    Classical hardware counters, like `instructions`, are **per-process**, whereas RAPL is **system-wide**: RAPL captures energy consumption for all processes currently running, not specifically by our application !

#### d) What does `energy-pkg` measure, and what's the unit ? What about the other event(s) ?

Compute your machine idle power consumption: 

$$
P_{idle} = \frac{\mathrm{energy{\text -}pkg}_{idle}}{t}
$$

Where $\mathrm{energy{\text -}pkg}_{idle}$ is in Joules, and $t$ is in seconds.
This is the average power consumed by the CPU package while the machine is idle, in watts

#### e) Measure the BLS algorithm energy consumption

```sh title="Workload Consumption"
time perf stat -r 5 -a -j -e power/energy-pkg/,power/energy-cores/ \
    ./scripts/run_bls.py kepler-8
```

Note that the `-r 5` flag causes `perf` to perform five meta-repetitions. The `time` command reports the sum of the timings for all runs.
Calculate the effective power and energy consumption for BLS.

$$
P_{effective} = \frac{\mathrm{energy{\text -}pkg_{BLS}}}{t_{BLS}} - P_{idle}
$$

---

### 2. Measuring performance metrics

What does the following command do ?
```sh title="Measuring performance"
time perf stat -r 5 -e instructions,cycles,cache-references,cache-misses \
    ./scripts/run_bls.py kepler-8
```

Execute this command and answer the following questions.

#### a) What's the observed variability in the execution time ?
#### b) What's the mean instructions / cycle ?
#### c) Is the application compute or memory intensive ?

In summary:

- Memory-intensive applications have low instructions per cycle and high memory metrics
- Compute-intensive applications are vectorized (high instructions per cycle) and fully utilize threads.
  Memory usage is relatively low because the arithmetic density is high.

#### d) What is costlier: running the BLS algorithm, or loading the dataset ?

Run the following:
```sh title="Perf Record"
perf record -g -- python3 ./scripts/run_bls.py kepler-8
perf report
```

You can move around the perf report using the arrow keys, and you can press `+` to expand a particular call tree.

How much time is spent in the BLS algorithm ?

Which would be more time-efficient for an engineer: optimizing the data loading process or optimizing the BLS algorithm?

### 3. Strong scaling analysis

Take a look at `scripts/strong_scaling.py`. It contains a code snippet for running the `scripts/run_bls.py` script with a given number of threads. Our goal is now to build a strong scaling plot.

#### a) Look and try to understand the purpose of the `scripts/stability.py` script

What are we measuring ? What information does this script provide about our environment?

#### b) Modify `stability.py` to measure the stability of `run_bls.py`

To further assess the stability of our setup, we should try to measure the distribution of multiple runs of `run_bls.py`

Modify the script to:

- Load the kepler 8 Dataset, and subsample it (Reduce the size to ~2k randomly selected samples)
    - Be sure to sort the dataset after subsampling by using `df.sort_values(by="time")` !
- Save the previous dataset, and execute `run_bls.py` on the subsampled dataset, measuring the time.
- Repeat the previous measurements approximately 100 times, and generate a distribution plot using seaborn.
    You can use a boxplot, kdeplot, violin plot, histogram, etc.
    Save the raw data to `results/stability_bls.csv`

If your machine is stable, the performance distribution should follow a normal distribution.

---

<figure markdown="span">
  ![Examples of different distribution plots.](image/lab5/bls_stability.png){ style="max-width: 60%; height: auto;" }
  <figcaption>Examples of different distribution plots.
  <br>
  The stability results here were gathered on a laptop that was in-use, thus the measures are quite unstable.
  </figcaption>
</figure>

---

#### c) Modify `scripts/strong_scaling.py` to build a strong scaling plot

Save the plot to `results/<date>/strong_scaling.png` where date is obtained via:
```python title="Formatting a timestamp"
import time
date = time.strftime("%Y_%m_%d-%H_%M_%S") # e.g. 2025_08_28-12_08_40
os.makedirs(f"results/{date}/", exist_ok=True)
```


<hr class="gradient" />

<div class="summary-section box-section" markdown>

<h2 class="hidden-title"> 5 - Summary</h2>

Upon completing this fifth lab, you should know how to:

- [x] Build simple plots using python and matplotlib
- [x] Improve a plot with titles, labels, formatting
- [x] Manipulate simple data formats (csv, json)
- [x] Use `perf` for measuring energy and performance hardware counters
- [x] Use `perf` sampling profiler to understand an application hotspots
- [x] Organise a report around data analysis

</div>