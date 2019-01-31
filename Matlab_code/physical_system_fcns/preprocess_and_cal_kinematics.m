function [Kinematics_train,Act_train] = preprocess_and_cal_kinematics(data, dt)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[processed_data] = preprocessing_fcn(data,.3);
% q=processed_data(:,[7, 8]);
% A=processed_data(:,[4, 5, 6]);
% sample_time=0:dt:dt*size(q,1)-dt;
data_train = processed_data;%because we want to train the model as well as possible in this stage%data(1:end/2,:);
q_train=data_train(:,[7, 8]);
Act_train=data_train(:,[4, 5, 6]);
u1=ddt(q_train(:,1),dt);
u2=ddt(q_train(:,2),dt);
du1=ddt(u1,dt);
du2=ddt(u2,dt);
Kinematics_train=[q_train(:,1) u1 du1 q_train(:,2) u2 du2];
end

