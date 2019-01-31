clear all;close all;clc;
load('C:\Users\Ali\Google Drive\Current\USC\Github\Tendon_Driven_Robotics\beyond_imitation_learning\results\reinforce_2_0\matfile_experimentid_reinforce_2_0_attempt_42_adaptation_T.mat')
threshold=300;
all_rewards_vec(1)=0;
best_rewards_vec(1)=0;
plot(0:length(all_rewards_vec)-1,all_rewards_vec,'r*');hold on
plot(0:length(all_rewards_vec)-1,best_rewards_vec)
line([0 length(all_rewards_vec)-1],[threshold threshold], 'color', 'red', 'LineStyle', '--')
xlim([0 length(all_rewards_vec)-1])
xlabel('attempt #')
ylabel('reward')
title('reinforcement with adaptation')