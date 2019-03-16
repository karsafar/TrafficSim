clc
clear
close all

% load data in the loop
% d = dir('*.mat');          
% Number_mat = length(d);   
% clear d
for l = 2:10
    dir_name = sprintf('seed-%s',num2str(l));
    fnm = sprintf('%s percent',num2str(50));
    d = dir([fullfile('/Users/robot/OneDrive - University of Bristol/PhD/bulk simulations/Scenarios/scenario 5 - long simulations/',dir_name,fnm), '/*.mat']);
    Number_mat = length(d);
    clear d
    
    eastArm = NaN(3,Number_mat);
    northArm = NaN(3,Number_mat);
    for i = 1:Number_mat
        filename = sprintf('test-%s.mat',num2str(i));
        load(fullfile('/Users/robot/OneDrive - University of Bristol/PhD/bulk simulations/Scenarios/scenario 5 - long simulations/',dir_name,fnm,filename),'-mat','sim','density')
%         load(fullfile('/Users/robot/OneDrive - University of Bristol/PhD/bulk simulations/Scenarios/scenario 5 - long simulations/',dir_name,fnm,filename),'sim','density')
%         toc
%         m = matfile(fullfile('/Users/robot/OneDrive - University of Bristol/PhD/bulk simulations/Scenarios/scenario 5 - long simulations/',dir_name,fnm,filename));
%         sim = m.sim;
        temp1 = nanmean(sim.horizArm.averageVelocityHistory);
        eastArm(:,i) = [temp1;density;density*temp1];
        % eastArm Arm data
%         eastArm.averagesAcrossSimulation(i) = nanmean(sim.horizArm.averageVelocityHistory);
%         eastArm.density(i) = density;
%         eastArm.flow(i) = eastArm.density(i)*eastArm.averagesAcrossSimulation(i);
        
        % northArm Arm data
%         northArm.averagesAcrossSimulation(i) = nanmean(sim.vertArm.averageVelocityHistory);
%         northArm.density(i) = density;
%         northArm.flow(i) = northArm.density(i)*northArm.averagesAcrossSimulation(i);
        temp2 = nanmean(sim.vertArm.averageVelocityHistory);
        northArm(:,i) = [temp2;density;density*temp2];
        %     for j = 1:nIterations
        %         eastArm.flowChange(i,j) = eastArm.density(i)*sim.horizArm.averageVelocityHistory(j);
        %         northArm.flowChange(i,j) = northArm.density(i)*sim.vertArm.averageVelocityHistory(j);
        %     end
        clear sim temp1 temp2 density
    end
    file_name = sprintf('rate-%s.mat',num2str(50));
    averageFlow = mean([eastArm(3,:);northArm(3,:)]);
    save(fullfile('/Users/robot/OneDrive - University of Bristol/PhD/bulk simulations/Scenarios/scenario 5 - long simulations/',dir_name,file_name),'eastArm','northArm','averageFlow')
    clear eastArm northArm averageFlow
end
% save('processedData.mat','eastArm','northArm','averageFlow');


%%
% 
% figure
% histogram(eastArm.flow)
% histfit(eastArm.flow)
% title('East Arm','FontSize',16)
% xlabel('Flow, veh/s','FontSize',16)
% 
% %%
% figure
% histogram(northArm.flow)
% histfit(northArm.flow)
% title('North Arm','FontSize',16)
% xlabel('Flow, veh/s','FontSize',16)
% 
% %%
% 
% averageFlow = mean([eastArm.flow;northArm.flow]);
% figure
% histogram(averageFlow)
% histfit(averageFlow)
% title('Average across the Junction','FontSize',16)
% xlabel('Flow, veh/s','FontSize',16)
% 

%% 
%figure
%boxplot(averageFlow)
%grid on
%max(averageFlow);
%min(averageFlow);

%%
%{
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

%% 
for i = 1:length(eastArm.flowChange)
    eastAverageFlow(i) = nanmean(eastArm.flowChange(1,1:i));
    northAverageFlow(i) = nanmean(northArm.flowChange(1,1:i));
end
figure
plot(eastArm.flowChange(1,:))
hold on
plot(northArm.flowChange(1,:))
hold on
plot(mean([eastArm.flowChange(1,:);northArm.flowChange(1,:)]))
xlabel('Iteration No','FontSize',16)
ylabel('Flow, veh/s','FontSize',16) 
%}