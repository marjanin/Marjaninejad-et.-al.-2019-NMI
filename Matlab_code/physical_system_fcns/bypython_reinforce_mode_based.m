function [done] = bypython_reinforce_mode_based(starting_babble_response_filepath, ...
                                                              reward,...
                                                              response_from_prior_activations_with_encodervals_filepath,...
                                                              input_prior_mat_path,...
                                                              mat_output_filepath,...
                                                              new_activations_filepath,...
                                                              activations_and_kinematics_for_prior_encodervals_filepath,...
                                                              new_desired_kinematics_filepath,...
                                                              maximum_phase1_run_number,...
                                                              goal_reward,...
                                                              adapt,...
                                                              run_mode,...
                                                              num_fine_search_iterations,...
                                                              show_figures)
% Takes in a reward and prior system settings, and outputs new rewards


%print inputs:
% adapt
% reward
% response_from_prior_activations_with_encodervals_filepath
% input_prior_mat_path
% mat_output_filepath
% new_activations_filepath
% activations_and_kinematics_for_prior_encodervals_filepath
% new_desired_kinematics_filepath
% maximum_phase1_run_number
% goal_reward

% Sampling frequency of the control loop for the Raspberry Pi, recorded empirically with low variance.

rng('shuffle')
fs=78;
done=false;
loaded_data=load(input_prior_mat_path);
run_numbers=loaded_data.run_numbers;
net_trained_1=loaded_data.net_trained_1;
%%
response_from_prior_activations_with_encodervals=csvread(response_from_prior_activations_with_encodervals_filepath, 1);
interpolated_response_from_prior_activations_with_encodervals = preprocessing_fcn(response_from_prior_activations_with_encodervals,.3);
if show_figures
    figure()
    subplot(2,2,1)
    plot(interpolated_response_from_prior_activations_with_encodervals(:,[7,8]))
    subplot(2,2,2)
    plot(interpolated_response_from_prior_activations_with_encodervals(:,4:6))
end
%%  add the filters and interpolations you use in the babble for the adaptation as well.
[prior_Kinematics] = angles2kinematics_fcn(interpolated_response_from_prior_activations_with_encodervals(:,7)', interpolated_response_from_prior_activations_with_encodervals(:,8)' ,1/fs);
prior_Act=interpolated_response_from_prior_activations_with_encodervals(:,4:6);
activations_and_kinematics_for_prior_encodervals =[prior_Act prior_Kinematics];
%% writing the kinematics and activations on csv files
if sum(run_numbers)==0
    csvwrite(activations_and_kinematics_for_prior_encodervals_filepath, [activations_and_kinematics_for_prior_encodervals])
else
    csvwrite(activations_and_kinematics_for_prior_encodervals_filepath, [activations_and_kinematics_for_prior_encodervals loaded_data.Kinematics])
end
%% Initializations during runs
if sum(run_numbers)==0 %% initializations for the first run
    all_rewards_vec = [];
    best_rewards_vec = [];
    mse1 = [];
    mse2 = [];
    total_mse = [];
    babble_net = loaded_data.net_trained_1;
    if run_mode==1
        mode1_run_num = 10;
    elseif run_mode==2
        %% Mode2_run num: number of members in group A or B. A is adapt, and B is babble-only (unadapted)
        rng(30);
        mode2_run_num=30;
        feature_dictionary=(0.6*(rand(mode2_run_num,10)-0.5))+0.5;  % train
        %feature_dictionary=rand(mode2_run_num,10);
        tmp=(0.6*(rand(mode2_run_num,10)-0.5))+0.5;  % test
        %tmp=rand(mode2_run_num,10);
        feature_dictionary=[feature_dictionary;tmp;tmp];
    end
else
    all_rewards_vec = loaded_data.all_rewards_vec;
    best_rewards_vec = loaded_data.best_rewards_vec;
    mse1 = loaded_data.mse1;
    mse2 = loaded_data.mse2;
    total_mse = loaded_data.total_mse;
    if run_mode==1
        mode1_run_num = loaded_data.mode1_run_num;
    elseif run_mode==2
        mode2_run_num = loaded_data.mode2_run_num;
        feature_dictionary = loaded_data.feature_dictionary;
    end
    babble_net = loaded_data.babble_net;
end
number_of_features=10;
%% adaptation and doneflag for modes
if run_mode==1
    adapt=1;
    if sum(run_numbers)>mode1_run_num-1
        done = true;
    end
elseif run_mode==2
    if sum(run_numbers)>mode2_run_num
        adapt=0;
    else
        adapt=1;
    end
    if sum(run_numbers)>(3*mode2_run_num)-1
        done = true;
    end
end
%% calculating MSEs
if sum(run_numbers)>0
    %total_mse = loaded_data.total_mse;
    mse1(sum(run_numbers))=mean((loaded_data.Kinematics([round(end/2):end],1)-interpolated_response_from_prior_activations_with_encodervals([round(end/2):end],7)).^2);% it is better if I interpolate response_from... first
    mse2(sum(run_numbers))=mean((loaded_data.Kinematics([round(end/2):end],4)-interpolated_response_from_prior_activations_with_encodervals([round(end/2):end],8)).^2);
    total_mse(sum(run_numbers))=mse1(sum(run_numbers))+mse2(sum(run_numbers));
    disp(['MSE for joint 1: ', num2str(mse1)])
    disp(['MSE for joint 2: ', num2str(mse2)])
    disp(['MSE for both joints: ', num2str(total_mse)])
end
%% decide on staying or moving to the last best position (run_mode 0)
best_reward=loaded_data.best_reward;
best_features=loaded_data.best_features;
if reward>best_reward
    best_reward=reward;% "reward" is generated by loaded_data.new_features
    if sum(run_numbers)>0
    best_features=loaded_data.new_features;
    end
end
best_rewards_vec=[best_rewards_vec; best_reward];
all_rewards_vec=[all_rewards_vec;reward];
disp(['best reward so far: ', num2str(best_reward)]);
%% For a given feature vector, we need to move it to fsHz, over ten cycles.
% to upsample, zeros are placed in the empty spots. Value of the placeholders are based on the connections between the values.
% the number of zeros between datapoints.
each_feature_length=8;

%% Feature space
tspan_features=linspace(0,(80/fs),80);
% For a given feature, this is the maximum, minimum the value selected can be (feature span). Same across all features.
feature_higher_limit=1;
feature_lower_limit=.1;      % 200

%% Learning parameters
if run_mode == 0
    % The coefficient that relates the standard deviation to the residual from current reward to max possible reward. empirically chosen through trial and error
    sd_scale_coefficient = 9000;
    % Approximately the highest reward ever recorded on the system, and serves as an upper bound
    highest_reward = 600;
    % The tightest the gaussian's SD can get.
    sd_minimum = 0.03;
    if best_reward < goal_reward % coarse search
        search_mode='c';
        run_numbers(1)=run_numbers(1)+1;
        disp(['Total run number: ', num2str(sum(run_numbers))])
        disp(['Search mode: Coarse search'])
        if run_numbers(1)>maximum_phase1_run_number
            done=true;
        end
    else
        if run_numbers(2)<num_fine_search_iterations % fine search
            search_mode='f';
    %         net_trained_1.trainParam.epochs = 50;
    %         [net_trained_1, ~] = train(net_trained_1,adaptation_kinematics',adaptation_activation_forces);
    %         view(net_trained_1)
            run_numbers(2)=run_numbers(2)+1;
            disp(['Total run number: ', num2str(sum(run_numbers))])
            disp(['Search mode: Fine search'])
            disp(['Mode run number: ', num2str(run_numbers(2))])
        else % end of the search
            search_mode='f';
            done=true;
            new_features=[];
        end
    end
elseif run_mode==1
    search_mode='c';
    run_numbers(1)=run_numbers(1)+1;
    new_features = .85*ones(1,10) + [-0.1 0.1 0.15 0.12 0.0 -0.1 -0.11 0.1 0.14 -0.1];
    %new_features=.85*ones(1,10);
elseif run_mode==2
    search_mode='c';
    run_numbers(1)=run_numbers(1)+1;
    if ~done
        new_features = feature_dictionary(sum(run_numbers),:);
    end
else
     error('Invalid run mode for the reinforcement learning')
end

if ~done
    %% concatination of the data for adaptation
    disp(['sum(run_numbers) is: ', num2str(sum(run_numbers))])
    if adapt
        if sum(run_numbers)==1
            babble_data=csvread(starting_babble_response_filepath, 1);
            [Kinematics_train,Act_train] = preprocess_and_cal_kinematics(babble_data, 1/fs);
            cum_Kinematics=[Kinematics_train];
            cum_Activations=[Act_train];
        else
            cum_Kinematics=[loaded_data.cum_Kinematics; prior_Kinematics((round(end/4):end),:)];% as a sanity check, comment these lines out and the NN should not change further since it is going to be just the babbling data
            cum_Activations=[loaded_data.cum_Activations; prior_Act((round(end/4):end),:)];% as a sanity check, comment these lines out and the NN should not change further since it is going to be just the babbling data
            [net_trained_1, ~] = physical_NN_model_re_fcn(cum_Kinematics, cum_Activations, net_trained_1);
        end
        disp(['size of cumulative data (Kinematics)is: ', num2str(size(cum_Kinematics))]);
    end
    %% mode select
    if run_mode==0
        switch search_mode
            case 'c'
                new_features=(feature_higher_limit-feature_lower_limit)*rand(1,number_of_features)+feature_lower_limit;
            case 'f'
                %moment_weight = .1;
                rnd_SD = max(sd_minimum,(highest_reward - best_reward)/sd_scale_coefficient);
                disp(['standard deviation: ', num2str(rnd_SD)]);
                rnd_mean=best_features;
                new_features = (rnd_SD*randn(1,number_of_features)) + rnd_mean;% + moment_weight*old_moment;
                new_features=min(new_features, feature_higher_limit*ones(1,number_of_features));
                new_features=max(new_features, feature_lower_limit*ones(1,number_of_features));
            otherwise
                error('Invalid search mode for the reinforcement learning')
        end
    end
    %% For a given feature vector, we need to move it to fsHz, over ten cycles.
    % to upsample, zeros are placed in the empty spots. Value of the placeholders are based on the connections between the values.
    % the number of zeros between datapoints.
    
    [q1_resampled_desired, q2_resampled_desired] = physical_limit_cycle_gen_fcn(new_features, each_feature_length);
    [Kinematics] = angles2kinematics_fcn(repmat(q1_resampled_desired,1,20), repmat(q2_resampled_desired,1,20) ,1/fs);
    % Estimating Activation values for the created pattern
    if run_mode==2
        if sum(run_numbers)>2*mode2_run_num
            run1_A_all_pred = babble_net(Kinematics')';
        else
            run1_A_all_pred = net_trained_1(Kinematics')';
        end
    else
        run1_A_all_pred = net_trained_1(Kinematics')';
    end
    if show_figures
        subplot(2,2,3)
        plot(Kinematics(:,[1,4]))
        subplot(2,2,4)
        plot(run1_A_all_pred(:,:))
    end
    csvwrite(new_activations_filepath,run1_A_all_pred)
    csvwrite(new_desired_kinematics_filepath,[run1_A_all_pred Kinematics])
end
clear loaded_data;
save(mat_output_filepath)
end

