close all
clear

prescription = 'density';
HorizArmBtCarRatio = 1; % per cent of cars are BtCars
VertArmBtCarRatio = 1; % per cent of cars are BtCars
carTypeRatios= [HorizArmBtCarRatio VertArmBtCarRatio];
plotFlag = true;
runTime = 3600; % in seconds
timeStep = 0.1; % in seconds
priority = true;
roadDimensions = [-200 100 4];
numberOfSimRuns = 8;
occupancy = {linspace(0.25,0.025,numberOfSimRuns);
    linspace(0.25,0.25,numberOfSimRuns)};

sim = NaN(1,numberOfSimRuns);
for k = 1:numberOfSimRuns
    [sim(k)] = driverscript_density(...
        carTypeRatios,...
        runTime,...
        plotFlag,...
        priority,...
        roadDimensions,...
        [occupancy{1}(k); occupancy{2}(k)],...
        timeStep);
end

save('/Users/robot/car_sim_mat_Files/density_29_04.mat','prescription','carTypeRatios','runTime','timeStep',...
    'plotFlag','occupancy','priority','roadDimensions','nIterations','k','sim','-v7.3')

% save real_data
% p = profile('info');
% save myprofiledata5 p

% clear p
% load myprofiledata
% profview(0,p)