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
selectRoadTypes = [1 1] ;

nIterations = runTime/dt;
nDigits = numel(num2str(dt))-2;
t_rng = round(linspace(0,runTime,nIterations),nDigits);
numberOfSimRuns = 20;
densityRange = [0.02, 0.04; 0.02, 0.04];
distMeanRange = [7, 10; 7, 10];

%% Decide type of road parameters
[subRoadArgs,numberOfSimRuns] = prescribe_traffic(selectRoadTypes,numberOfSimRuns,carTypes,carTypeRatios,fixedSeed,roadDims,densityRange,distMeanRange);

manualFlag = 0;
if manualFlag
    %% needs a UI with dialogbox to input paramenters
    sz = [2 4];
    varTypes = {'double','double','double','function_handle'};
    varNames = {'position','velocity','acceleration','carType'};
    % table of all cars inputed manually
    T = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
    T.position = [20;-20];
    T.velocity = [5;7];
    T.acceleration = [1;1];
    T.carType = {carTypes{3};carTypes{3}};
    H_Arm = SpawnCars(T,'horizontal',roadDims.Start(1),roadDims.End(1),roadDims.Width(1),dt);
    V_arm = SpawnCars(T,'vertical',roadDims.Start(2),roadDims.End(2),roadDims.Width(2),dt);
else
    % need a loop to go through 1 to k subroad arguments
    H_Arm = SpawnCars([subRoadArgs(1).Horizontal,{carTypes}],'horizontal',roadDims.Start(1),roadDims.End(1),roadDims.Width(1),dt);
    V_arm = SpawnCars([subRoadArgs(1).Vertical,{carTypes}],'vertical',roadDims.Start(2),roadDims.End(2),roadDims.Width(1),dt);
end
%% run simulations
for k = 1:numberOfSimRuns
    sim(k) = run_simulation({roadTypes{selectRoadTypes(1)},roadTypes{selectRoadTypes(2)}},carTypes,subRoadArgs(k),t_rng,plotFlag,priority,roadDims,nIterations,dt);
end


