%% physical_adaptation.m
% This code get the current NN model and the data coming from the system
% (activations and their corresponding kinematics) and updates he NN model
% based on the data.

clear all;close all;clc;
addpath('../generic_fcns/')
addpath('../physical_system_fcns/')
addpath('../data/')
addpath('../results/')
addpath('../../output')

run1_all_data = load('../results/test7_run1_all_data.mat');
fs = run1_all_data.fs;
dt = run1_all_data.dt;
%% Re-training (adapting) the model
file_name='test8_adapt_response.csv'; %% data coming from running the system
[net_trained_2] = training_net_2_fcn(run1_all_data, file_name);
%% Creating the pattern
%run time in seconds
%f1 is the frequency of the hip cycle and f2 is the frequency of the knee
%cycle
run1_time=40; f1=1.00; f2=1.00; l=.1;
q1min=65; q1max=165; q2min=20; q2max=120;
run1_time_samples=0:dt:run1_time;
[run1_q1_desired_scaled, run1_q2_desired_scaled, Kinematics] = create_pattern_fcn(run1_time, dt, f1, f2, q1min, q1max, q2min, q2max);
%figure();animation_fcn(1,run1_time_samples,run1_q1_desired_scaled,run1_q2_desired_scaled,'../results/run2.avi');
%% Estimating Activation values for the created pattern
run2_A_all_pred = net_trained_2(Kinematics')';
run_plots_fcn(Kinematics, run1_time_samples,...
    run1_q1_desired_scaled, run1_q2_desired_scaled, run2_A_all_pred)
%% Saving results
save('../results/test8_run2_A_all_pred.mat','run2_A_all_pred')
save('../results/test8_run2_all_data.mat')