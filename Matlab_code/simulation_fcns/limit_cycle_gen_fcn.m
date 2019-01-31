function [q1_system, q2_system] = limit_cycle_gen_fcn(features,each_feature_length, angle_limiting_factor)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
num_of_features=length(features);
feat_angles=[0:2*pi/num_of_features:(2*pi-(2*pi/num_of_features))];
q1_raw=features.*sin(feat_angles);
q2_raw=features.*cos(feat_angles);
q1_scaled=((q1_raw)*pi/2)*angle_limiting_factor+0;
q2_scaled=((q2_raw)*pi/2)*angle_limiting_factor;%-fix these_ranges based on the training data on the abbling;
% disp(['q1_min: ', num2str((180/pi)*min(q1_scaled))])
% disp(['q1_max: ', num2str((180/pi)*max(q1_scaled))])
% disp(['q2_min: ', num2str((180/pi)*min(q2_scaled))])
% disp(['q2_max: ', num2str((180/pi)*max(q2_scaled))])


%figure();plot([q1_raw q1_raw(1)],[q2_raw q2_raw(1)])
q1_scaled_extended = [q1_scaled q1_scaled(1)];
q2_scaled_extended = [q2_scaled q2_scaled(1)];
q1_scaled_long = [];
q2_scaled_long = [];
for ii = 1:num_of_features
    q1_scaled_long = [q1_scaled_long linspace(q1_scaled_extended(ii), q1_scaled_extended(ii+1), each_feature_length)];
    q2_scaled_long = [q2_scaled_long linspace(q2_scaled_extended(ii), q2_scaled_extended(ii+1), each_feature_length)];
end
q1_raw_long_3=[q1_scaled_long(1:end-1) q1_scaled_long(1:end-1) q1_scaled_long];
q2_raw_long_3=[q2_scaled_long(1:end-1) q2_scaled_long(1:end-1) q2_scaled_long];
%figure();plot(q1_raw_long, q2_raw_long)

fir_filter_length = round(each_feature_length/2);
q1_filtered_3 = filtfilt(ones(1, fir_filter_length)/fir_filter_length, 1, q1_raw_long_3);
q2_filtered_3 = filtfilt(ones(1, fir_filter_length)/fir_filter_length, 1, q2_raw_long_3);

q1_filtered=q1_filtered_3(length(q1_scaled_long):2*length(q1_scaled_long)-1);
q2_filtered=q2_filtered_3(length(q2_scaled_long):2*length(q2_scaled_long)-1);

% q2_filtered=zeros(size(q2_filtered));
% q2_filtered(1:end/4)=.7;
% q2_filtered(3*end/4:end)=1;
% q2_filtered=filtfilt(ones(1,500)/500,1,q2_filtered);

q1_system=q1_filtered;
q2_system=q1_filtered+q2_filtered; % the system's q2 is defined as the angle between the second limb and the vertical line (q1+q2 based on joint angles)
% close all
% figure(); plot(q1_filtered, q2_filtered);title('nice fig')
% figure();plot(q1_filtered);hold on;plot(q2_filtered);title('q1 and q2')
% figure();plot(q1_system);hold on;plot(q2_system);title('system')
% pause()

% close all;
% plot(q1_filtered);hold on;plot(q2_filtered)
end

