FROM continuumio/miniconda


# Metadata
LABEL description="Docker image containing all dependencies required to run Genetic Correlation (LDSC version) Nextflow "

# Maintainer
LABEL Ibrahim Bashe Farah <ibrahim@shivom.io>

# Install python dependencies 
RUN conda env create --file environment.yml
RUN source activate  LDSC