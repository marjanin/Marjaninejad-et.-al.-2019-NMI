function zdot=dbpend_rhs_mapping(t,y,ode_params, tTor, Tor1, Tor2)           

% double pendulum simulation equations and code are adopted, with modifications from:
% http://ruina.tam.cornell.edu/research/topics/locomotion_and_robotics/ranger/ranger_paper/Reports/Ranger_Robot/control/simulator/doublependulum.html

%t
%y

q1 = y(1);                          
u1 = y(2);                          
q2 = y(3);                         
u2 = y(4);  
%if max(y(1),y(3))>pi || min(y(1),y(3))<-pi
if (q1>pi/2 && u1>0)
    distance=q1-pi/2;
    damping_ratio_1=1+50*distance;
elseif (q1<-pi/2 && u1<0)
    distance=-pi/2-q1;
    damping_ratio_1=1+50*distance;
else
    damping_ratio_1=1;
end  
    
if (q2>pi/2 && u2>0)
    distance=q2-pi/2;
    damping_ratio_2=1+50*distance;
elseif (q2<-pi/2 && u2<0)
    distance=-pi/2-q2;
    damping_ratio_2=1+50*distance;
else
    damping_ratio_2=1;
end

%[damping_ratio_1 damping_ratio_2]

                     
%t
% T1 = 0; %zero torques for unactuated system
% T2 = 0;
% T1=-u1;
% T2=-u2
% 
T1in_notlimited=interp1(tTor, Tor1, t);
T2in_notlimited=interp1(tTor, Tor2, t);

[T1in_limited] = limit_in_range_fcn(T1in_notlimited, ode_params.max_Tor_limit, ode_params.min_Tor_limit);
[T2in_limited] = limit_in_range_fcn(T2in_notlimited, ode_params.max_Tor_limit, ode_params.min_Tor_limit);

T1=T1in_limited-damping_ratio_1*u1;
T2=T2in_limited-damping_ratio_2*u2;



M11 = -ode_params.I1-ode_params.a^2*ode_params.m1-ode_params.m2*ode_params.l^2;
M12 = -cos(-q1+q2)*ode_params.l*ode_params.a*ode_params.m2;
M21 = -cos(-q1+q2)*ode_params.l*ode_params.a*ode_params.m2;
M22 = -ode_params.m2*ode_params.a^2-ode_params.I2;

RHS1 = ode_params.m2*ode_params.g*ode_params.l*sin(q1)-ode_params.m2*ode_params.l*u2^2*ode_params.a*sin(-q1+q2)+ode_params.a*sin(q1)*ode_params.m1*ode_params.g-T1+T2;
RHS2 = ode_params.a*sin(q2)*ode_params.m2*ode_params.g-T2+ode_params.m2*ode_params.a*u1^2*ode_params.l*sin(-q1+q2);

M    = [M11 M12; M21 M22];
RHS  = [RHS1 ; RHS2];
udot =  M \ RHS;

ud1 = udot(1);
ud2 = udot(2);

zdot = [u1 ud1 u2 ud2]'  ;            
