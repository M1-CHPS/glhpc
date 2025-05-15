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