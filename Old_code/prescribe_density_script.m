close all
clear
%% INPUT PARAMETERS
% prescription = 'density'; % remove this and use class check in the plotting function

roadTypes = {@LoopRoad @FiniteRoad};
carTypes = {@IdmCar, @HdmCar, @AggressiveCar, @PassiveCar, @HesitantCar, @ManualCar};
carTypeRatios = [0 0 1 0 0 0; 0 0 1 0 0 0];
% carTypeRatios = [0 0 0 0 0 1;0 0 0.25 0.15 0.15 0.45];
assert(sum(carTypeRatios(1,:)) == 1,'Wrong distribution of horizontal arm rations');
assert(sum(carTypeRatios(2,:)) == 1,'Wrong distribution of vertical arm rations');
plotFlag = true;
runTime = 3600; % in seconds
dt = 0.1;       % in seconds
priority = true;
repeatableDistribution = [true true];
% road dimensions
road.Start = [-150; -150];
road.End = [150; 150];
road.Width = [4; 4];
road.Length = road.End - road.Start;

InitNumberOfSimRuns = 30;
noSpawnAreaLength = 24.4; % length of no spawn area around the junction + length of a car for safe respawn
max_density = 1/6.4;    % number of cars per metre (0.1562)

densityRange = [0.00001, 0.04;
                0.00002, 0.04];
assert(all(densityRange(:,2) <= max_density),'wrong max limit of densities. Have to be 0.1562 max');
assert(all(densityRange(:,1) >= 0),'wrong min limit of densities. have to be positive');

%%            
init_density.horizontal = sum(densityRange(1,:))-logspace(log10(densityRange(1,1)),log10(densityRange(1,2)),InitNumberOfSimRuns);
init_density.vertical = sum(densityRange(2,:))-logspace(log10(densityRange(2,1)),log10(densityRange(2,2)),InitNumberOfSimRuns);

[numCars.horizontal(:), idx]= unique(round(init_density.horizontal(:) * (road.Length(1) - noSpawnAreaLength)),'first');
[numCars.vertical(:), idx1] = unique(round(init_density.vertical(:) * (road.Length(2) - noSpawnAreaLength)),'first');

numCars.horizontal = flip(numCars.horizontal);
numCars.vertical = flip(numCars.vertical);
numCars.vertical = numCars.vertical(1)*ones(1,numel(numCars.horizontal));

numberOfSimRuns = numel(numCars.horizontal);
density.horizontal = numCars.horizontal/road.Length(1);
density.vertical = numCars.vertical/road.Length(2);

for k = 1:numberOfSimRuns
    for i = 1:numel(carTypes)
        if i == numel(carTypes)
            allCarsNumArray(k).horizontal(i) = numCars.horizontal(k) - sum(allCarsNumArray(k).horizontal(1:i-1));
            allCarsNumArray(k).vertical(i) = numCars.vertical(k) - sum(allCarsNumArray(k).vertical(1:i-1));
        else
            allCarsNumArray(k).horizontal(i) = round(numCars.horizontal(k)*carTypeRatios(1,i));
            allCarsNumArray(k).vertical(i) = round(numCars.vertical(k)*carTypeRatios(2,i));
        end
    end
end

nIterations = runTime/dt;
nDigits = numel(num2str(dt))-2;
t_rng = round(linspace(0,runTime,nIterations),nDigits);
    
for k = 1:numberOfSimRuns
    subRoadArgs.Horizontal = [{allCarsNumArray(k).horizontal},numCars.horizontal(k),nIterations, repeatableDistribution(1)];
    subRoadArgs.Vertical = [{allCarsNumArray(k).vertical},numCars.vertical(k),nIterations,repeatableDistribution(2)];
    
    sim(k) = run_simulation({roadTypes{1},roadTypes{1}},carTypes,subRoadArgs,t_rng,plotFlag,priority,road,nIterations,dt);
    
end
% beep
save('/Users/robot/car_sim_mat_Files/density_20-06-18_Idm.mat','prescription','carTypeRatios','carTypes','numCars','allCarsNumArray',...
    'runTime','dt','t_rng','plotFlag','priority','density','road','numberOfSimRuns','nIterations','sim','-v7.3')
beep
% save real_data
% p = profile('info');
% save myprofiledata5 p

% clear p
% load myprofiledata
% profview(0,p)