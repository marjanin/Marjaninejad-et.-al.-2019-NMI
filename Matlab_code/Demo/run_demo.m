clear; clc; close all
addpath('../bin/')
addpath('../simulation_fcns/')
addpath('../generic_fcns/')
user_input_1=input('Please press 1 for physical system runs or 2 for simulation runs: ');
if user_input_1==1
    disp('You have selected physical system')
    disp('Demo code will run motor babbling recorded from the physical system to create the inverse map.')
    disp('This will take less than a minute in most systems.')
    user_input_2=input('Please press 1 to confirm: ');
    if user_input_2==1
        physical_babbling
        % to change the file to babble on, please open the
        % physical_babbling.m and follow the commented instructions
    else
        disp('Run has been aborted by the user')
    end
elseif user_input_1==2
    disp('You have selected simulations')
    disp('Please press 1 to generate motor babbling in simulation and train the inverse map on it')
    disp('or press 2 to run the reward-driven movement learning (see Supplementary Figure 2)')
    disp('or press 3 to run the cyclical movements in air on a single trajectory experiment (see Supplementary Figure 3a,b)')
    disp('or press 4 to run the cyclical movements in air on different trajectories experiment (see Supplementary Figure 3c)')
    user_input_2=input(': ');
    switch user_input_2
        case 1
            user_input_3=input('Generating babbling data and training the ANN will take about 7 mins on an average system. Please press 1 to proceed: ');
            if user_input_3==1
                net = babbling_fcn();
            else
                disp('Run has been aborted by the user')
            end
        case 2
            user_input_3=input('Running this experiment will take about 4 mins on an average system. Please press 1 to proceed: ');
            if user_input_3==1
                SR1_reinforcement_N_times_main
            else
                disp('Run has been aborted by the user')
            end
        case 3
            user_input_3=input('Running this experiment will take about 3.5 mins on an average system. Please press 1 to proceed: ');
            if user_input_3==1
                SR2a_main
            else
                disp('Run has been aborted by the user')
            end
        case 4
            user_input_3=input('Running this experiment will take about 55 mins on an average system. Please press 1 to proceed: ');
            if user_input_3==1
                SR2c_main
            else
                disp('Run has been aborted by the user')
            end
        otherwise
            disp('Invalid choice. Run has been aborted')
    end
end
