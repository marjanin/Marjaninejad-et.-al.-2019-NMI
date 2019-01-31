# to run this file, run python3 -i interactive.py


import os
import numpy as np
from proctor import *
import pdb
from log_extractor import *


hlinewrap('Creating Variables')
user = "pi"
ip = "10.120.80.222"

ensure_rpi_online(ip)
remote_user_host = "%s@%s" % (user, ip)

# once output response files are created, they will land here. this is also a good place to put your babble input data.
local_output_folderpath = "../output/"
experiment_id = "test_encoder_values"
# input_filepath = "../testdata/test6_run1_A_all_pred.csv" #give the full path. I recommend putting your stuff in the output folder.
# give the full path. I recommend putting your stuff in the output folder.
input_filepath = "../testdata/generated_babble_aug15.csv"
# give the full path. I recommend putting your stuff in the output folder.
input_filepath = "../testdata/babble_aug15_validation.csv"
# test7_generated_babble
# test7_run1_A_all_pred
# this can be _babble, or _adapt etc.
# optional_response_prefix = "_adapted"
optional_response_prefix = "_validated"
hlinewrap('Starting activations on Rpi for %s%s' %
          (experiment_id, optional_response_prefix))
hline()
# This is the function you will call from the python command line. The outputs of this function are the locations where the response CSV is saved to disk.
result_csv_local_filepath, result_log_local_filepath = prescribe_activations_and_scp_results(
    experiment_id, remote_user_host, input_filepath, local_output_folderpath, optional_response_prefix)

# print out the results:
announce_id(experiment_id, optional_response_prefix)
announce_response(result_csv_local_filepath, result_log_local_filepath)
reward = extract_reward(result_log_local_filepath, verbose=True)
