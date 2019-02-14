clc
clear
close all

%% load data in the loop
d = dir('*.mat');          
Number_mat = length(d);    
for i = 1:Number_mat
    load(['test-' num2str(i) '.mat'])
    
    % eastArm Arm data
    eastArm.averagesAcrossSimulation(i) = nanmean(sim.horizArm.averageVelocityHistory);
    eastArm.density(i) = density;
    eastArm.flow(i) = eastArm.density(i)*eastArm.averagesAcrossSimulation(i);

    % northArm Arm data
    northArm.averagesAcrossSimulation(i) = nanmean(sim.vertArm.averageVelocityHistory);
    northArm.density(i) = density;
    northArm.flow(i) = northArm.density(i)*northArm.averagesAcrossSimulation(i);
    
    
    clear sim
end
save('processedData.mat','eastArm','northArm');


%%

figure
histogram(eastArm.flow)
histfit(eastArm.flow)
title('East Arm','FontSize',16)
xlabel('Flow, veh/s','FontSize',16)

%%
figure
histogram(northArm.flow)
histfit(northArm.flow)
title('North Arm','FontSize',16)
xlabel('Flow, veh/s','FontSize',16)

%%

averageFlow = mean([eastArm.flow;northArm.flow]);
figure
histogram(averageFlow)
histfit(averageFlow)
title('Average across the Junction','FontSize',16)
xlabel('Flow, veh/s','FontSize',16)


%% 
figure
boxplot(averageFlow)
grid on
max(averageFlow)
min(averageFlow)

%%
title('Average across the Junction','FontSize',16)
sampleSpace = [1:numel(averageFlow)]';
scatter(sampleSpace,averageFlow)
hold on
grid on
f = fit(sampleSpace,averageFlow','poly1');
plot(f)
ylim([0 0.15])
yticks((0:0.01:0.15))
ylabel('Flow, veh/s','FontSize',16)
xlabel('Simulation No','FontSize',16)