import os
import numpy as np
from proctor import *
import pdb
from log_extractor import *

hlinewrap('Creating Variables')
user, ip, remote_user_host = initialize_pi()

local_output_folderpath = "../output/"

##' by default it will run the input filepath list first (in order)
##' then it will repeat num_replicates_per_pattern times
def run_filepaths_with_replicates(experiment_id, input_filepath_list, num_replicates_per_pattern, verbose=False):
    rewards = []
    for replicate in range(num_replicates_per_pattern):
        print('.', end='')
        if verbose:
            hlinewrap('# Replicate %s' % replicate)
        for x in range(len(input_filepath_list)):
            input_filepath = input_filepath_list[x]
            optional_response_prefix = "_iteration_%s_replicate%s" % (x, replicate)
            if verbose:
                hlinewrap('## Starting activations on Rpi for %s%s' % (experiment_id, optional_response_prefix))
            result_csv_local_filepath, result_log_local_filepath = prescribe_activations_and_scp_results(
                experiment_id, remote_user_host, input_filepath, local_output_folderpath, optional_response_prefix)
            reward = extract_reward(result_log_local_filepath, verbose)
            observation = [(x, input_filepath, replicate, reward, result_csv_local_filepath, result_log_local_filepath)]
            if verbose:
                print(observation)
            rewards += observation
    return(rewards)

if __name__ == '__main__':
    # up to 100 patterns
    num_random_trajectories = 2
    input_filepath_list = [get_validation_action_filepath(x) for x in range(1, num_random_trajectories)]
    print(input_filepath_list)

    rewards = run_filepaths_with_replicates("random_actions_with_replicates", input_filepath_list, num_replicates_per_pattern = 3, verbose=False)
    hlinewrap("Rewards", False)
    hlinewrap(rewards)
    # Clean up
    interrupt_current_processes(remote_user_host)
