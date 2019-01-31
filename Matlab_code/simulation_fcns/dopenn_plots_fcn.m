function dopenn_plots_fcn(t,z,ode_param)
% This function plots joint angles. This function can also plot some energy
% measure (successive difference in total energies) related to pendulum
% physics (second plot)
figure()
plot(t,z(:,1),t,z(:,3)-z(:,1));
xlabel('time (s)'); ylabel('position (rad)');legend('q_1','q_2diff');title('Joint angles')
%% successive difference in total energies
% for i=1:length(t)
%     [KE(i), PE(i)] = dbpend_energy(t(i),z(i,:),ode_param.m1, ode_param.m2, ode_param.I1, ode_param.I2, ode_param.l, ode_param.a, ode_param.g);
% end
% TE = KE + PE;
% TE_diff = diff(TE);
% 
% figure()
% plot(t(1:end-1),TE_diff)

end

