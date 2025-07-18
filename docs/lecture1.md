---
title: "CM1: Software Engineering for HPC and AI -- Introduction & Development Environment"
institute: "Master Calcul Haute Performance et Simulation - GLHPC | UVSQ"
author: "P. de Oliveira Castro, M. Jam"
date: \today
theme: metropolis
colortheme: orchid
fonttheme: structurebold
toc: true
toc-depth: 2
slide-level: 2
header-includes:
  - \metroset{sectionpage=progressbar}
---

# Introduction to Software Engineering for HPC and AI

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

  - n-body: integrates **1.45 trillion** particules per second.

How to achieve such performance?

- Algorithmic improvements:
  - Use tree-based methods (Barnes-Hut) to reduce complexity from $O(n^2)$ to $O(n \log n)$ or better.
- Parallelization: distribute computation accross many cores.
- Vectorization: use SIMD instructions to process multiple data points in parallel.
- Data locality: optimize data access patterns to minimize memory latency and maximize cache usage.

Compiler optimizations, performance tuning, hardware acceleration are also crucial.

/section{Introduction aux systèmes de contrôle de version}

# Version Control Systems

## What is Version Control?

Version control involves **tracking and managing** the **changes** made to project files.

Each version is associated with a date, an author, and a message. Developers can work on a copy corresponding to a specific version.

## Objectives

-   **Enhance communication** among developers (track code evolution, messages).
-   **Isolate experimental developments** (work branches).
-   **Ensure code stability** (stable version on the main branch, ability to revert to a stable version).
-   **Manage releases** (tags for specific versions).

## Vocabulary Related to Versions

- **Version**: A stage in the progress of software development (*revision* in English).
- **Modification**: A set of additions and deletions applied to one or more files.
- **Version Change**: Applying a modification to a version creates a new version.

## Vocabulary Related to Storage

- **Repository**: A public storage space containing versioned files.
- **Clone**: A copy of the project and its version control data. Cloning a repository provides a local working copy.
- **Working Copy**: A private local copy of the repository or part of it, where developers can make changes.

## Vocabulary Related to Changes

- **Commit**: 
  - *Noun*: A modification to one or more files in the project.
  - *Verb*: To apply a modification to the project.
- **Update**: Incorporate commits made by other developers into your working copy.
- **Diff**: A textual representation of changes between the project file and the local copy (e.g., `+++` for additions, `---` for deletions).

## Vocabulary Related to Branches

- **Branch**: A set of modifications originating from a specific version. The main branch (e.g., `main` or `master`) contains the primary project changes. Branches diverge from the main branch or other branches.
- **Merge**: Combine two branches into one.
- **Conflict**: Contradictory changes to the same file. Occurs when two developers modify the same part of a file differently or during branch merging.
- **Tag**: A label assigned to a specific version (e.g., `release-0.1.1`).

## Centralized VCS

Centralized Version Control System (VCS)

- **Single repository** for all versions.

### Advantages:
- Simplified centralized management.

### Examples:
- CVS (1990) *(OpenBSD)*
- Subversion SVN (2000) *(Apache, Redmine, Struts)*

## Distributed VCS

Distributed Version Control System (DVCS)

### Advantages:
- **Multiple repositories** can exist.
- Version control can be performed **locally**.
- No need for network connectivity.

### Examples:
- Mercurial (2005) *(Mozilla, Python, OpenOffice.org)*
- Bazaar (2005) *(Ubuntu, MySQL)*
- Git (2005) *(Linux Kernel, Debian, VLC, Android, Gnome, Qt)*
    
## Introduction to DVCS: Git

### History

- Git was created in **2005** to version the development of the Linux kernel.
- Designed as a **distributed version control system** (replacing BitKeeper).

### Context

- Widely used by projects: Linux Kernel, Debian, VLC, Android, Gnome, Qt, etc.
- Accessible via command-line interface.
- Graphical tools available: gitk, qgit.

## Core Principles of Git

- Git does **not store differences** between commits (unlike SVN).
- Instead, Git stores **snapshots** of the project's file hierarchy at each commit.
- These snapshots are based on **hierarchical structures of objects**.
- Git operations revolve around manipulating these objects.


## Hash
- Each object has a unique hash (SHA1).
- Files describing history are referenced by a 40-character encrypted object name (SHA1).

### Advantages
- Git identifies identical objects by comparing their hashes.
- The same content stored in different repositories will always have the same hash.

## Git Principles: Object States
- **Size**: The size of the content.
- **Content**: The actual data of the object.
- **Type**: Object types include "blob", "tree", "commit", "tag".

## Git Principles: Object Types
- **Blob**: Stores file data.
- **Tree**: References a list of other trees or blobs.
- **Commit**: Points to a single tree, representing the project at a specific point in time. Includes metadata like timestamp, author, and parent commits.
- **Tag**: Labels a specific commit for easy reference.

## Commit Representation
*(Git Community Book, p13)*  
![Commit Representation](image/lecture1/modele_obj1.png)

## Commit Structure
*(Git Community Book, p14)*  
![Commit Structure](image/lecture1/modele_obj2.png)

## Git Repository

- **.git directory**:  
  - Stores the project's history.  
  - Contains metadata for version control.  
  - Located at the root of the project.

![Git Repository Contents](image/lecture1/contenu_git.png)

## Working Directory

- Current version of project files.  
- Files are replaced or removed by Git during branch or version changes.

## Index

- **Staging Area**:  
  - Bridge between the working directory and the repository.  
  - Used to group changes for a single commit.  
- Only the **index content** is committed, not the working directory.
## Basic Commands

- `git init`: Initialize a Git repository.
- `git clone <repository>`: Clone a repository.
- `git status`: Check the status of the working directory and staging area.
- `git add <file>`: Stage changes for commit.
- `git commit`: Commit staged changes.

## Basic Commands (Continued)

- `git pull`: Update local repository from remote.
- `git push`: Push local commits to remote repository.
- `git log`: View commit history.
- `git checkout <hash>`: Switch to a specific commit using its SHA1 hash.
- `git branch <branchName>`: Create a new branch.

## Branches: Purpose

- Work on changes that diverge from the main branch or another branch.
- Isolate experimental developments.
- Avoid disrupting shared development efforts.
- Version parallel developments with the option to merge later.

## Branches: Commands

- `git branch` or `git checkout -b <branchName>`: Create a new branch.
- `git checkout <branchName>`: Switch to an existing branch.
- `git merge <branchName>`: Merge a branch into the current branch.
- `git branch -d <branchName>`: Delete a branch.
- `git branch`: List all branches and show the current branch.

## Conflict Management

- **Conflict:** Occurs during branch merging when two changes affect the same lines.

- **Resolution Steps:**
  1. Merge is paused.
  2. Conflict zones are marked in the file.
  3. Edit the file to resolve conflicts by choosing one version or combining changes.
  4. Verify and validate the resolution.
  5. Commit the resolved conflict.

## Correction Methods

- **Undo Changes:** Use `git reset` to discard modifications.
- **Amend Last Commit:** Use `git commit --amend` to modify the previous commit.
- **Branch-Based Correction:** Create a new branch from a specific version and work from there.
- **Rewrite History:** Use `git rebase` to edit commits and history.

### Warning

- **Rewriting History:** Interactive rebasing is risky. Only rewrite commits that haven't been pushed to a remote repository. Prefer branch-based corrections for safer handling.
    
## Centralized Collaboration

![Interactions with a centralized system](image/lecture1/CentralizedVCS.png)

## Decentralized with Central Repository

![Constrained interactions with a decentralized system](image/lecture1/DistributedVCS_withCentral.png)

## Fully Decentralized Collaboration

![Interactions with a decentralized system](image/lecture1/DistributedVCS_Complex.png)

## Best Practices for Collaborative Development

### Before Development

- Define a **developer charter**:
  - Naming conventions for files, functions, variables.
  - Standards for technical documentation and comments.
  - Indentation rules (tabs vs spaces).

- Establish a **version control strategy**.

### During Development

- Create **isolated commits** (one commit = one coherent change).
- Write **concise commit messages** (max 60 characters summarizing the change).
- Add detailed commit descriptions if necessary.
- **Regularly update** your working copy.
- **Share updates** with team members.

## Tools

### Useful Tools

- **Platforms**: GitHub, Bitbucket, GitLab.
- **Visualization Tools**: gitk, qgit.
- **Commit Editing Tools**: git gui.

## References

- [*The Git Community Book* (French version)](http://alx.github.io/gitbook/book.pdf)
- [Wikipedia: Git (Software)](http://en.wikipedia.org/wiki/Git_(software))
- [Tech Talk: Linus Torvalds on Git (YouTube)](http://www.youtube.com/watch?v=4XpnKHJAok8)
