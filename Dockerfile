# Use an official Julia runtime as a parent image
FROM julia:1.9-bullseye

# Set the working directory in the container to /app
WORKDIR /app

# Install LaTeX tools
RUN apt-get update && apt-get install -y \
    texlive-latex-recommended \
    latexmk \
    && rm -rf /var/lib/apt/lists/*


# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed packages specified in Project.toml and Manifest.toml
RUN julia --project=/app -e 'using Pkg; Pkg.instantiate(); Pkg.precompile()'

# Make port 80 available to the world outside this container
EXPOSE 80

# Run app/run.jl when the container launches
CMD ["julia", "--project=/app", "run.jl"]
