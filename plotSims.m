% clc
% clear
% close all
% 
% % load porcessed data
% load('processedData.mat');

% find test number of interest
% [lia, loc] = ismember([60,20,20],pointsCartesian,'rows');
% 
% % load the test data
% load(['test-' num2str(loc) '.mat']);


%% 

load(['test-' num2str(37) '.mat']);

%% for results gui

setappdata(0,'horiz',sim.horizArm);
setappdata(0,'vert',sim.vertArm);
setappdata(0,'iter',i);
setappdata(0,'t_rng',t_rng);
setappdata(0,'density_H',density);
setappdata(0,'density_V',density);

%% junction crossing graph
figure(6)
plot(sim.crossOrder,'-b','LineWidth',1.5)
axis([0 numel(sim.crossOrder) 0 3])
grid on 
xlabel('Number of Junction Crosses','FontSize',16)
text(numel(sim.crossOrder)/2,-0.1,'\uparrow East Arm Crosses','FontSize',16)
text(numel(sim.crossOrder)/2,1.1,'\downarrow North Arm Crosses','FontSize',16)
ylim([-0.5,1.5])

%% flow change 
for i = 1:nIterations
    eastArm.flowChange(i) = density*sim.horizArm.averageVelocityHistory(i);
    northArm.flowChange(i) = density*sim.vertArm.averageVelocityHistory(i);
end
figure
% plot(eastArm.flowChange(1,:))
hold on
% plot(northArm.flowChange(1,:))
hold on
plot(mean([eastArm.flowChange(1,:);northArm.flowChange(1,:)]))
xlabel('Iteration No','FontSize',16)
ylabel('Flow, veh/s','FontSize',16) 
grid on


%% occupancy pre-junction
numNaN = sum(isnan(sim.horizArm.averageVelocityHistory));

crossSection.in = -3-sim.horizArm.allCars(1).ownDistfromRearToFront;
crossSection.out = -3+sim.horizArm.allCars(1).ownDistfromRearToBack;

East.count = zeros(nIterations,1);
for iCar = 1:sim.horizArm.nCarHistory
    iCar_pos = sim.horizArm.carHistory(iCar).locationHistory;
    iCar_times = sim.horizArm.carHistory(iCar).timeHistory;
    iCar_times = iCar_times(iCar_pos>=crossSection.in & iCar_pos<=crossSection.out);
    iCar_pos = iCar_pos(iCar_pos>=crossSection.in & iCar_pos<=crossSection.out);
    [tf,loc]=ismember(iCar_times,t_rng);
    if ~isempty(iCar_pos) && min(iCar_times) > (0.1*numNaN)
        for i = loc(1):loc(end)
            East.count(i) = 1;
        end
    end
end
North.count = zeros(nIterations,1);
for iCar = 1:sim.vertArm.nCarHistory
    iCar_pos = sim.vertArm.carHistory(iCar).locationHistory;
    iCar_times = sim.vertArm.carHistory(iCar).timeHistory;
    iCar_times = iCar_times(iCar_pos>=crossSection.in & iCar_pos<=crossSection.out);
    iCar_pos = iCar_pos(iCar_pos>=crossSection.in & iCar_pos<=crossSection.out);
    [tf,loc]=ismember(iCar_times,t_rng);
    if ~isempty(iCar_pos) && min(iCar_times) > (0.1*numNaN)
        for i = loc(1):loc(end)
            North.count(i) = 1;
        end
    end
end

East.Occupancy = zeros(1,length(East.count));
North.Occupancy = zeros(1,length(East.count));

for i = max(numNaN,1):nIterations
    East.Occupancy(i) = nansum(East.count(1:i))/(i-numNaN);
    North.Occupancy(i) = nansum(North.count(1:i))/(i-numNaN);
end
East.Occupancy = East.Occupancy*100;
North.Occupancy = North.Occupancy*100;
title('Occupancy','FontSize',14)
xlabel('Time, s','FontSize',14)
ylabel(' Occupancy, per cent','FontSize',14)
hold('on');
grid('on');
plot(t_rng,East.Occupancy,'-r','LineWidth',1)
plot(t_rng,North.Occupancy,'-b','LineWidth',1)

%{%
%% Spatiotenporal Velocity Profiles

                    %%%%%%%%%%%%%% West-East Arm %%%%%%%%%%%%%%
ax1 = subplot(2,1,1);
set(ax1,'FontSize',16)
title(ax1,'West-East Arm Velocity Profiles')
xlabel(ax1,'Time, s')
ylabel(ax1,'Position, m')
hold(ax1,'on');
grid(ax1,'on');
axis(ax1,[0 t_rng(nIterations) sim.horizArm.startPoint sim.horizArm.endPoint] )
sz = 5;
for iCar = 1:sim.horizArm.nCarHistory
    scatter(ax1,sim.horizArm.carHistory(iCar).timeHistory,sim.horizArm.carHistory(iCar).locationHistory,sz,sim.horizArm.carHistory(iCar).velocityHistory,'filled');
end
c = colorbar;
c.Label.String = 'Velocity, m/s';
c.Label.FontSize = 12;
caxis([0 13])
colormap(flipud(jet));

                    %%%%%%%%%%%%%% South-North Arm %%%%%%%%%%%%%%
ax2 = subplot(2,1,2);
set(ax2,'FontSize',16)
title(ax2,'South-North Arm Velocity Profiles')
xlabel(ax2,'Time, s')
ylabel(ax2,'Position, m')
hold(ax2,'on');
grid(ax2,'on');
axis(ax2,[0 t_rng(nIterations) sim.vertArm.startPoint sim.vertArm.endPoint] )
sz = 5;
for iCar = 1:sim.vertArm.nCarHistory
    scatter(ax2,sim.vertArm.carHistory(iCar).timeHistory,sim.vertArm.carHistory(iCar).locationHistory,sz,sim.vertArm.carHistory(iCar).velocityHistory,'filled');
end
c = colorbar;
c.Label.String = 'Velocity, m/s';
c.Label.FontSize = 12;
caxis([0 13])
colormap(flipud(jet));
%}%







%% Flow


%{%
% tf = isa(sim.horizArm,'LoopRoad');
for i = 1:nIterations
    cumulativeAverage(1,i) = nanmean(sim.horizArm.averageVelocityHistory(1:i));
    cumulativeAverage(2,i) = nanmean(sim.vertArm.averageVelocityHistory(1:i));
end
% if tf == 0
%     density = sim.horizArm.numCarsHistory/sim.horizArm.Length;
% end
flow.WestEast = density*cumulativeAverage(1,:);
flow.SouthNorth = density*cumulativeAverage(2,:);

flowDifference = abs(flow.WestEast + flow.SouthNorth)/2;

figure(2)
% ax3 = subplot(2,1,1);
ax3 = axes;
set(ax3,'FontSize',16)
title(ax3,'Demand')
xlabel(ax3,'Time, s')
ylabel(ax3,'Flow, veh/s')
hold(ax3,'on');
grid(ax3,'on');
plot(ax3,t_rng,flow.WestEast,'LineWidth',1)
plot(ax3,t_rng,flow.SouthNorth,'LineWidth',1)
plot(ax3,t_rng,flowDifference,'-k','LineWidth',1)
axis(ax3,[0 t_rng(nIterations) 0 max(max(flow.WestEast),max(flow.SouthNorth))])
legend(ax3,'West-East Arm Flow','South-North Arm Flow','Junction Flow')


%% Speed variance


figure(3)
ax4 = axes;
set(ax4,'FontSize',16)
title(ax4,'Speed Variance')
xlabel(ax4,'Time, s')
ylabel(ax4,' \sigma^{2}, m^{2}/s^{2}')
hold(ax4,'on');
grid(ax4,'on');
plot(ax4,t_rng,sim.horizArm.variance,'LineWidth',1)
plot(ax4,t_rng,sim.vertArm.variance,'LineWidth',1)
axis(ax4,[0 t_rng(nIterations) 0 max(max(sim.horizArm.variance),max(sim.vertArm.variance))])
legend(ax4,'West-East Arm Flow','South-North Arm Flow')
 

%% Time-Displacement
figure(4)
ax5 = axes;
set(ax5,'FontSize',16)
title(ax5,'Trajectories')
xlabel(ax5,'Time, s')
ylabel(ax5,'Horizontal Position, m')
hold(ax5,'on');
grid(ax5,'on');
x1 = 0;
x2 = t_rng(nIterations);
y1 = sim.horizArm.allCars(1).s_in;
y2 = -sim.horizArm.allCars(1).s_in;
x = [x1, x2, x2, x1, x1];
y = [y1, y1, y2, y2, y1];
axis(ax5,[0 t_rng(nIterations) sim.horizArm.startPoint sim.horizArm.endPoint] )
yyaxis(ax5,'left')
patch(ax5,x,y,[0.5 0.5 0.5],'EdgeColor','None');
for iCar = 1:sim.horizArm.nCarHistory
 h1 =   plot(ax5,sim.horizArm.carHistory(iCar).timeHistory,sim.horizArm.carHistory(iCar).locationHistory,'b-','LineWidth',1);
end
yyaxis(ax5,'right')
for jCar = 1:sim.vertArm.nCarHistory
 h2 =   plot(ax5,sim.vertArm.carHistory(jCar).timeHistory,sim.vertArm.carHistory(jCar).locationHistory,'r-','LineWidth',1);
end
ylabel(ax5,'Vertical Position, m')
set(ax5, 'Ydir', 'reverse')
legend([h1,h2],'West-East Arm Flow','South-North Arm Flow')
axis(ax5,[0 t_rng(nIterations) sim.vertArm.startPoint sim.vertArm.endPoint] )
%}%

%% plot individual car profiles


i = 2;
if i == 1
    nCars = sim.horizArm.carHistory(226:235);
elseif i == 2
    nCars = sim.vertArm.carHistory(185:191);
end

figure(5)
ax6 = subplot(3,1,1);
set(ax6,'FontSize',16)
title(ax6,'Displacement Profile')
xlabel(ax6,'Time, s')
ylabel(ax6,'Position, m')
hold(ax6,'on');
grid(ax6,'on');

x1 = min(nCars(1).timeHistory);
x2 = max(nCars(end).timeHistory);
y1 = nCars(1).s_in;
y2 = nCars(1).s_out;
x = [x1, x2, x2, x1, x1];
y = [y1, y1, y2, y2, y1];
patch(ax6,x,y,[0.5 0.5 0.5],'EdgeColor','None');

for i = 1:numel(nCars)
    iCar = nCars(i);
    plot(ax6,iCar.timeHistory,iCar.locationHistory,'-','LineWidth',1)
end
axis(ax6,[min(nCars(1).timeHistory) max(iCar.timeHistory) min(nCars(1).locationHistory) max(iCar.locationHistory)])
% axis(ax6,[1590 1600 -10 10])

ax7 = subplot(3,1,2);
set(ax7,'FontSize',16)
title(ax7,'Velocity Profile')
xlabel(ax7,'Time, s')
ylabel(ax7,' Velocity V, m/s')
hold(ax7,'on');
grid(ax7,'on');
% axis(ax7,[min(iCar.timeHistory) max(iCar.timeHistory) 0 iCar.maximumVelocity])
% plot(ax7,iCar.timeHistory,iCar.velocityHistory,'b-','LineWidth',1)
for i = 1:numel(nCars)
    iCar = nCars(i);
    plot(ax7,iCar.timeHistory,iCar.velocityHistory,'-','LineWidth',1)
end
axis(ax7,[min(nCars(1).timeHistory) max(iCar.timeHistory) 0 iCar.maximumVelocity])
% axis(ax7,[1590 1600  0 2])

ax8 = subplot(3,1,3);
set(ax8,'FontSize',16)
title(ax8,'Acceleration Profile')
xlabel(ax8,'Time, s')
ylabel(ax8,' Acceleration V, m/s^2')
hold(ax8,'on');
grid(ax8,'on');
% axis(ax8,[min(iCar.timeHistory) max(iCar.timeHistory) min(iCar.a_feas_min,min(iCar.accelerationHistory)) max(iCar.a_max,max(iCar.accelerationHistory))])
% plot(ax8,iCar.timeHistory,iCar.accelerationHistory,'b-','LineWidth',1)
for i = 1:numel(nCars)
    iCar = nCars(i);
    plot(ax8,iCar.timeHistory,iCar.accelerationHistory,'-','LineWidth',1)
end
axis(ax8,[min(nCars(1).timeHistory) max(iCar.timeHistory) min(iCar.a_feas_min,min(iCar.accelerationHistory)) max(iCar.a_max,max(iCar.accelerationHistory))])
% axis(ax8,[1590 1600 -3 3])






%}
