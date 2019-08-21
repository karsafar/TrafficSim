clear
close all
clc

roadTypes = {@LoopRoad @FiniteRoad};
carTypes = {@carTypeA, @carTypeB, @carTypeC};

plotFlag = false;
runTime = 3600;
dt = 0.1;
nIterations = (runTime/dt)+1;
nDigits = numel(num2str(dt))-2;
t_rng = 0:dt:runTime;

nSeeds = 1;
fixedSeed = [1:nSeeds;
             1:nSeeds];

priority = false;


%
 density = [linspace(0.02,0.07,26), linspace(0.08,0.13, 6)];
% density = [linspace(0.02,0.048,5), linspace(0.049,0.065,17),linspace(0.072,0.144,10)];
% density = [linspace(0.02,0.044,7), linspace(0.046,0.07,13)];
% density = [linspace(0.02,0.06,21)];

n = 30;
nCars = [n; n];

road.Length = round(nCars./density);  % length is rounded so need to correct the value of density
half_length = road.Length/2;
road.Start = [-half_length(1,:); -half_length(2,:)];
road.End = [half_length(1,:); half_length(2,:)];
road.Width = [4; 4];

noSpawnAreaLength = road.Width(1)+Car.dimension(2); % length of no spawn area around the junction + length of a car for safe re-spawn
max_density = 1/6.4;    % number of cars per metre (0.1562)

maxDen = nCars./(6.4*nCars+noSpawnAreaLength);
errMess1 = sprintf('East road density has to be <= %.4f', maxDen(1));
errMess2 = sprintf('North road density has to be <= %.4f', maxDen(2));

density = nCars./road.Length;

%% 
transientCutOffLength = 0;
swapRate = 0;

%%
allCarsNumArray_H = zeros(32,numel(carTypes));
allCarsNumArray_V = zeros(32,numel(carTypes));
for i = 1:length(density)
    alpha = 50; beta  = 0; gamma =  0;
    
%     carTypeRatios = [alpha/100 beta/100 gamma/100; alpha/100 beta/100 gamma/100];
    carTypeRatios = [0 1 0; 0 1 0];


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

save('type_B_density_range.mat',...
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
    'fixedSeed',...
    'roadTypes',...
    'alpha',...
    'beta',...
    'gamma',...
    'transientCutOffLength',...
    'swapRate',...
    '-v7.3')
