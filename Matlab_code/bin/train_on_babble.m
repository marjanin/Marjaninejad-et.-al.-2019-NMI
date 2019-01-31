function [target_path_to_validation_csv,target_path_for_output_matfile] = train_on_babble(experiment_id, babbling_response_filepath, target_path_to_validation_csv, target_path_for_output_matfile, matlab_working_directory)

close all;clc;
cd(matlab_working_directory)
addpath('../generic_fcns/')
addpath('../physical_system_fcns/')
addpath('../data/')
fs=78;dt=1/fs;

% write code to produce new_action_trajectory

csvwrite(target_path_to_validation_csv,new_action_trajectory)
save(target_path_for_output_matfile)
end