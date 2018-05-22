close all
clear 
% % % 
% load('/Users/robot/car_sim_mat_Files/flow_change_07_05_0_0_fall_off40xlongroad_morepoints.mat');
load('/Users/robot/car_sim_mat_Files/density_21_05_passive_Idm.mat');
if strcmpi(prescription,'flow')
    for i = 1:numel(sim)
        horizNumCars(i) = mean(sim(i).horizArm.numCarsHistory);
%         vertNumCars(i) = mean(sim(i).vertArm.numCarsHistory);
        
        density.horizontal(i) = horizNumCars(i)/(road.Length(1));
%         density.vertical(i) = vertNumCars(i)/(road.Length(2));
    end
end

for iSim = 1:numel(sim)  
    averagesAcrossSimulations.horizontal(iSim) = mean(sim(iSim).horizArm.averageVelocityHistory);
%     averagesAcrossSimulations.vertical(iSim) = mean(sim(iSim).vertArm.averageVelocityHistory);
end

flow.horizontal = density.horizontal.* averagesAcrossSimulations.horizontal;
% flow.vertical = density.vertical.* averagesAcrossSimulations.vertical;

% plot speed-density diagrams
density_diagram_plots(density,averagesAcrossSimulations);

% plot density-flow diagrams
flowdiagramplots(flow,density);
%

% iSim = 1;
% Arm = 'horizontal';
% time_displacement_plots(iSim,sim,Arm,roadDimensions,nIterations)

iSim = 1;
Arm = 'horizontal';
iCar = 1;
time_velocity_plot(iCar,iSim,sim,Arm)

iSim = 1;
Arm = 'horizontal';
time_average_velocity_plots(iSim,sim,Arm,runTime,dt);

iSim = 1;
Arm = 'horizontal';
time_aggregated_velocity_plots(iSim,sim,Arm,runTime,dt);
%%
function time_velocity_plot(iCar,iSim,sim,Arm)
if strcmpi(Arm,'horizontal')
    times = sim(iSim).horizArm.car(iCar).times;
    velocities = sim(iSim).horizArm.car(iCar).velocities;
else
    times = sim(iSim).vertArm.car(iCar).times;
    velocities = sim(iSim).vertArm.car(iCar).velocities;
end
figure(1);
ha1 = axes;
title(ha1,'Velocity profile','FontSize',20)
ylabel(ha1,' Velocity V, m/s','FontSize',18)
xlabel(ha1,' Time, s','FontSize',18)
hold on
grid on
plot(ha1,times,velocities,'b-','LineWidth',1)
axis(ha1,[min(times) max(times) 0 10])
end

function time_displacement_plots(iSim,sim,Arm,roadDimensions,nIterations)
times = nan(sim(iSim).horizArm.nCarHistory,nIterations);
positions = nan(sim(iSim).horizArm.nCarHistory,nIterations);
if strcmpi(Arm,'horizontal')
    for iCar = 1:sim(iSim).horizArm.nCarHistory
        times(iCar,1:length(sim(iSim).horizArm.car(iCar).times)) = sim(iSim).horizArm.car(iCar).times;
        positions(iCar,1:length(sim(iSim).horizArm.car(iCar).positions)) = sim(iSim).horizArm.car(iCar).positions-roadDimensions(1);
    end
else
    for iCar = 1:sim(iSim).vertArm.nCarHistory
        times(iCar,1:length(sim(iSim).vertArm.car(iCar).times)) = sim(iSim).vertArm.car(iCar).times;
        positions(iCar,1:length(sim(iSim).vertArm.car(iCar).positions)) = sim(iSim).vertArm.car(iCar).positions-roadDimensions(1);
    end
end
figure(3);
ha3 = axes;
title(ha3,'All car displacements along the Arm','FontSize',20)
xlabel(ha3,'Time, s','FontSize',18)
ylabel(ha3,'Position, m','FontSize',18)
hold on
grid on
for i = 1:size(positions,1)
    plot(ha3,real(times(i,:)),real(positions(i,:)),'b-','LineWidth',1)
end

end
%
function time_average_velocity_plots(iSim,sim,Arm,runTime,timeStep)
if strcmpi(Arm,'horizontal')
    velcoityAverages = sim(iSim).horizArm.averageVelocityHistory;
else
    velcoityAverages = sim(iSim).vertArm.averageVelocityHistory;
end
figure(5);
ha5 = axes;
title(ha5,'Velocity Average at every time step','FontSize',20)
ylabel(ha5,' Velocity <V>, m/s','FontSize',18)
xlabel(ha5,' Time, s','FontSize',18)
hold on
grid on
plot(ha5,[0:timeStep:runTime-timeStep],velcoityAverages,'b-')
axis(ha5,[0 runTime 0 10])

end
%
function time_aggregated_velocity_plots(iSim,sim,Arm,runTime,timeStep)
if strcmpi(Arm,'horizontal')
    cummulativeAverage = zeros(1,length(sim(iSim).horizArm.averageVelocityHistory));
    for i = 1:length(sim(iSim).horizArm.averageVelocityHistory)
        cummulativeAverage(i) = mean(sim(iSim).horizArm.averageVelocityHistory(1:i));
    end
else
    cummulativeAverage.vertical = zeros(1,length(sim(iSim).vertArm.averageVelocityHistory));
    for j = 1:length(sim(iSim).vertArm.averageVelocityHistory)
        cummulativeAverage(j) = mean(sim(iSim).vertArm.averageVelocityHistory(1:j));
    end
end

figure(7);
ha7 = axes;
title(ha7,'Velocity Average Over the Simulation','FontSize',20)
ylabel(ha7,' Velocity <V>, m/s','FontSize',18)
xlabel(ha7,' Time, s','FontSize',18)
hold on
grid on
plot(ha7,[0:timeStep:runTime-timeStep],cummulativeAverage,'b-')

end
%
function density_diagram_plots(density,averagesAcrossSimulations)
figure(9);
ha9 = axes;
title(ha9,'Speed-Density Diagram','FontSize',20)
xlabel(ha9,' Density K, veh/m','FontSize',18)
ylabel(ha9,' Velocity <V>, m/s','FontSize',18)
hold on
grid on
[k,q,v] = fundamentaldiagram();
plot(ha9,k,v,'k')
plot(ha9,density.horizontal,averagesAcrossSimulations.horizontal,'-b*');
% plot(ha9,density.vertical,averagesAcrossSimulations.vertical,'r-');
legend(ha9,{'Analytical curve','Simulation results'},'FontSize',18)
end
%
function flowdiagramplots(flow,density)
figure(10);
ha10 = axes;
title(ha10,'Flow-Density Diagram','FontSize',20)
xlabel(ha10,' Density K, veh/m','FontSize',18)
ylabel(ha10,' Flow Q, veh/s','FontSize',18)
hold on
grid on
[k,q,v] = fundamentaldiagram();
plot(ha10,k,q,'k')
plot(ha10,density.horizontal,flow.horizontal,'-b^');
% plot(ha10,density.vertical,flow.vertical,'-r^');
legend(ha10,{'Analytical curve','Simulation results'},'FontSize',18)
end