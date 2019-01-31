clear all; clear functions;close all;clc;
addpath('../simulation_fcns/')
addpath('../generic_fcns/')
addpath('../results/')
%net = babbling_fcn();

%
each_phase_attempt_no = 30;
rng(0);
feature_library=[];
rnd_tmp=.5*rand(each_phase_attempt_no,10)+.1;
feature_library=rnd_tmp;
rnd_tmp=.5*rand(each_phase_attempt_no,10)+.1;
feature_library=[feature_library; rnd_tmp; rnd_tmp];
%
adapt=true;

extra_run_results = cell(each_phase_attempt_no,2);
load('../results/Aug31_100Hz_F15wmin_300seconds_systemID_tendondriven_babbling_model.mat')
cum_pattern_run_kinematics=Kinematics(:,[1, 2, 4, 5]); % for the first run
cum_input_force_values=Force;
net_adapt=net;
T=10; % simulations length
framespersec=500; % fs
dt=1/framespersec;
tspan_features=linspace(0,T,T*framespersec);
number_of_feautures=10; %T*fs should be = to number_of_features * each_feature_lenght
each_feature_length=500;
%done=false;
Y_thresh=-2;
angle_limiting_factor=1;
clc;
disp('Run mode: 1');
for attempt_number = 1:each_phase_attempt_no*3
    close all
    disp('\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/');
    disp('----------------------------------------');
    disp('/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\');
    disp(['Attempt number: ', num2str(attempt_number)]);
    %% Main code
    % initialization
    % running the simulation
    new_features=feature_library(attempt_number,:);
    if attempt_number<=each_phase_attempt_no
        adapt = true;
    else
        adapt = false;
    end
    if attempt_number>2*each_phase_attempt_no
        net_adapt = net;
    else
        refined_net=net_adapt;
    end
    [new_reward, new_pattern_run_kinematics, new_input_force_values, new_desired_angs_and_locs, new_real_angs_and_locs] = ...
            run_simulation_get_reward_fcn(new_features, net_adapt, tspan_features, each_feature_length, dt,ode_params_init, options, Y_thresh, angle_limiting_factor);
    % adaptation
    cum_pattern_run_kinematics = [cum_pattern_run_kinematics; repmat(new_pattern_run_kinematics,10,1)];
    cum_input_force_values = [cum_input_force_values (repmat(new_input_force_values,1,10))];
    % storing the results of each attempt
    extra_run_results{attempt_number,1} = new_desired_angs_and_locs;
    extra_run_results{attempt_number,2} = new_real_angs_and_locs;
    q1_desired = new_desired_angs_and_locs(1,:);
    q2_desired = new_desired_angs_and_locs(2,:)-new_desired_angs_and_locs(1,:);
    q1_real = new_real_angs_and_locs(1,:);
    q2_real = new_real_angs_and_locs(2,:)-new_real_angs_and_locs(1,:);
    mse1(attempt_number) = mean((q1_desired-q1_real).^2);
    mse2(attempt_number) = mean((q2_desired-q2_real).^2);
    total_mse(attempt_number) = mse1(attempt_number)+mse2(attempt_number);
    disp(['MSE1: ',num2str(mse1)])
    disp(['MSE2: ',num2str(mse2)])
    disp(['Total MSE: ',num2str(total_mse)])
    % refinement
    if adapt
        [Kinematics_re1, Forces_re1, ~] = input_output_tendondriven_form_fcn(tspan_features, cum_pattern_run_kinematics, cum_input_force_values); % reforming the data to feed to the NN
        [net_adapt, ~] = NN_model_re_fcn(Kinematics_re1, Forces_re1, net_adapt);
    end
end
save('../results/Sep1_SR2b_newconfig_De');
%% Visualization
close all
load('../results/Sep1_SR2b_newconfig_De');
bar(1-.1:each_phase_attempt_no-.1, total_mse(each_phase_attempt_no+1:2*each_phase_attempt_no),'FaceAlpha',.5);hold on;
bar(1:each_phase_attempt_no, total_mse(2*each_phase_attempt_no+1:end),'FaceAlpha',.5);
legend('With adapt','without adapt','location','northwest')
ylabel('mse');
xlabel('trajectory')
xticks(1:30)
xlim([0 31])
ylim([0 .033])
xticklabels({'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',...
    'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'aa', 'bb', 'cc', 'dd'})
title('adaptation vs. no adaptation (simulation)')
mean_mse_yesrefine=mean(total_mse(each_phase_attempt_no+1:2*each_phase_attempt_no));
mean_mse_norefine=mean(total_mse(2*each_phase_attempt_no+1:end));
error_reduced_percentage = 100*((mean_mse_norefine-mean_mse_yesrefine)/mean_mse_norefine);
disp(['Mean MSE for the 30 runs with refinement: ', num2str(mean_mse_yesrefine)]);
disp(['Mean MSE for the 30 runs without refinement: ', num2str(mean_mse_norefine)]);
disp(['Reduced error percentage: ', num2str(error_reduced_percentage),'%']);