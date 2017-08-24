#!/bin/bash

# This script creates the Dockerfile using neurodocker. It is based on the
# Dockerfile from https://github.com/neurohackweek/jupyterhub-docker

docker run --rm kaczmarj/neurodocker generate -b neurodebian:stretch-non-free -p apt \
    --instruction "RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -" \
    --install dcm2niix convert3d ants graphviz tree git-annex-standalone vim emacs-nox nano less ncdu tig git-annex-remote-rclone xvfb mesa-utils build-essential nodejs \
    --afni version=latest \
    --fsl version=5.0.10 \
    --freesurfer version=6.0.0 min=True \
    --spm version=12 matlab_version=R2017a \
    --install psmisc libapparmor1 sudo \
    --instruction "RUN bash -c \"curl http://download2.rstudio.org/rstudio-server-\$(curl https://s3.amazonaws.com/rstudio-server/current.ver)-amd64.deb >> rstudio-server-amd64.deb && dpkg -i rstudio-server-amd64.deb && rm rstudio-server-amd64.deb\" " \
    --instruction "RUN curl -sSL https://dl.dropbox.com/s/lfuppfhuhi1li9t/cifti-data.tgz?dl=0 | tar zx -C / " \
    --user=neuro \
    --miniconda python_version=3.6 \
                conda_install="jupyter jupyterlab traits pandas matplotlib scikit-learn seaborn swig reprozip reprounzip altair traitsui apptools configobj vtk jupyter_contrib_nbextensions bokeh scikit-image" \
                env_name="neuro" \
                pip_install="https://github.com/nipy/nibabel/archive/master.zip https://github.com/nipy/nipype/tarball/master nilearn https://github.com/INCF/pybids/archive/master.zip datalad dipy nipy duecredit pymvpa2 mayavi git+https://github.com/jupyterhub/nbrsessionproxy.git" \
    --instruction "RUN bash -c \"source activate neuro && python -m ipykernel install --user --name neuro --display-name Py3-neuro \" " \
    --instruction "RUN bash -c \"source activate neuro && pip install --pre --upgrade ipywidgets pythreejs \" " \
    --instruction "RUN bash -c \"source activate neuro && pip install  --upgrade https://github.com/maartenbreddels/ipyvolume/archive/23eb91685dfcf200ee82f89ab6f7294f9214db8c.zip && jupyter nbextension install --py --sys-prefix ipyvolume && jupyter nbextension enable --py --sys-prefix ipyvolume \" " \
    --instruction "RUN bash -c \"source activate neuro && jupyter nbextension enable rubberband/main && jupyter nbextension enable exercise2/main && jupyter nbextension enable spellchecker/main \" " \
    --instruction "RUN bash -c \"source activate neuro && jupyter serverextension enable --sys-prefix --py nbrsessionproxy && jupyter nbextension install --sys-prefix --py nbrsessionproxy && jupyter nbextension enable --sys-prefix --py nbrsessionproxy \" " \
    --miniconda python_version=2.7 \
                env_name="afni27" \
                conda_install="ipykernel" \
                add_to_path=False \
    --instruction "RUN bash -c \"source activate afni27 && python -m ipykernel install --user --name afni27 --display-name Py2-afni \" " \
    --instruction "RUN bash -c \"source activate neuro && python -c 'from nilearn import datasets; haxby_dataset = datasets.fetch_haxby()' \" " \
    --workdir /home/neuro \
    --no-check-urls > Dockerfile
