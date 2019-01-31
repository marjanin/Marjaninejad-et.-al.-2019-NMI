
import os
import numpy as np
from proctor import *
import pdb
from log_extractor import *

indices_of_interest = [1,2,3,4,5,6,7,8,9,10]

hlinewrap('Creating Variables')
user, ip, remote_user_host = initialize_pi()
local_output_folderpath = "../output/"
experiment_id = "random_actions"
num_replicates = 3
indices_with_replicates = indices_of_interest * num_replicates
num_shuffles = 0
while 0 in np.diff(indices_with_replicates):
	print('Num Shuffles: %s to prevent sequential repeats' % num_shuffles)
	shuffle(indices_with_replicates)
	num_shuffles += 1

rewards = []
tic = time.time()
verbose = True
for x in indices_with_replicates:
    input_filepath = get_validation_action_filepath(x)
    optional_response_prefix = "_iteration%s" % x
    if verbose:
        hlinewrap('Starting activations on Rpi for %s%s' %
              (experiment_id, optional_response_prefix))
    result_csv_local_filepath, result_log_local_filepath = prescribe_activations_and_scp_results(
        experiment_id, remote_user_host, input_filepath, local_output_folderpath, optional_response_prefix)
# print out the results:
    if verbose:
        announce_id(experiment_id, optional_response_prefix)
        announce_response(result_csv_local_filepath, result_log_local_filepath)
    reward = extract_reward(result_log_local_filepath, verbose)
    rewards += [(x, reward)]
    print("Time per activation: %s " %(time.time() - tic))
    tic = time.time()

print(rewards)
# results = ["index%s,reward%s" % (index, rewards[index])
#            for index in indices_with_replicates]
# print(results)
interrupt_current_processes(remote_user_host)