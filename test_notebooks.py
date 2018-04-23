from glob import glob
import sys, os, time
import pytest, pdb

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
        ep = ExecutePreprocessor(kernel_name=kernel_name, timeout=7200) #, allow_errors=True

        try:
            ep.preprocess(nb, {'metadata': {'path': this_file_directory}})

        except CellExecutionError as e:
            if "SKIP" in e.traceback:
                print(str(e.traceback).split("\n")[-2])
            else:
                raise e

    return nb, errors


def reduce_notebook_load(path):
    """
    Changes the number of subjects in examples and hands-on to two,
    to reduce computation time on circleci.
    """

    path_short = path[:-6] + '_short.ipynb'

    with open(path, 'r') as input_file, open(path_short, 'w') as output_file:
        for line in input_file:

            # Reduce subject_list in handson notebooks
            if '/handson' in path \
                and "subject_list = ['02', '03', '04'," in line:
                    line = line.replace(
                        "[\'02\', \'03\', \'04\', \'07\', \'08\', \'09\']",
                        "[\'02\', \'07\']")
            elif '/example' in path:

                # Reduce subject_list in example notebooks
                if "subject_list = ['01', '02', '03'," in line:
                    line = line.replace(
                      "[\'01\', \'02\', \'03\', \'04\', \'05\', \'06\', \'07\', \'08\', \'09\', \'10\']",
                      "[\'02\', \'03\']")

                elif "subject_list = ['02', '03'," in line:
                    line = line.replace(
                      "[\'02\', \'03\', \'04\', \'05\', \'07\', \'08\', \'09\']",
                      "[\'02\', \'03\']")

                # Restrict output plots to subject 02
                elif "sub-01" in line:
                    line = line.replace("sub-01", "sub-02")

                # Force plotting of sub-03-10 to be sub-02 in example_1stlevel
                if 'example_1stlevel' in path and "/sub-" in line:
                    for s in range(3, 11):
                        line = line.replace('sub-%02d' % s, 'sub-02')

            output_file.write(line)

    return path_short


Dir_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), "notebooks")

@pytest.mark.parametrize("notebook", glob(os.path.join(Dir_path, "basic*.ipynb")) +
                         [os.path.join(Dir_path, "introduction_python.ipynb"),
                          os.path.join(Dir_path, "introduction_dataset.ipynb"),
                          os.path.join(Dir_path, "introduction_quickstart.ipynb"),
                          os.path.join(Dir_path, "introduction_showcase.ipynb")] +
                         [os.path.join(Dir_path, "example_preprocessing.ipynb"),
                          os.path.join(Dir_path, "example_1stlevel.ipynb"),
                          os.path.join(Dir_path, "example_normalize.ipynb"),
                          os.path.join(Dir_path, "example_2ndlevel.ipynb")] +
                         [os.path.join(Dir_path, "handson_preprocessing.ipynb"),
                          os.path.join(Dir_path, "handson_analysis.ipynb")])

def test_notebooks(notebook):
    test_version()

    if 'example' in notebook or 'handson' in notebook:
        notebook = reduce_notebook_load(notebook)
        print('Testing shortened notebook.')

    t0 = time.time()
    nb, errors = _notebook_run(notebook)
    print("time", time.time() - t0)
    assert errors == []
