function [net, new_features, run_numbers, done, search_mode] = ...
    generate_new_action_fcn(reinforce_type, phase_goal_reward, net, adaptation_kinematics, adaptation_activation_forces, reward, old_features, run_numbers, phase2runlimit, tspan_features, adapt)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

number_of_feautures=length(old_features);
feature_higher_limit=1;
feature_lower_limit=.1;
done=false;
if reward < phase_goal_reward % coarse search
    search_mode='c';
    run_numbers(1)=run_numbers(1)+1;
    disp(['Total run number: ', num2str(sum(run_numbers))])
    disp('Search mode: Phase I')
    disp(['Mode run number: ', num2str(run_numbers(1))])
else
    if run_numbers(2)<phase2runlimit % fine search
        search_mode='f';
        run_numbers(2)=run_numbers(2)+1;
        disp(['Total run number: ', num2str(sum(run_numbers))])
        disp('Search mode: Phase II')
        disp(['Mode run number: ', num2str(run_numbers(2))])
    else % end of the search
        search_mode='f';
        done=true;
        new_features=[];
    end
end

if ~done
    switch search_mode
        case 'c'
            new_features=(feature_higher_limit-feature_lower_limit)*rand(1,number_of_feautures)+feature_lower_limit;
        case 'f'
            %moment_weight = .1;
            if strcmp(reinforce_type,'cf')
                rnd_SD = max(0.05,(8.5-reward)/1);
                %rnd_SD
                rnd_mean = old_features;
                new_features = (rnd_SD*randn(1,number_of_feautures)) + rnd_mean;% + moment_weight*old_moment;
                new_features=min(new_features, feature_higher_limit*ones(1,number_of_feautures));
                new_features=max(new_features, feature_lower_limit*ones(1,number_of_feautures));
            elseif strcmp(reinforce_type,'cc')
                new_features=(feature_higher_limit-feature_lower_limit)*rand(1,number_of_feautures)+feature_lower_limit;
            else
                error('invalid reinforcement type')
            end
        otherwise
            error('invalid search mode for the reinforcement learning')
    end
    if sum(run_numbers)>1 % skip the first one
        if adapt
            [Kinematics_re1, Forces_re1, ~] = input_output_tendondriven_form_fcn(tspan_features, adaptation_kinematics, adaptation_activation_forces); % reforming the data to feed to the NN
            [net, ~] = NN_model_re_fcn(Kinematics_re1, Forces_re1, net);
        end
    end
end

end

