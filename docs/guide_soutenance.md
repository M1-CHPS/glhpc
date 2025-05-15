# Graded Project

??? tip "Submission Checklist"
    - Your archive is named `nom_prenom.tar.gz`
    - It contains a folder `nom_prenom/`
    - You included `build.sh`, `run.sh`, and your code in `src/`
    - Your report is named `nom_prenom.pdf`
    - No binaries or compiled files are included
    - You submitted a GitHub repo link in the email


## 0 - Instructions

You are to provide a short report, between 3-5 pages, answering the subject below. The submission deadline will be provided via email during the semester.

### 0.1) Submission guideline

!!! danger
    You must follow these submission guidelines exactly. Failure to do so may result in your project not being graded and defaulting to the second exam session.

    - Send, by email, a .tar.gz file named `nom_prenom.tar.gz`
        * You can create it by using:
        ```bash
        tar -czvf nom_prenom.tar.gz ./nom_prenom
        ```
    - Your project **must follow** the directory structure below:
        ```
        nom_prenom/
            build.sh # Script to build your project (This can call make or cmake, etc.)
            run.sh   # Script to run your project
            src/
                # All of your .c and .h files go here
            scripts/
                # All of your analysis or bash scripts go here
            nom_prenom.pdf # Your report
        ```
    - Create a **public** github repository containing your code, and send the link along with the archive.
    - Do **not** include any binaries or compiled files: no `.o`, `.a`, `.so`, or executables.
    - **Deadline policy:** Submissions after the deadline will incur a penalty of **-1 point per 5 minutes**.