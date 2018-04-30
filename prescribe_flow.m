close all
clear all

prescription = 'flow';
HorizArmBtCarRatio = 1; % per cent of cars are BtCars
VertArmBtCarRatio = 1; % per cent of cars are BtCars
carTypeRatios = [HorizArmBtCarRatio VertArmBtCarRatio];
plotFlag = true;
runTime = 3600; % in seconds
timeStep = 0.1; % in seconds
numberOfSimRuns = 4;
distributionMean = {logspace(log10(5),log10(5),numberOfSimRuns);
              logspace(log10(5),log10(5),numberOfSimRuns)};
priority = true;
roadDimensions = [-500 500, 4];

sim = NaN(1,numberOfSimRuns);
for k = 1:numberOfSimRuns
    [sim(k)] = driverscript_flow(...
        carTypeRatios,...
        runTime,...
        plotFlag,...
        priority,... 
        roadDimensions,...
        [distributionMean{1}(k); distributionMean{2}(k)],...
        timeStep);
end

save('/Users/robot/car_sim_mat_Files/flow_change_18_04_3.mat','prescription','carTypeRatios','timeStep',...
    'plotFlag','distributionMean','priority','roadDimensions','runTime','k','sim','-v7.3')





