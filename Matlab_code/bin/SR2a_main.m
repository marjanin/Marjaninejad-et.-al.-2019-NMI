clear all; clear functions;close all;clc;
addpath('../simulation_fcns/')
addpath('../generic_fcns/')
addpath('../results/')
%net = babbling_fcn();


load('../results/Aug31_100Hz_F15wmin_300seconds_systemID_tendondriven_babbling_model.mat')
rng(4);
new_features=.4*ones(1,10)+.3*rand(1,10);
adapt=true;
N=10; %max attempt_number
extra_run_results = cell(N,2);
cum_pattern_run_kinematics=Kinematics(:,[1, 2, 4, 5]); % for the first run
cum_input_force_values=Force;
net_adapt=net;
T=10; % simulations length
framespersec=100; % fs
dt=1/framespersec;
tspan_features=linspace(0,T,T*framespersec);
number_of_feautures=10; %T*fs should be = to number_of_features * each_feature_lenght
each_feature_length=100;
%done=false;
Y_thresh=-2;
angle_limiting_factor=1;
clc;
disp('Run mode: 1');
for attempt_number = 1:N
    pause(5);close all
    disp('\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/');
    disp('----------------------------------------');
    disp('/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\');
    disp(['Attempt number: ', num2str(attempt_number)]);
    %% Main code
    % initialization
    % running the simulation
    [new_reward, new_pattern_run_kinematics, new_input_force_values, new_desired_angs_and_locs, new_real_angs_and_locs] = ...
            run_simulation_get_reward_fcn(new_features, net_adapt, tspan_features, each_feature_length, dt,ode_params_init, options, Y_thresh, angle_limiting_factor);
    % adaptation
    cum_pattern_run_kinematics = [cum_pattern_run_kinematics; repmat(new_pattern_run_kinematics,10,1)];
    cum_input_force_values = [cum_input_force_values (repmat(new_input_force_values,1,10))];
    % storing the results of each attempt
    extra_run_results{attempt_number,1} = new_desired_angs_and_locs;
    extra_run_results{attempt_number,2} = new_real_angs_and_locs;
    q1_desired = new_desired_angs_and_locs(1,:);
    q2_desired_diff = new_desired_angs_and_locs(2,:)-new_desired_angs_and_locs(1,:);
    q1_real = new_real_angs_and_locs(1,:);
    q2_real_diff = new_real_angs_and_locs(2,:)-new_real_angs_and_locs(1,:);
    mse1(attempt_number) = mean((q1_desired-q1_real).^2);
    mse2(attempt_number) = mean((q2_desired_diff).^2);
    total_mse(attempt_number) = mse1(attempt_number)+mse2(attempt_number);
    mean_mse(attempt_number)=total_mse(attempt_number)/2;
    disp(['MSE1: ',num2str(mse1)])
    disp(['MSE2: ',num2str(mse2)])
    disp(['Total MSE: ',num2str(total_mse)])
    disp(['mean MSE: ',num2str(mean_mse)])
    % refinement
    if adapt && (attempt_number~=N)
        [Kinematics_re1, Forces_re1, ~] = input_output_tendondriven_form_fcn(tspan_features, cum_pattern_run_kinematics, cum_input_force_values); % reforming the data to feed to the NN
        [net_adapt, ~] = NN_model_re_fcn(Kinematics_re1, Forces_re1, net_adapt);
    end
end
save('../results/Sep1_SR2a_silver_newconfig_De');

%% Visualization
close all;clear all;clc;
N=10;
disp('Visualization')
load('../results/Sep1_SR2a_silver_newconfig_De');
boxplot(repmat(total_mse,5,1))
ylim([.4 .425])
title('MSE over refinement iterations for a specific trajectory (simulation)')
xlabel('Iterations with refinement')
ylabel('MSE (single repetition)')
%
figure()
bar(total_mse)
title('MSE over refinement iterations for a specific trajectory (simulation)')
xlabel('Iterations with refinement')
ylabel('MSE (single repetition)')
%
for refine_num_cntr=1:N
    q1_desired(refine_num_cntr,:) = extra_run_results{refine_num_cntr,1}(1,:);
    q2_desired_diff(refine_num_cntr,:) = extra_run_results{refine_num_cntr,1}(2,:) - extra_run_results{refine_num_cntr,1}(1,:);
    q1_real(refine_num_cntr,:) = extra_run_results{refine_num_cntr,2}(1,:);
    q2_real_diff(refine_num_cntr,:) = extra_run_results{refine_num_cntr,2}(2,:) - extra_run_results{refine_num_cntr,2}(1,:);
end
%
figure()
%plot(q1_desired(refine_num_cntr,:),q2_desired(refine_num_cntr,:));
M=6;
subplot_cntr=0;
for refine_num_cntr=[1,2:2:10]
    subplot_cntr=subplot_cntr+1;
    figure(3)
    subplot(1,M,subplot_cntr);plot(q1_real(refine_num_cntr,:),q2_real_diff(refine_num_cntr,:));hold on; plot(q1_desired(refine_num_cntr,:),q2_desired_diff(refine_num_cntr,:));
    if subplot_cntr~=1
        yticks([])
    end
    xlabel('Proximal')
    if subplot_cntr==1
        ylabel('Distal')
    end
    axis equal
    axis([-1. 1.2 -1.35 1.2])
    figure(4)
    subplot(2,M,subplot_cntr);plot(q1_desired(refine_num_cntr,:));hold on; plot(q1_real(refine_num_cntr,:));ylim([-.8 1.1]);
    if subplot_cntr~=1
        yticks([])
    end
    xticks([])
    subplot(2,M,M+subplot_cntr);plot(q2_desired_diff(refine_num_cntr,:));hold on; plot(q2_real_diff(refine_num_cntr,:));ylim([-1.4 1.1]);
    if subplot_cntr~=1
        yticks([])
    end
end