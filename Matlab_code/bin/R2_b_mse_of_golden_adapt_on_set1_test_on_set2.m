clear all; clear functions;close all;clc;
addpath('../simulation_fcns/')
addpath('../generic_fcns/')
addpath('../results/')
%% add required paths and data
load('../results/360seconds_systemID_tendondriven_babbling_model.mat')
%%  initializations
%phase2runlimit = 15;
T=10; % simulations length
framespersec=500; % fs
dt=1/framespersec;
tspan_features=linspace(0,T,T*framespersec);
number_of_feautures=10; %T*fs should be = to number_of_features * each_feature_lenght
each_feature_length=500;
done=false;
best_reward=-1000;
net_adapt=net;
best_features=zeros(1,10);
best_pattern_run_kinematics=[];
best_input_force_values=[];
run_numbers = [0 0];
rewards=[];
best_rewards_mode1=[];
best_rewards_mode2=[];
Y_thresh = -1.9; %with -1.85 Y_thresh, 1.9 is almost the highest possible reward
angle_limiting_factor = 0.8;
phase_goal_reward = 1.0;
cum_pattern_run_kinematics=Kinematics(1:3:end,[1, 2, 4, 5]); % for the first run
cum_input_force_values=Force(:,1:3:end);
[reinforce_mode, phase2runlimit, adapt] = deal('cc',10,true);

run_no = 100;
adapt_no = 2;

random_features_library=zeros(run_no*2,10);
for library_cntr=1:run_no*2
    random_features_library(library_cntr,:)= .1*rand(1,10)+.5;
end

%% run 1
mse_results1=zeros(run_no,adapt_no);
net_adapt=net;
for run_no_cntr=1:run_no
    cum_pattern_run_kinematics=Kinematics(1:3:end,[1, 2, 4, 5]); % for the first run
    cum_input_force_values=Force(:,1:3:end);
    close all
    new_rand_features = .4*rand(1,10)+.2;
    run_numbers=[0 0];
    for adapt_no_cntrl=1:adapt_no
        [net_adapt, new_features, run_numbers, done, search_mode] = ...
                generate_new_action_fcn(reinforce_mode, phase_goal_reward, net_adapt, cum_pattern_run_kinematics, cum_input_force_values, best_reward, best_features, run_numbers, phase2runlimit, tspan_features, adapt);
        new_features = random_features_library(run_no_cntr,:);
        [new_reward, new_pattern_run_kinematics, new_input_force_values, new_desired_angs_and_locs, new_real_angs_and_locs] = ...
                    run_simulation_get_reward_fcn(new_features, net_adapt, tspan_features, each_feature_length, dt,ode_params_init, options, Y_thresh, angle_limiting_factor);
        cum_pattern_run_kinematics = [cum_pattern_run_kinematics; new_pattern_run_kinematics];
        cum_input_force_values = [cum_input_force_values new_input_force_values];     
        mse_results1(run_no_cntr,adapt_no_cntrl)=sum((new_desired_angs_and_locs(1,:)-new_real_angs_and_locs(1,:)).^2)+sum((new_desired_angs_and_locs(2,:)-new_real_angs_and_locs(2,:)).^2);
    end
end
%% run 2
adapt_no = 1;
adapt=false;
mse_results2=zeros(run_no,adapt_no);

for run_no_cntr=1:run_no
    cum_pattern_run_kinematics=Kinematics(1:3:end,[1, 2, 4, 5]); % for the first run
    cum_input_force_values=Force(:,1:3:end);
    close all
    new_rand_features = rand(1,10);
    run_numbers=[0 0];
    for adapt_no_cntrl=1:adapt_no
        [net_adapt, new_features, run_numbers, done, search_mode] = ...
                generate_new_action_fcn(reinforce_mode, phase_goal_reward, net_adapt, cum_pattern_run_kinematics, cum_input_force_values, best_reward, best_features, run_numbers, phase2runlimit, tspan_features, adapt);
        new_features = random_features_library(run_no+run_no_cntr,:);
        [new_reward, new_pattern_run_kinematics, new_input_force_values, new_desired_angs_and_locs, new_real_angs_and_locs] = ...
                    run_simulation_get_reward_fcn(new_features, net, tspan_features, each_feature_length, dt,ode_params_init, options, Y_thresh, angle_limiting_factor);
        cum_pattern_run_kinematics = [cum_pattern_run_kinematics; new_pattern_run_kinematics];
        cum_input_force_values = [cum_input_force_values new_input_force_values];     
        mse_results2_oldNN(run_no_cntr,adapt_no_cntrl)=sum((new_desired_angs_and_locs(1,:)-new_real_angs_and_locs(1,:)).^2)+sum((new_desired_angs_and_locs(2,:)-new_real_angs_and_locs(2,:)).^2);
    end
end

for run_no_cntr=1:run_no
    cum_pattern_run_kinematics=Kinematics(1:3:end,[1, 2, 4, 5]); % for the first run
    cum_input_force_values=Force(:,1:3:end);
    close all
    new_rand_features = rand(1,10);
    run_numbers=[0 0];
    for adapt_no_cntrl=1:adapt_no
        [net_adapt, new_features, run_numbers, done, search_mode] = ...
                generate_new_action_fcn(reinforce_mode, phase_goal_reward, net_adapt, cum_pattern_run_kinematics, cum_input_force_values, best_reward, best_features, run_numbers, phase2runlimit, tspan_features, adapt);
        new_features = random_features_library(run_no+run_no_cntr,:);
        [new_reward, new_pattern_run_kinematics, new_input_force_values, new_desired_angs_and_locs, new_real_angs_and_locs] = ...
                    run_simulation_get_reward_fcn(new_features, net_adapt, tspan_features, each_feature_length, dt,ode_params_init, options, Y_thresh, angle_limiting_factor);
        cum_pattern_run_kinematics = [cum_pattern_run_kinematics; new_pattern_run_kinematics];
        cum_input_force_values = [cum_input_force_values new_input_force_values];     
        mse_results2_newNN(run_no_cntr,adapt_no_cntrl)=sum((new_desired_angs_and_locs(1,:)-new_real_angs_and_locs(1,:)).^2)+sum((new_desired_angs_and_locs(2,:)-new_real_angs_and_locs(2,:)).^2);
    end
end
save('R2_b_results_Aug23')