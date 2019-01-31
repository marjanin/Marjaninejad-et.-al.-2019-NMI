function [reward, pattern_modelout, input_force_values, desired_angs_and_locs, real_angs_and_locs] = run_simulation_get_reward_fcn(new_features, net,...
    tspan_features, each_feature_length, dt,ode_params_init, options, Y_thresh, angle_limiting_factor)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
[q1_resampled_desired, q2_resampled_desired] = limit_cycle_gen_fcn(new_features, each_feature_length, angle_limiting_factor);
[X_desired, Y_desired, dX_Dsired, dY_desired] = cartesian_processing_fcn(q1_resampled_desired,q2_resampled_desired,ode_params_init.l,1/dt);
[pattern_desired] = angles2kinematics_fcn(q1_resampled_desired, q2_resampled_desired ,dt);
%ode_params_init.max_Tor_limit=2000;ode_params_init.min_Tor_limit=-2000;

initial_conds=[pattern_desired(1,1) pattern_desired(1,2) pattern_desired(1,4) pattern_desired(1,5)];
input_force_values=net(pattern_desired');
[tTor,Tor1_P,Tor2_P]=force2torque_fcn(tspan_features, input_force_values);
[time_pattern_modelout, pattern_modelout, te_P, ye_P, ie_P] = ode113(@(t,y) dbpend_rhs(t,y,ode_params_init, tspan_features, Tor1_P, Tor2_P),tspan_features,initial_conds,options);
% visualizing the run
figure();subplot(1,2,1);plot(pattern_desired(:,1));hold on;plot(pattern_modelout(:,1));xlabel('samples');ylabel('q_1');legend('Desired','Controlled')
subplot(1,2,2);plot(pattern_desired(:,4)-pattern_desired(:,1));hold on;plot(pattern_modelout(:,3)-pattern_modelout(:,1));xlabel('samples');ylabel('q_2');legend('Desired','Controlled')
[X_real, Y_real, dX_real, dY_real] = cartesian_processing_fcn(pattern_modelout(:,1),pattern_modelout(:,3),ode_params_init.l,1/dt);
%[pl] = path_length_fcn(X_real, Y_real);
[reward] = caclulate_reward_fcn(X_real, Y_real, dX_real, dY_real, Y_thresh, 0);
%visualize limit cycles
%% packing kinematic outputs
q1_real=pattern_modelout(:,1);
q2_real=pattern_modelout(:,3);
real_angs_and_locs=[q1_real';q2_real';X_real';Y_real';];
desired_angs_and_locs=[q1_resampled_desired;q2_resampled_desired;X_desired;Y_desired;];
figure();plot(real_angs_and_locs(1,:), real_angs_and_locs(2,:)-real_angs_and_locs(1,:));title('angle space plot');xlabel('q_1');ylabel('q2');axis([-pi/2 pi/2 -pi/2 pi])
hold on;plot(desired_angs_and_locs(1,:), desired_angs_and_locs(2,:)-desired_angs_and_locs(1,:)); legend('real (which yielded the reward','desired')
figure();plot(real_angs_and_locs(3,:), real_angs_and_locs(4,:));hold on;line([-2 2],[Y_thresh Y_thresh],'color','r')
title('X-Y space');xlabel('X');ylabel('Y');axis([-2*ode_params_init.l 2*ode_params_init.l -2*ode_params_init.l ode_params_init.l])
end
