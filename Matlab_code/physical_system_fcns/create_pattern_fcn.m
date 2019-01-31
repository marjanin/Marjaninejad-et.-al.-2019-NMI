function [run1_q1_desired_scaled, run1_q2_desired_scaled, Kinematics] = create_pattern_fcn(run1_time, dt, f1, f2, q1min, q1max, q2min, q2max)
% This function generates a custom trajectory (q1 and q2 patterns to move
% in a stride-like pattern. q1min/max, and q2min/max are going to be
% selected manually by the user for now based on the ditribution of the
% babbling data

% run1_time=40;
% f1=.25;
% f2=.25;
% q1min=1800;
% q1max=2500;
% q2min=150;
% q2max=1400;

run1_time_samples = 0:dt:run1_time;
run1_q1_desired_normalized = sin(2*pi*f1*run1_time_samples);
run1_q1_desired_scaled = .5*(q1max-q1min)*(run1_q1_desired_normalized)+.5*(q1max+q1min);
run1_q2_desired_normalized = cos(2*pi*f2*run1_time_samples);
run1_q2_desired_scaled = .5*(q2max-q2min)*(run1_q2_desired_normalized)+.5*(q2max+q2min);
u1 = ddt(run1_q1_desired_scaled,dt);
u2 = ddt(run1_q2_desired_scaled,dt);
du1 = ddt(u1,dt);
du2 = ddt(u2,dt);
Kinematics = [run1_q1_desired_scaled' u1' du1' run1_q2_desired_scaled' u2' du2'];
end

