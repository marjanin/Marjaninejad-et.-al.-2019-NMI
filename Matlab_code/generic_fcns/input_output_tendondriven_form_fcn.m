function [Kinematics,Forces,delta_t] = input_output_tendondriven_form_fcn(tspan, z, Force)
%input_output_form_fcn calculates acceleration values and forms the input/outputs to feed to the NN
%z=z(1:end-1,:);
Force1=Force(1,:);
Force2=Force(2,:);
Force3=Force(3,:);
delta_t=(tspan(end)-tspan(end-1));
ud1_=ddt(z(:,2),delta_t);
ud2_=ddt(z(:,4),delta_t);
Kinematics=[z(:,1) z(:,2) ud1_ z(:,3) z(:,4) ud2_];
Force1_resam=resample(Force1',size(z,1),size(Force1',1));
Force2_resam=resample(Force2',size(z,1),size(Force2',1));
Force3_resam=resample(Force3',size(z,1),size(Force3',1));
Forces=[Force1_resam Force2_resam Force3_resam];
end
