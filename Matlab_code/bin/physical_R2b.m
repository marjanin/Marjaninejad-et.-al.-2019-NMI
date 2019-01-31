%% Initialization
close all;clear all;clc;
load('C:\Users\Ali\Google Drive\Current\USC\Github\Tendon_Driven_Robotics\beyond_imitation_learning\results\air_adaptation_sets_of_30_range0p2to0p8_0\matfile_experimentid_air_adaptation_sets_of_30_range0p2to0p8_0_attempt_91_adaptation_T.mat')
%% Visualization
figure()
bar(1:(size(total_mse,2)/3), total_mse((size(total_mse,2)/3)+1:2*(size(total_mse,2)/3)),'FaceAlpha',.5)
hold on;
bar(1-.1:(size(total_mse,2)/3)-.1, total_mse(2*(size(total_mse,2)/3)+1:end),'FaceAlpha',.5)
legend('With adapt','without adapt','location','northwest')
ylabel('mse');
xlabel('trajectory #')
title('adaptation vs. no adaptation')
mean_mse_yesrefine=mean(total_mse((size(total_mse,2)/3)+1:2*(size(total_mse,2)/3)));
mean_mse_norefine=mean(total_mse(2*(size(total_mse,2)/3)+1:end));
error_reduced_percentage = 100*((mean_mse_norefine-mean_mse_yesrefine)/mean_mse_norefine);
disp(['Mean MSE for the 30 runs with refinement: ', num2str(mean_mse_yesrefine)]);
disp(['Mean MSE for the 30 runs without refinement: ', num2str(mean_mse_norefine)]);
disp(['Reduced error percentage: ', num2str(error_reduced_percentage),'%']);
% figure()
% mse_diff=total_mse(6:10)-total_mse(11:end);
% histogram(mse_diff)