clear
close all
clc

roadTypes = {@LoopRoad @FiniteRoad};
carTypes = {@carTypeA, @carTypeB, @carTypeC};

plotFlag = false;
runTime = 720;
dt = 0.1;
nIterations = (runTime/dt)+1;
nDigits = numel(num2str(dt))-2;
t_rng = 0:dt:runTime;

nSeeds = 50;
fixedSeed = [1:nSeeds;
             1:nSeeds];

priority = false;

% road dimensions
road.Start = [-200; -200];
road.End = [200; 200];
road.Width = [4; 4];
road.Length = road.End - road.Start;

noSpawnAreaLength = 24.4; % length of no spawn area around the junction + length of a car for safe re-spawn
max_density = 1/6.4;    % number of cars per metre (0.1562)

transientCutOffLength = 100;
swapRate = 0.1;
%%

init_density = 0.043;
nCars = round(init_density * road.Length);
density = nCars(1)/road.Length(1);

%%
for i = 1:50
    
%     rng(fixedSeed(1,i));
%     ringType(i) = rng;

    alpha = 50; beta  = 50; gamma =  0;
    
    carTypeRatios = [alpha/100 beta/100 gamma/100; alpha/100 beta/100 gamma/100];
    
    allCarsNumArray_H = zeros(1,numel(carTypes));
    allCarsNumArray_V = zeros(1,numel(carTypes));
%     for j = 1:numel(carTypes)
%         if j == numel(carTypes)
%             allCarsNumArray_H(j) = nCars(1) - sum(allCarsNumArray_H(1:j-1));
%             allCarsNumArray_V(j) = nCars(2) - sum(allCarsNumArray_V(1:j-1));
%         else
%             allCarsNumArray_H(j) = round(nCars(1)*carTypeRatios(1,j));
%             allCarsNumArray_V(j) = round(nCars(2)*carTypeRatios(2,j));
%         end
%     end
% 
%     Arm_H(i) = SpawnCars([{allCarsNumArray_H},fixedSeed(1,i),{carTypes}],'horizontal',road.Start(1),road.End(1),road.Width(1),dt,nIterations);
%     Arm_V(i) = SpawnCars([{allCarsNumArray_V},fixedSeed(2,i),{carTypes}],'vertical',road.Start(2),road.End(2),road.Width(2),dt,nIterations);
%     
end
Arm_H = [];
Arm_V = [];
%%

save('Initial_data_test_10min.mat',...
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
    'nSeeds',...
    'roadTypes',...
    'alpha',...
    'beta',...
    'gamma',...
    'transientCutOffLength',...
    'swapRate',...
    '-v7.3')
