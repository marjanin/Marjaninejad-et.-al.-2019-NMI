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
%% Creating the pattern
new_features = ones(1,10);
each_feature_length = 8;
[q1_resampled_desired, q2_resampled_desired] = physical_limit_cycle_gen_fcn(new_features, each_feature_length);
[Kinematics] = angles2kinematics_fcn(repmat(q1_resampled_desired,1,10), repmat(q2_resampled_desired,1,10) ,1/78);

%%
% %run time in seconds
% %f1 is the frequency of the hip cycle
% run1_time=40; f1=1.00; f2=1.00; l=.1;
% q1min=65; q1max=165; q2min=20; q2max=120;
% run1_time_samples=0:dt:run1_time;
% [run1_q1_desired_scaled, run1_q2_desired_scaled, Kinematics] = create_pattern_fcn(run1_time, dt, f1, f2, q1min, q1max, q2min, q2max);
% %figure();animation_fcn(1,run1_time_samples,run1_q1_desired_scaled,run1_q2_desired_scaled,'../results/run1.avi');
%% Estimating Activation values for the created pattern
run1_time_samples=1:800;
run1_A_all_pred = net_trained_1(Kinematics')';
run_plots_fcn(Kinematics, run1_time_samples,...
    Kinematics(:,1), Kinematics(:,4), run1_A_all_pred)
%% Saving results
save('../results/babble_aug15_validation.mat','run1_A_all_pred')
save('../results/babble_aug15_validation.mat')
csvwrite('../../testdata/babble_aug15_validation.csv',run1_A_all_pred)