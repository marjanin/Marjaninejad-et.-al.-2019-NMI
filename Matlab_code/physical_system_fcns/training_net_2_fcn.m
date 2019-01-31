function [net_trained_2] = training_net_2_fcn(run1_all_data, file_name)
%% Visualization of the inputs
net_trained_1 = run1_all_data.net_trained_1;
dt = run1_all_data.dt;
raw_data=csvread(file_name,1,0);
[processed_data] = preprocessing_fcn(raw_data,.3);
q=processed_data(:,[7, 8]);
A=processed_data(:,[4, 5, 6]);
sample_time=0:dt:dt*size(q,1)-dt;
figure();
plot(sample_time, q);xlabel('time_{(s)}');
ylabel('angle_{(degrees)}');title('q_1 and q_2 from the run');
legend('q1','q2')
figure();
plot(sample_time, A);xlabel('time_{(s)}');
ylabel('motor activation value');title('Actvations from the run');
legend('motor1', 'motor2', 'motor3')
figure();
plot(sample_time, q);xlabel('time_{(s)}');
ylabel('angle_{(degrees)}');hold on;plot(sample_time,run1_all_data.run1_q1_desired_scaled);hold on;
(plot(sample_time,run1_all_data.run1_q2_desired_scaled));
q1_error=mean((q(:,1)-run1_all_data.run1_q1_desired_scaled').^2);
q2_error=mean((q(:,2)-run1_all_data.run1_q2_desired_scaled').^2);
title({'Comparing desired and achieved joint movements',['q_1 error: ',num2str(q1_error),'; q_2 error: ',num2str(q2_error)]});
legend('achieved q_1', 'achieved q_2','desired q_1','desired q_2');
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
% re-training NN
%net_trained_1.trainParam.epochs=10;
[net_trained_2, tr2] = train(net_trained_1,Kinematics_train',A_train');


figure();
plot(Kinematics_train);legend('q1','u1','du1','q2','u2','du2');
title('kinematics of the collected data from the post-babbling trained systems');
xlabel('sample');ylabel('amplitude');
end

