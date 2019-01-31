%% Initialization
close all;clear all;clc;
for folder_num=0:9
    load(['C:\Users\Ali\Google Drive\Current\USC\Github\Tendon_Driven_Robotics\beyond_imitation_learning\results\Fig2a_Results_Aug26_air_repeated\air_repeated_trajectory_silver_5refinements_', num2str(folder_num), '\matfile_experimentid_air_repeated_trajectory_silver_5refinements_', num2str(folder_num), '_attempt_6_adaptation_T.mat'])
    all_total_mse(folder_num+1,:)=total_mse;
end
%% Visualization
close all
boxplot(all_total_mse)
title('MSE over refinement iterations for a specific trajectory')
xlabel('Iterations with refinement')
ylabel('MSE (10 repetition boxplots)')