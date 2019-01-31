%% Initialization
close all;clear all;clc;
for i=1:5
    data=load(['C:\Users\Ali\Desktop\tmp\matfile_experimentid_air_adaptat_', num2str(i),'.mat']);
    total_mse(i,:)=data.total_mse;
end
mean_total_mse=mean(total_mse);
total_mse_diff=total_mse(:,(size(mean_total_mse,2)/3)+1:2*(size(mean_total_mse,2)/3),:)-total_mse(:,(2*(size(mean_total_mse,2)/3)+1:end),:);
%% Visualization
figure()
bar(1:(size(mean_total_mse,2)/3), mean_total_mse((size(mean_total_mse,2)/3)+1:2*(size(mean_total_mse,2)/3)),'FaceAlpha',.5)
hold on;
bar(1-.1:(size(mean_total_mse,2)/3)-.1, mean_total_mse(2*(size(mean_total_mse,2)/3)+1:end),'FaceAlpha',.5)
legend('With adapt','without adapt','location','northwest')
ylabel('mse');
xlabel('trajectory #')
title('adaptation vs. no adaptation')
mean_mse_yesrefine=mean(mean_total_mse((size(mean_total_mse,2)/3)+1:2*(size(mean_total_mse,2)/3)));
mean_mse_norefine=mean(mean_total_mse(2*(size(mean_total_mse,2)/3)+1:end));
error_reduced_percentage = 100*((mean_mse_norefine-mean_mse_yesrefine)/mean_mse_norefine);
disp(['Mean MSE for the 30 runs with refinement: ', num2str(mean_mse_yesrefine)]);
disp(['Mean MSE for the 30 runs without refinement: ', num2str(mean_mse_norefine)]);
disp(['Reduced error percentage: ', num2str(error_reduced_percentage),'%']);
hold on%figure()
boxplot(-total_mse_diff);hold on;
line([1 30], [0 0], 'color', 'k', 'LineStyle', '--')
ylim([-600 1600])
% figure()
% mse_diff=mean_total_mse(6:10)-mean_total_mse(11:end);
% histogram(mse_diff)