close all
clear 
load('/Users/robot/cross_sim/3dplot/fundamental_params.mat');
load('/Users/robot/cross_sim/3dplot/density_all.mat');

figure(1);
ha1 = axes;
title(ha1,'Speed-Density Diagram','FontSize',20)
xlabel(ha1,' Density K, veh/m','FontSize',18)
ylabel(ha1,' Velocity <V>, m/s','FontSize',18)
hold on
grid on
plot(ha1,k,v,'k')
load('/Users/robot/cross_sim/3dplot/vel_idm.mat');
plot(ha1,density.horizontal,averagesAcrossSimulations.horizontal,'--');
load('/Users/robot/cross_sim/3dplot/vel_aggressive1.mat');
plot(ha1,density.horizontal,averagesAcrossSimulations.horizontal,'b^-');
load('/Users/robot/cross_sim/3dplot/vel_passive1.mat');
plot(ha1,density.horizontal,averagesAcrossSimulations.horizontal,'r-s');
load('/Users/robot/cross_sim/3dplot/vel_hesitant1.mat');
plot(ha1,density.horizontal,averagesAcrossSimulations.horizontal,'go-');
legend(ha1,{'Analytical curve','Idm Cars','Aggressive Cars','Passive Cars','Hesitant Cars'},'FontSize',18)

figure(2);
ha2 = axes;
title(ha2,'Flow-Density Diagram','FontSize',20)
xlabel(ha2,' Density K, veh/m','FontSize',18)
ylabel(ha2,' Flow Q, veh/s','FontSize',18)
hold on
grid on

plot(ha2,k,q,'k')
load('/Users/robot/cross_sim/3dplot/flow_idm.mat');
plot(ha2,density.horizontal,flow.horizontal,'--');
load('/Users/robot/cross_sim/3dplot/flow_aggressive1.mat');
plot(ha2,density.horizontal,flow.horizontal,'b^-');
load('/Users/robot/cross_sim/3dplot/flow_passive1.mat');
plot(ha2,density.horizontal,flow.horizontal,'r-s');
load('/Users/robot/cross_sim/3dplot/flow_hesitant1.mat');
plot(ha2,density.horizontal,flow.horizontal,'go-');
legend(ha2,{'Analytical curve','Idm Cars','Aggressive Cars','Passive Cars','Hesitant Cars'},'FontSize',18)
