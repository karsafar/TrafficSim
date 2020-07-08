clear
close all
clc

% setup the simulator 
roadTypes = {@LoopRoad @FiniteRoad};
carTypes = {@IdmModel, @HdmModel, @carTypeA, @carTypeB, @carTypeC, @carTypeA_old};

plotFlag = false;
setappdata(0,'drawRAte',1);

runTime = 600; % sec
dt = 0.1;
nIterations = (runTime/dt)+1;
nDigits = numel(num2str(dt))-2;
t_rng = 0:dt:runTime;

fixedSeed = [1 2];
% seedType = rng('shuffle', 'combRecursive');
priority = false;

transientCutOffLength = 0;

% set a_idm value 
a_idm = 1; %(m/s^2)
setappdata(0,'maxIdmAccel',a_idm);

% new input parameters
t_off = 0;
setappdata(0,'t_off',t_off);


spawnType = 0; % 0 - random; 1 - phased
setappdata(0,'spawnType',spawnType);


swapRate = 0;
%%

density(1) = 0.1;
density(2) = 0.1;

% Name the output file
fnm = sprintf('Density0-1FourCars.mat')

% dens = 0.002:0.001:0.13;
% for density = dens
n = 4;
nCars(1) = n;
nCars(2) = n;

% time gap setup
distFlag = 0; % 1 - is a distribution; 0 - is fixed 
if distFlag
    pd = makedist('Normal','mu',2,'sigma',0.5); % time gap with mean 2 seconds
    pd = truncate(pd,0,4); % distribution truncated at 0 and 4 seconds
    timeGapDist = random(pd,2*n,1); % (s)
else
    timeGapDist = 1*ones(2*n,1); % (s)
end
setappdata(0,'time_gap_dist',timeGapDist);

% set maximum feasible decelearion
mix = 0;% 1-mix arms; 2 - random arms; 0 - fixed arms
if mix > 0
    pd = makedist('Normal','mu',-9,'sigma',2); % maximum deceleration with mean -9 m/s^2
    pd = truncate(pd,-13,-5); % distribution truncated at -13 and -5 m/s^2
    if mix == 1
        a_feas_min = random(pd,n,1); % (m/s^2)
        a_feas_min = [a_feas_min; -9*ones(n,1)]; % (m/s^2)
    elseif mix == 2
        a_feas_min = random(pd,2*n,1); % (m/s^2)
    end
elseif mix == 0
    a_feas_min = -9*ones(2*n,1); % % (m/s^2)
end

setappdata(0,'MinFeasibleDecel',a_feas_min);

% road parameters
road.Length = round(nCars./density);  % length is rounded so need to correct the value of density
half_length = road.Length/2;
road.Start = [-half_length(:,1); -half_length(:,2)];
road.End = [half_length(:,1); half_length(:,2)];
road.Width = [4; 4];


noSpawnAreaLength = road.Width(1)+Car.dimension(2); % length of no spawn area around the junction + length of a car for safe re-spawn
max_density = 1/6.4;    % number of cars per metre (0.1562)

maxDen = nCars./(6.4*nCars+noSpawnAreaLength);
errMess1 = sprintf('East road density has to be <= %.4f', maxDen(1));
errMess2 = sprintf('North road density has to be <= %.4f', maxDen(2));


assert(maxDen(1)>=density(1),errMess1);
assert(maxDen(2)>=density(2),errMess2);


density = nCars./road.Length;


% 1 - stops plotting north arm, 0 - normal junction plotting
setappdata(0,'RoadOrJunctionFlag',0);
% 1 - single arm simulation
singleArmFlag = 1;
if singleArmFlag
    density(2) = 0;
    nCars(2) = 0;
end


if spawnType
    [k,q,v,~] = fundamentaldiagram();
    stpSz = 10;
    vi = [0 0];
    if density(1) ~= 0
        [ki(1),vi(1)] = polyxpoly(k(2:stpSz:end-1),v(2:stpSz:end-1),density(1)*ones(1,numel(v(2:stpSz:end-1))),v(2:stpSz:end-1));
    end
    if density(2) ~= 0
        [ki(2),vi(2)] = polyxpoly(k(2:stpSz:end-1),v(2:stpSz:end-1),density(2)*ones(1,numel(v(2:stpSz:end-1))),v(2:stpSz:end-1));
    end
    setappdata(0,'v_euil',vi);
end
% end


%%
iIteration = 0;
if plotFlag == 0 || t_off > 0
    f = waitbar(0,'','Name','Running simulation',...
        'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
    setappdata(f,'canceling',0);
    waitbar(0,f,sprintf('%d percent out of %d iterations',round(iIteration*100/nIterations),nIterations))
end
%single simulation flag 
setappdata(0,'simType',0);

carTypeRatios = [0 0 1 0 0 0; 0 0 1 0 0 0];
% carTypeRatios = [0 0 0 1 0 0; 0 0 0 1 0 0];
% carTypeRatios = [0 0 0 1 0 0; 1 0 0 0 0 0];

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

tic
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
toc

% %% close the waitbar
if plotFlag == 0
    f = findall(0,'type','figure','tag','TMWWaitbar');
    delete(f)
end

% return
%% save the simulation results
% save(['test-' num2str(19) '.mat'],...
save(fullfile(fnm),...
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

