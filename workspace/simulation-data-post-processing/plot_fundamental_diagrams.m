clc
clear
close all

%load data in the loop
d = dir('test-*');          
Number_mat = length(d);   
clear d
for i = 1:Number_mat
    i
        filename = sprintf('test-%s.mat',num2str(i));
        load(fullfile(filename),'-mat','sim','density')
        
        eastArm.density(i) = density(1);
        northArm.density(i) = density(end);
        junction.density(i) = mean(density);
        
        
        %%
        
        velArrayEast = NaN(sim.horizArm.numCars,(numel(sim.crossOrder)-1));
        velArrayNorth = NaN(sim.vertArm.numCars,(numel(sim.crossOrder)-1));
        for iCar = 1:sim.horizArm.numCars
            velArrayEast(iCar,:) = sim.horizArm.allCars(iCar).History(3,:);
        end
        for iCar = 1:sim.vertArm.numCars
            velArrayNorth(iCar,:) = sim.vertArm.allCars(iCar).History(3,:);
        end
        meanVelArrayEast = mean(velArrayEast,1);
        meanVelArrayNorth = mean(velArrayNorth,1);
        
        cumsumVelEast = cumsum(meanVelArrayEast);
        cumsumVelNorth = cumsum(meanVelArrayNorth);
        
        cumulativeAverage= cumsumVelEast./[1:(numel(sim.crossOrder)-1)];
        cumulativeAverage(2,:) = cumsumVelNorth./[1:(numel(sim.crossOrder)-1)];
        
        
    %%   
        
        
        
        eastArm.meanVelocity(i) = nanmean(cumulativeAverage(1,:));
        northArm.meanVelocity(i) = nanmean(cumulativeAverage(2,:));
        junction.meanVelocity(i) = nanmean([eastArm.meanVelocity(i),northArm.meanVelocity(i)]);
        
        clear sim density
end

eastArm.flow = eastArm.density.*eastArm.meanVelocity;
northArm.flow = northArm.density.*northArm.meanVelocity;
junction.flow = junction.density.*junction.meanVelocity;

save('processedData.mat','eastArm','northArm','junction')
return
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

%% saving figure as a PDF
fig = gcf;
fig.PaperPositionMode = 'auto';
fig.PaperPosition;
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(fig,'East-arm-sym-1-dens-0056','-dpdf','-r0','-bestfit')
%% ploting funcitons
%
function plot_density_speed(density1,meanVelocity1,density2,meanVelocity2,density3,meanVelocity3)
% figure;
% ha9 = subplot(2,2,1);
ha9 = axes;

% title(ha9,'Speed-Density Diagram','FontSize',14)
xlabel(ha9,'Density \rho (veh/m)','FontSize',16)
ylabel(ha9,' Average Velocity <V> (m/s)','FontSize',16)
hold on
grid on
[k,~,v] = fundamentaldiagram();
plot(ha9,k,v,'k','LineWidth',2)
plot(ha9,k,v/2,'Color',[0.5 0.5 0.5 ],'LineWidth',2)
% plot(ha9,density1,meanVelocity1,'-b');
% plot(ha9,density2,meanVelocity2,'r-');
plot(ha9,density3,meanVelocity3,'b-o','LineWidth',2);
% legend(ha9,{'Analytical curve','East Arm','North Arm','Average'},'FontSize',18)
legend(ha9,{'Steady-State Velocity v_e','Half of Steady-State Velocity','Junction Simulation Average'},'FontSize',16)
xlim([0.015 0.15])
xticks(0.02:0.01:0.144)
end
%
function plot_density_flow(flow1,density1,flow2,density2,flow3,density3)
% figure;
% ha10 = subplot(2,2,3);
ha10 = axes;
% title(ha10,'Flow-Density Diagram','FontSize',20)
xlabel(ha10,' Density K, veh/m','FontSize',16)
ylabel(ha10,' Flow Q, veh/s','FontSize',16)
hold on
grid on
[k,q,v] = fundamentaldiagram();
plot(ha10,k,q,'k')
plot(ha10,density1,flow1,'-b');
plot(ha10,density2,flow2,'-r');
plot(ha10,density3,flow1+flow2,'--g');
legend(ha10,{'Analytical curve','East Arm','North Arm','Average'},'FontSize',16)
end
function plot_flow_speed(flow1,meanVelocity1,flow2,meanVelocity2,flow3,meanVelocity3)
% figure;
% ha11 = subplot(2,2,2);
ha11 = axes;
% title(ha11,'Speed-Flow Diagram','FontSize',20)
xlabel(ha11,' Capacity Q (veh/hr)','FontSize',16)
ylabel(ha11,'Average Velocity <V>  (m/s)','FontSize',16)
hold on
grid on
[k,q,v] = fundamentaldiagram();
% plot(ha11,q,v,'k','LineWidth',2)
plot(ha11,2*q*3600,v,'k','LineWidth',2,'DisplayName','Steady-State Velocity v_e')
plot(ha11,q*3600,v/2,'-','Color',[0.5 0.5 0.5 ],'LineWidth',2,'DisplayName','Half of Steady-State Velocity')


% plot(ha11,flow1*3600,meanVelocity1,'-r','DisplayName','East Arm');
% plot(ha11,flow2*3600,meanVelocity2,'-g','DisplayName','North Arm');
plot(ha11,(flow1+flow2)*3600,meanVelocity3,'bo-','LineWidth',2,'DisplayName','Junction Simulation Average');
legend(ha11,'FontSize',16)
% legend(ha11,{'Analytical curve','East Arm','North Arm','Average'},'FontSize',16)
end