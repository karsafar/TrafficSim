function [k,q, v] = fundamentaldiagram()

delta = 2;
s0 = 6;     % m
s1 = 0;     % m
v0 = 8;    % m/s
T = 1.6;    % sec


v = linspace(0,v0,100);

q = flowpoints(v,s0,s1,v0,T,delta);

k = densitypoints(v,s0,s1,v0,T,delta);

% convert to km and hours
% k = k*1000;
% q = q*3600;

% figure()
% plot(q,v)
% xlabel('q veh/s')
% ylabel('v (m/s)')
% grid on


% figure()
% plot(ha5,k,q,'k')
% xlabel(' Density k (veh/m)')
% ylabel(' Flow q veh/s')
% grid on

% figure()
% plot(k,v)
% xlabel('k (veh/m)')
% ylabel('v (m/s)')
% grid on
%
%
% s = 1./k;
%
% figure()
% plot(s,v)
% xlabel('s (m)')
% ylabel('v (m/s)')
% grid on
end