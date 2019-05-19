clc
clear
close all

%load data in the loop
d = dir('test-*');          
Number_mat = length(d);   
clear d
for i = 1:Number_mat
        filename = sprintf('test-%s.mat',num2str(i));
        load(fullfile(filename),'-mat','sim','density')
        
        eastArm.density(i) = density;
        northArm.density(i) = density;
        junction.density(i) = density;
        
        eastArm.meanVelocity(i) = nanmean(sim.horizArm.averageVelocityHistory);
        northArm.meanVelocity(i) = nanmean(sim.vertArm.averageVelocityHistory);
        junction.meanVelocity(i) = nanmean([eastArm.meanVelocity(i),northArm.meanVelocity(i)]);
        
        clear sim density
end

eastArm.flow = eastArm.density.*eastArm.meanVelocity;
northArm.flow = northArm.density.*northArm.meanVelocity;
junction.flow = junction.density.*junction.meanVelocity;

save('processedData.mat','eastArm','northArm','junction')

%%

load('processedData.mat')
%%
plot_density_speed(eastArm.density,eastArm.meanVelocity,northArm.density,northArm.meanVelocity, junction.density,junction.meanVelocity);

plot_density_flow(eastArm.flow,eastArm.density, northArm.flow,northArm.density,junction.flow,junction.density);

plot_flow_speed(eastArm.flow,eastArm.meanVelocity,northArm.flow,northArm.meanVelocity,junction.flow,junction.meanVelocity)


%% plot density-speed diagrams

plot_density_speed(eastArm.density,eastArm.meanVelocity,northArm.density,northArm.meanVelocity, junction.density,junction.meanVelocity);

%%
% plot_density_speed(northArm.density,northArm.meanVelocity);
%%
% plot_density_speed(junction.density,junction.meanVelocity);

%% plot density-flow diagrams

plot_density_flow(eastArm.flow,eastArm.density, northArm.flow,northArm.density,junction.flow,junction.density);
%%
% plot_density_flow(northArm.flow,northArm.density);
%%
% plot_density_flow(junction.flow,junction.density);
% 
%% plot speed-flow diagrams

plot_flow_speed(eastArm.flow,eastArm.meanVelocity,northArm.flow,northArm.meanVelocity,junction.flow,junction.meanVelocity)
%%
% plot_flow_speed(northArm.flow,northArm.meanVelocity)
%%
% plot_flow_speed(junction.flow,junction.meanVelocity)



%% ploting funcitons
%
function plot_density_speed(density1,meanVelocity1,density2,meanVelocity2,density3,meanVelocity3)
% figure;
ha9 = subplot(2,2,1);
title(ha9,'Speed-Density Diagram','FontSize',20)
xlabel(ha9,' Density K, veh/m','FontSize',18)
ylabel(ha9,' Velocity <V>, m/s','FontSize',18)
hold on
grid on
[k,q,v] = fundamentaldiagram();
plot(ha9,k,v,'k')
plot(ha9,density1,meanVelocity1,'-b');
plot(ha9,density2,meanVelocity2,'r-');
plot(ha9,density3,meanVelocity3,'g--');
legend(ha9,{'Analytical curve','East Arm','North Arm','Average'},'FontSize',18)
end
%
function plot_density_flow(flow1,density1,flow2,density2,flow3,density3)
% figure;
ha10 = subplot(2,2,3);
title(ha10,'Flow-Density Diagram','FontSize',20)
xlabel(ha10,' Density K, veh/m','FontSize',18)
ylabel(ha10,' Flow Q, veh/s','FontSize',18)
hold on
grid on
[k,q,v] = fundamentaldiagram();
plot(ha10,k,q,'k')
plot(ha10,density1,flow1,'-b');
plot(ha10,density2,flow2,'-r');
plot(ha10,density3,flow3,'--g');
legend(ha10,{'Analytical curve','East Arm','North Arm','Average'},'FontSize',18)
end
function plot_flow_speed(flow1,meanVelocity1,flow2,meanVelocity2,flow3,meanVelocity3)
% figure;
ha11 = subplot(2,2,2);
title(ha11,'Speed-Flow Diagram','FontSize',20)
xlabel(ha11,' Flow Q, veh/s','FontSize',18)
ylabel(ha11,' Velocity <V>, m/s','FontSize',18)
hold on
grid on
[k,q,v] = fundamentaldiagram();
plot(ha11,q,v,'k')
plot(ha11,flow1,meanVelocity1,'-b');
plot(ha11,flow2,meanVelocity2,'-r');
plot(ha11,flow3,meanVelocity3,'--g');
legend(ha11,{'Analytical curve','East Arm','North Arm','Average'},'FontSize',18)
end