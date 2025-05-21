#!/usr/bin/bash

set -e
set -o pipefail

PDF_ENGINE="pdflatex"
OUTPUT_DIR=$(realpath ./slides)
mkdir -p $OUTPUT_DIR

# We must CD into docs so we can retrieve the images / ressources correctly
cd ./docs

echo "Searching for lecture*.md files..."

find . -type f -name "lecture*.md" | while read -r src; do
    base=$(basename "${src%.md}")
    pdf="${OUTPUT_DIR}/${base}.pdf"

    echo "Converting $src -> $pdf"

    pandoc "$src" -t beamer -o "$pdf" \
        -V theme=metropolis \
        --pdf-engine="$PDF_ENGINE" \
        -V colortheme=orchid \
        -V fonttheme=structurebold \

done

echo "All lecture PDFs generated."