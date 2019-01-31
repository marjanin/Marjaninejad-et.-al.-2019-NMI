function [value,isterminal,direction] = ali_events(t,y)
% Locate the time when height passes through zero in a decreasing direction
% and stop integration.
value = y(1)+1*pi/2;     % detect height = 0
isterminal = 0;   % stop the integration
direction = -1;   % negative direction