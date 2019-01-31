function [net_trained_1] = training_net_1_fcn(file_name, dt)
% This function creates a NN model and trains it with the data provided in
% the "filename.csv" in the "..\data" folder
%data = [Order Start_Time End_Time PWM1 PWM2 PWM3 HIP(deg) KNEE(deg)];
%% loading and pre-processing the data
raw_data=csvread(file_name,1,0);
[processed_data] = preprocessing_fcn(raw_data,.3);
%processed_data=raw_data;
q=processed_data(:,[7, 8]);
A=processed_data(:,[4, 5, 6]);
sample_time=0:dt:dt*size(q,1)-dt;

%% NN - Train
% assigning the training data
data_train = processed_data;%because we want to train the model as well as possible in this stage%data(1:end/2,:);
q_train=data_train(:,[7, 8]);
A_train=data_train(:,[4, 5, 6]);
% calculating kinematics
u1=ddt(q_train(:,1),dt);
u2=ddt(q_train(:,2),dt);
du1=ddt(u1,dt);
du2=ddt(u2,dt);
Kinematics_train=[q_train(:,1) u1 du1 q_train(:,2) u2 du2];
% creating and training NN
layers=[15];
net_trained_1=feedforwardnet(layers);
% neural network already scales internally, so tansig yields values in the
% range the input.
net_trained_1.layers{length(layers) + 1}.transferFcn = 'tansig';
[net_trained_1, tr] = train(net_trained_1,Kinematics_train',A_train');
%% NN- Test
% assigning the test data
data_test = processed_data((end/2)+1:end,:);
q_test=data_test(:,[7, 8]);
A_test=data_test(:,[4, 5, 6]);
% calculating kinematics
u1=ddt(q_test(:,1),dt);
u2=ddt(q_test(:,2),dt);
du1=ddt(u1,dt);
du2=ddt(u2,dt);
Kinematics_test=[q_test(:,1) u1 du1 q_test(:,2) u2 du2];
% running the NN
A_p_test=net_trained_1(Kinematics_test')';

%% Visualization of the inputs
figure();
plot(Kinematics_train);legend('q1','u1','du1','q2','u2','du2');
title('kinematics of the collected babbling data');
xlabel('sample');ylabel('amplitude');
figure();
plot(sample_time, q);xlabel('time_{(s)}');
ylabel('angle_{(degrees)}');title('q_1 and q_2 from babbling');
legend('q1','q2')
figure();
plot(sample_time, A);xlabel('time_{(s)}');
ylabel('motor activation value');title('Actvations from babbling');
legend('motor1', 'motor2', 'motor3');

%% Visualization of the test outputs
figure();
for act_ind=1:3
subplot(1,3,act_ind);plot(A_test(:,act_ind));hold on;plot(A_p_test(:,act_ind));
    xlabel('time_{(ms)}');ylabel('angle_{(degrees)}');
    title(['Activation ',num2str(act_ind),' (test)']);
    legend('real','predicted');
end
