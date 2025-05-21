# How to build locally

## Installing mkdocs

This course uses mkdocs as a build system:

```bash
virtualenv ./venv
source ./venv/bin/activate
pip install mkdocs-jupyter nbconvert
```

## Building

```bash
# At the root level
mkdocs serve
```

## Slides

All files named "lecture*.md" will be treated as pandoc-style slides. They can be integrated in mkdocs like any other markdown file.
Alternatively, they can be converted to PDF by running

```bash
./build_all_slides.sh
```

Note that this requires both `pandoc` and `pdflatex` to be installed on your system.