function [xm2, ym2, dxm2, dym2] = cartesian_processing_fcn(q1_resampled,q2_resampled,l,fs)
%cartesian_processing_fcn returns the X, Y location of the endpoint of the
%leg
%% X Y
xm1=l*sin([q1_resampled]);
ym1=-l*cos([q1_resampled]);
xm2=xm1+l*sin([q2_resampled]);
ym2=ym1-l*cos([q2_resampled]);

dxm2=ddt(xm2,fs);
dym2=ddt(ym2,fs);
%% Plottings
% figure()    
% plot(xm2,ym2)
% hold on
% axis equal
% axis([min(xm2) max(xm2) min(ym2) max(ym2)])
% %axis([-pi/2 pi/2 0 pi/2]);
% xlabel('X');ylabel('Y');
% %animation
% for i=1:length(xm2)/15:length(xm2)
%     plot(xm2(round(i)),ym2(round(i)),'r*')
%     axis equal
%     axis([min(xm2) max(xm2) min(ym2) max(ym2)])
%     pause(.1)
% end
end

