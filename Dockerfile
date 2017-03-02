# This Dockerfile is based on the dockerfile 'fmriprep' from the Poldrack
# Lab (https://github.com/poldracklab/fmriprep).
#
# This means that the same copyrights apply to this Dockerfile, as they do for
# the above mentioned dockerfile. For more information see:
# https://github.com/miykael/nipype_tutorial
FROM andrewosh/binder-base

MAINTAINER Michael Notter <michaelnotter@hotmail.com>

# Switch to root user for installation
USER root

#---------------------------------------------
# Update OS dependencies and setup neurodebian
#---------------------------------------------
USER root
RUN ln -snf /bin/bash /bin/sh
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -yq --no-install-recommends bzip2 ca-certificates curl git tree unzip wget xvfb zip
ENV NEURODEBIAN_URL http://neuro.debian.net/lists/jessie.de-md.full
RUN curl -sSL $NEURODEBIAN_URL | tee /etc/apt/sources.list.d/neurodebian.sources.list && \
    apt-key adv --recv-keys --keyserver hkp://pgp.mit.edu:80 0xA5D32F012649A5A9 && \
    apt-get update -qq

#---------------------
# Install FSL and AFNI
#---------------------
USER root
RUN apt-get update && \
    apt-get install -y -qq --no-install-recommends fsl-core fsl-atlases afni
ENV FSLDIR=/usr/share/fsl/5.0 \
    FSLOUTPUTTYPE=NIFTI_GZ \
    FSLMULTIFILEQUIT=TRUE \
    POSSUMDIR=/usr/share/fsl/5.0 \
    LD_LIBRARY_PATH=/usr/lib/fsl/5.0:$LD_LIBRARY_PATH \
    FSLTCLSH=/usr/bin/tclsh \
    FSLWISH=/usr/bin/wish \
    AFNI_MODELPATH=/usr/lib/afni/models \
    AFNI_IMSAVE_WARNINGS=NO \
    AFNI_TTATLAS_DATASET=/usr/share/afni/atlases \
    AFNI_PLUGINPATH=/usr/lib/afni/plugins \
    PATH=/usr/lib/fsl/5.0:/usr/lib/afni/bin:$PATH

#-----------------------------------------------------
# Update conda and pip dependencies (including Nipype)
#-----------------------------------------------------
RUN conda update conda --yes --quiet
RUN conda config --add channels conda-forge
RUN conda install --yes --quiet ipython \
                                pip \
                                jupyter \
                                notebook \
                                nb_conda \
                                nb_conda_kernels \
                                matplotlib \
                                graphviz \
                                pandas \
                                seaborn \
                                nipype
RUN python -c "from matplotlib import font_manager"

# Clean up Python3 environment and delete not needed packages
RUN conda remove --name python3 --all --yes --quiet && \
    conda remove qt pyqt scikit-image scikit-learn sympy --yes --quiet && \
    conda clean -tipsy

#---------------------------------------------
# Install graphviz and update pip dependencies
#---------------------------------------------
USER root
RUN apt-get install -yq --no-install-recommends graphviz
USER $NB_USER
RUN pip install --upgrade --quiet pip && \
    pip install --upgrade --quiet nipy \
                                  rdflib \
                --ignore-installed && \
    rm -rf ~/.cache/pip

#-----------------------------------------------------
# Clear apt cache and delete unnecessary folders
#-----------------------------------------------------
RUN apt-get clean remove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /boot /media /mnt /opt /srv

ENV SHELL /bin/bash
