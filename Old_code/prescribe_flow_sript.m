close all
clear
%% INPUT PARAMETERS
% prescription = 'flow';

roadTypes = {@LoopRoad @FiniteRoad};
carTypes = {@IdmCar, @HdmCar, @AggressiveCar, @PassiveCar, @HesitantCar, @ManualCar};

% carTypeRatios = [0 0 1 0 0 0; 0 0 1 0 0 0];
carTypeRatios = [0 0 0 0 0 1;0 0 0.25 0.15 0.15 0.45];
assert(sum(carTypeRatios(1,:)) == 1,'Wrong distribution of horizontal arm rations');
assert(sum(carTypeRatios(2,:)) == 1,'Wrong distribution of vertical arm rations');

plotFlag = true;
runTime = 3600; % in seconds
dt = 0.1; % in seconds
priority = true;
fixedDistribution = [true true];
% road dimensions
roadDims.Start = [-150; -150];
roadDims.End = [150; 150];
roadDims.Width = [4; 4];
roadDims.Length = roadDims.End - roadDims.Start;
selectRoadTypes = [2 2];
nIterations = runTime/dt;
nDigits = numel(num2str(dt))-2;
t_rng = round(linspace(0,runTime,nIterations),nDigits);
numberOfSimRuns = 10;

%%
[subRoadArgs] = prescribe_traffic(selectRoadTypes,numberOfSimRuns,carTypes,carTypeRatios,nIterations,fixedDistribution);


% numberOfSimRuns = 10;
% distMeanRange = [7, 10;
%                  7, 10];
%
% distributionMean.horizontal = logspace(log10(distMeanRange(1,1)),log10(distMeanRange(1,2)),numberOfSimRuns);
% distributionMean.vertical = logspace(log10(distMeanRange(2,1)),log10(distMeanRange(2,2)),numberOfSimRuns);

for k = 1:numberOfSimRuns
    [sim(k)] = run_simulation({roadTypes{selectRoadTypes(1)},roadTypes{selectRoadTypes(2)}},carTypes,subRoadArgs,t_rng,plotFlag,priority,roadDims,nIterations,dt);
end

save('/Users/robot/car_sim_mat_Files/flow_change_09_05_0_0_.mat','prescription','carTypeRatios','dt','t_rng',...
    'plotFlag','distributionMean','priority','road','runTime','numberOfSimRuns','sim','-v7.3')





