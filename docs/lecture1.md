---
title: "CM1: Software Engineering for HPC and AI -- Introduction & Development Environment"
institute: "Master Calcul Haute Performance et Simulation - GLHPC | UVSQ"
author: "P. Oliveira, M. Jam"
date: \today
theme: metropolis
colortheme: orchid
fonttheme: structurebold
toc: true
toc-depth: 2
header-includes:
  - \metroset{sectionpage=progressbar}
---

## Syllabus

- Lecture 1: Introduction & Development Environment
- Lecture 2: Mastering C for Performance and HPC
- Lecture 3: Building, Testing and Debugging Scientific Software
- Lecture 4: Experimental Design, Profiling and Performance/Energy Optimization
- Lecture 5: HPC for AI

*Project*: Inference Engine for a Deep Network

## Introduction & Development Environment

- Principles of software engineering applied to HPC and AI.
- Introduction to computing architectures.
- Software engineering: lifecycle, quality, maintainability, reproducibility, collaboration.
- Development tools: shell scripts, dependency management, Git, IDEs, etc.

## Analytical solution to the 2-Body Problem

Consider two particles with masses $m_1$ and $m_2$ at positions $x_1$ and $x_2$ under gravitational interaction.

$$m_1.a_1 = -\frac{G.m_1.m_2}{\|x_1 - x_2\|^3} (x_2 - x_1)$$
$$m_2.a_2 = -\frac{G.m_1.m_2}{\|x_1 - x_2\|^3} (x_1 - x_2)$$

Solved by Bernoulli in 1734, $x_1$ and $x_2$ can be expressed as simple equations that depend on time, masses, and initial conditions.

## Why Simulate the n-Body Problem?

- For $n=3$ or more, no practical analytical solution exists.
- Even advanced mathematical solutions (e.g., Sundman, 1909) are too slow for real use.
- **Computer simulations** allow us to study the motion of many interacting particles.
  - Efficient algorithms (e.g., Barnes-Hut, Fast Multipole) make large-scale simulations possible.
- **HPC is essential** to simulate realistic systems in physics, astronomy, and AI.
  - Simulation + HPC = understanding complex systems!

## Naive n-Body Simulation in C

```c
// Compute accelerations based on gravitational forces
for (int i = 0; i < num_particles; i++) {
  double ax = 0.0, ay = 0.0, az = 0.0;
  for (int j = 0; j < num_particles; j++) {
    if (i == j) continue;
    double dx = p[j].x - p[i].x;
    double dy = p[j].y - p[i].y;
    double dz = p[j].z - p[i].z;
    double d_sq = dx * dx + dy * dy + dz * dz;
    double d = sqrt(d_sq);
    double f = G * p[i].m * p[j].m / (d_sq * d);
    ax += f * dx / p[i].m;
    ay += f * dy / p[i].m;
    az += f * dz / p[i].m;
  }
  p[i].ax = ax;
  p[i].ay = ay;
  p[i].az = az;
}
```

## Naive n-Body Simulation in C

Introduce a time step `dt` and update positions based on gravitational forces.

```c
// Update positions based on computed accelerations
for (int i = 0; i < num_particles; i++) {
  p[i].x += p[i].ax * dt * dt;
  p[i].y += p[i].ay * dt * dt;
  p[i].z += p[i].az * dt * dt;
}
```

## High Performance Computing

Fugaku (2020, 442 petaflops, 7.3 million cores)

  - n-body: integrates 1.45 trillion particules per second.

How to achieve such performance?

- Algorithmic improvements:
  - Use tree-based methods (Barnes-Hut, Fast Multipole) to reduce complexity from $O(n^2)$ to $O(n \log n)$ or better.
- Parallelization: distribute computation accross many cores.
- Vectorization: use SIMD instructions to process multiple data points in parallel.
- Data locality: optimize data access patterns to minimize memory latency and maximize cache usage.

Compiler optimizations, performance tuning, hardware acceleration are also crucial.