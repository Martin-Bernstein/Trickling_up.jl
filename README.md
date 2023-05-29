# Trickling_up

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://Martin-Bernstein.github.io/Trickling_up.jl/dev/)
[![Build Status](https://github.com/Martin-Bernstein/Trickling_up.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Martin-Bernstein/Trickling_up.jl/actions/workflows/CI.yml?query=branch%3Amain)


The goal of this replication kit is to reproduce the main results from Auclert et. al., 2023, "The trickling up of Excess Savings." There are two ways to run this replication: from this repository, using software installed on your machine; or via a Docker container. (If you are unfamiliar with Docker, replicating via the Docker container allows you to run the project on a virtual machine configured with all of the necessary software for replication.)

This readme will explain steps first for replication using this repository, and second using the docker container.

# Replicating from this repository

## Software requirements
1. `julia` (version 1.9 was used for this) which can be downloaded [here](https://julialang.org/downloads/)
2. `latexmk` is needed to compile .tex files produced during replication into .pdf files. This is part of the standard TeXLive distribution, available [here](https://www.tug.org/texlive/)

## Replication instructions

1. Download (or clone, for git users) this repository to your computer.
2. Open terminal and navigate to the directory where you have placed this repository. Calling that `/path/to/pkg`, run the following commands:
```
julia               #Start the Julia REPL
cd("/path/to/pkg")  #Navigate to the location of the package repository on your machine
using Pkg           
Pkg.activate(".")   #Activate the package
include("run.jl")   #Commands in the run.jl file will execute replication
```
3. The above will output the table and figures to `/path/to/pkg/output`. You can check that the files `figure4.pdf`, `table1.tex`, and `table1.pdf` have been newly written into the `output` folder, and that they correspond to the figures in the original paper (the manuscript is at `Auclert_original.pdf`)

# Replicating with the docker container
