function [reward] = caclulate_reward_fcn(X, Y, dX, dY, Y_thresh, pl)
%UNTITLED Summary of this function goes here

%%
% now it only cares about the sample for which the condition applies
% (Y<-1.7) and dx<0 therefore, if the leg moves very slow in those
% conditions, it will still consider that as a really good move. I need to
% integrate over the velocity so that it actually calculates the
% displacement.
%%
%   Detailed explanation goes here
% X,Y,dX,dY

%dX=dX/max(dX);
%tread_run=sum(Y<-1.7 & dX<0)-sum(Y<-1.7 & dX>0);

touch_indices=find(Y<Y_thresh);
tread_run=sum(dX(touch_indices)<0)-sum(dX(touch_indices)>0);
reward_raw=tread_run/length(X);
tread_run=-sum(dX(touch_indices))*10000/15;
reward_raw=tread_run;

reward=reward_raw;%*1e7;
%reward=reward-pl/7;

end

