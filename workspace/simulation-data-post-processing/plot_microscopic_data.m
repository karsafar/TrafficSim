clc
% clear
close all
set(0,'defaultAxesTickLabelInterpreter','latex'); 
set(0,'defaultLegendInterpreter','latex');
set(0,'defaultLegendFontName','Times New Roman');
set(0,'defaultTextInterpreter','latex');
set(0,'defaultTextboxshapeInterpreter','latex');
set(0,'defaultAxesFontSize',22);
set(0,'defaultAxesFontName','Times New Roman');

%%
warmUp =  exist('transientCutOffLength');
if warmUp
    transCut = transientCutOffLength*10;
else
    transCut = 0;
end
    
velArrayEast = NaN(sim.horizArm.numCars,(nIterations-transCut));
velArrayNorth = NaN(sim.vertArm.numCars,(nIterations-transCut));
for iCar = 1:sim.horizArm.numCars
    velArrayEast(iCar,:) = sim.horizArm.allCars(iCar).History(3,transCut+1:end);
end
for iCar = 1:sim.vertArm.numCars
    velArrayNorth(iCar,:) = sim.vertArm.allCars(iCar).History(3,transCut+1:end);
end


% Spatiotenporal Velocity Profiles

d = 2; % density on points in scatter plot
plot_spatiotemporal_profiles(sim,transCut,t_rng(transCut+1:end),(nIterations-transCut),d)
pause(1)
% saving figure as a PDF
% xlim([1000 1500])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig.PaperPosition;
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
% print(fig,'/Users/robot/cross_sim/workspace/Chapter03-data/junction-flow-change-sym-1-vel-0-no-warm-up-002','-dpdf','-r0','-bestfit')
% print(fig,'/Users/robot/cross_sim/workspace/Chapter02-data/test-simulations-type-A/n_cars_vs_road_length_prescription/junction/junc_30_cars_1500_m_0_02_zoomed','-dpdf','-r0','-bestfit')
print(fig,'non-symmetric-arms-diff','-dpdf','-r0','-bestfit')
close all
%% flow change

% plot_flow_change(velArrayEast,velArrayNorth,density,t_rng(transCut+1:end),(nIterations-transCut))

%% Flow

plot_aggregated_flow(sim,transCut,density,t_rng(transCut+1:end),(nIterations-transCut))

%% Speed variance

plot_speed_variance(sim,velArrayEast,velArrayNorth,t_rng(transCut+1:end),(nIterations-transCut))

%% Time-Displacement

% split_trajectory_profiles(sim,transCut,t_rng(transCut+1:end),(nIterations-transCut))


%
%%

% %% Time-Displacement
% 
% plot_time_displacement(sim,transCut,t_rng(transCut+1:end),(nIterations-transCut))

%{
% % load porcessed data
% load('processedData.mat');

% find test number of interest
% [lia, loc] = ismember([60,20,20],pointsCartesian,'rows');
%
% % load the test data
% load(['test-' num2str(loc) '.mat']);

%%

load(['test-' num2str(21) '.mat']);

%
%% for results gui

setappdata(0,'horiz',sim.horizArm);
setappdata(0,'vert',sim.vertArm);
setappdata(0,'iter',nIterations);
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
%}
 
 %%                                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 
function plot_flow_change(velArrayEast,velArrayNorth,density,t_rng,nIterations)
 
meanVelArrayEast = mean(velArrayEast,1);
meanVelArrayNorth = mean(velArrayNorth,1);

if numel(density) == 1
    density(2) = density(1);
end
for i = 1:nIterations
    eastArm.flowChange(i) = density(1)*meanVelArrayEast(i);
    northArm.flowChange(i) = density(2)*meanVelArrayNorth(i);
end
junction.flowChange = mean([eastArm.flowChange;northArm.flowChange]);
% 
% figure()
% ax1 = axes;
% plot(ax1,t_rng,northArm.flowChange,'b-','LineWidth',2)
% xlabel(ax1,'Time (s)')
% ylabel(ax1,'Flow (veh/s)')
% 
% figure()
% ax2 = axes;
% plot(ax2,t_rng,eastArm.flowChange,'r-','LineWidth',2)
% xlabel(ax2,'Time (s)')
% ylabel(ax2,'Flow (veh/s)')
% 
% figure()
% ax3 = axes;
% plot(ax3,t_rng,junction.flowChange,'g-','LineWidth',2)
% xlabel(ax3,'Time (s)')
% ylabel(ax3,'Flow (veh/s)')

figure()
ax4 = axes;
plot(ax4,t_rng,eastArm.flowChange*3600,'r-',...
         t_rng,northArm.flowChange*3600,'b-',...
         t_rng,junction.flowChange*3600,'g-','LineWidth',2)
xlabel(ax4,'Time (s)')
ylabel(ax4,'Flow Change (veh/hr)')
xlim([1000 1500])
ylim([0 max(max(eastArm.flowChange*3600),max(northArm.flowChange*3600))])
legend('East-bound Arm Flow','North-bound Arm Flow','Junction Flow');
e = diff(northArm.flowChange*3600);
n = diff(eastArm.flowChange*3600);
j = diff(junction.flowChange*3600);
%{
%% occupancy pre-junction
numNaN = sum(isnan(sim.horizArm.averageVelocityHistory));

crossSection.in = -3-sim.horizArm.allCars(1).ownDistfromRearToFront;
crossSection.out = -3+sim.horizArm.allCars(1).ownDistfromRearToBack;

East.count = zeros(nIterations,1);
for iCar = 1:sim.horizArm.nCarHistory
    iCar_pos = sim.horizArm.carHistory(iCar).History(2,:);
    iCar_times = sim.horizArm.carHistory(iCar).History(1,:);
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
    iCar_pos = sim.vertArm.carHistory(iCar).History(2,:);
    iCar_times = sim.vertArm.carHistory(iCar).History(1,:);
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
%}
end
function plot_spatiotemporal_profiles(sim,transCut,t_rng,nIterations,d)
%%%%%%%%%%%%%% West-East Arm %%%%%%%%%%%%%%
% for i = 1:48
%     tic
%     clf
%     figure(1)
%     load(['test-' num2str(i) '.mat']);
    X = [];
    Y = [];
    Z = [];

    maxVelocity = 13;
    for iCar = 1:sim.horizArm.numCars
        X = [X t_rng(1:d:end)];
        Y = [Y sim.horizArm.allCars(iCar).History(1,1:d:end)];
        Z = [Z sim.horizArm.allCars(iCar).History(2,1:d:end)];
    end
    
    X1 = [];
    Y1 = [];
    Z1 = [];
    for iCar = 1:sim.vertArm.numCars
        X1 = [X1 t_rng(1:d:end)];
        Y1 = [Y1 sim.vertArm.allCars(iCar).History(1,1:d:end)];
        Z1 = [Z1 sim.vertArm.allCars(iCar).History(2,1:d:end)];
    end
    
%     ax1 = subplot(2,1,1);
    figure(1);
    ax1 = axes;
    
    
%     set(ax1);
%     title(ax1,'East Arm')
    xlabel(ax1,'Time (s)');
    ylabel(ax1,'Displacement ($\mathrm{m}$)');
    hold(ax1,'on');
    grid(ax1,'on');
    
    axis(ax1,[transCut/10 t_rng(nIterations) sim.horizArm.startPoint sim.horizArm.endPoint] );
%     xlim(ax1,[transientCutOffLength t_rng(nIterations)])
    
    caxis manual
    caxis([0 maxVelocity]);
    x1 = transCut/10;
    x2 = t_rng(nIterations);
    y1 = sim.horizArm.allCars(1).s_in;
    y2 = -sim.horizArm.allCars(1).s_in;
    x = [x1, x2, x2, x1, x1];
    y = [y1, y1, y2, y2, y1];
    % axis(ax1,[0 t_rng(nIterations) sim.horizArm.startPoint sim.horizArm.endPoint] )
    c = colorbar(ax1);
    set(c,'YTick',(1:2:maxVelocity));
    c.Label.Interpreter = 'latex';
    c.TickLabelInterpreter = 'latex';
    c.Label.String = 'Velocity ($\mathrm{m/s}$)';
%     c.Label.FontSize = 14;
    colormap(flipud(jet));
    
       
    sz = 4;
    X(Y> 2.825) = NaN;
    Z(Y> 2.825) = NaN;
    Y(Y> 2.825) = NaN;
    scatter(ax1,X,Y,sz,Z,'filled');
%     patch(ax1,x,y,[0.5 0.5 0.5],'EdgeColor','k','FaceColor','None');
    h1 = patch(ax1,x,y,[0.5 0.5 0.5],'EdgeColor','None');
    h1.FaceAlpha = 0.4;
%     return
    
    
    %%%%%%%%%%%%%% South-North Arm %%%%%%%%%%%%%%
%     ax2 = subplot(2,1,2);
    f1 = figure(2);
    ax2 = axes;
    f1.Visible = 'off';
%     set(ax2);
%     title(ax2,'North Arm')
    xlabel(ax2,'Time ($\mathrm{s}$');
    ylabel(ax2,'Displacement ($\mathrm{m}$)');
    hold(ax2,'on');
    grid(ax2,'on');
    axis(ax2,[transCut/10 t_rng(nIterations) sim.vertArm.startPoint sim.vertArm.endPoint] );
    
    caxis manual;
    caxis([0 maxVelocity]);
    c = colorbar(ax2);
    set(c,'YTick',(1:2:maxVelocity));
    c.Label.Interpreter = 'latex';
    c.TickLabelInterpreter = 'latex';
    c.Label.String = 'Velocity ($\mathrm{m/s}$)';
%     c.Label.FontSize = 14;
    colormap(flipud(jet));

%     figure
%     ddt = delaunayTriangulation(double(X1'),double(Y1')) ;
%     tri = ddt.ConnectivityList ;
%     xi = ddt.Points(:,1) ;
%     yi = ddt.Points(:,2) ;
%     F = scatteredInterpolant(double(X1'),double(Y1'),double(Z1'));
%     zi = F(xi,yi) ;
%     trisurf(tri,xi,yi,zi)
%         xlabel('Time, s')
%     ylabel('Position, m')
%     ylabel('velocity, m/s')
%     view(2)
%     oldcmap = colormap;
%     colormap( flipud(oldcmap) );
%     shading interp
    % plot the trajectories
%     scatter(ax1,X,Y,sz,Z,'filled');
    X1(Y1> 2.825) = NaN;
    Z1(Y1> 2.825) = NaN;
    Y1(Y1> 2.825) = NaN;
%     scatter(ax2,X1,Y1,sz,Z1,'filled');
    scatter(ax1,X1,-Y1,sz,Z1,'filled');
    h2 = patch(ax1,x,y,[0.5 0.5 0.5],'EdgeColor','None');
    h2.FaceAlpha = 0.4;

%     xlim(ax2,[transientCutOffLength t_rng(nIterations)])
%     pause(1)
%     toc
% end

end

function plot_aggregated_flow(sim,transCut,density,t_rng,nIterations)
%{%
% tf = isa(sim.horizArm,'LoopRoad');
% for i = 1:nIterations
%     cumulativeAverage(1,i) = nanmean(sim.horizArm.averageVelocityHistory(1:i));
%     cumulativeAverage(2,i) = nanmean(sim.vertArm.averageVelocityHistory(1:i));
% end
velArrayEast = NaN(sim.horizArm.numCars,nIterations);
velArrayNorth = NaN(sim.vertArm.numCars,nIterations);
for iCar = 1:sim.horizArm.numCars
    velArrayEast(iCar,:) = sim.horizArm.allCars(iCar).History(2,transCut+1:end);
end
for iCar = 1:sim.vertArm.numCars
    velArrayNorth(iCar,:) = sim.vertArm.allCars(iCar).History(2,transCut+1:end);
end
meanVelArrayEast = mean(velArrayEast,1);
meanVelArrayNorth = mean(velArrayNorth,1);

cumsumVelEast = cumsum(meanVelArrayEast);
cumsumVelNorth = cumsum(meanVelArrayNorth);

cumulativeAverage= cumsumVelEast./[1:nIterations];
cumulativeAverage(2,:) = cumsumVelNorth./[1:nIterations];
% for i = 1:nIterations
%     cumulativeAverage(1,i) = mean(meanVelArrayEast,2);
%     cumulativeAverage(2,i) = mean(meanVelArrayEast,1);
% end

% if tf == 0
%     density = sim.horizArm.numCarsHistory/sim.horizArm.Length;
% end
flow.WestEast = density(1)*cumulativeAverage(1,:);
flow.SouthNorth = density(2)*cumulativeAverage(2,:);

flowDifference = abs(flow.WestEast + flow.SouthNorth)/2;

figure(3)
% ax3 = subplot(2,1,1);
ax = axes;
cla(ax)
% title(ax3,'Demand')
xlabel(ax,'Time (s)')
ylabel(ax,'Flow (veh/hr)')
hold(ax,'on');
grid(ax,'on');
tLength = 3600;
plot(ax,t_rng,flow.WestEast*tLength,'r-','LineWidth',2)
plot(ax,t_rng,flow.SouthNorth*tLength,'b-','LineWidth',2)
[k,q, v] = fundamentaldiagram();
flowVal = q(abs(k-density(1))<0.00001);
plot(ax,t_rng,flowVal(1)*ones(1,nIterations)*tLength,'k--','LineWidth',1)
xlim([0 3600])
ylim([0 flowVal(1)*tLength+100])
% plot(ax,t_rng,flowDifference,'-b','LineWidth',2)
% axis(ax,[0 t_rng(nIterations) 0 max(max(flow.WestEast),max(flow.SouthNorth))])
% legend(ax,'West-East Arm Flow','South-North Arm Flow','Junction Flow','Location','southwest')

legend(ax,'Eastbound arm flow','Northbound arm flow','Steady-state flow at density $\rho=0.04\,\mathrm{veh/m}$','Location','southeast')
end

function plot_speed_variance(sim,velArrayEast,velArrayNorth,t_rng,nIterations)
meanVelArrayEast = mean(velArrayEast,1);
meanVelArrayNorth = mean(velArrayNorth,1);

varianceEast = sum((velArrayEast-meanVelArrayEast).^2,1)/sim.horizArm.numCars;
varianceNorth = sum((velArrayNorth-meanVelArrayNorth).^2,1)/sim.vertArm.numCars;
varianceJunciton = (varianceEast + varianceNorth)./2;

figure()
ax = axes;
% title(ax,'Speed Variance')
xlabel(ax,'Time (s)')
ylabel(ax,'Speed variance $\sigma^{2}\,(\mathrm{m^{2}/s^{2}})$')
hold(ax,'on');
grid(ax,'on');
plot(ax,t_rng,varianceEast,'r-*','LineWidth',1)
plot(ax,t_rng,varianceNorth,'b-o','LineWidth',1)
% plot(ax,t_rng,varianceJunciton,'LineWidth',2)

if max(max(varianceEast),max(varianceNorth)) > 0
    axis(ax,[0 t_rng(nIterations) 0 max(max(varianceEast),max(varianceNorth))])
else
    xlim(ax,[0 t_rng(nIterations)])
end
legend(ax,'Eastbound arm variance','Northbound arm variance')

% legend(ax,'Junction Average Speed Variance')
end

function split_trajectory_profiles(sim,transCut,t_rng,nIterations)
figure()
ax = axes;
xlabel(ax,'Time (s)')
ylabel(ax,'Displacement (m)')
hold(ax,'on');
x1 = 0;
x2 = t_rng(nIterations);
y1 = sim.horizArm.allCars(1).s_in;
y2 = -sim.horizArm.allCars(1).s_in;
x = [x1, x2, x2, x1, x1];
y = [y1, y1, y2, y2, y1];
axis(ax,[0 t_rng(nIterations) sim.horizArm.startPoint sim.horizArm.endPoint] )
patch(ax,x,y,[0.5 0.5 0.5],'EdgeColor','None');

for i = 1:2
    if i == 1
        arm = sim.horizArm;
    else
        arm = sim.vertArm;
    end
    k = 1;
    for iCar = 1:arm.numCars
        
        t_Car  = arm.allCars(iCar).History(1,transCut+1:end);
        d_Car  = arm.allCars(iCar).History(2,transCut+1:end);
        
        idx = find(d_Car>=arm.endPoint);
        idx = [0,idx,nIterations];
        
        if i == 2
            d_Car  = -d_Car;
        end
        for j = 1:numel(idx)-1
            if i == 1
                plot(ax,t_Car(idx(j)+1:6:idx(j+1)), d_Car(idx(j)+1:6:idx(j+1)),'b-','LineWidth',2)
            else
                plot(ax,t_Car(idx(j)+1:6:idx(j+1)), d_Car(idx(j)+1:6:idx(j+1)),'r-','LineWidth',2)
            end
            k = k+1;
        end
    end
end
axis(ax,[transCut/10 t_rng(nIterations) sim.horizArm.startPoint sim.horizArm.endPoint] )
end






%% ---!!!! I don't need this !!!!---
%{
function plot_individual_profiles(sim,nIterations)
%% plot individual car profiles 
i = 1;
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

x1 = min(nCars(1).History(1,:));
x2 = max(nCars(end).History(1,:));
y1 = sim.horizArm.allCars(1).s_in;
y2 = sim.horizArm.allCars(1).s_out;
x = [x1, x2, x2, x1, x1];
y = [y1, y1, y2, y2, y1];
patch(ax6,x,y,[0.5 0.5 0.5],'EdgeColor','None');

for i = 1:numel(nCars)
    iCar = nCars(i);
    plot(ax6,iCar.History(1,:),iCar.History(2,:),'-','LineWidth',1)
end
axis(ax6,[min(nCars(1).History(1,:)) max(iCar.History(1,:)) min(nCars(1).History(2,:)) max(iCar.History(2,:))])
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
    plot(ax7,iCar.History(1,:),iCar.History(3,:),'-','LineWidth',1)
end
axis(ax7,[min(nCars(1).History(1,:)) max(iCar.History(1,:)) 0 iCar.maximumVelocity])
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
    plot(ax8,iCar.History(1,:),iCar.History(4,:),'-','LineWidth',1)
end
axis(ax8,[min(nCars(1).History(1,:)) max(iCar.History(1,:)) min(iCar.a_feas_min,min(iCar.History(4,:))) max(iCar.a_max,max(iCar.History(4,:)))])
% axis(ax8,[1590 1600 -3 3])


end
function plot_time_displacement(sim,transCut,t_rng,nIterations)
figure()
ax = axes;
% title(ax,'Trajectories')
xlabel(ax,'Time (s)')
ylabel(ax,'Displacement (m)')
hold(ax,'on');
x1 = 0;
x2 = t_rng(nIterations);
y1 = sim.horizArm.allCars(1).s_in;
y2 = -sim.horizArm.allCars(1).s_in;
x = [x1, x2, x2, x1, x1];
y = [y1, y1, y2, y2, y1];
axis(ax,[0 t_rng(nIterations) sim.horizArm.startPoint sim.horizArm.endPoint] )
% yyaxis(ax,'left')
patch(ax,x,y,[0.5 0.5 0.5],'EdgeColor','None');
for iCar = 1:sim.horizArm.numCars
    h1 = plot(ax,sim.horizArm.allCars(iCar).History(1,transCut+1:end),sim.horizArm.allCars(iCar).History(2,transCut+1:end),'b.','LineWidth',0.5);
end
% yyaxis(ax,'right')
for jCar = 1:sim.horizArm.numCars
    h2 = plot(ax,sim.vertArm.allCars(jCar).History(1,transCut+1:end),-sim.vertArm.allCars(jCar).History(2,transCut+1:end),'r.','LineWidth',0.5);
end
% yticks([ min(-sim.vertArm.carHistory(jCar).History(2,transCut+1:end)) max(-sim.vertArm.carHistory(jCar).History(2,transCut+1:end))])
% ylabel(ax,'North Arm, m')
% set(ax, 'Ydir', 'reverse')
legend([h1,h2],'East Arm','North Arm')
axis(ax,[0 t_rng(nIterations) sim.vertArm.startPoint sim.vertArm.endPoint] )
end
%}