clear
close all
clc

roadTypes = {@LoopRoad @FiniteRoad};
carTypes = {@carTypeA, @carTypeB, @carTypeC};

plotFlag = false;
runTime = 360;
dt = 0.1;
nIterations = (runTime/dt)+1;
nDigits = numel(num2str(dt))-2;
t_rng = 0:dt:runTime;

nSeeds = 1;
fixedSeed = [1:nSeeds;
             1:nSeeds];

priority = false;

% road dimensions
road.Start = [-250; -250];
road.End = [250; 250];
road.Width = [4; 4];
road.Length = road.End - road.Start;

noSpawnAreaLength = 24.4; % length of no spawn area around the junction + length of a car for safe re-spawn
max_density = 1/6.4;    % number of cars per metre (0.1562)

transientCutOffLength = 50;
swapRate = 0;
%%

% init_density = 0.01;
% nCars = round(init_density * road.Length);
% density = nCars(1)/road.Length(1);

%%
allCarsNumArray_H = zeros(32,numel(carTypes));
allCarsNumArray_V = zeros(32,numel(carTypes));
for i = 1:32
    init_density = 0.02+(i-1)*0.004;
    nCars(1) = round(init_density * road.Length(1));
    nCars(2) = round(init_density * road.Length(2));
    density = nCars(1)/road.Length(1);

    alpha = 50; beta  = 50; gamma =  0;
    
%     carTypeRatios = [alpha/100 beta/100 gamma/100; alpha/100 beta/100 gamma/100];
    carTypeRatios = [1 0 0; 1 0 0];


    for j = 1:numel(carTypes)
        if j == numel(carTypes)
            allCarsNumArray_H(i,j) = nCars(1) - sum(allCarsNumArray_H(i,1:j-1));
            allCarsNumArray_V(i,j) = nCars(2) - sum(allCarsNumArray_V(i,1:j-1));
        else
            allCarsNumArray_H(i,j) = round(nCars(1)*carTypeRatios(1,j));
            allCarsNumArray_V(i,j) = round(nCars(2)*carTypeRatios(2,j));
        end
    end

%     Arm_H(i) = SpawnCars([{allCarsNumArray_H},fixedSeed(1,1),{carTypes}],'horizontal',road.Start(1),road.End(1),road.Width(1),dt,nIterations);
%     Arm_V(i) = SpawnCars([{allCarsNumArray_V},fixedSeed(2,1),{carTypes}],'vertical',road.Start(2),road.End(2),road.Width(2),dt,nIterations);
%     
end

%%
Arm_H = [];
Arm_V = [];

save('E-A-N-A.mat',...
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
    'Arm_H',...
    'Arm_V',...
    'fixedSeed',...
    'roadTypes',...
    'alpha',...
    'beta',...
    'gamma',...
    'transientCutOffLength',...
    'swapRate',...
    '-v7.3')
