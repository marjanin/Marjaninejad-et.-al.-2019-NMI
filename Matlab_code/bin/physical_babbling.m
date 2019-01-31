%% physical_babbling.m
% This code will read the babbling data from the data folder and trains and
% runs a neural network to create the desired activation values to run the 
% leg in a custom trajectory (which is also created in this code) 

clear all;close all;clc;
addpath('../generic_fcns/')
addpath('../physical_system_fcns/')
addpath('../data/')
addpath('../../output')
%% Inputs
babble_id = 'babble_aug22_18h17_10v_air';% (or any other babbling file e.g.,: 'aug25_generated_babble_78hz_via_aug31_eve');
fs=78;
%% Training the model
file_name=sprintf('%s_response.csv',babble_id); % babbling data

dt=1/fs;
[net_trained_1] = training_net_1_fcn(file_name, dt);
%% Creating the pattern
%run time in seconds
%f1 is the frequency of the hip cycle
run1_time=40; f1=1.00; f2=1.00; l=.1;
q1min=0; q1max=140; q2min=250; q2max=360; % check for each run to make sure it matches with the encoder min and max (based on encoder offset)
run1_time_samples=0:dt:run1_time;
[run1_q1_desired_scaled, run1_q2_desired_scaled, Kinematics] = create_pattern_fcn(run1_time, dt, f1, f2, q1min, q1max, q2min, q2max);
%figure();animation_fcn(1,run1_time_samples,run1_q1_desired_scaled,run1_q2_desired_scaled,'../results/run1.avi');
%% Estimating Activation values for the created pattern
run1_A_all_pred = net_trained_1(Kinematics')';
run_plots_fcn(Kinematics, run1_time_samples,...
    run1_q1_desired_scaled, run1_q2_desired_scaled, run1_A_all_pred)
%% Saving results
%save(sprintf('../results/%s_run1_A_all_pred.mat', babble_id),'run1_A_all_pred')
%% Instantiating the reinforcement loop within the matlab environment
run_numbers=[0 0];
best_features=zeros(1,10);
best_reward=-inf;
%save(sprintf('../../output/%s_response_environment.mat', babble_id))
