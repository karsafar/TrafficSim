close all
clear

%% INPUT PARAMETERS
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
fixedSeed = [true true];
% road dimensions
roadDims.Start = [-150; -150];
roadDims.End = [150; 150];
roadDims.Width = [4; 4];
roadDims.Length = roadDims.End - roadDims.Start;
selectRoadTypes = [1, 1] ;
[PrescriptionRange]= input_dialog_box(selectRoadTypes);

nIterations = runTime/dt;
nDigits = numel(num2str(dt))-2;
t_rng = round(linspace(0,runTime,nIterations),nDigits);
numberOfSimRuns = 20;


%% Decide type of road parameters
[subRoadArgs,numberOfSimRuns] = prescribe_traffic(selectRoadTypes,numberOfSimRuns,carTypes,carTypeRatios,nIterations,fixedSeed,roadDims,PrescriptionRange);

%% run simulations
for k = 1:numberOfSimRuns
    sim(k) = run_simulation({roadTypes{selectRoadTypes(1)},roadTypes{selectRoadTypes(2)}},carTypes,subRoadArgs(k),t_rng,plotFlag,priority,roadDims,nIterations,dt);
end

function [horiz, vert] = input_dialog_box(selectRoadTypes)

if selectRoadTypes(1) == 1 && selectRoadTypes(2) == 1
    prompt = {'Enter Density values for horizontal arm:','Enter Density values for vertical arm:'};
    title = 'Input';
    dims = [1 35];
    definput = {'0.04 0.04','0.04 0.04'};
    answer = inputdlg(prompt,title,dims,definput);
elseif selectRoadTypes(1) == 1 && selectRoadTypes(2) == 2
    prompt = {'Enter Density values for horizontal arm:','Enter mean spawning values for vertical arm:'};
    title = 'Input';
    dims = [1 35];
    definput = {'0.04','7'};
    answer = inputdlg(prompt,title,dims,definput);
elseif selectRoadTypes(1) == 2 && selectRoadTypes(2) == 2
    prompt = {'Enter mean spawning values for horizontal arm:','Enter mean spawning values for vertical arm:'};
    title = 'Input';
    dims = [1 35];
    definput = {'7','7'};
    answer = inputdlg(prompt,title,dims,definput);
elseif selectRoadTypes(1) == 2 && selectRoadTypes(2) == 1
    prompt = {'Enter mean spawning values for horizontal arm:','Enter Density values for vertical arm:'};
    title = 'Input';
    dims = [1 35];
    definput = {'7','0.04'};
    answer = inputdlg(prompt,title,dims,definput);
end
horiz = str2num(answer{1});
vert = str2num(answer{2});
end

