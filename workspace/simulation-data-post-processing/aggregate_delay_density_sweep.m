clc
clear
% close all

[k,q, v] = fundamentaldiagram();

d = dir('test-*.mat');
Number_mat = length(d);
numCars = [];
travelTimesEast = NaN(Number_mat,5000);travelTimesNorth = NaN(Number_mat,5000);
Delay_East = NaN(Number_mat,5000);Delay_North = NaN(Number_mat,5000);
interestRegion = 200;
for i = 1:Number_mat
    %% load simualation
    fnm = sprintf('test-%s',num2str(i));
    load(fullfile(fnm))
%     interestRegion = road.Length(1);
    %% calculate travel times for each arm
    [travelTimesEastTemp] = calc_travel_times(sim.horizArm,interestRegion,t_rng);
    [travelTimesNorthTemp] = calc_travel_times(sim.vertArm,interestRegion,t_rng);
    
    travelTimesEast(i,1:numel(travelTimesEastTemp)) = travelTimesEastTemp;
    travelTimesNorth(i,1:numel(travelTimesNorthTemp)) = travelTimesNorthTemp;
    
    %% calculate equilibrium travel times for each arm density
    v_eq_East = v(abs(k-density(1))<0.00001);
    t_eq_East(i) = interestRegion/v_eq_East(1);
    
    v_eq_North = v(abs(k-density(2))<0.00001);
    t_eq_North(i) = interestRegion/v_eq_North(1);
    
    %% plot travel time differences for each arm
    %     figure(1)
    %     cla
    %     h1 = histogram(travelTimesEast-t_eq_East);
    %     hold on
    %     h2 = histogram(travelTimesNorth-t_eq_North);
    %     legend('East arm delays','North arm delays')
    %
    %% aggregate travel times for each arm over ensembles
    Delay_East(i,:) = travelTimesEast(i,:)-t_eq_East(i);
    Delay_North(i,:) = travelTimesNorth(i,:)-t_eq_North(i);
    i
    
    
    %% Mean
    %     m_E(i) = mean(travelTimesEast);
    %     std_E(i) = std(travelTimesEast);
    %
    %     m_N(i) = mean(travelTimesNorth);
    %     std_N(i) = std(travelTimesNorth);
    
    %     %% Fairness Metric
    %     nCrosses = numel(r_E) + numel(r_N);
    %     R_E(i) = numel(r_E)/nCrosses;
    %     R_N(i) = numel(r_N)/nCrosses;
    %
    %     % Global utility of the juncton
    %     F(i) = min(m_E*R_E(i),m_N*R_N(i))/max(m_E*R_E(i),m_N*R_N(i))
    
end
save('AggregatedDelays200Meter.mat','Delay_East','Delay_North','t_eq_East','t_eq_North','travelTimesEast','travelTimesNorth')

return

g1 = repmat({'Eastbound'},numel(m_E),1);
g2 = repmat({'Northbound'},numel(m_N),1);
g = [g1; g2];
boxplot([m_E-t_eq_East;m_N-t_eq_East],g)
title('ensembles over 25 simulations')
xlabel('Junction Arms')
ylabel('Average Junction Delay $\overline{D}$ (s)')

%%
n = 1;
for i = 0.002:0.001:0.131
    temp = v(abs(k-i)<0.00001);
    v_eq_East(n) = temp(1);
    n = n+1;
end
%%
t_eq_East = interestRegion./v_eq_East;

delayE = m_E-t_eq_East;
delayN = m_N-t_eq_East;
delayN(isinf(delayN)) = NaN;
delayE(isinf(delayE)) = NaN;
plot([0.001:0.001:0.13],delayE,'r*',[0.001:0.001:0.13],delayN,'bo');
xlabel('Density $\rho$ (veh/m)')
ylabel('Average Junction Delay $\overline{T}$ (s)')


%% Average Delay over density sweep
meanEastDelay = nanmean(Delay_East')';
meanNorthDelay = nanmean(Delay_North')';
meanEastDelay(isinf(meanEastDelay)) = NaN;
meanNorthDelay(isinf(meanNorthDelay)) = NaN;

plot([0.001:0.001:0.13],meanEastDelay,'r*',[0.001:0.001:0.13],meanNorthDelay,'bo');
xlabel('Density $\rho$ (veh/m)')
ylabel('Average Delay $\overline{D}$ (s)')
% set(gca, 'YScale', 'log')
xticks(gca,0:0.01:0.13)

%% Gini coefficient over density sweep
Gini = [];
for i = 1:Number_mat
        
    travelArrayEast = travelTimesEast(i,:);
    travelArrayNorth = travelTimesNorth(i,:);
    travelArray = [travelArrayEast(~isinf(travelArrayEast)) travelArrayNorth(~isinf(travelArrayNorth))];
    travelArray(isnan(travelArray)) = [];
    population = 1:numel(travelArray);
    % [g,l,a] = gini(population,abs(delayArray),true)
    
    delayArraySort = [0 sort(abs(travelArray),'Ascend')];
    
    delayArraySort = cumsum(delayArraySort);
    delayCum = delayArraySort/delayArraySort(end);
    %     x_rng = (1:numel(delayCum))/numel(delayCum);
    x_rng = [0 population]/population(end);
    % figure(3)
    % plot(x_rng,delayCum,'k-')
    % hold on
    % plot([0,1],[0,1],'--k');
    
    
    Gini(i) = 1-sum((delayCum(1:end-1)+delayCum(2:end)).*diff(x_rng))
    
    
    %         B = trapz(delayCum)/numel(delayCum);
    %         A = 0.5 - B;
    %         Gini(i,j) = A/(A+B);
end
plot([0.001:0.001:0.13],Gini,'r*')
xlabel('Density $\rho$ (veh/m)')
xticks(gca,0:0.01:0.13)
ylabel('Gini Coefficient $G$')
ylim([0 1])
xlim([0 0.13])
%% Gini of a junction 
meanEastDelay = nanmean(Delay_East')';
meanNorthDelay = nanmean(Delay_North')';
meanEastDelay(isnan(meanEastDelay)) = inf;
meanNorthDelay(isnan(meanNorthDelay)) = inf;
  
delayArrayJunction = [meanEastDelay meanNorthDelay];
Gini = [];
for i = 1:Number_mat
    
    travelArray = abs(delayArrayJunction(i,:));
    travelArray(isinf(travelArray)) = 1e3
    population = 1:numel(travelArray);
    % [g,l,a] = gini(population,abs(delayArray),true)
    
    delayArraySort = [0 sort(abs(travelArray),'Ascend')];
    
    delayArraySort = cumsum(delayArraySort);
    delayCum = delayArraySort/delayArraySort(end);
%     x_rng = (1:numel(delayCum))/numel(delayCum);
    x_rng = [0 population]/population(end);
    
    % figure(3)
    % plot(x_rng,delayCum,'k-')
    % hold on
    % plot([0,1],[0,1],'--k');
    
    
    Gini(i) = 1-sum((delayCum(1:end-1)+delayCum(2:end)).*diff(x_rng));
    i
%     
%     B = trapz(cumsum(delayArray))/delayArray(end)
%     A = 0.5 - B
%     Gini(i) = A/(A+B)
end
plot([0.001:0.001:0.13],Gini(1,:),'r*-')
xlabel('Density $\rho$ (veh/m)')
xticks(gca,0:0.01:0.13)
ylabel('Junction Gini Coefficient $G$')
ylim([0 1])


%% saving figure as a PDF
% xlim([1000 1500])
pause(2)
fig = gcf;
fig.PaperPositionMode = 'auto';
fig.PaperPosition;
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(fig,'gini-phased-travel-time-junction.pdf','-dpdf','-r0','-bestfit')
% pause(3)
% close all


%%
function [travelTimes] = calc_travel_times(arm,interestRegion,t_rng)


travelTimes = [];
for iCar = 1:arm.numCars
    tempDisp = arm.allCars(iCar).History(1,:);
    
    % separate displacements of each car that are within the region of interest
    tempDispRange = tempDisp(arm.allCars(iCar).History(1,:)>=-interestRegion/2 &...
        arm.allCars(iCar).History(1,:)<=interestRegion/2);
    
    % separate times of each car that are within the region of interest
    tempTimeRange = t_rng(arm.allCars(iCar).History(1,:)>=-interestRegion/2 &...
        arm.allCars(iCar).History(1,:)<=interestRegion/2);
    
    % set to 1 the displacement array when vehicle re-enters the region of interest
    dispEdges = diff(tempDispRange)<0;
    
    % pick indices of re-entrance
    x = find(dispEdges);
    
    
    if ~isempty(tempDispRange) && ~isempty(x)
        % check if the first values of displacement array is at the exact start
        % of the region of interest
        if diff([-interestRegion/2,tempDispRange(1)]) < 5
            % if yes, then  set values of next elements after the edges
            dispEdges(x+1) = 1;
            tmp = [tempTimeRange(1) tempTimeRange(dispEdges)];
        else
            % if not, then remove the first element of dispalcement array from the list of edge values
            dispEdges(x(1)) = 0;
            % set values of next elements after the edges
            dispEdges(x+1) = 1;
            % store without the first element
            tmp = [tempTimeRange(dispEdges)];
        end
        
        % make the list of edge elements into an even array of elements
        if mod(numel(tmp),2)
            tmp = tmp(1:end-1);
        end
        % pair the start and end of the region of interest to calculate the
        % travel time from end to end
        TimeRangePairs = [];
        TimeRangePairs(:,1) = tmp(1:2:end);
        TimeRangePairs(:,2) = tmp(2:2:end);
        travelTimes = [travelTimes diff(TimeRangePairs')];
    else
        travelTimes = [travelTimes inf];
    end
end
end

