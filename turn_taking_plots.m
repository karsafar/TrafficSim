% clc
% clear
% close all
% 
% %% load the test data
% load(['test-' num2str(loc) '.mat']);


%% junction crossing graph
figure(6)
plot(sim.crossOrder,'-b','LineWidth',1.5)
axis([0 numel(sim.crossOrder) 0 3])
grid on 
xlabel('Number of Junction Crosses','FontSize',16)
text(numel(sim.crossOrder)/2,-0.1,'\uparrow East Arm Crosses','FontSize',16)
text(numel(sim.crossOrder)/2,1.1,'\downarrow North Arm Crosses','FontSize',16)
ylim([-0.5,1.5])


%% Car ratio fluctuations
horizRatios = sim.horizArm.carTypeRatios(1,:)./sim.horizArm.carTypeRatios(2,:);
vertRatios = sim.vertArm.carTypeRatios(1,:)./sim.vertArm.carTypeRatios(2,:);

figure(7)
plot(t_rng,horizRatios)
hold on
grid on 
plot(t_rng,vertRatios)
plot(t_rng,ones(1,numel(t_rng)),'-k','LineWidth',2);
xlabel('Time, s','FontSize',16)
ylabel('ratio of A/B cars','FontSize',16)
lgd = legend('East Arm','North Arm','Base ratio');
lgd.FontSize = 16;

%%

horizAggregatedAverage = NaN(1,nIterations);
vertAggregatedAverage = NaN(1,nIterations);
for i = 1:nIterations
    horizAggregatedAverage(i) = mean(horizRatios(1:i));
    vertAggregatedAverage(i) = mean(vertRatios(1:i));
end

figure(8)
plot(t_rng,horizAggregatedAverage)
hold on
grid on 
plot(t_rng,vertAggregatedAverage)
plot(t_rng,ones(1,numel(t_rng)),'-k','LineWidth',2);
xlabel('Time, s','FontSize',16)
ylabel('Average ratio of A/B cars','FontSize',16)
lgd = legend('East Arm','North Arm','Base ratio');
lgd.FontSize = 16;
ylim([0,2])

%%
figure(9)
% ax11 = subplot(2,1,1);
% title(ax11,'East Arm','FontSize',16)
histogram(horizRatios,'Normalization','pdf')
hold on
% ax12 = subplot(2,1,2);
% title(ax11, 'North Arm','FontSize',16)
histogram(vertRatios,'Normalization','pdf')
lgd = legend('East Arm','North Arm');
lgd.FontSize = 16;
