clear
close all
clc
roadTypes = {@LoopRoad @FiniteRoad};
carTypes = {@IdmModel, @HdmModel, @carTypeA, @carTypeB, @carTypeC, @carTypeA_old};

plotFlag = true;
setappdata(0,'drawRAte',1);

runTime = 360; % sec
dt = 0.1;
nIterations = (runTime/dt)+1;
nDigits = numel(num2str(dt))-2;
t_rng = 0:dt:runTime;

fixedSeed = [ 0 0];
% seedType = rng('shuffle', 'combRecursive');
priority = false;


transientCutOffLength = 0;
swapRate = 0;
%%

density = 0.010;

n = 1;
nCars = [n; n];

road.Length = round(nCars/density);  % length is rounded so need to correct the value of density
half_length = road.Length/2;
road.Start = [-half_length(1,:); -half_length(2,:)];
road.End = [half_length(1,:); half_length(2,:)];
road.Width = [4; 4];


noSpawnAreaLength = road.Width(1)+Car.dimension(2); % length of no spawn area around the junction + length of a car for safe re-spawn
max_density = 1/6.4;    % number of cars per metre (0.1562)

maxDen = nCars./(6.4*nCars+noSpawnAreaLength);
errMess1 = sprintf('East road density has to be <= %.4f', maxDen(1));
errMess2 = sprintf('North road density has to be <= %.4f', maxDen(2));


assert(maxDen(1)>=density,errMess1);
assert(maxDen(2)>=density,errMess2);


density = nCars./road.Length;

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

carTypeRatios = [0 0 1 0 0 0; 0 0 1 0 0 0];
% carTypeRatios = [0 0 0 1 0 0; 0 0 0 1 0 0];
% carTypeRatios = [0 0 1 0 0 0; 0 0 1 0 0 0];

allCarsNumArray_H = zeros(1,numel(carTypes));
allCarsNumArray_V = zeros(1,numel(carTypes));
for j = 1:numel(carTypes)
    if j == numel(carTypes)
        allCarsNumArray_H(j) = nCars(1) - sum(allCarsNumArray_H(1:j-1));
        allCarsNumArray_V(j) = nCars(2) - sum(allCarsNumArray_V(1:j-1));
    else
        allCarsNumArray_H(j) = floor(nCars(1)*carTypeRatios(1,j));
        allCarsNumArray_V(j) = floor(nCars(2)*carTypeRatios(2,j));
    end
end

% 1-loopToad; 2-finiteRoad
selectRoadTypes = [1 1];

if selectRoadTypes(1) == 1
    Arm.H = SpawnCars([{allCarsNumArray_H},fixedSeed(1),{carTypes}],'horizontal',road.Start(1),road.End(1),road.Width(1),dt,nIterations);
else
    spawnRate = 3; % 1/q, larger the rate lower the flow
    Arm.H = [{carTypeRatios(1,:)},spawnRate,fixedSeed(1),dt,nIterations];
end
if selectRoadTypes(2) == 1
    Arm.V = SpawnCars([{allCarsNumArray_V},fixedSeed(2),{carTypes}],'vertical',road.Start(2),road.End(2),road.Width(2),dt,nIterations);
else
    spawnRate = 3; % 1/q, larger the rate lower the flow
    Arm.V = [{carTypeRatios(2,:)},spawnRate,fixedSeed(2),dt,nIterations];
end


% control random process
rng('shuffle', 'combRecursive');

% tic
%% run the simuation
sim = run_simulation(...
    {roadTypes{selectRoadTypes(1)},...
    roadTypes{selectRoadTypes(2)}},...
    carTypes,...
    Arm.H,...
    Arm.V,...
    t_rng,...
    plotFlag,...
    priority,...
    road,...
    nIterations,...
    transientCutOffLength,...
    swapRate,...
    dt);
% toc

% %% close the waitbar
if plotFlag == 0
    f = findall(0,'type','figure','tag','TMWWaitbar');
    delete(f)
end

return
%% save the simulation results

% save(['test-' num2str(19) '.mat'],...
save('test-BT_2.mat',...
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
    'transientCutOffLength',...
    'swapRate',...
    '-v7.3')

