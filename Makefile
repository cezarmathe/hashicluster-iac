# Makefile

# Machine image build to run.
BUILD ?= generic

# Machine image builder to use. Leave empty to run for all builders
BUILDER ?=
BUILDER_EXPANDED = $(shell \
if [[ ! -z "$(BUILDER)" ]]; then \
	printf "%s" "-only=$(BUILD).$(BUILDER).$(BUILD)" \
fi \
)

# Machine image build environment to use. This specifies which variables file
# to use.
BUILDER_ENV ?= default

# Default recipe.
default: help

# Build a machine image.
build:
	packer build \
		$(BUILDER_EXPANDED) \
		-var-file=build/$(BUILD)/$(BUILDER_ENV).pkrvars.hcl \
		build/$(BUILD)/$(BUILD).pkr.hcl
.PHONY: build

# Print the help section.
help:
	@echo hashicluster-iac/Makefile
	@echo
	@echo Available commands:
	@echo - build: build a machine image
.PHONY: help
