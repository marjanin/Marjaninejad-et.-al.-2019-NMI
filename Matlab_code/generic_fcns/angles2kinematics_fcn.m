function [z_D] = angles2kinematics_fcn(q1, q2 ,delta_t)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
u1=ddt(q1,delta_t);
u2=ddt(q2,delta_t);
du1=ddt(u1,delta_t);
du2=ddt(u2,delta_t);
z_D=[q1' u1' du1' q2' u2' du2'];
end

