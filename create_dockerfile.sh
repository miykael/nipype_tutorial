#!/bin/bash

# This script creates the Dockerfile using neurodocker. It is based on the
# Dockerfile from https://github.com/neurohackweek/jupyterhub-docker

docker run --rm kaczmarj/neurodocker generate -b neurodebian:stretch-non-free -p apt \
    --instruction "RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -" \
    --install ants dcm2niix convert3d graphviz tree git-annex-standalone vim emacs-nox nano less ncdu tig git-annex-remote-rclone build-essential nodejs r-recommended psmisc libapparmor1 sudo dc \
    --install afni \
    --instruction "ENV PATH=/usr/lib/afni/bin:\$PATH " \
    --freesurfer version=6.0.0 min=True \
    --install fsl \
    --instruction "RUN sed -i '\$iFSLDIR=/usr/share/fsl\n. \${FSLDIR}/5.0/etc/fslconf/fsl.sh\nPATH=\${FSLDIR}/5.0/bin:\${PATH}\nexport FSLDIR PATH' \$ND_ENTRYPOINT" \
    --spm version=12 matlab_version=R2017a \
    --instruction "RUN curl -sSL https://dl.dropbox.com/s/lfuppfhuhi1li9t/cifti-data.tgz?dl=0 | tar zx -C / " \
    --user=neuro \
    --miniconda conda_install="python=3.6 altair apptools bokeh codecov configobj cython joblib jupyter jupyter_contrib_nbextensions jupyterhub jupyterlab matplotlib nitime pandas reprounzip reprozip scikit-image scikit-learn seaborn swig traits traitsui" \
                env_name="neuro3" \
                add_to_path=True \
                pip_install="https://github.com/nipy/nipype/tarball/master https://github.com/nipy/nibabel/archive/master.zip https://github.com/INCF/pybids/archive/master.zip git+https://github.com/jupyterhub/nbserverproxy.git git+https://github.com/jupyterhub/nbrsessionproxy.git https://github.com/satra/mapalign/archive/master.zip datalad dipy duecredit nilearn nipy niworkflows pprocess pymvpa2" \
    --instruction "RUN bash -c \"source activate neuro3 && python -m ipykernel install --sys-prefix --name neuro3 --display-name Py3-neuro\" " \
    --instruction "RUN bash -c \"source activate neuro3 && pip install --no-cache-dir --pre --upgrade ipywidgets pythreejs\" " \
    --instruction "RUN bash -c \"source activate neuro3 && pip install --no-cache-dir --upgrade https://github.com/maartenbreddels/ipyvolume/archive/master.zip && jupyter nbextension install --py --sys-prefix ipyvolume && jupyter nbextension enable --py --sys-prefix ipyvolume\" " \
    --instruction "RUN bash -c \"source activate neuro3 && pip install --no-cache-dir git+https://github.com/data-8/gitautosync && jupyter serverextension enable --py nbgitautosync --sys-prefix\" " \
    --instruction "RUN bash -c \"source activate neuro3 && jupyter nbextension enable rubberband/main && jupyter nbextension enable exercise2/main && jupyter nbextension enable spellchecker/main && jupyter nbextension enable vega --py --sys-prefix\" " \
    --instruction "RUN bash -c \"source activate neuro3 && jupyter serverextension enable --sys-prefix --py nbserverproxy && jupyter serverextension enable --sys-prefix --py nbrsessionproxy && jupyter nbextension install --sys-prefix --py nbrsessionproxy && jupyter nbextension enable --sys-prefix --py nbrsessionproxy\" " \
    --user=root \
    --instruction "RUN echo 'neuro:neuro' | chpasswd && usermod -aG sudo neuro" \
    --instruction "RUN mkdir /data && chown neuro /data && chmod 777 /data && mkdir /output && chown neuro /output && chmod 777 /output && mkdir /repos && chown neuro /repos && chmod 777 /repos" \
    --user=neuro \
    --instruction "RUN cd /repos && git clone https://github.com/neuro-data-science/neuroviz.git && git clone https://github.com/neuro-data-science/neuroML.git && git clone https://github.com/ReproNim/reproducible-imaging.git && git clone https://github.com/miykael/nipype_tutorial.git && git clone https://github.com/jmumford/nhwEfficiency.git && git clone https://github.com/jmumford/R-tutorial.git" \
    --instruction "RUN bash -c \"source activate neuro3 && cd /data && datalad install -r ///workshops/nih-2017/ds000114 && datalad --on-failure ignore get -r -J4 ds000114/sub-01/ses-test/anat && datalad --on-failure ignore get -r -J4 ds000114/sub-01/ses-test/func/*fingerfootlips* && datalad --on-failure ignore get -r -J4 ds000114/derivatives/fmriprep/sub-01/anat && datalad --on-failure ignore get -r -J4 ds000114/derivatives/fmriprep/sub-01/ses-test/func/*fingerfootlips*\" " \
    --instruction "RUN curl -sSL https://osf.io/dhzv7/download?version=3 | tar zx -C /data/ds000114/derivatives/fmriprep" \
    --instruction "ENV LD_LIBRARY_PATH=\"/usr/lib/R/lib:\${LD_LIBRARY_PATH}\" " \
    --instruction "RUN bash -c \"echo c.NotebookApp.ip = \'0.0.0.0\' > ~/.jupyter/jupyter_notebook_config.py\" " \
    --workdir /repos \
    --no-check-urls > Dockerfile
