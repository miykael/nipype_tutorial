import sys
from glob import glob
import pytest

def test_version():
    import nipype
    print("nipype version: ", nipype.__version__)


def reduce_notebook_load(path):
    """
    Changes the number of subjects in examples and hands-on to two,
    to reduce computation time on CircleCi.
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


if __name__ == '__main__':

    test_version()

    # Notebooks that should be tested
    notebooks = []

    # Test mode that should be run
    test_mode = int(sys.argv[1])

    # Specifies which tests should be run
    if test_mode == 1:

        # Test introduction, basic and advanced notebooks
        notebooks += sorted(glob("/home/neuro/nipype_tutorial/notebooks/introduction*.ipynb"))
        notebooks += sorted(glob("/home/neuro/nipype_tutorial/notebooks/basic*.ipynb"))
        notebooks += sorted(glob("/home/neuro/nipype_tutorial/notebooks/advanced*.ipynb"))

    elif test_mode == 2:

        # Test example notebooks
        for n in ["/home/neuro/nipype_tutorial/notebooks/example_preprocessing.ipynb",
                  "/home/neuro/nipype_tutorial/notebooks/example_1stlevel.ipynb",
                  "/home/neuro/nipype_tutorial/notebooks/example_normalize.ipynb",
                  "/home/neuro/nipype_tutorial/notebooks/example_2ndlevel.ipynb"]:

            print('Reducing: %s' % n)
            notebooks.append(reduce_notebook_load(n))

    elif test_mode == 3:

        # Test hands-on notebooks
        for n in ["/home/neuro/nipype_tutorial/notebooks/handson_preprocessing.ipynb",
                  "/home/neuro/nipype_tutorial/notebooks/handson_analysis.ipynb"]:

            print('Reducing: %s' % n)
            notebooks.append(reduce_notebook_load(n))

    # testing all tests from the notebooks list
    pytest_exit_code = pytest.main(["--nbval-lax",  "--nbval-cell-timeout", "7200", "-vs"] + notebooks)
    sys.exit(pytest_exit_code)
