import time
from proctor import *
# @param runmode: 0 - normal reinforcement
# 1 - golden trajectory test in air. adapt on one trajectory
# 2 - adapt on a variety of trajectories and test on a second set of unseen trajectories, to be compared with the nonadapted babble model on the second set.


def reinforce_fcn(experiment_id,
                  starting_babble_mat_filepath,
                  starting_babble_response_filepath,
                  goal_reward=60,
                  maximum_phase1_run_number=1000,
                  adapt=True,
                  local_output_folderpath="",
                  num_fine_search_iterations=10,
                  run_mode=0,
                  show_figures=False, remote_user_host=""):

  target_folderpath = abspath_join(local_output_folderpath, experiment_id)
  ensure_mkdir(target_folderpath)
  start_time = time.time()
  verbose = False
  matlab_working_directory = "/Users/briancohn/Documents/GitHub/marjanin/Tendon_Driven_Robotics/beyond_imitation_learning/bin/"
  eng = start_matlab_in_working_dir_with_added_paths(
      matlab_working_directory)
  hlinewrap("Experiment: %s" % experiment_id)
  # Start the reward as negative so the search begins in coarse
  reward = -10000
  response_from_prior_activations_with_encodervals_filepath = starting_babble_response_filepath  # initialized
  input_prior_mat_path = starting_babble_mat_filepath  # initialized
  attempt_number = 0
  done = False
  rewards = []
  while not done:
    attempt_number += 1
    optional_response_prefix, mat_output_filepath, new_activations_filepath, prior_physics_filepath, new_desired_kinematics_filepath = prep_filepaths_for_bypython(
        experiment_id, attempt_number, adapt, target_folderpath)
    done = eng.bypython_reinforce_mode_based(starting_babble_response_filepath,
                                             reward,
                                             response_from_prior_activations_with_encodervals_filepath,
                                             input_prior_mat_path,
                                             mat_output_filepath,
                                             new_activations_filepath,
                                             prior_physics_filepath,
                                             new_desired_kinematics_filepath,
                                             maximum_phase1_run_number,
                                             goal_reward,
                                             adapt,
                                             run_mode,
                                             num_fine_search_iterations,
                                             show_figures)
    if done:
      hlinewrap("Done flag set to True. Reinforcement is complete.")
      break
    response_from_prior_activations_with_encodervals_filepath, log_path = prescribe_activations_and_scp_results(experiment_id=experiment_id,
                                                                                                                remote_user_host=remote_user_host,
                                                                                                                local_activations_filepath=new_activations_filepath,
                                                                                                                local_output_folderpath=target_folderpath,
                                                                                                                optional_response_prefix=optional_response_prefix)
    input_prior_mat_path = mat_output_filepath
    reward = extract_reward(log_path, verbose)
    hlinewrap("Reward: %s" % reward)
    rewards += [reward]
    elapsed = (time.time() - start_time) / 60
  hlinewrap('Elapsed time per experiment: %s' % elapsed)
  return(rewards)
