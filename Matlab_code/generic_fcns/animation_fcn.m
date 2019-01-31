function animation_fcn(l,tspan,q1,q2,name)
%animation_fcn will create the animation for the joint angles data provided
%to it
figure()
writerObj = VideoWriter(name);
open(writerObj)
for ii=1:length(tspan)
    animation_progress=100*ii/length(tspan);
    disp(['animation progress:', num2str(animation_progress),'%']);
    pause(.01)
    set_point=75;
    xm1=l*sind(q1(ii)-set_point);
    ym1=-l*cosd(q1(ii)-set_point);
    xm2=xm1+l*sind(q1(ii)+q2(ii)-set_point*2);
    ym2=ym1-l*cosd(q1(ii)+q2(ii)-set_point*2);
    plot([0],[0],'ko','MarkerSize',3); %pivot point
    hold on
    plot([0 xm1],[0 ym1],'r','LineWidth',2);% first pendulum
    plot([xm1 xm2],[ym1 ym2],'b','LineWidth',2);% second pendulum
    axis([-2*l 2*l -2*l 2*l]);
    axis square
    hold off
    set(gca,'xtick',[])
    set(gca,'xticklabel',[])
    set(gca,'ytick',[])
    set(gca,'yticklabel',[])
    title('Desired limb position')
    writeVideo(writerObj,getframe(gcf));
end
close(writerObj)
end
