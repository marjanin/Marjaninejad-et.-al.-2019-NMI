import matlab.engine
from generic_functions import *
import time


def prep_matlab_output_filepaths(experiment_id, local_output_folderpath):
    matlab_file_output_filepath = abspath_join(
        local_output_folderpath, "%s_babble_trained_data_created_%s.mat" % (experiment_id, time.time()))
    matlab_validation_csv_filepath = abspath_join(
        local_output_folderpath, "%s_babble_validation_set_created_%s.csv" % (experiment_id, time.time()))
    return(matlab_file_output_filepath, matlab_validation_csv_filepath)


def prep_matlab_adaptation_filepaths(experiment_id, local_output_folderpath):
    matlab_file_output_filepath = abspath_join(
        local_output_folderpath, "%s_adapted_trained_data_created_%s.mat" % (experiment_id, time.time()))
    matlab_validation_csv_filepath = abspath_join(
        local_output_folderpath, "%s_adapted_validation_set_created_%s.csv" % (experiment_id, time.time()))
    return(matlab_file_output_filepath, matlab_validation_csv_filepath)


def train_on_babble_matlab(experiment_id, babbling_response_filepath, target_path_to_validation_csv, target_path_for_output_matfile, matlab_working_directory):
    global eng
    eng.cd(r'%s' % matlab_working_directory, nargout=0)
    res = eng.train_on_babble(experiment_id, babbling_response_filepath, target_path_to_validation_csv,
                              target_path_for_output_matfile, matlab_working_directory, nargout=2)
    print('a')
    print(eng.eval('exception = MException.last;', nargout=0))
    print('b')
    print(eng.eval('getReport(exception)'))
    return(res)
    # outputs: target_path_to_validation_csv,target_path_for_output_matfile


def adapt_on_response_matlab(experiment_id, response_filepath, prior_mat_filepath, target_path_to_validation_csv, target_path_for_output_matfile, matlab_working_directory):
    eng.cd(r'%s' % matlab_working_directory, nargout=0)
    res = eng.physical_adaptation(experiment_id, response_filepath, prior_mat_filepath, target_path_to_validation_csv,
                                  target_path_for_output_matfile, matlab_working_directory, nargout=2)
    print('a')
    print(eng.eval('exception = MException.last;', nargout=0))
    print('b')
    print(eng.eval('getReport(exception)'))
    return(res)
    # outputs: target_path_to_validation_csv,target_path_for_output_matfile
