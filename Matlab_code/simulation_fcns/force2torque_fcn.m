function [tTor,Tor1,Tor2]=force2torque_fcn(tForce, Force)
%force2torque_fcn Creates torque values for a 2DOF tendon driven system
%with moment arm matrix R and muscle force values Force1, Force2, and
%Force 3.
Force1=Force(1,:);
Force2=Force(2,:);
Force3=Force(3,:);
tTor=tForce;
R=[1.2 -1.5 -.5;
    0 -.9 .8];
Tor_m=R*[Force1; Force2; Force3];
Tor1=Tor_m(1,:);
Tor2=Tor_m(2,:);
end

