clear
close all
clc

for i = 1:11
    folderName = sprintf('density-%s',num2str(i));
    cum_count = [];
    for j = 1:1
        fileName = sprintf('test-%s.mat',num2str(j));
        load(fullfile(folderName,fileName))
        %     load(['test-' num2str(j) '.mat']);
        count = abs(diff(sim.crossCount));
        cum_count(j,1) = count(1);
        for k = 2:numel(count)
            cum_count(j,k) = (cum_count(j,k-1)+count(k))*count(k);
        end
    end
    i
    turnTakinglengths(i,:) = max(cum_count,[],2);
end



turnTakinglengths = max(cum_count,[],2);
%%
[k,q, v] = fundamentaldiagram();
maxCrosses = 2*q*t_rng(end);
nCars = 10:2:30;
for i = 1:51
    iCar = nCars(i);
    [a,idx] = ismember(round(dens(1,i),5),round(k,5));
    normData(i,:) = turnTakinglengths(i,:)./maxCrosses(idx);
end

%%

xRange = [0.02:0.002:0.06];
boxplot(normData,xRange)
% axis([0 11 0 1])
ylabel('Normalized Longest Turn-Taking','FontSize',14)
xlabel('Num cars per arm','FontSize',14)
%% 
% xRange = [10:2:30];
ax3 = axes;

%
[k,q, v] = fundamentaldiagram();
k_new = k*500-9;
xticks('auto')
xticklabels({'0.022','0.026','0.030','0.034','0.038','0.042','0.046','0.050','0.054','0.058'})
plot(ax3,k_new,2*q*3600,'k-','LineWidth',2,'DisplayName','Fundamental Diagram of Junction')
hold on
plot(ax3,k_new,q*3600,'-','Color',[0.5 0.5 0.5 ],'LineWidth',2,'DisplayName','Findamental Diagram of Single Arm')
% view([90 -90])

%% Equilibrium flow for the density range
flow2NumCrosses = 3600;
dens_rng = [0.001:0.001:0.07];
for i = 1:numel(dens_rng)
    flow_tmp = q(abs(k-dens_rng(i))<0.0001)*flow2NumCrosses;
    flow_rng(i) = flow_tmp(1);
end

%% Normilased Junction Flow (Single Simulations)
load('AggregatedDelays200Meter.mat')
[k,q, v] = fundamentaldiagram();

flow2NumCrosses = 3600;
dens_rng = linspace(0.001,0.07,70);
flow_rng = NaN(1,nDensPoints);
flowTotal = NaN(1,nDensPoints);
flowTotalNorm = NaN(1,nDensPoints);

for i = 1:nDensPoints
    flow_tmp = q(abs(k-dens_rng(i))<0.0001)*flow2NumCrosses;
    flow_rng(i) = flow_tmp(1);
    flowTotal(i) = numel(data(i).crossCount);
    
    % normalise the flow
    flowTotalNorm(i) = flowTotal(i)/(2*flow_rng(i));
end
ax3 = axes;
hold on
plot(ax3,flowTotalNorm,'go-')
xticks('auto')
xticklabels(string([0.01:0.01:0.07]))

% ylabel('Normalised Junction Flow $\hat{Q}_{\Sigma}$ ')
% xlabel('Density $\rho$ (veh/m)')

%% Gini coefficient line of phased scenario
load('AggregatedDelays200Meters.mat')

densNum = 70;

Gini = [];
for i = 1:densNum
        
    travelArrayEast = travelTimesEast(i,:);
    travelArrayNorth = travelTimesNorth(i,:);
    travelArray = [travelArrayEast(~isinf(travelArrayEast)) travelArrayNorth(~isinf(travelArrayNorth))];
    travelArray(isnan(travelArray)) = [];
    population = 1:numel(travelArray);
    
    delayArraySort = [0 sort(abs(travelArray),'Ascend')];
    
    delayArraySort = cumsum(delayArraySort);
    delayCum = delayArraySort/delayArraySort(end);
    x_rng = [0 population]/population(end);

    
    Gini(i) = 1-sum((delayCum(1:end-1)+delayCum(2:end)).*diff(x_rng));

end



ax3 = axes;
hold on
plot(ax3,Gini(1:70),'go-')
% xticks('auto')
% xticklabels(string([0.01:0.01:0.07]))
legend('Phased set-up')
%% Box plots of normalised flow over density sweep (Ensemble simulations)
load('FlawAndFairnessEnsembles.mat')
% ax3 = axes;
xRange = round(density(1,:),3);
boxplot(ax3,Gini',xRange)
ylabel('Gini Coefficient $G$ ')
xlabel('Density $\rho$ (veh/m)')
xticks('auto')
% xticklabels({'0.022','0.026','0.030','0.034','0.038','0.042','0.046','0.050','0.054','0.058'})

% xticks(0.01:0.01:0.07)
xticklabels(string([0.01:0.01:0.07]))
grid on
hold on
ylim([0 1])
%% saving figure as a PDF
% xlim([1000 1500])
pause(2)
fig = gcf;
fig.PaperPositionMode = 'auto';
fig.PaperPosition;
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(fig,'fairness-random-ensembles-vs-phased-3-sec-accel-9.pdf','-dpdf','-r0','-bestfit')
% pause(3)
% close all
