clear
close all
clc

roadTypes = {@LoopRoad @FiniteRoad};
carTypes = {@carTypeA, @carTypeB, @carTypeC};

plotFlag = true;
setappdata(0,'drawRAte',0);

runTime = 3600;
dt = 0.1;
nIterations = (runTime/dt)+1;
nDigits = numel(num2str(dt))-2;
t_rng = 0:dt:runTime;
fixedSeed = [false false];
priority = false;

% road dimensions
road.Start = [-300; -300];
road.End = [300; 300];
road.Width = [4; 4];
road.Length = road.End - road.Start;

noSpawnAreaLength = 24.4; % length of no spawn area around the junction + length of a car for safe re-spawn
max_density = 1/6.4;    % number of cars per metre (0.1562)

%%
density = 0.03;
nCars = round(density * road.Length);
RealDensity = nCars/road.Length;

%%
iIteration = 0;
if plotFlag == 0
    f = waitbar(0,'','Name','Running simulation',...
        'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
    setappdata(f,'canceling',0);
    waitbar(0,f,sprintf('%d percent out of %d iterations',round(iIteration*100/nIterations),nIterations))
end
%single simulation flag 
setappdata(0,'simType',0);

carTypeRatios = [0.4 0.2 0.4; 0.4 0.2 0.4];

allCarsNumArray_H = zeros(1,numel(carTypes));
allCarsNumArray_V = zeros(1,numel(carTypes));
for j = 1:numel(carTypes)
    if j == numel(carTypes)
        allCarsNumArray_H(j) = nCars(1) - sum(allCarsNumArray_H(1:j-1));
        allCarsNumArray_V(j) = nCars(2) - sum(allCarsNumArray_V(1:j-1));
    else
        allCarsNumArray_H(j) = round(nCars(1)*carTypeRatios(1,j));
        allCarsNumArray_V(j) = round(nCars(2)*carTypeRatios(2,j));
    end
end

Arm.H = SpawnCars([{allCarsNumArray_H},fixedSeed(1),{carTypes}],'horizontal',road.Start(1),road.End(1),road.Width(1),dt,nIterations);
Arm.V = SpawnCars([{allCarsNumArray_V},fixedSeed(1),{carTypes}],'vertical',road.Start(2),road.End(2),road.Width(2),dt,nIterations);

%% run the simuation
sim = run_simulation(...
    {roadTypes{1},...
    roadTypes{1}},...
    carTypes,...
    Arm,...
    t_rng,...
    plotFlag,...
    priority,...
    road,...
    nIterations,...
    dt);

%% save the simulation results
save(['/Users/robot/.CMVolumes/Karam Safarov/PhD/short simulations/single-run-sim/test-' num2str(1) '.mat'],...
    'carTypeRatios',...
    'carTypes',...
    'nCars',...
    'allCarsNumArray_H',...
    'allCarsNumArray_V',...
    'runTime',...
    'dt',...
    't_rng',...
    'plotFlag',...
    'priority',...
    'density',...
    'road',...
    'nIterations',...
    'sim',...
    '-v7.3')

%% close the waitbar
if plotFlag == 0
    f = findall(0,'type','figure','tag','TMWWaitbar');
    delete(f)
end

