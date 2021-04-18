clear
close all
clc

%% Name the output file
fnm = sprintf('a_junc_ahead_3.mat')

%% define types road and car objects available for simulations
roadTypes = {@LoopRoad @FiniteRoad};
carTypes = {@IdmModel, @HdmModel, @carTypeA, @carTypeB, @carTypeC, @carTypeA_old};

%% set-up flags
spawnType = 1; % 0 - random; 1 - phased

timeDistFlag = 0; % 1 - is a distribution; 0 - is fixed (2 seconds)

accelFlag = 0;% 1-mix arms; 2 - random arms; 0 - fixed arms

accelAheadFlag = 0;% 1-mix arms; 2 - random arms; 0 - fixed arms

plotFlag = 1; % 0 - don't plot sim, 1- plot sim

singleArmFlag = 0;% 1 - stops plotting north arm, 0 - normal junction plotting

drawRateFlag = 1; % 1 - fast moving objects, 0 - slow moving objects

priority = 0;% 1- east arm has priority, 0 - no priority

selectRoadTypes = [1 1]; % 1-loopToad; 2-finiteRoad

%% simulation resolution
runTime = 3600; % sec
dt = 0.1;
nIterations = (runTime/dt)+1;
nDigits = numel(num2str(dt))-2;
t_rng = 0:dt:runTime;

%% randomnes of initial positions of vehicles
fixedSeed = [1 2];
% seedType = rng('shuffle', 'combRecursive');

% length of time when junction crossing logic is not used
transientCutOffLength = 0;

% set movement speed of vehicles
setappdata(0,'drawRAte',drawRateFlag);

% set a_idm value 
a_idm = 1.5; %(m/s^2)
setappdata(0,'maxIdmAccel',a_idm);

% don't draw simulation for a given time t_off
t_off = 0; 
setappdata(0,'t_off',t_off);

% initial position and velocity of vehicles
setappdata(0,'spawnType',spawnType);

% [0-1] chance of swap
swapRate = 0;

%% density setup
n_d = 0.014;
density(1) = n_d; % east arm density
density(2) = n_d; % north arm density

% dens = 0.002:0.001:0.13;
% for density = dens
n = 3;
nCars(1) = n; % east arm num cars
nCars(2) = n; % north arm num cars

%% time gap setup
if timeDistFlag
    pd = makedist('Uniform','upper',3,'lower',1); % time gap with mean 2 seconds
    timeGapDist = random(pd,2*n,1); % (s)
else
    timeGapDist = 2*ones(2*n,1); % (s)
end

%% set maximum feasible decelearion
if accelFlag > 0
    pd = makedist('Uniform','upper',-5,'lower',-13); % maximum deceleration with mean -9 m/s^2
    if accelFlag == 1
        a_feas_min = random(pd,n,1); % (m/s^2)
        a_feas_min = [a_feas_min; -9*ones(n,1)]; % (m/s^2)
    elseif accelFlag == 2
        a_feas_min = random(pd,2*n,1); % (m/s^2)
    end
elseif accelFlag == 0
    a_feas_min = -9*ones(2*n,1); % (m/s^2)
end

%% set maximum crossing acceleration
if accelAheadFlag > 0
    pd = makedist('Uniform','upper',1.2,'lower',1.8); % maximum crossing accel with mean 1.5 m/s^2
    if accelAheadFlag == 1
        a_ahead = random(pd,n,1); % (m/s^2)
        a_ahead = [a_ahead; 1.5*ones(n,1)]; % (m/s^2)
    elseif accelAheadFlag == 2
        a_ahead = random(pd,2*n,1); % (m/s^2)
    end
elseif accelAheadFlag == 0
    a_ahead = 1.5*ones(2*n,1); % (m/s^2)
end


%% set vehicle type parameters for run_simulation code

% PassiveVehicle = [3 -5 1.2];
% 
% timeGapDist(1) = PassiveVehicle(1);
% 
% a_feas_min(1)  = PassiveVehicle(2);
% 
% a_ahead(1)     = PassiveVehicle(3);

setappdata(0,'time_gap_dist',timeGapDist);

setappdata(0,'MinFeasibleDecel',a_feas_min);

setappdata(0,'MaxCrossAccel',a_ahead);

%%  road parameters and density correction
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

% correctedd density according to road length
density = nCars./road.Length;
% density(2) = 0;
% nCars(2) = 0;
%% junction or single road simulations
setappdata(0,'RoadOrJunctionFlag',singleArmFlag);
if singleArmFlag
    density(2) = 0;
    nCars(2) = 0;
end

%% if phased start, generate equilibrium velocities
if spawnType
    [k,q,v,~] = fundamentaldiagram();
%     stpSz = 10;
    vi = [0 0];
    if density(1) ~= 0
        v_temp = v(abs(k-density(1))<0.00005);
        vi(1) = v_temp(1);
%         [ki(1),vi(1)] = polyxpoly(k(2:stpSz:end-1),v(2:stpSz:end-1),density(1)*ones(1,numel(v(2:stpSz:end-1))),v(2:stpSz:end-1));
    end
    if density(2) ~= 0
        v_temp = v(abs(k-density(2))<0.00005);
        vi(2) = v_temp(1);
%         [ki(2),vi(2)] = polyxpoly(k(2:stpSz:end-1),v(2:stpSz:end-1),density(2)*ones(1,numel(v(2:stpSz:end-1))),v(2:stpSz:end-1));
    end
    setappdata(0,'v_euil',vi);
end


%% wait bar plotting 
iIteration = 0;
if plotFlag == 0 || t_off > 0
    f = waitbar(0,'','Name','Running simulation',...
        'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
    setappdata(f,'canceling',0);
    waitbar(0,f,sprintf('%d percent out of %d iterations',round(iIteration*100/nIterations),nIterations))
end

%% single simulation flag 
setappdata(0,'simType',0);

%% penetration rations of vehicles 
carTypeRatios = [0 0 1 0 0 0; 0 0 1 0 0 0];
% carTypeRatios = [0 0 0 1 0 0; 0 0 0 1 0 0];
% carTypeRatios = [0 0 0 1 0 0; 1 0 0 0 0 0];


%% convert penetration ratio into number of cars of each type
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

%% generate car objects array for each arm
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

%% control random process
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

%% save the simulation results
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

