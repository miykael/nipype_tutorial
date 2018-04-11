from glob import glob
import sys
import os
import time
import pytest

import nbformat
from nbconvert.preprocessors import ExecutePreprocessor
from nbconvert.preprocessors.execute import CellExecutionError


def test_version():
    import nipype
    print("nipype version: ", nipype.__version__)


def _notebook_run(path):
    """
    Execute a notebook via nbconvert and collect output.
    :returns (parsed nb object, execution errors)
    """
    kernel_name = 'python%d' % sys.version_info[0]
    this_file_directory = os.path.dirname(__file__)
    errors = []

    with open(path) as f:
        nb = nbformat.read(f, as_version=4)
        nb.metadata.get('kernelspec', {})['name'] = kernel_name

        # Could also set: allow_errors=True
        ep = ExecutePreprocessor(kernel_name=kernel_name, timeout=7200)

        try:
            ep.preprocess(nb, {'metadata': {'path': this_file_directory}})

        except CellExecutionError as e:
            if "SKIP" in e.traceback:
                print(str(e.traceback).split("\n")[-2])
            else:
                raise e

    return nb, errors


Dir_path = os.path.join(
    os.path.dirname(os.path.realpath(__file__)), '..', "notebooks")


@pytest.mark.parametrize(
    "notebook", [os.path.join(Dir_path, "introduction_python.ipynb"),
                 os.path.join(Dir_path, "introduction_quickstart.ipynb")])
def test_notebooks(notebook):
    t0 = time.time()
    nb, errors = _notebook_run(notebook)
    print("time", time.time() - t0)
    assert errors == []
