function [k,q,v,s_u] = fundamentaldiagram()

delta = 4;
s0 = 2;     % m
l = 4.4;     % m
v0 = 13;    % m/s
T = 1.6;    % sec

n = 20000;
v = linspace(0,v0,n);


k = densitypoints(v,s0,l,v0,T,delta);

q = flowpoints(v,s0,l,v0,T,delta);

% q = v.*k;
s_u = 1./k;
% s_u = gappoints(v,s0,l,v0,T,delta);
s_u(isinf(s_u)) = NaN;


l_c = 16.8;
return
%% 
figure
plot(k,s_u,'b-','LineWidth',2)
hold on
plot(k,l_c.*ones(1,n)+v*4,'r-','LineWidth',2)
xlabel('\rho (veh/m)','FontSize',18)
ylabel('s (m)','FontSize',18)
xlim([0.001 0.1])
ylim([0 100])
legend('Steady-State Space Gap','Minimum Junction "Invisible" Space Gap');

%% 
figure
plot(k,v,'b-','LineWidth',2)
% axis([0 100 0 13])
xlabel('\rho (veh/m)','FontSize',18)
ylabel('Velocity v (m/s)','FontSize',18)
hold on
s_min = l_c +v*4;
v_min = s_min./t_gap;
plot(k,v_min,'r-','LineWidth',2)
xlim([0.001 0.1])
legend('Steady-State Velocity','Minimum Junction "Invisible" Velocity');


%%
t_gap = s_u./v;

figure();
ax1 = plot(k,t_gap,'b-','LineWidth',2);
xlabel(' Density $\rho$ (veh/m)')
ylabel('Time Gap (s)')
grid on
hold on
% 2 seconds gap
tVal = 2
t2sec = tVal*ones(1,n);
% ax2 = plot(k,t2sec,'k--','LineWidth',2);

%

% t_min_fixed = l_c./v;
% ax2 = plot(k,t_min_fixed,'g-','LineWidth',1);
% 



t_min = (l_c+v*(2*tVal))./v;
ax3 = plot(k,t_min,'r-','LineWidth',2);
xlim([0 0.13])
ylim([0 10])


[xi,yi] = polyxpoly(k(1:4:n),t_min(1:4:n),k(1:4:n),t_gap(1:4:n));
ax4 = plot(xi,yi,'k*','LineWidth',3);

legend([ax1,ax3,ax4],{'IDM Steady-State Time Gap','Time to Cross the Junction in a Steady-State Flow',...
    'Physiscal Limiting Point to Cross the Junction in a Steady-State Flow for $t_{\mathrm{min}} = 2\,\mathrm{s}$'},'Location','southeast');

%%
[xi1,yi1] = polyxpoly(k(1:4:n),t_min_fixed(1:4:n),k(1:4:n),t_gap(1:4:n));
ax5 = plot(xi1,yi1,'k*','LineWidth',3);

%%
[xi2,yi2] = polyxpoly(k(1:4:n),t_min(1:4:n),k(1:4:n),t2sec(1:4:n));
legend([ax1,ax2,ax3],{'Steady-State Time Gap','Crossing time with equilibrium velocity',...
    'Crossing time with equilibrium velocity and 2 seconds buffer'},'Location','northwest');
%% 2 wall
rho2sec = xi2*ones(1,n);
t_rng = linspace(1,8,n);
ax4 = plot(rho2sec,t_rng,'k--','LineWidth',1);

%
[xi3,yi3] = polyxpoly(rho2sec(1:5:n),t_rng(1:5:n),k(5000:7000),t_gap(5000:7000));
ax5 = plot(xi,yi,'k*',xi2,yi2,'k*',xi3,yi3,'k*','LineWidth',3);


%%
% t_min = 16.8./v;
% plot(v,s_u)

% axis([0 30 0 50])

% plot(s_u,v)
% lambda = fliplr((s_u./(v.^3)).*((v.^2)/2 - s_u));
% theta = linspace(0,180,8401);
% plot(theta,lambda(1000:9400))

% convert to km and hours
% k = k*1000;
% q = q*3600;

% figure()
% plot(q,v)
% xlabel('q veh/s')
% ylabel('v (m/s)')
% grid on
% 
% 
% figure()
% plot(k,q,'k')
% xlabel(' Density k (veh/m)')
% ylabel(' Flow q veh/s')
% grid on
% 
%%
figure(1)
plot(k,v,'k-','LineWidth',2)
xlabel('Density (veh/m)','FontSize',14)
% xlim([10 80])
% xticks(10:2:80)
ylabel('Average Velocity (m/s)','FontSize',14)
grid on
title('Speed-Density','FontSize',14)


%% space gap
s = 1./k;
y_assimptote = 0:0.0001:0.16;
x_assimptote = ones(1,1601)*6.4;

figure(2)
plot(x_assimptote,y_assimptote,'k--','LineWidth',1)
hold on

y_assimptote = 0:0.01:100;
x_assimptote = ones(1,10001)*16.8;
plot(x_assimptote,y_assimptote,'k--','LineWidth',1)

x_assimptote = 0:1:60;
y_assimptote = ones(1,61)*0.059;
plot(x_assimptote,y_assimptote,'k--','LineWidth',1)

% plot(s,k*500,'k-','LineWidth',2)
plot(s,k,'k-','LineWidth',2)
xlabel('Headway (m)','FontSize',14)
% ylabel('v (m/s)')
ylabel('Density (veh/m)','FontSize',14)
ylim([0.02 0.16])
% yticks(0.020:0.004:0.1562)

% ylabel('Num cars per arm')
% ylim([10 80])
% yticks(10:2:80)
grid on

%% time gap
y_assimptote = 0:0.01:100;
x_assimptote = ones(1,10001)*1.2923;
t = s/v0;

figure(3)
plot(x_assimptote,y_assimptote,'k--','LineWidth',1)
hold on
x_assimptote = 0:0.001:3;
y_assimptote = ones(1,3001)*0.059;
plot(x_assimptote,y_assimptote,'k--','LineWidth',1)

% plot(t,k*500,'k-','LineWidth',2)
plot(t,k,'k-','LineWidth',2)
xlabel('Time Gap (s)','FontSize',14)
xlim([0 3])
xticks(0:0.2:3)
ylabel('Density (veh/m)','FontSize',14)
ylim([0.02 0.144])
yticks(0.020:0.01:0.144)

% ylabel('Num cars per arm')
% ylim([10 72])
% yticks(10:2:72)
grid on


%% number of crosses
figure(4)
x_assimptote = 0:0.01:3000;
y_assimptote = ones(1,300001)*0.06;
plot(x_assimptote,y_assimptote,'k--','LineWidth',1)
hold on

plot(2*q*3600,k,'k-','LineWidth',2)
xlabel('nCrosses/hour,','FontSize',14)
ylabel('Density, \rho','FontSize',14)
ylim([0.02 0.144])
yticks(0.02:0.01:0.144)
xlim([0 3000])
grid on
legend('Critical Density','Analytical Max Capacity')
end