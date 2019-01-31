function vis_reward_vs_rep_fcn(run_result, threshold)
% reward_vs_rep plots rewards vs repetitions.

%% individual curves
figure();
for iteration_num_cntr = 1:size(run_result,1)
    plot(0:length([run_result{iteration_num_cntr}]),[0; run_result{iteration_num_cntr}],'color',...
        [0, 0.4470, 0.7410, .3],'linewidth', 1.2); hold on
    current_length_part1 = length([run_result{iteration_num_cntr,1}]);
    current_length_total = length([run_result{iteration_num_cntr,1};run_result{iteration_num_cntr,2}]);
    plot(current_length_part1:current_length_total,[run_result{iteration_num_cntr,1}(end); run_result{iteration_num_cntr,2}],'color',...
        [0.4940, 0.1840, 0.5560, 0.3],'linewidth', 1.2)
end

%% average curve calculations
% phase1 calculations
[avg_results_1, max_length_1] = vis_average_score_fcn(run_result(:,1));
% phase2 calculations
run_result_2_padded = cell(size(run_result,1));
for iteration_num_cntr = 1:size(run_result,1)
    run_result_2_padded{iteration_num_cntr,1}=[nan(size(run_result{iteration_num_cntr,1}));run_result{iteration_num_cntr,2}];
end
[avg_results_2, ~] = vis_average_score_fcn(run_result_2_padded);
acc=0;acc_cntr=0;
for iteration_num_cntr = 1:size(run_result,1)
    if length(run_result{iteration_num_cntr,1})==1
        acc=acc+run_result{iteration_num_cntr,1};
        acc_cntr=acc_cntr+1;
    end
end
avg_results_2(1)=acc/acc_cntr;
% combined calculations
run_results_single=cell(size(run_result,1),1);
for iteration_num_cntr = 1:size(run_result,1)
    run_results_single{iteration_num_cntr}=[run_result{iteration_num_cntr,1};run_result{iteration_num_cntr,2}]';
end
[avg_results_all, max_length_all] = vis_average_score_fcn(run_results_single);

%% average curve plots
plot(0:max_length_all,[0 avg_results_all],'k','linewidth',5)
plot(0:max_length_1,[0 avg_results_1],'c','linewidth',3)
plot(avg_results_2,'color',[1 .11 .5],'linewidth',3)
xlim([0, max_length_all])
line([0 max_length_all],[threshold threshold],'Color','red','LineStyle','--')
xlabel('Try #')
ylabel('Reward')
end