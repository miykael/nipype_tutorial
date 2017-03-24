# This Dockerfile is based on the dockerfile 'fmriprep' from the Poldrack
# Lab (https://github.com/poldracklab/fmriprep). The jupyter notebook foundation
# is based on jupyter/docker-stacks's base-notebook.
#
# This means that the same copyrights apply to this Dockerfile, as they do for
# the above mentioned dockerfiles. For more information see:
# https://github.com/miykael/nipype_env

FROM miykael/nipype_level1
MAINTAINER Michael Notter <michaelnotter@hotmail.com>

#-------------------------
# Your Docker Instructions
#-------------------------

# <-- Change the level above (under FROM) -->

# <--  Put your docker instructions here  -->


#------------------------------------------
# Copy Tutorial Notebooks into Docker Image
#------------------------------------------
USER root
COPY index.ipynb /home/$NB_USER/work/index.ipynb
COPY notebooks /home/$NB_USER/work/notebooks
COPY static /home/$NB_USER/work/static


#------------------------------------------------
# Create /output folder and give power to NB_USER
#------------------------------------------------
USER root
RUN mkdir -p /output
RUN chown -R $NB_USER:users /home/$NB_USER && \
    chown -R $NB_USER:users /output

# Set default user to NB_USER
USER $NB_USER

RUN pip install pybids
