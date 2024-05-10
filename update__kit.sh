#!/bin/bash

set -e

# Create the demosystem files
bndbuild page0.o page1_without_parts.o

# copy them to the kit
cp page0.o page1_without_parts.o kit
cp demosystem/public_macros.asm kit