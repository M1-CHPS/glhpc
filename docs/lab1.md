---
lab: true
description: Setting up linux, the shell, and Git for version control.
---

# Lab 1 - Prerequisites - Linux, the shell, Git

<hr class="gradient" />

### Objectives

In this lab, you will get familiar with the very basics of using the Linux shell, installing and using a code editor, and setting up git.

The final section of this lab will have you combine all these tools to set up a simple project for a Hello World program in C.

---

## 1 - Linux

[Linux](https://en.wikipedia.org/wiki/Linux) is a family of Operating Systems (like Windows or MacOS) that are suited for programming. Most high-performance clusters will run a version of Linux, and as such **it is mandatory that you learn how to use it.**

If you have a personal laptop, we **highly** recommend you set up Linux (or MacOS) on it. Alternatively, you can use [Docker](https://hub.docker.com/_/ubuntu/) or a [virtual machine](https://www.virtualbox.org/) on Windows, but note that this is highly impractical. Lastly, you can set up and use WSL.

!!! tip
    The university may be able to lend laptops while you're on-site, but you likely won't be able to bring them home for assignments.

!!! Danger
    Most of the labs weren't tested on Mac. You will probably encounter OS-related issues, especially on newer ARM-based laptops.

<div class="optional-section box-section" markdown>

### 1. <span class="toc-title"> (Optional) </span> Installing Fedora

If you want to install Linux on your personal laptop but aren’t sure where to start, you can follow [these instructions](annex/install_fedora.md).

[**Fedora**](https://getfedora.org/) is a modern, open-source Linux distribution sponsored by Red Hat. It ships with the GNOME 3 desktop environment by default and uses `dnf` as its package manager.

If you're new to Linux and want something simple to use, Fedora is a great place to start.

Otherwise, Ubuntu or Debian are great options.
</div>

<hr class="gradient" />

## 2 - The linux Shell and Bash

On Windows/MacOS, you most likely use the file manager or other graphical interfaces to interact with your computer. On linux however, we use the **Linux Shell** via a terminal/console.

<figure markdown="span">
  ![The Shell](image/lab1/the_shell.png){ style="max-width: 80%; height: auto;" }
  <figcaption>The Konsole terminal on a Fedora KDE setup, running a Zsh shell.
  </figcaption>
</figure>

The shell is a very powerful tool to interact with your computer through **commands** instead of graphical interfaces.

!!! Warning
    To copy/paste in your terminal you must use `CTRL+SHIFT+C` and `CTRL+SHIFT+V`. Pressing
    `CTRL+C` will KILL (stop) the current command.

    If you press `CTRL+S`, the terminal is put on hold. Nothing will display anymore. Press `CTRL+Q` to re-enable your terminal

---

### 1. Basic Exercices

#### a) First, try starting a new terminal

Look for an app called `terminal`, `console` or even `konsole`. In some linux distribution, `CTRL+ALT+T` will open a new terminal.

- A `terminal` is the graphical application displaying the text.
- A `shell` is the underlying program that interprets and executes commands that you provide. By default, your shell will probably be `bash`, which is one of the most basic shells available. All shells serve the same function, but some come with plugins and other tools to make your life easier.

#### b) Try inputing the following commands. What does the `ls` command do ?

```bash title="ls"
# Don't worry about this yet
cd ~
ls
ls -lh
ls -lah
```

All shell command take the form `<cmd> (<flag>) <argument>`. Flags (starting with either `-` or `--` depending on the command) are used to change the behavior of the command, e.g. add colors, change the output format, etc.


#### c) Run the following commands **step-by-step** and try to understand what is happening:
```bash title="mkdir and moving around the filesystem"
ls
mkdir glhpc
ls
cd ./glhpc
ls
mkdir lab1
cd ./lab1
ls
```
What does `mkdir` do ? `cd` ?

#### d) Based on the previous question, could you give a definition for the term "Current Working Directory" (CWD) ?
Execute the following to confirm your definition:

```bash title="Print Working Directory"
pwd
```

#### e) Execute the following step-by-step:
```bash title="Echoing in files"
echo "Bonjour"
echo "Bonjour, mon username est $USER et mon home est dans $HOME"
echo "Bonjour" > bonjour.txt
ls
cat ./bonjour.txt
ls -lah > ./bonjour.txt
cat ./bonjour.txt
```

* What does `echo` do ? What is your `USER` and your `HOME` ?
* What does the `>` operator do ? (Tips: Did you see the output of this command in your terminal ?)
* What does `cat` do ?

#### f) Run the following commands

`USER` and `HOME` are "environment variables", they are used to store properties/attributes to be reused later.
For example, the `HOME` environment variable stores the home directory of the user. Environment variables are accesed by prefixing a `$` sign.

```bash title="One time use env. var"
MY_VAR=test echo "my var is $MY_VAR"
echo "my var is $MY_VAR"
```
The second line should print an empty line: the format `<var>=<value> <cmd> ...` is used to define environment variables that only store their values for the duration of the following command.

```bash title="Exporting env. vars"
export MY_VAR=test
echo $MY_VAR
```

Exported env. variables keep their values for the **lifetime of the current shell session**: closing your terminal will destroy all variables.

!!! Tip
    When starting a new shell, the file `~/.bashrc` (or `~/.zshrc`) is "sourced" (loaded) to setup the environment. 

    You can append `export` lines at the end of these file, which will then be run everytime you start a new terminal.

#### g) Execute the following:
```bash title="More moving around the filesystem"
cd ~/glhpc
ls -lh
mkdir lab1
```

* Did the last command (`mkdir lab1`) work ? Why not ?
* What does `cd ..` do ? What does `..` mean ? 
* Execute these commands: `pwd`, `realpath .`, `realpath ..`, `realpath ~/glhpc/lab1/..`


#### h) Run the following:
```bash
man mkdir
```

What do you see ? Try to find the `mkdir` flag to disable errors on existing folders, so that `mkdir lab1` runs succesfully.

Press the `q` key to exit `man`. 

!!! tip
    What you just saw is called a `man page`. `man` is short for `manual`. It's an offline documentation that is always available on all shells. 
    Some tools also provide `man pages` when installed, so that you can arlways search for documentation. You can even search `man man` !

    If you're ever stuck on a problem/bug (and you will), you should always read the documentation, or the man pages, for solutions. Googling a bug or an error message is not cheating. This is commonly referred to as `Read The F*cking Manual` (RTFM).

!!! tip
    Note that you do not have to `cd` in a directory to interact with it:
    ```bash title="Running command through directories"
    mkdir -p ./lab1/test01
    ls ./lab1/test01
    echo "Je suis un fichier" > ./lab1/test01/test.txt
    ```

    This is significantly faster than doing
    ```bash
    cd ./lab1
    cd ./test01
    ls
    echo "Je suis un fichier" ./test.txt
    cd ..
    cd ..
    ```

---

### 2. More Exercises

#### a) Find what `~` is a shortcut for
```bash
cd ~
```

#### b) Create the following file structure using only your terminal:
```
exo7/
    readme.md # With the text "Bonjour"
    dossier0/
        test.txt  # With the text "test0"
    dossier1/
        test.txt # With the text "test1"
```

Where `exo7/`, `dossier0/` and `dossier1/` are folders/directories, and the two `test.txt` are textual files.
This directory should be located inside `~/glhpc/lab1/exo7`.

If the `tree` command is available on your system, you should get the following output:

<figure markdown="span">
  ![Final output](image/lab1/tree_exo7.png){ style="max-width: 80%; height: auto;" }
  <figcaption>The newly created folders and files.
  </figcaption>
</figure>

#### c) Finally, run the following from `~/glhpc/lab1`

```bash title="Recursive cp of a directory"
cp -r ./exo7 ./exo7_copy
```

What does `cp` do ? Why do we use the `-r` flag ?

#### d) Ensure the copy worked:

```bash title="ls with target"
ls -lh ./exo7_copy
```

#### e) Deleting the copied folder

The `rm` command is used to remove files, while the `rmdir` command is used to delete **empty folders**. In order to delete a folder, and all the files it contains, we must use the `--force` and `--recursive` flags, also known as `rm -rf`.

Try the following:
```bash title="Erasing (permanently) the copied folder"
rm -rf ./exo7_copy
```

!!! Danger
    `rm -rf` is definitive: there is no way to recover your files after this. No trashbin. If you delete an important folder, **it is gone forever**. 

    **You should always be very careful when doing this.**

    **Thought experiment**: what would happen if you were to run `rm -rf /`, where `/` is the root of your filesystem ? In modern shells, it will probably show an error, or ask for confirmation, but **yes, this could instantly erase all of your files, including your operating system, and crash your computer.**

---

### 3. Cheatsheet 🐍 

| **Goal**                     | **Command**           | **Variants**                                                                       |
|------------------------------|-----------------------|------------------------------------------------------------------------------------|
| **Create a directory**       | `mkdir <path>`        | `mkdir -p <path>` to ignore errors                                                 |
| **Go inside a directory**    | `cd <path>`           | `cd ..` to go up one level, `cd ~` to go to your home                              |
| **List all files**           | `ls (<path>)`         | `ls -lah (<path>)` for pretty print with human-readable numbers. Show hidden files |
| **Print cwd**                | `pwd`                 |                                                                                    |
| **Convert to absolute path** | `realpath (<path>)`   |                                                                                    |
| **Print text**               | `echo <text>`         | `echo $<VARIABLE>` to print a variable                                             |
| **Redirect output to file**  | `>`                   | Example: `echo "Bonjour" > test.txt`                                               |
| **Print file content**       | `cat <path>`          | For big files: `less <path>`                                                       |
| **Delete a file**            | `rm <path>`           |                                                                                    |
| **Delete a directory**       | `rmdir <path>`        | Delete a non empty directory `rm -rf <path>`                                       |
| **Create empty file**        | `touch <path>`        |                                                                                    |
| **Copy a file**              | `cp <input> <output>` | `cp -r <input> <output>` to copy folders recursively                               |

---

<div class="goingfurther-section box-section" markdown>

### 4. <span class="toc-title"> (Going-Further)</span> Upgrading bash

While powerful, `bash` is a very basic shell. Some shells like `fish` or `oh-my-zsh` come with extensions/plugins that can significantly improve your workflow, with auto-completion, coloring, suggestions and many other.

In the near future, **you will spend a lot of time** in your programming environment. Taking a few hours making it more practical or comfortable is a worthwhile investement.

A minimalist `oh-my-zsh` setup is described [here](annex/oh-my-zsh.md). `fish` is very simple to install and pretty powerful, but I do not recommend it due to some `bash` incompatibilities. 

</div>

<hr class="gradient" />

<div class="optional-section box-section" markdown>


## 3 - <span class="toc-title"> (Optional) </span> Code Editor (VSCode)

We are now going to see the second most critical tool you will use during the Master, second only to the shell: a code editor. Modern code editors allow you to open source files, images, pdf, or even videos. You use your editor to create programs, and the shell to execute them. 

<figure markdown="span">
  ![vscode](image/lab1/vscode.png){ style="max-width: 80%; height: auto;" }
  <figcaption>Visual Studio Code (VSCode) Example
  </figcaption>
</figure>

As a starting point, you should download `VSCode` which will cover most of your needs in the future. Do NOT listen to your obnoxious classmates telling you to "just use vim". They cannot be saved.


### 1. Installation:

#### a) Direct download

Go to the [VSCode Website](https://code.visualstudio.com/download) and select the option matching your OS. For Fedora, click on the `.rpm` button. 

Then double click on the downloaded `.rpm` file to automatically install `VSCode`. 

You can achieve the same effect using:
```bash title="Fedora"
sudo dnf install ./code-1.99.3-1744761644.el8.x86_64.rpm
```

#### b) Snap install

Snap is a very helpful application to automatically install, update, and manage third-party tools (VSCode, pycharm, Spotify, etc.)

```bash title="Fedora"
sudo dnf install snap
snap install code
```

#### c) Usage

Using your shell navigate to the directory you wish to open in VSCode:


```bash
cd ./glhpc/
code .
```

From there, try creating a file, installing extensions (Python, C++, cmake, etc.) and familiarize yourself with the shortcuts.

!!! tip
    You can also open a terminal directly inside VSCode ! 
    
    The shortcut should be `CTRL+J`, but you can always use the terminal menu.

</div>

<hr class="gradient" />


## 4 - Getting ready for git

A critical part of programming is called "versioning" or "Version Control System" (VCS). This answers the following questions:

- How can I share my code with my colleagues / classmates / friends / everyone ?
- How can I keep a history of the different versions of my code ? Say `version 1.0`, `v2.0`, `v3.0.1.alpha-prelease`, etc.
- How can multiple people work together on the same project ?

We will dive into git later. For now, do the following:

#### a) Create a [Github account](https://github.com/signup) if you don't already have one. 

You may wish to keep this account after the master: you should use your personal email so you won't lose acces to it.

You should setup two factor authentication (2FA) ASAP.

#### b) Setting up SSH keys

!!! Danger
    **If you are on a laptop lent by the university, skip this question.** 
    SSH-keys are stored system-wide: other students will be able to access your secret key(s) and you github account if you do this. 
    
    Instead, you should:

    - Install VSCode and connect to GitHub, then push from github. Disconnect your account before returning your laptop
    - Generate SSH-keys on a USB-Drive, and use these keys to pull/push from GitHub so that your keys never leave the drive.
        - Use `GIT_SSH_COMMAND="ssh -i /media/usb/github_key -o IdentitiesOnly=yes" git push` and replace `/media/usb/github_key` by the path to your SSH-Keys on your USB-Drive

You should follow the [official guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) on how to generate and add an ssh key to your github account.

<hr class="gradient" />

## 5 - First C Project

### 0. Pulling from github Classroom

You will receive a link to GitHub classroom during the lab session. Accept the invite and click on your name. This will automatically create a `glhpc-<name>-lab1 `repository on GitHub for you.

First, clone this repository:

```bash title="Cloning a GitHub repository"
git clone <ssh_url> 
```

**You should use the SSH url of your repo (Click on the green "code" button on GitHub and on SSH).**
You should see a simple `Readme.md` and `.gitignore` files inside the newly created folder.

### 1. Creating the project

#### a) Create the following file structure:

```title="Project file structure"
glhpc-lab1/
    first_c_project/
        build.sh # Empty text file
        src/
            main.c # Empty text file
```

Try to do this only using the shell. If you're using **VSCode** you can `cd` into `first_c_project` and run `code .`
**Make sure to create this structure inside the cloned repo.**

!!! Tip
    To create an empty file, you can use the `touch <file>` command instead of `echo`.


#### b) Modify `main.c` so that it contains:

```c title="main.c"
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char** argv) {
    printf("Hello World !");
    return 0;
}
```

??? "Explanation of the code"
    The first two lines are preprocessor commands: they import the standard input/output library `stdio.h` as well as the standard C library `stdlib.h`.
    These two libraries contain the core functions of the C language.

    The line `int main(int argc, char** argv)` defines the `main` function:
    
    - It returns an integer (`int`)
    - `int argc` (The first argument) is the number of arguments/flags passed to the programs
    - `char** argv` is an array of characters chains (strings) that stores the arguments themselves

    `printf(...)` is used to print to the terminal.

    `return 0;` returns the value `0` at the end of the function. This signals to the shell that everything went well and the program completed succesfully.
    Returning 1 would signal an error.

---

### 2. Setup git

Please refer to Lecture 1 for all the git commands you will need in this section.

#### a) Run `git status`, then stage all files from `first_c_project` in git.
#### b) Create a first commit with the message "My first commit"

You should use the command `git commit -m "<message>"` or git may open nano/vim for you to edit the commit message, which may be confusing.

#### c) Ensure the commit worked:

`git log` should display the previous commit, and `git status` should no longer display the content of `first_c_project`. Feel free to commit files from the previous exercises of the lab if you want.

---

### 3. Compiling and running C code

We will now try to run our first program, but before that we need to install a few tools.

#### a) Install GCC

First, we need a *C compiler* to transform the `main.c` file into an executable. We will see in future courses what this does.

For now, install the following packages:

=== "Fedora"
    ```sh
    sudo dnf install gcc glibc-devel make gdb valgrind
    ```
    
=== "Ubuntu"
    ```sh
    sudo apt update
    sudo apt install gcc libc6-dev make gdb valgrind
    ```

#### b) Check GCC is working

Run the following:

```sh
gcc --version
```
```title="Expected output"
gcc (GCC) 14.3.1 20250808 (Red Hat 14.3.1-3)
Copyright (C) 2024 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```

!!! Note
    Do not worry if you have a different compiler version that the one shown here, it should not matter for this course.

#### c) Compiling `main.c`

You can now compile your first program by running

```bash title="First compilation"
gcc src/main.c -o main -g 
```

You should see that a `main` file has been created for you.

#### d) Run main

Run the program by using `./main`

---

### 4. First compilation script

#### a) Create a `build.sh` script that contains the compilation command.

The `build.sh` script should act as a simple way to run the compiler instead of having to write the command by hand everytime.

#### b) Try to run `./build.sh`. Does it work ?

Linux uses a concept of **file permissions**: some files can be read, written to, executed, or a mix of the previous.
These permissions are user dependent: you are allowed to read your own files, but this privilege should not extend to other users.

Run the following:

```sh title="Checking permissions"
ls -lah
```

```sh title="Expected output"
-rw-r--r--.  1 user user   0 Aug 26 9:48 build.sh
```

`rw-r--r--` can be read as: 

- The user can Read and Write
- The group can Read
- Others can Read

#### c) Make `build.sh` executable

Run the following:

```sh title="Adding permissions"
chmod +x ./build.sh
```

`chmod` is a command to modify the permissions of a file. `x` designates the eXecution permission, so this command can be read as *add execution permission to build.sh*.

You should see that the file now has permissions `rwxr-xr-x`. This can be read as:

- The user can Read, Write, and eXecute
- The Group can Read and eXecute
- Others can Read and eXecute


#### d) Restrict permissions so that only you (the user) can read, write, and execute build.sh. Neither the group nor others should have any permissions.

In binary:

- `rwx` = 111 = 7
- `r-x` = 101 = 5
- `r--` = 100 = 4

One can write `chmod 444 ./build.sh` which translates to `r--r--r--` (100 100 100). 

Use this to find the command needed to only give permissions to yourself.

---

### 5. Uploading to GitHub

#### a) Commit all changes you've made so far to git

!!! Tip
    Git is recursive: it doesn't matter whether you run the git commands from `lab1` or `first_c_project`: git knows whether the `cwd` is contained inside a git repository.

#### b) Push on GitHub

The first time you push on the repository, git might:

- Ask you to setup your email/username: Follow git instructions and make sure to use the same as the one you've used on GitHub.
- Set the upstream branch using `--set-upstream`: Follow git instructions

!!! Danger
    If you are using a laptop lent by the university, **do not run `git config --global add user.email`** or you will set the GitHub email for the entire laptop. This would allow other students to push using your GitHub account, or you may see other people pushing to your own repository.

    Simply do `git config add user.email <email>` **inside root folder of the git repository**.

<hr class="gradient" />

<div class="optional-section box-section" markdown>

## 3 - <span class="toc-title"> (Optional) </span> NBody 3D

If you finish the lab early and have time left, try implementing a simple 3D N-Body simulation instead of the previous `Hello World!`. For simplicity, assume all particles have the same mass and only consider gravity as the acting force. 

</div>

<hr class="gradient" />

<div class="summary-section box-section" markdown>

<h2 class="hidden-title"> 5 - Summary</h2>

Upon completing this first lab, you should:

- [x] Have a working programming environment
- [x] Know how to navigate the file system with the shell
- [x] Know how to use basic file operations
- [x] Know how to use VSCode to write and edit files
- [x] Be ready to use git with Github

</div>