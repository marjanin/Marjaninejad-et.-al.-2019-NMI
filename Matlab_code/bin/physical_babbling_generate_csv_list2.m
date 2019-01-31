%% physical_babbling.m
% This code will read the babbling data from the data folder and trains and
% runs a neural network to create the desired activation values to run the 
% leg in a costum trajectory (which is also created in this code) 

clear all;close all;clc;
addpath('../generic_fcns/')
addpath('../physical_system_fcns/')
addpath('../../testdata/')
addpath('../../output')

%% Training the model
file_name='babble_aug15_response.csv'; % babbling data
fs=78;dt=1/fs;
[net_trained_1] = training_net_1_fcn(file_name, dt);
%% loop for creating the list
number_of_feautures=10;
for list_length=1:500
    list_length
% Creating the pattern
feature_higher_limit=.8;
feature_lower_limit=.2;
new_features=(feature_higher_limit-feature_lower_limit)*rand(1,number_of_feautures)+feature_lower_limit;
%new_features = ones(1,10);
each_feature_length = 8;
[q1_resampled_desired, q2_resampled_desired] = physical_limit_cycle_gen_fcn(new_features, each_feature_length);
[Kinematics] = angles2kinematics_fcn(repmat(q1_resampled_desired,1,20), repmat(q2_resampled_desired,1,20) ,1/78);
% Estimating Activation values for the created pattern
run1_A_all_pred = net_trained_1(Kinematics')';
% close all;
% run1_time_samples=1:1600;
% run_plots_fcn(Kinematics, run1_time_samples,...
%     Kinematics(:,1), Kinematics(:,4), run1_A_all_pred)
% pause()
% Saving results
%save('../results/babble_aug15_validation.mat','run1_A_all_pred')
save(['../../testdata/validation_list/',num2str(list_length),'.mat'])
csvwrite(['../../testdata/validation_list/',num2str(list_length),'.csv'],run1_A_all_pred)
end