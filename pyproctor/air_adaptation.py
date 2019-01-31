# cd ~/Documents/GitHub/marjanin/Tendon_Driven_Robotics/pyproctor &&python3 air_adaptation.py
# or if you are already in the path:  to run this file, run `python3 air_adaptaion.py`
from proctor import *
from log_extractor import *
from reinforce_fcn import *

user, ip, remote_user_host = initialize_pi()
babble_id = "aug25_generated_babble_78hz_via_aug31_eve"
babble_response, babble_mat_path, local_output_folderpath, input_babble = initialize_babble_params(
    babble_id)

if __name__ == '__main__':
  num_experiment_replicates = 15

  bigexperiment_id = "air_adaptation_sets_of_30_range0p2to0p8_5reps_withpower"
  experiment_ids = ["%s_%s" %
                    (bigexperiment_id, i) for i in range(1,7)]
                    # (bigexperiment_id, i) for i in range(num_experiment_replicates)]

  reward_path_per_experiment = [reinforce_fcn(
      experiment_id=experiment_id,
      starting_babble_mat_filepath=babble_mat_path,
      starting_babble_response_filepath=babble_response,
      goal_reward=100,
      maximum_phase1_run_number=100,
      adapt=True,
      local_output_folderpath=local_output_folderpath,
      num_fine_search_iterations=10,
      run_mode=2,
      show_figures=False,
      remote_user_host=remote_user_host)
      for experiment_id in experiment_ids]
  print(reward_path_per_experiment)
  save_summary(bigexperiment_id, reward_path_per_experiment,
               local_output_folderpath, announce=True)
  interrupt_current_processes(remote_user_host)
