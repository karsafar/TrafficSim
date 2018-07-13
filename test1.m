close all
clear

%% INPUT PARAMETERS
roadTypes = {@LoopRoad @FiniteRoad};
carTypes = {@IdmCar, @HdmCar, @AggressiveCar, @PassiveCar, @HesitantCar, @ManualCar};

% carTypeRatios = [0 0 1 0 0 0; 0 0 1 0 0 0];
carTypeRatios = [0 0 0.5 0 0 0.5;0 0 0.25 0.15 0.15 0.45];
assert(sum(carTypeRatios(1,:)) == 1,'Wrong distribution of horizontal arm rations');
assert(sum(carTypeRatios(2,:)) == 1,'Wrong distribution of vertical arm rations');

plotFlag = true;
runTime = 3600; % in seconds
dt = 0.1; % in seconds
priority = true;
fixedSeed = [true true];
% road dimensions
roadDims.Start = [-150; -150];
roadDims.End = [150; 150];
roadDims.Width = [4; 4];
roadDims.Length = roadDims.End - roadDims.Start;

title = 'Select road type';
prompt = {'Horizontal arm','Veritcal arm'};
dims = [1 50; 1 50;];
definput = {'1 - density, 0 - flow', '1 - density, 0 -  flow'};
answer = inputdlg(prompt,title,dims,definput);
selectRoadTypes = [str2num(answer{1}); str2num(answer{2})];

nIterations = runTime/dt;
nDigits = numel(num2str(dt))-2;
t_rng = round(linspace(0,runTime,nIterations),nDigits);
numberOfSimRuns = 1;
densityRange = [0.02, 0.04; 0.02, 0.04];
distMeanRange = [7, 10; 7, 10];

%% Decide type of road parameters
[subRoadArgs,numberOfSimRuns] = prescribe_traffic(selectRoadTypes,numberOfSimRuns,carTypes,carTypeRatios,fixedSeed,roadDims,densityRange,distMeanRange);

% swich to manual spawn
title = 'Select sim input type';
prompt = {'Horizontal arm ','Vertical arm'};
dims = [1 50; 1 50;];
definput = {'1 - manual, 0 - prescribed density', '1 - manual, 0 - prescribed density'};
answer = inputdlg(prompt,title,dims,definput);
manualFlag = [str2num(answer{1}); str2num(answer{2})];
Arm = decide_input(manualFlag,carTypes,roadDims,subRoadArgs,dt);

%% run simulations
for k = 1:numberOfSimRuns
    sim(k) = run_simulation({roadTypes{selectRoadTypes(1)},roadTypes{selectRoadTypes(2)}},carTypes,Arm,t_rng,plotFlag,priority,roadDims,nIterations,dt);
end


