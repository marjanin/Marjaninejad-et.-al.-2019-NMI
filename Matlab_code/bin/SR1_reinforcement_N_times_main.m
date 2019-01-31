clear all; clear functions;close all;clc;
addpath('../simulation_fcns/')
addpath('../generic_fcns/')
addpath('../results/')
%net = babbling_fcn();
%% reinforce_modes = {'cc', 'cf'};
rng(3) % setting the initial random values (default 0)
reinforce_modes = {'cf'};
adapt=true;
for reinforce_mode=reinforce_modes
    N = 1;  % the number of replicates (e.g., 120; 1 is for a single run)
    phase2runlimit = 10; % reward threshold
    run_results = cell(N,2);
    extra_run_results = cell(N,2);
    for attempt_number = 1:N
        clc;
        disp('\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/');
        disp('----------------------------------------');
        disp('/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\');
        disp(['Reincorcement mode: ', reinforce_mode{1}]);
        disp(['Attempt number: ', num2str(attempt_number)]);
        disp('\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/');
        disp('----------------------------------------');
        disp('/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\');
        %% running the reinforcement code
        [best_rewards_mode1, best_rewards_mode2, rewards, best_desired_angs_and_locs, best_real_angs_and_locs] = ...
            reinforce_everlearn_cumulative_fcn(reinforce_mode{1}, phase2runlimit, adapt);
        % storing the results of each attempt
        run_results{attempt_number,1} = best_rewards_mode1;
        run_results{attempt_number,2} = best_rewards_mode2;
        run_results{attempt_number,3} = rewards;
        extra_run_results{attempt_number,1} = best_desired_angs_and_locs;
        extra_run_results{attempt_number,2} = best_real_angs_and_locs;
    end
    save(['../results/Sep1_Adaptcum_120run_results_newconfig_De',reinforce_mode{1}]);
end
%% Visualization (can be used to regenerate plots similar to Supplementary Figure 2
% close all;
% clear all;
% clc;
% reinforce_mode = {'cf'};
% load(['../results/Sep1_Adaptcum_120run_results_newconfig_De',reinforce_mode{1}])
% colormap jet;
% cmap = colormap;
% transparency=.4;
% N2=30;
% figure_num=1;
% run_results_new=run_results;
% for attempt_number = 1:N2
%     run_results_new{attempt_number, 3}(run_results{attempt_number, 3}<0)=0;
% end
% for reinforce_mode=reinforce_modes
%     figure(figure_num)
%     rewards_for_hist=[];
%     best_rewards_for_hist=[];
%     phaseI_length_for_hist=[];
%     for attempt_number = 1:N2
%         run_length = length(run_results_new{attempt_number,3});
%         plot(0:run_length, [0; run_results_new{attempt_number,1}; run_results_new{attempt_number,2}],'linewidth', 2, 'color',[cmap(attempt_number*2,:) transparency]);hold on
%         scatter(0:run_length, [0; run_results_new{attempt_number,3}],'MarkerFaceColor',[cmap(attempt_number*2,:)],'MarkerEdgeColor',[1 1 1])
%         alpha(transparency)
%         phaseI_length_for_hist=[phaseI_length_for_hist; length(run_results{attempt_number,1})];
%         rewards_for_hist=[rewards_for_hist; run_results_new{attempt_number,3}];
%         best_rewards_for_hist=[best_rewards_for_hist; run_results_new{attempt_number,2}(end)];
%         [~, best_attempt_index(attempt_number)]=max([run_results{attempt_number,1};run_results{attempt_number,2}]);
%     end
%     rewards_for_hist(rewards_for_hist<0)=0;
%     line([0 max(xticks)],[8 8],'color','red','LineStyle','--')
%     xlabel('attempt')
%     ylabel('reward')
%     xlim([0 45])
%     ylim([0 14])
%     figure_num=figure_num+1;
%     figure(figure_num)
%     histogram(rewards_for_hist);hold on
%     figure_num=figure_num+1;
%     figure(figure_num)
%     histogram(best_rewards_for_hist);hold on
%     figure_num=figure_num+1;
%     figure(figure_num)
%     boxplot(best_rewards_for_hist)
%     ylim([0 14])
%     figure_num=figure_num+1;
%     figure(figure_num)
%     histogram(phaseI_length_for_hist)
%     figure_num=figure_num+1;
%     figure(figure_num)
%     boxplot(phaseI_length_for_hist)
%     ylim([0 45])
%     figure_num=figure_num+1;
%     figure(figure_num)
%     histogram(best_attempt_index)
%     figure_num=figure_num+1;
%     figure(figure_num)
%     boxplot(best_attempt_index)
%     ylim([0 45])
% end
