function [processed_data] = preprocessing_fcn(raw_data,filter_cuttoff)
% This function takes the raw_data matrix (coming from the physical system)
% and first, resamples it (interpolates to have constant sampling rate) and
% next, smoothens the encoder recordings (lowpass filter with normalized
% cutt-off (input argument)
% input(s):
%   raw_data: N by 8 matrix coming from the physical system
%   filter_cuttoff: the normalized cutt-off frequency of the lowwpass
%       filter [0-1]
% outpu(s):
%   processed_data
%
% columns of raw_data are supposed to be in the following order:
%   [Order Start_Time End_Time PWM1 PWM2 PWM3 HIP(deg) KNEE(deg)]

%% resampling (interpolating to create uniformly sampled data)
resampled_data=raw_data;
[resampled_data(:,4:8),resampled_data(:,3)] = resample(raw_data(:,4:8),raw_data(:,3));
resampled_data(:,2)=resampled_data(:,3);
%% smoothening (bi-directional low-pass filtering) the joint angles (encoder values)
filter_order=6;
smooth_data=resampled_data;
% [b,a]=butter(filter_order,filter_cuttoff,'low');   % Bandpass digital filter design
% smooth_data(:,7:8)=filtfilt(b,a,resampled_data(:,7:8));
processed_data=smooth_data;
%% visualization
% %h = fvtool(b,a);                       % Visualize filter
% index_to_compare=7;
% plot(data(:,index_to_compare));hold on;plot(resampled_data(:,index_to_compare));plot(smooth_data(:,index_to_compare))
end