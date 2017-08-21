# This Dockerfile is based on the dockerfile 'fmriprep' from the Poldrack
# Lab (https://github.com/poldracklab/fmriprep). The jupyter notebook foundation
# is based on jupyter/docker-stacks's base-notebook.
#
# This means that the same copyrights apply to this Dockerfile, as they do for
# the above mentioned dockerfiles. For more information see:
# https://github.com/miykael/nipype_env

FROM miykael/nipype_level3
MAINTAINER Michael Notter <michaelnotter@hotmail.com>

#-------------------------
# Your Docker Instructions
#-------------------------

# <-- Change the level above (under FROM) -->

# <--  Put your docker instructions here  -->


#----------------------------
# Download Tutorial Notebooks
#----------------------------
USER root

# Get notebooks from miykael/nipype_tutorial
RUN wget -q -P /home/$NB_USER/work \
    https://github.com/miykael/nipype_tutorial/archive/master.zip --no-check-certificate && \
    unzip -q /home/$NB_USER/work/master.zip -d /home/$NB_USER/work/ && \
    cp /home/$NB_USER/work/nipype_tutorial-master/index.ipynb /home/$NB_USER/work/index.ipynb && \
    cp -r /home/$NB_USER/work/nipype_tutorial-master/notebooks /home/$NB_USER/work/notebooks && \
    cp -r /home/$NB_USER/work/nipype_tutorial-master/static /home/$NB_USER/work/static && \
    rm -rf /home/$NB_USER/work/master.zip /home/$NB_USER/work/nipype_tutorial-master


#--------------------------------------------------
# Download scaffold of tutorial dataset via datalad
#--------------------------------------------------
RUN cd /home/$NB_USER/work && \
    datalad install -r ///workshops/nih-2017/ds000114


#----------------------------------------------------------
# Create /data and /output folder and give power to NB_USER
#----------------------------------------------------------
USER root
EXPOSE 8888
RUN mkdir -p /data /output /tutorial
RUN chown -R $NB_USER:users /home/$NB_USER && \
    chown -R $NB_USER:users /data && \
    chown -R $NB_USER:users /output && \
    chown -R $NB_USER:users /tutorial
WORKDIR /tutorial

# Set default user to NB_USER
USER $NB_USER
