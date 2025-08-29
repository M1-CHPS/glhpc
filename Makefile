PDF_ENGINE = xelatex
OUTPUT_DIR = slides
DOCS_DIR = docs
PANDOC_STYLES = pandoc-styles
PREAMBLE = $(PANDOC_STYLES)/preamble.tex
LUA_FILTER = $(PANDOC_STYLES)/remove_mkdocs_only.lua
THEME = metropolis
COLORTHEME = orchid
FONTSIZE = 9pt
MAINFONT = Comfortaa Regular
MONOFONT = Latin Modern Mono

LECTURE_MD := $(wildcard $(DOCS_DIR)/lecture*.md)
LECTURE_PDF := $(patsubst $(DOCS_DIR)/%.md,$(OUTPUT_DIR)/%.pdf,$(LECTURE_MD))

.PHONY: all clean

all: $(LECTURE_PDF)

$(OUTPUT_DIR)/%.pdf: $(DOCS_DIR)/%.md $(PREAMBLE) $(LUA_FILTER)
	@mkdir -p $(OUTPUT_DIR)
	@echo "Converting $< -> $@"
	pandoc "$<" -t beamer -o "$@" \
	  --pdf-engine=$(PDF_ENGINE) \
	  -H $(PREAMBLE) \
	  --resource-path=$(DOCS_DIR):$(PANDOC_STYLES) \
	  -V theme=$(THEME) \
	  -V colortheme=$(COLORTHEME) \
	  --listings \
	  -V lang=en \
	  -V fontsize=$(FONTSIZE) \
	  -V mainfont="$(MAINFONT)" \
	  -V monofont="$(MONOFONT)" \
	  --lua-filter=$(LUA_FILTER)

clean:
	rm -f $(OUTPUT_DIR)/lecture*.pdf


