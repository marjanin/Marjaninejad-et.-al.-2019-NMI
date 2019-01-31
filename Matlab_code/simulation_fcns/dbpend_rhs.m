function zdot=dbpend_rhs(t,y,ode_params, tTor, Tor1, Tor2)           

% double pendulum simulation equations and code are adopted, with modifications from:
% http://ruina.tam.cornell.edu/research/topics/locomotion_and_robotics/ranger/ranger_paper/Reports/Ranger_Robot/control/simulator/doublependulum.html

q1 = y(1);                          
u1 = y(2);                          
q2 = y(3);                         
u2 = y(4);  
q2_diff=q2-q1;
u2_diff=u2-u1;
damp_coef=500000;

if (q1>pi/2 && u1>0)
    distance=q1-pi/2;
    damping_ratio_1=1+damp_coef*distance;% was +50
elseif (q1<-pi/2 && u1<0)
    distance=-pi/2-q1;
    damping_ratio_1=1+damp_coef*distance;
else
    damping_ratio_1=1;
end  
    
if (q2_diff>pi/2 && u2_diff>0)
    distance=q2_diff-pi/2;
    damping_ratio_2=1+damp_coef*distance;
elseif (q2_diff<-pi/2 && u2_diff<0)
    distance=-pi/2-q2_diff;
    damping_ratio_2=1+damp_coef*distance;
else
    damping_ratio_2=1;
end

% T1 = 0; %zero torques for unactuated system
% T2 = 0;
% T1=-u1;
% T2=-u2
 
T1=interp1(tTor, Tor1, t)-damping_ratio_1*u1;
T2=interp1(tTor, Tor2, t)-damping_ratio_2*u2_diff;

M11 = -ode_params.I1-ode_params.a^2*ode_params.m1-ode_params.m2*ode_params.l^2;
M12 = -cos(-q1+q2)*ode_params.l*ode_params.a*ode_params.m2;
ode_params.m21 = -cos(-q1+q2)*ode_params.l*ode_params.a*ode_params.m2;
ode_params.m22 = -ode_params.m2*ode_params.a^2-ode_params.I2;

RHS1 = ode_params.m2*ode_params.g*ode_params.l*sin(q1)-ode_params.m2*ode_params.l*u2^2*ode_params.a*sin(-q1+q2)+ode_params.a*sin(q1)*ode_params.m1*ode_params.g-T1+T2;
RHS2 = ode_params.a*sin(q2)*ode_params.m2*ode_params.g-T2+ode_params.m2*ode_params.a*u1^2*ode_params.l*sin(-q1+q2);

M    = [M11 M12; ode_params.m21 ode_params.m22];
RHS  = [RHS1 ; RHS2];
udot =  M \ RHS;

ud1 = udot(1);
ud2 = udot(2);

% [damping_ratio_1 damping_ratio_2]
% [q1 q2_diff]
% t

zdot = [u1 ud1 u2 ud2]'  ;            
