# Trickling_up

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://Martin-Bernstein.github.io/Trickling_up.jl/dev/)
[![Build Status](https://github.com/Martin-Bernstein/Trickling_up.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Martin-Bernstein/Trickling_up.jl/actions/workflows/CI.yml?query=branch%3Amain)


The goal of this replication kit is to reproduce the main results from Auclert et. al., 2023, "The trickling up of Excess Savings." The original replication kit is in the directory `auclertoriginal`. I replicate Figures 1 and 4 (figures 2 and 3 are author illustrations) and Table 1 from the manuscript (`auclertoriginal/tricklingup.pdf`). 

The original scripts that I translate into Julia are `auclertoriginal/replication/Figure1.py`, `auclertoriginal/ct_re_solver.py`, and `auclertoriginal/trickling up model.py`.

There are two ways to run my replication: from this repository, using software installed on your machine; or via a Docker container. (If you are unfamiliar with Docker, replicating via the Docker container allows you to run the project on a virtual machine configured with all of the necessary software.)

This readme will explain steps first for replication using this repository, and second using the docker container.

# Replicating from this repository

## Software requirements
1. `julia` (version 1.9 was used for this) which can be downloaded [here](https://julialang.org/downloads/)
2. `latexmk` is needed to compile .tex files produced during replication into .pdf files. This is part of the standard TeXLive distribution, available [here](https://www.tug.org/texlive/)
3. Replication should work on recent mac and windows OS. I conducted replication on an M1-chip mac OS 12.6.3; as the green `passing` badge above shows (click on it for more), the package also compiles and runs successfully on the latest intel-chip macs and on the latest windows.

## Replication instructions

1. Download (or clone, for git users) this repository to your computer.
2. Open a command line interface (terminal) and navigate to the directory where you have placed this repository. Say you have placed this repository in `/path/to/pkg` – then type and run the following commands in your terminal:
```
julia               #Start the Julia REPL
cd("/path/to/pkg")  #Navigate to the location of the package repository on your machine
using Pkg           
Pkg.activate(".")   #Activate the package
include("run.jl")   #Commands in the run.jl file will execute replication
```
3. The above will output the table and figures to `/path/to/pkg/output`. You can check that the files `figure1.pdf`,`figure4.pdf`, `table1.tex`, and `table1.pdf` have been newly written into the `output` folder, and that they correspond to the figures in the original paper (the manuscript is at `auclertoriginal/tricklingup.pdf`).

# Replicating with the docker container
The docker image for this project is available on DockerHub and is called martinbernstein/trickling-up-docker. The steps below describe how to run a contained from this project and view its output. (If you are familiar with Docker, the `Dockerfile` in this repository was used to construct the Docker image.)

## Software requirements
1. `Docker` in order to access and run the container. You can download the latest version of Docker desktop [here](https://www.docker.com/products/docker-desktop/).

## Replication using the command line

1. "Pull" the Docker container from DockerHub: in a terminal, run
    ```
    docker pull martinbernstein/trickling-up-docker:latest
    ```
2. Run the Docker container by typing the code below into terminal. The Docker container will write tables and figures to an output folder. You can specify where on your machine you would like this output folder to live, by replacing `/path/to/desired/output` with your desired file path. The rest of the code should be typed in as is:

    ```
    docker run -it --rm -v /path/to/desired/outputfolder:/app/output martinbernstein/trickling-up-docker
    ```

Errors may appear in your console; these are because the compilation of the .tex tables is leading the Docker container to attempt to open the pdfs, which it cannot do. Ignore these errors, they do not affect replication.

3. Check that the figures and tables in your `/path/to/desired/outputfolder` are as in the original manuscript.

The one downside to this replication technique is that the container is entirely opaque: you cannot see what I am doing to replicate the paper. You can look inside the container by instead using Docker desktop, following the steps below.

## Replication using Docker desktop
1. Open Docker desktop. Search for trickling-up-docker in the search bar at the top (which you can also open with command-K). Search in the "images" tab.
2. Select the `martinbernstein/trickling-up-docker` image. Click `Run`. Under optional settings, you can optionally name the container and assign a local host; click `Run` again when done.
3. The container will begin to run. The `Logs` tab will open by default. It may show errors; this does not mean that the container is not running successfully. Navigate instead to the `Files` tab.
4. Open the `app` directory in the `Files` tab. Here, you can view the code contained in the Docker container (i.e., the `.jl` files in this directory). You can verify that they are the same as the code in this repository.
5. Once the container has run, replicated tables and figures will be in the `/app/output` directory. You can verify that the "Last modified" will be the time at which you ran the container. To view these files, control-click on them and select `save`. You can then save the replication output and verify that it matches the manuscript (which is in `auclertoriginal/tricklingup.pdf`).
