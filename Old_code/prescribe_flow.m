close all
clear

prescription = 'flow';
carTypes = {@Car, @IdmCar, @BtCar};
HorizArmCarRatios = [0 0.8 0.2];
VertArmCarRatios = [0 1 0];

carTypeRatios = zeros(2,3);
for i = 1:numel(carTypes)
    carTypeRatios(1,i) = sum(HorizArmCarRatios(1:i)) - carTypeRatios(1,i); 
    carTypeRatios(2,i) = sum(VertArmCarRatios(1:i)) - carTypeRatios(2,i); 
end

% carTypeRatios = [HorizArmBtCarRatio VertArmBtCarRatio];
plotFlag = true;
runTime = 3600; % in seconds
timeStep = 0.1; % in seconds
numberOfSimRuns = 4;
distributionMean = {logspace(log10(5),log10(10),numberOfSimRuns);
              logspace(log10(5),log10(10),numberOfSimRuns)};
priority = true;
roadDimensions = [-500 500, 4];

sim = NaN(1,numberOfSimRuns);
for k = 1:numberOfSimRuns
    [sim(k)] = driverscript_flow(...
        carTypes,...
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





