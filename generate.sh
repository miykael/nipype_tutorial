#!/bin/bash

set -e

# Generate Dockerfile
generate_docker() {
  docker run --rm kaczmarj/neurodocker:master generate docker \
           --base neurodebian:stretch-non-free \
           --pkg-manager apt \
           --install convert3d ants fsl gcc g++ graphviz tree \
                     git-annex-standalone vim emacs-nox nano less ncdu \
                     tig git-annex-remote-rclone octave netbase \
           --add-to-entrypoint "source /etc/fsl/fsl.sh" \
           --spm12 version=r7219 \
           --user=neuro \
           --workdir /home/neuro \
           --miniconda \
             conda_install="python=3.8 pytest jupyter jupyterlab jupyter_contrib_nbextensions
                            traits pandas matplotlib scikit-learn scikit-image seaborn nbformat nb_conda" \
             pip_install="git+https://github.com/nipy/nipype.git@rel/1.8.4
                          pybids==0.13.1
                          nilearn datalad[full] nipy duecredit nbval niflow-nipype1-workflows" \
             create_env="neuro" \
             activate=True \
           --env LD_LIBRARY_PATH="/opt/miniconda-latest/envs/neuro:$LD_LIBRARY_PATH" \
           --run-bash "source activate neuro && jupyter nbextension enable exercise2/main && jupyter nbextension enable spellchecker/main" \
           --user=root \
           --run 'mkdir /data && chmod 777 /data && chmod a+s /data' \
           --run 'mkdir /output && chmod 777 /output && chmod a+s /output' \
           --user=neuro \
           --run 'printf "[user]\n\tname = miykael\n\temail = michaelnotter@hotmail.com\n" > ~/.gitconfig' \
           --run-bash 'source activate neuro && cd /data && datalad install -r ///workshops/nih-2017/ds000114 && cd ds000114 && datalad update -r && datalad get -r sub-01/ses-test/anat sub-01/ses-test/func/*fingerfootlips*' \
           --run 'curl -L https://files.osf.io/v1/resources/fvuh8/providers/osfstorage/580705089ad5a101f17944a9 -o /data/ds000114/derivatives/fmriprep/mni_icbm152_nlin_asym_09c.tar.gz && tar xf /data/ds000114/derivatives/fmriprep/mni_icbm152_nlin_asym_09c.tar.gz -C /data/ds000114/derivatives/fmriprep/. && rm /data/ds000114/derivatives/fmriprep/mni_icbm152_nlin_asym_09c.tar.gz && find /data/ds000114/derivatives/fmriprep/mni_icbm152_nlin_asym_09c -type f -not -name ?mm_T1.nii.gz -not -name ?mm_brainmask.nii.gz -not -name ?mm_tpm*.nii.gz -delete' \
           --copy . "/home/neuro/nipype_tutorial" \
           --user=root \
           --run 'chown -R neuro /home/neuro/nipype_tutorial' \
           --run 'rm -rf /opt/conda/pkgs/*' \
           --user=neuro \
           --run 'mkdir -p ~/.jupyter && echo c.NotebookApp.ip = \"0.0.0.0\" > ~/.jupyter/jupyter_notebook_config.py' \
           --workdir /home/neuro/nipype_tutorial \
           --cmd jupyter-notebook
}

# Generate Singularity file (does not include last --cmd option)
generate_singularity() {
  docker run --rm kaczmarj/neurodocker:master generate singularity \
           --base neurodebian:stretch-non-free \
           --pkg-manager apt \
           --install convert3d ants fsl gcc g++ graphviz tree \
                     git-annex-standalone vim emacs-nox nano less ncdu \
                     tig git-annex-remote-rclone octave netbase \
           --add-to-entrypoint "source /etc/fsl/fsl.sh" \
           --spm12 version=r7219 \
           --user=neuro \
           --workdir /home/neuro \
           --miniconda \
             conda_install="python=3.8 pytest jupyter jupyterlab jupyter_contrib_nbextensions
                            traits pandas matplotlib scikit-learn scikit-image seaborn nbformat nb_conda" \
             pip_install="git+https://github.com/nipy/nipype.git@rel/1.8.4
                          pybids==0.13.1
                          nilearn datalad[full] nipy duecredit nbval niflow-nipype1-workflows" \
             create_env="neuro" \
             activate=True \
           --env LD_LIBRARY_PATH="/opt/miniconda-latest/envs/neuro:$LD_LIBRARY_PATH" \
           --run-bash "source activate neuro && jupyter nbextension enable exercise2/main && jupyter nbextension enable spellchecker/main" \
           --user=root \
           --run 'mkdir /data && chmod 777 /data && chmod a+s /data' \
           --run 'mkdir /output && chmod 777 /output && chmod a+s /output' \
           --user=neuro \
           --run 'printf "[user]\n\tname = miykael\n\temail = michaelnotter@hotmail.com\n" > ~/.gitconfig' \
           --run-bash 'source activate neuro && cd /data && datalad install -r ///workshops/nih-2017/ds000114 && cd ds000114 && datalad update -r && datalad get -r sub-01/ses-test/anat sub-01/ses-test/func/*fingerfootlips*' \
           --run 'curl -L https://files.osf.io/v1/resources/fvuh8/providers/osfstorage/580705089ad5a101f17944a9 -o /data/ds000114/derivatives/fmriprep/mni_icbm152_nlin_asym_09c.tar.gz && tar xf /data/ds000114/derivatives/fmriprep/mni_icbm152_nlin_asym_09c.tar.gz -C /data/ds000114/derivatives/fmriprep/. && rm /data/ds000114/derivatives/fmriprep/mni_icbm152_nlin_asym_09c.tar.gz && find /data/ds000114/derivatives/fmriprep/mni_icbm152_nlin_asym_09c -type f -not -name ?mm_T1.nii.gz -not -name ?mm_brainmask.nii.gz -not -name ?mm_tpm*.nii.gz -delete' \
           --copy . "/home/neuro/nipype_tutorial" \
           --user=root \
           --run 'chown -R neuro /home/neuro/nipype_tutorial' \
           --run 'rm -rf /opt/conda/pkgs/*' \
           --user=neuro \
           --run 'mkdir -p ~/.jupyter && echo c.NotebookApp.ip = \"0.0.0.0\" > ~/.jupyter/jupyter_notebook_config.py' \
           --workdir /home/neuro/nipype_tutorial
}

generate_docker > Dockerfile
generate_singularity > Singularity
