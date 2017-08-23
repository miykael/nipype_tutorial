#!/bin/bash

# Create the Dockerfile for nipype_tutorial using neurodocker
docker run --rm kaczmarj/neurodocker generate -b neurodebian:stretch-non-free -p apt \
    --afni version=latest \
    --freesurfer version=6.0.0 min=True \
    --install dcm2niix convert3d ants fsl graphviz tree git-annex-standalone vim emacs-nox nano less ncdu tig git-annex-remote-rclone \
    --spm version=12 matlab_version=R2017a \
    --instruction="RUN sed -i '\$iexport SPMMCRCMD=\"/opt/spm12/run_spm12.sh /opt/mcr/v92/ script\"' \$ND_ENTRYPOINT" \
    --user=neuro \
    --miniconda python_version=3.6 \
            conda_install="jupyter jupyterlab traits pandas matplotlib scikit-learn seaborn swig reprozip reprounzip codecov cython graphviz joblib nitime scikit-image" \
            env_name="neuro" \
            pip_install="https://github.com/nipy/nipype/tarball/master https://github.com/INCF/pybids/tarball/master https://github.com/poldracklab/mriqc/tarball/master https://github.com/poldracklab/fmriprep/tarball/master datalad dipy nipy nilearn duecredit pymvpa2 pprocess" \
    --miniconda python_version=2.7 \
            env_name="afni27" \
            add_to_path=False \
    --expose 8888 \
    --workdir /home/neuro \
    --no-check-urls > Dockerfile
