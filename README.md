# Trickling_up

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://Martin-Bernstein.github.io/Trickling_up.jl/dev/)
[![Build Status](https://github.com/Martin-Bernstein/Trickling_up.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Martin-Bernstein/Trickling_up.jl/actions/workflows/CI.yml?query=branch%3Amain)


The goal of this replication kit is to reproduce the main results from Auclert et. al., 2023, "The trickling up of Excess Savings." The original replication kit is in the directory `auclert_original`. I replicate Figures 1 and 4 (figures 2 and 3 are author illustrations) and Table 1 from the manuscript (`auclert_original/tricklingup.pdf`). The original scripts that I translate into Julia are `auclert_original/replication/Figure1.py`, `auclert_original/ct_re_solver.py`, and `auclert_original/trickling up model.py`.

There are two ways to run my replication: from this repository, using software installed on your machine; or via a Docker container. (If you are unfamiliar with Docker, replicating via the Docker container allows you to run the project on a virtual machine configured with all of the necessary software.)

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
3. The above will output the table and figures to `/path/to/pkg/output`. You can check that the files `figure1.pdf`,`figure4.pdf`, `table1.tex`, and `table1.pdf` have been newly written into the `output` folder, and that they correspond to the figures in the original paper (the manuscript is at `auclert_original/tricklingup.pdf`).

# Replicating with the docker container

## Software requirements
1. `Docker` in order to access and run the container. You can download the latest version of Docker desktop [here](https://www.docker.com/products/docker-desktop/).

## Replication using the command line

1. "Pull" the Docker container from DockerHub:
    ```
    docker pull martinbernstein/trickling-up-docker:latest
    ```
2. Run the Docker container. The Docker container will write tables and figures to an output folder. You can specify where on your machine you would like this output folder to live, by replacing `/path/to/desired/output` with your desired file path. The rest of the code should be typed in as is below.
    ```
    docker run -it --rm -v /path/to/desired/outputfolder:/app/output martinbernstein/trickling-up-docker
    ```
3. Check that the figures and tables in your `/path/to/desired/outputfolder` are as in the original manuscript.

The one downside to this replication technique is that the container is entirely opaque: you cannot see what I am doing to replicate the paper. You can look inside the contained by instead using Docker desktop.

## Replication using Docker desktop
1. Open Docker desktop. Search for trickling-up-docker in the search bar at the top (which you can also open with command-K). Search in the "images" tab.
2. Select the `martinbernstein/trickling-up-docker` image. Click `Run`. Under optional settings, you can optionally name the container and assign a local host; click `Run` again when done.
3. The container will begin to run. The `Logs` tab will open by default. It may show errors; this does not mean that the container is not running successfully. Navigate instead to the `Files` tab.
4. Open the `app` directory in the `Files` tab. Here, you can view the code contained in the Docker container (and verify that it is the same as the code in this repository).
5. The replicated tables and figures will be in the `/app/output` directory. You can verify that the "Last modified" will be the time at which you ran the container. To view these files, control-click on them and select `save`. You can then save the replication output and verify that it matches the manuscript.
