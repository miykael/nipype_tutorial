#!/bin/bash

# This script creates the Dockerfile using neurodocker. It is based on the
# Dockerfile from https://github.com/neurohackweek/jupyterhub-docker

docker run --rm kaczmarj/neurodocker generate -b neurodebian:stretch-non-free -p apt \
    --instruction "RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -" \
    --install fsl dcm2niix convert3d ants graphviz tree git-annex-standalone vim emacs-nox nano less ncdu tig git-annex-remote-rclone build-essential nodejs r-recommended psmisc libapparmor1 sudo dc \
    --instruction "RUN apt-get update && apt-get install -yq xvfb mesa-utils libgl1-mesa-dri && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* " \
    --afni version=latest \
    --freesurfer version=6.0.0 min=True \
    --spm version=12 matlab_version=R2017a \
    --instruction "RUN curl -sSL https://dl.dropbox.com/s/lfuppfhuhi1li9t/cifti-data.tgz?dl=0 | tar zx -C / " \
    --user=neuro \
    --miniconda conda_install="python=3.6 jupyter jupyterlab traits pandas matplotlib scikit-learn seaborn swig reprozip reprounzip altair traitsui apptools configobj jupyter_contrib_nbextensions bokeh scikit-image codecov nitime cython joblib jupyterhub=0.7.2" \
                env_name="neuro3" \
                add_to_path=True \
                pip_install="https://github.com/nipy/nibabel/archive/master.zip https://github.com/nipy/nipype/tarball/master nilearn https://github.com/INCF/pybids/archive/master.zip datalad dipy nipy duecredit pymvpa2 git+https://github.com/jupyterhub/nbserverproxy.git git+https://github.com/jupyterhub/nbrsessionproxy.git https://github.com/satra/mapalign/archive/master.zip pprocess " \
    --instruction "RUN bash -c \"source activate neuro3 && python -m ipykernel install --sys-prefix --name neuro3 --display-name Py3-neuro\" " \
    --instruction "RUN bash -c \"source activate neuro3 && pip install --no-cache-dir --pre --upgrade ipywidgets pythreejs\" " \
    --instruction "RUN bash -c \"source activate neuro3 && pip install --no-cache-dir --upgrade https://github.com/maartenbreddels/ipyvolume/archive/master.zip && jupyter nbextension install --py --sys-prefix ipyvolume && jupyter nbextension enable --py --sys-prefix ipyvolume\" " \
    --instruction "RUN bash -c \"source activate neuro3 && jupyter nbextension enable rubberband/main && jupyter nbextension enable exercise2/main && jupyter nbextension enable spellchecker/main\" " \
    --instruction "RUN bash -c \"source activate neuro3 && jupyter serverextension enable --sys-prefix --py nbserverproxy && jupyter serverextension enable --sys-prefix --py nbrsessionproxy && jupyter nbextension install --sys-prefix --py nbrsessionproxy && jupyter nbextension enable --sys-prefix --py nbrsessionproxy\" " \
    --instruction "RUN bash -c \"source activate neuro3 && pip install --no-cache-dir git+https://github.com/data-8/gitautosync && jupyter serverextension enable --py nbgitautosync --sys-prefix\" " \
    --user=root \
    --instruction "RUN mkdir /data && chown neuro /data && chmod 777 /data && mkdir /output && chown neuro /output && chmod 777 /output && mkdir /repos && chown neuro /repos && chmod 777 /repos" \
    --instruction "RUN echo 'neuro:neuro' | chpasswd && usermod -aG sudo neuro" \
    --user=neuro \
    --instruction "RUN bash -c \"source activate neuro3 && cd /data && datalad install -r ///workshops/nih-2017/ds000114 && datalad --on-failure ignore get -r -J8 ds000114/sub-0[12]/ses-test/anat && datalad --on-failure ignore get -r -J8 ds000114/sub-0[12]/ses-test/func/*fingerfootlips* && datalad --on-failure ignore get -r -J8 ds000114/derivatives/fmriprep/sub-0[12]/anat && datalad --on-failure ignore get -r -J8 ds000114/derivatives/fmriprep/sub-0[12]/ses-test/func/*fingerfootlips* && datalad --on-failure ignore get -r -J8 ds000114/derivatives/freesurfer/sub-0[12] && datalad --on-failure ignore get -r -J8 ds000114/derivatives/freesurfer/fsaverage5\" " \
    --instruction "RUN curl -sSL https://osf.io/dhzv7/download?version=3 | tar zx -C /data/ds000114/derivatives/fmriprep" \
    --workdir /repos \
    --instruction "RUN cd /repos && git clone https://github.com/neuro-data-science/neuroviz.git && git clone https://github.com/neuro-data-science/neuroML.git && git clone https://github.com/ReproNim/reproducible-imaging.git && git clone https://github.com/miykael/nipype_tutorial.git && git clone https://github.com/jmumford/nhwEfficiency.git && git clone https://github.com/jmumford/R-tutorial.git" \
    --instruction "ENV FSLDIR=\"/usr/share/fsl\"" \
    --instruction "RUN . \${FSLDIR}/5.0/etc/fslconf/fsl.sh" \
    --instruction "ENV PATH=\"\${FSLDIR}/5.0/bin:\${PATH}\"" \
    --instruction "ENV PATH=\"\${PATH}:/usr/lib/rstudio-server/bin\" " \
    --instruction "ENV LD_LIBRARY_PATH=\"/usr/lib/R/lib:\${LD_LIBRARY_PATH}\" " \
    --instruction "RUN bash -c \"echo c.NotebookApp.ip = \'0.0.0.0\' > ~/.jupyter/jupyter_notebook_config.py\" " \
    --no-check-urls > Dockerfile
