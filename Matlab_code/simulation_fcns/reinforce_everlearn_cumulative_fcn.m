function [best_rewards_mode1, best_rewards_mode2, rewards, best_desired_angs_and_locs, best_real_angs_and_locs] = ...
    reinforce_everlearn_cumulative_fcn(reinforce_mode, phase2runlimit, adapt)
% reinforce_every_fcn runs the whole system in a loop
% Argument(s):
%    reinforce_mode (str): It will define the reinforcement type
%    phase2runlimit (Int): The number of phase II runs
%    adapt (Logical): Adapts if true and does not adapt if false
% Return(s):
%   reward and best results' dynamics

% todo: add animation to see what is going on

% note 1: make sure that the initial conditions for ODEs are updated for
% each run (I think I checked it)

%% add required paths and data
load('../results/Aug31_100Hz_F15wmin_300seconds_systemID_tendondriven_babbling_model.mat')
%%  initializations
%phase2runlimit = 15;
T=10; % simulations length
framespersec=100; % fs
dt=1/framespersec;
tspan_features=linspace(0,T,T*framespersec);
number_of_feautures=10; %T*fs should be = to number_of_features * each_feature_lenght
each_feature_length=framespersec*T/number_of_feautures;
done=false;
best_reward=-0;
net_adapt=net;
best_features=zeros(1,10);
best_pattern_run_kinematics=[];
best_input_force_values=[];
run_numbers = [0 0];
rewards=[];
best_rewards_mode1=[];
best_rewards_mode2=[];
Y_thresh = -1.75; %with -1.85 Y_thresh, 1.9 is almost the highest possible reward
angle_limiting_factor = 1;
phase_goal_reward = 8;
cum_pattern_run_kinematics=Kinematics(:,[1, 2, 4, 5]); % for the first run
cum_input_force_values=Force;
%% main loop
%coarse search
while ~done
    pause(5)
    close all;nnet.guis.closeAllViews();
    [net_adapt, new_features, run_numbers, done, search_mode] = ...
        generate_new_action_fcn(reinforce_mode, phase_goal_reward, net_adapt, cum_pattern_run_kinematics, cum_input_force_values, best_reward, best_features, run_numbers, phase2runlimit, tspan_features, adapt);
    if ~done
        [new_reward, new_pattern_run_kinematics, new_input_force_values, new_desired_angs_and_locs, new_real_angs_and_locs] = ...
            run_simulation_get_reward_fcn(new_features, net_adapt, tspan_features, each_feature_length, dt,ode_params_init, options, Y_thresh, angle_limiting_factor);
        cum_pattern_run_kinematics = [cum_pattern_run_kinematics; new_pattern_run_kinematics];
        cum_input_force_values = [cum_input_force_values new_input_force_values];
        disp(['size of the data (kinematics) is now: ', num2str(size(cum_pattern_run_kinematics))]);
        disp(['size of the data (forces) is now: ', num2str(size(cum_input_force_values))]);
        disp('----------------------------------------')
        disp(['Best reward: ', num2str(best_reward)])
        disp(['New reward: ',num2str(new_reward)])
        disp('----------------------------------------')
        %physical system will get activation trajectories instead of features as the input.
        %it is easier to work with for the simulation to have feature.
        if new_reward>best_reward
            %net = new_net;
            best_reward = new_reward;
            best_features = new_features;
            best_pattern_run_kinematics = new_pattern_run_kinematics;
            best_input_force_values = new_input_force_values;
            best_desired_angs_and_locs = new_desired_angs_and_locs;
            best_real_angs_and_locs = new_real_angs_and_locs;
            best_run_model=net_adapt;
        end
        rewards = [rewards; new_reward];
        if strcmp(search_mode,'c')
            best_rewards_mode1=[best_rewards_mode1;best_reward];
        elseif strcmp(search_mode,'f')
            best_rewards_mode2=[best_rewards_mode2;best_reward];
        else
            error('invalid search mode for the reinforcement learning')
        end
    end
end

end

