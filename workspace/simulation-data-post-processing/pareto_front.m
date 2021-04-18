clc
clear

%% load up 
d = dir('test-*.mat');
Number_mat = length(d);

% load data for fairness
load('AggregatedDelaysFullLength.mat')

% load data for flow
load('aggregatedCrossingData.mat')


%% calculate normilsied flow
[k,q, v] = fundamentaldiagram();

flow2NumCrosses = 3600;
dens_rng = linspace(0.001,0.13,Number_mat);
flow_rng = NaN(1,Number_mat);
flowTotal = NaN(1,Number_mat);
flowTotalNorm = NaN(1,Number_mat);

for i = 1:Number_mat
    flow_tmp = q(abs(k-dens_rng(i))<0.0001)*flow2NumCrosses;
    flow_rng(i) = flow_tmp(1);
    flowTotal(i) = numel(data(i).crossCount);
    
    % normalise the flow
    flowTotalNorm(i) = flowTotal(i)/(2*flow_rng(i));
end


%% Gini coefficient over density sweep
Gini = NaN(1,Number_mat);
for i = 1:Number_mat
    
    travelArrayEast = travelTimesEast(i,:);
    travelArrayNorth = travelTimesNorth(i,:);
    travelArray = [travelArrayEast(~isinf(travelArrayEast)) travelArrayNorth(~isinf(travelArrayNorth))];
    travelArray(isnan(travelArray)) = [];
    
    population = 1:numel(travelArray);    
    delayArraySort = [0 sort(abs(travelArray),'Ascend')];
    
    delayArraySort = cumsum(delayArraySort);
    delayCum = delayArraySort/delayArraySort(end);
    x_rng = [0 population]/population(end);
    
    % figure(3)
    % plot(x_rng,delayCum,'k-')
    % hold on
    % plot([0,1],[0,1],'--k');
    
    % calculate Gini coefficient
    Gini(i) = 1-sum((delayCum(1:end-1)+delayCum(2:end)).*diff(x_rng));
end
%% plot pareto
ax1 = axes;
X = flowTotalNorm;
Y = Gini;

caxis manual
caxis([0 0.13]);
% axis(ax1,[0 t_rng(nIterations) sim.horizArm.startPoint sim.horizArm.endPoint] )
c = colorbar(ax1);
set(c,'YTick',(0.01:0.02:0.13));
c.Label.Interpreter = 'latex';
c.TickLabelInterpreter = 'latex';
c.Label.String = 'Density $\rho\,(\mathrm{veh/m}$)';
colormap(flipud(jet));

hold on
Z = dens_rng;
sz = 20;
scatter(ax1,X,Y,sz,Z,'filled')
xlabel('Normised Junction Flow $\hat{Q}_{\Sigma}$')
ylabel('Gini Coefficient $G$')
set(gca, 'YDir','reverse')
axis([0 1 0 1])


%% saving figure as a PDF
% xlim([1000 1500])
pause(2)
fig = gcf;
fig.PaperPositionMode = 'auto';
fig.PaperPosition;
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(fig,'pareto-front.pdf','-dpdf','-r0','-bestfit')
% pause(3)
% close all