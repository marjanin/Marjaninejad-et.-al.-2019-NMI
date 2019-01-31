clear all;
% This code creates and trains the neural network model using the babbling
% data: random activation values output and the kinematics created by those
% activations (using the simulator) as the input of the NN
% This code uses some modified code originally written by simulation by
% Andy Ruina
% link: http://ruina.tam.cornell.edu/research/topics/
% locomotion_and_robotics/ranger/ranger_paper/Reports/
% Ranger_Robot/control/simulator/doublependulum.html

%% initialization
rng(0);
T=300; % running time in seconds
[ode_params_init,framespersec,T,tspan,z0] = dopenn_init_fcn(T);
ode_params=ode_params_init;
%% System ID input generator
fs=framespersec;
pass_chance=1/fs;max_force=15;min_force=1.5;% max force was 12
[~,Force1] = systemID_input_gen_fcn(T,framespersec,pass_chance,max_force,min_force,'d');
[~,Force2] = systemID_input_gen_fcn(T,framespersec,pass_chance,max_force,min_force,'d');
[tForce,Force3] = systemID_input_gen_fcn(T,framespersec,pass_chance,max_force,min_force,'d');
Force=[Force1; Force2; Force3];
[tTor,Tor1,Tor2]=force2torque_fcn(tForce, Force);

% babbling visualizations
close all;plot(tForce,Force1);hold on;plot(tForce,Force2);xlabel('time');hold on;...
    plot(tForce,Force3);xlabel('time');ylabel('Force (N)');legend('F1', 'F2', 'F3');title('Babbling Forces')
figure();plot(tTor,Tor1);hold on;plot(tTor,Tor2);xlabel('time');ylabel('Torque (Nm)');legend('T1','T2');title('Babbling Torques')
%% Running the simulation
options=odeset('Events',@ali_events,'abstol',1e-9,'reltol',1e-9);
[t, z, te, ye, ie] = ode113(@(t,y) dbpend_rhs(t,y,ode_params, tTor, Tor1, Tor2),tspan,z0,options);
save(['../results/Aug31_100Hz_F',num2str(max_force), 'wmin_',num2str(T),'seconds_systemID_tendondriven_babbling_data.mat']);

%% Animation
%dopenn_animation_fcn(l,tspan(1:100:end),z(1:100:end,:))
%% Plots
dopenn_plots_fcn(t,z,ode_params)
%% Calculating the derivatives and formatting the input/output data to be ready to be fed to the NN
[Kinematics, Forces, delta_t] = input_output_tendondriven_form_fcn(tspan,z, Force);
save(['../results/Aug31_100Hz_F',num2str(max_force), 'wmin_',num2str(T),'seconds_babbling_Kinematics_and_Forces.mat'],'Kinematics','Forces','tspan');
%% NN model
layers=[15];
[net, tr] = NN_model_fcn(Kinematics, Forces,layers);
%% Saving all the data
save(['../results/Aug31_100Hz_F',num2str(max_force), 'wmin_',num2str(T),'seconds_systemID_tendondriven_babbling_model.mat']);


