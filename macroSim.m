close all
clear

%% INPUT PARAMETERS
roadTypes = {@LoopRoad @FiniteRoad};
carTypes = {@IdmCar, @HdmCar, @AggressiveCar, @PassiveCar, @HesitantCar, @ManualCar};

carTypeRatios = [0 0 0 0 0 1; 0 0 1 0 0 0];
% carTypeRatios = [0 0 1 0 0 0;0 0 0.25 0.15 0.15 0.45];
assert(sum(carTypeRatios(1,:)) == 1,'Wrong distribution of horizontal arm rations');
assert(sum(carTypeRatios(2,:)) == 1,'Wrong distribution of vertical arm rations');

plotFlag = true;
runTime = 3600; % in seconds
dt = 0.1; % in seconds
priority = true;
fixedSeed = [false false];
% road dimensions
roadDims.Start = [-150; -150];
roadDims.End = [150; 150];
roadDims.Width = [4; 4];
roadDims.Length = roadDims.End - roadDims.Start;
selectRoadTypes = [1 2] ;

nIterations = runTime/dt;
nDigits = numel(num2str(dt))-2;
t_rng = round(linspace(0,runTime,nIterations),nDigits);
numberOfSimRuns = 25;
densityRange = [0.03, 0.03; 0.0001, 0.0001];
distMeanRange = [7, 10; 27, 30];

%% Decide type of road parameters
[subRoadArgs,numberOfSimRuns] = prescribe_traffic(selectRoadTypes,numberOfSimRuns,carTypes,carTypeRatios,fixedSeed,roadDims,densityRange,distMeanRange,dt,nIterations);

%% run simulations
for k = 1:numberOfSimRuns
    tic
    sim(k) = run_simulation({roadTypes{selectRoadTypes(1)},roadTypes{selectRoadTypes(2)}},carTypes,subRoadArgs(k),t_rng,plotFlag,priority,roadDims,nIterations,dt);
    runTime(k) = toc;
end

for k = 1:numberOfSimRuns
    numCars(k) = subRoadArgs(k).Horizontal{2};
end
plot(numCars, runTime,'*-')
xlabel('Number of Cars per 1 km');
ylabel('Simulation Time, s')
grid on

