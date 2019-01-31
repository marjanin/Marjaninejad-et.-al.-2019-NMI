function vis_try_and_reward_distributions_fcn(run_result)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
final_rewards=zeros(1,size(run_result,1));
try_number=zeros(1,size(run_result,1));
for iteration_num_cntr = 1:size(run_result,1)
    try_number(iteration_num_cntr) = length(run_result{iteration_num_cntr,1})+length(run_result{iteration_num_cntr,2});
    final_rewards(iteration_num_cntr) = run_result{iteration_num_cntr,2}(end);
end
figure();
subplot(1,2,1);
hist(try_number)
mean_try_num=mean(try_number);
disp(['mean attempt number: ',num2str(mean_try_num)])
xlabel('number of total tries')
ylabel('frequency')
subplot(1,2,2);
hist(final_rewards)
mean_final_rewards=mean(final_rewards);
disp(['mean final reward: ',num2str(mean_final_rewards)])
xlabel('Final reward')
end

