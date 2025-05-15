# Bash Cheatsheet

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