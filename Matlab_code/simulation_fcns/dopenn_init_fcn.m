function [ode_params_init,framespersec,T,tspan,z0] = dopenn_init_fcn(T)
%dopenn_init_fcn initializes parameters
%%%%%%%%% INITIALIZE PARAMETERS %%%%%%

%Mechanical parameters.
ode_params_init.m1  =  1;    ode_params_init.m2 =  1;  % masses
ode_params_init.I1  =  0.5;  ode_params_init.I2 = 0.5;  % inertias about cms
ode_params_init.l   =  1;              % length of links
ode_params_init.a   =  .5;            % dist. from O to G1 and E to G2 (see figures)
ode_params_init.g   =  10;

% Initial conditions and other settings.
framespersec=100;  %if view is not speeded or slowed in dbpend_animate
%T=60;             %duration of animation  in seconds
tspan=linspace(0,T,T*framespersec);
q1    = 0;%pi/2-0.1; %angle made by link1 with vertical
u1    = 0;        %abslolute velocity of link1   
q2    = 0;%pi ;      %angle made by link2 with vertical
u2    = 0;        %abslolute velocity of link2

z0=[q1 u1 q2 u2]';

end

