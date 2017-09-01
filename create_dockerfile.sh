#!/bin/bash

# This script creates the Dockerfile using neurodocker. It is based on the
# Dockerfile from https://github.com/neurohackweek/jupyterhub-docker

docker run --rm kaczmarj/neurodocker generate -b neurodebian:stretch-non-free -p apt \
    --instruction "RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -" \
    --install dcm2niix convert3d ants graphviz tree git-annex-standalone vim emacs-nox nano less ncdu tig git-annex-remote-rclone build-essential nodejs r-recommended psmisc libapparmor1 sudo dc \
    --instruction "RUN apt-get update && apt-get install -yq xvfb mesa-utils libgl1-mesa-dri && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* " \
    --install afni fsl \
    --freesurfer version=6.0.0 min=True \
    --spm version=12 matlab_version=R2017a \
    --instruction "RUN bash -c \"curl -sSL  http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.0.0_1.0.2g-1ubuntu11.2_amd64.deb > libssl1.0.0_1.0.2g-1ubuntu11.2_amd64.deb && dpkg -i libssl1.0.0_1.0.2g-1ubuntu11.2_amd64.deb && rm libssl1.0.0_1.0.2g-1ubuntu11.2_amd64.deb\" " \
    --instruction "RUN bash -c \"curl -sSL http://download2.rstudio.org/rstudio-server-\$(curl https://s3.amazonaws.com/rstudio-server/current.ver)-amd64.deb >> rstudio-server-amd64.deb && dpkg -i rstudio-server-amd64.deb && rm rstudio-server-amd64.deb\" " \
    --instruction "RUN Rscript -e 'install.packages(c(\"neuRosim\", \"ggplot2\", \"fmri\", \"dplyr\", \"tidyr\", \"Lahman\", \"data.table\", \"readr\"), repos = \"http://cran.case.edu\")' " \
    --instruction "RUN curl -sSL https://dl.dropbox.com/s/lfuppfhuhi1li9t/cifti-data.tgz?dl=0 | tar zx -C / " \
    --user=neuro \
    --miniconda python_version=3.6 \
                conda_install="jupyter jupyterlab traits pandas matplotlib scikit-learn seaborn swig reprozip reprounzip altair traitsui apptools configobj vtk jupyter_contrib_nbextensions bokeh scikit-image codecov nitime cython joblib jupyterhub=0.7.2" \
                env_name="neuro3" \
                add_to_path=True \
                pip_install="https://github.com/nipy/nibabel/archive/master.zip https://github.com/nipy/nipype/tarball/master nilearn https://github.com/INCF/pybids/archive/master.zip datalad dipy nipy duecredit pymvpa2 mayavi git+https://github.com/jupyterhub/nbserverproxy.git git+https://github.com/jupyterhub/nbrsessionproxy.git https://github.com/satra/mapalign/archive/master.zip pprocess " \
    --instruction "RUN bash -c \"source activate neuro3 && python -m ipykernel install --sys-prefix --name neuro3 --display-name Py3-neuro \" " \
    --instruction "RUN bash -c \"source activate neuro3 && pip install --pre --upgrade ipywidgets pythreejs \" " \
    --instruction "RUN bash -c \"source activate neuro3 && pip install  --upgrade https://github.com/maartenbreddels/ipyvolume/archive/master.zip && jupyter nbextension install --py --sys-prefix ipyvolume && jupyter nbextension enable --py --sys-prefix ipyvolume \" " \
    --instruction "RUN bash -c \"source activate neuro3 && jupyter nbextension enable rubberband/main && jupyter nbextension enable exercise2/main && jupyter nbextension enable spellchecker/main \" " \
    --instruction "RUN bash -c \"source activate neuro3 && jupyter serverextension enable --sys-prefix --py nbserverproxy && jupyter serverextension enable --sys-prefix --py nbrsessionproxy && jupyter nbextension install --sys-prefix --py nbrsessionproxy && jupyter nbextension enable --sys-prefix --py nbrsessionproxy \" " \
    --instruction "RUN bash -c \" source activate neuro3 && pip install git+https://github.com/data-8/gitautosync && jupyter serverextension enable --py nbgitautosync --sys-prefix \" " \
    --miniconda python_version=2.7 \
                env_name="afni27" \
                conda_install="ipykernel" \
                add_to_path=False \
    --instruction "RUN bash -c \"source activate neuro3 && python -m ipykernel install --sys-prefix --name afni27 --display-name Py2-afni \" " \
    --user=root \
    --instruction "RUN mkdir /data && chown neuro /data && chmod 777 /data && mkdir /output && chown neuro /output && chmod 777 /output && mkdir /repos && chown neuro /repos && chmod 777 /repos" \
    --instruction "RUN echo 'neuro:neuro' | chpasswd && usermod -aG sudo neuro" \
    --user=neuro \
    --instruction "RUN bash -c \"source activate neuro3 && cd /data && datalad install -r ///workshops/nih-2017/ds000114 && datalad get -r -J4 ds000114/sub-0[12]/ses-test/ && datalad get -r ds000114/derivatives/fr*/sub-0[12] && datalad get -r ds000114/derivatives/fm*/sub-0[12]/anat && datalad get -r ds000114/derivatives/fm*/sub-0[12]/ses-test && datalad get -r ds000114/derivatives/f*/fsaverage5 \" " \
    --instruction "RUN curl -sSL https://osf.io/dhzv7/download?version=3 | tar zx -C /data/ds000114/derivatives/fmriprep" \
    --workdir /home/neuro \
    --instruction "RUN cd /repos && git clone https://github.com/neuro-data-science/neuroviz.git && git clone https://github.com/neuro-data-science/neuroML.git && git clone https://github.com/ReproNim/reproducible-imaging.git && git clone https://github.com/miykael/nipype_tutorial.git && git clone https://github.com/jmumford/nhwEfficiency.git && git clone https://github.com/jmumford/R-tutorial.git" \
    --instruction "ENV PATH=\"\${PATH}:/usr/lib/rstudio-server/bin\" " \
    --instruction "ENV LD_LIBRARY_PATH=\"/usr/lib/R/lib:\${LD_LIBRARY_PATH}\" " \
    --instruction "RUN bash -c \"echo c.NotebookApp.ip = \'0.0.0.0\' > ~/.jupyter/jupyter_notebook_config.py\" " \
    --no-check-urls > Dockerfile
