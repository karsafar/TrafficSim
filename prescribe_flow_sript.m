clc
close all
clear
prescription = 'flow';
roadTypes = {@LoopRoad @FiniteRoad};
carTypes = {@Car, @IdmCar, @BtCar};

HorizArmCarRatios = [0 0.5 0.5];
VertArmCarRatios = [0 1 0];
carTypeRatios = zeros(2,3);
for i = 1:numel(carTypes)
    carTypeRatios(1,i) = sum(HorizArmCarRatios(1:i)) - carTypeRatios(1,i); 
    carTypeRatios(2,i) = sum(VertArmCarRatios(1:i)) - carTypeRatios(2,i); 
end

plotFlag = true;
runTime = 14400; % in seconds
dt = 0.1; % in seconds
numberOfSimRuns = 10;
distributionMean.horizontal = logspace(log10(3),log10(10),numberOfSimRuns);
distributionMean.vertical = logspace(log10(30),log10(30),numberOfSimRuns);
priority = true;

% road dimensions
road.Start = [-600; -600];
road.End = [600; 600];
road.Width = [4; 4];
road.Length = road.End - road.Start;

nIterations = runTime/dt;
nDigits = numel(num2str(dt))-2;
t_rng = round(linspace(0,runTime,nIterations),nDigits);

for k = 1:numberOfSimRuns
    subRoadArgs.Horizontal = [{carTypeRatios(1,:)},distributionMean.horizontal(k),nIterations];
    subRoadArgs.Vertical = [{carTypeRatios(2,:)},distributionMean.vertical(k),nIterations];
        
    [sim(k)] = run_simulation({roadTypes{2},roadTypes{2}},carTypes,subRoadArgs,t_rng,plotFlag,priority,road,nIterations,dt);
end

beep

save('/Users/robot/car_sim_mat_Files/flow_change_09_05_0_0_.mat','prescription','carTypeRatios','dt','t_rng',...
    'plotFlag','distributionMean','priority','road','runTime','numberOfSimRuns','sim','-v7.3')





