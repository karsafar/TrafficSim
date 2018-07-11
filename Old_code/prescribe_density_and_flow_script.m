close all
clear
prescription = 'density-flow';
roadTypes = {@LoopRoad @FiniteRoad};
carTypes = {@Car, @IdmCar, @BtCar};
plotFlag = false;
runTime = 360; % in seconds
dt = 0.1; % in seconds
priority = true;

% road dimensions
road.Start = [-200; -300];
road.End = [100; 200];
road.Width = [4; 4];
road.Length = road.End - road.Start;

%% density
carTypeRatios(1,:) = [0 0 1];
InitNumberOfSimRuns = 30;
noSpawnAreaLength = 20; % length of no spawn area around the junction

init_density.horizontal = 0.04-logspace(log10(0.001),log10(0.035),InitNumberOfSimRuns);

[numCars.horizontal(:), idx]= unique(round(init_density.horizontal(:) * (road.Length(1) - noSpawnAreaLength)),'first');

numCars.horizontal = flip(numCars.horizontal);

numberOfSimRuns = numel(numCars.horizontal);
density.horizontal = numCars.horizontal/road.Length(1);

for k = 1:numberOfSimRuns
    for i = 1:numel(carTypes)
        if i == numel(carTypes)
            allCarsNumArray(k).horizontal(i) = numCars.horizontal(k) - sum(allCarsNumArray(k).horizontal(1:i-1));
        else
            allCarsNumArray(k).horizontal(i) = round(numCars.horizontal(k)*carTypeRatios(1,i));
        end
    end
end

%% flow 
VertArmCarRatios = [0 1 0];
carTypeRatios(2,:) = zeros(1,3);
for i = 1:numel(carTypes)
    carTypeRatios(2,i) = sum(VertArmCarRatios(1:i)) - carTypeRatios(2,i); 
end
distributionMean.vertical = logspace(log10(3),log10(10),numberOfSimRuns);

%% 
nIterations = runTime/dt;
nDigits = numel(num2str(dt))-2;
t_rng = round(linspace(0,runTime,nIterations),nDigits);
    
for k = 1:numberOfSimRuns
    subRoadArgs.Horizontal = [{allCarsNumArray(k).horizontal},numCars.horizontal(k),nIterations];
    subRoadArgs.Vertical = [{carTypeRatios(2,:)},distributionMean.vertical(k),nIterations];
    
    sim(k) = run_simulation({roadTypes{1},roadTypes{2}},carTypes,subRoadArgs,t_rng,plotFlag,priority,road,nIterations,dt);
end

save('a/density_07_05_0_0.mat','prescription','carTypeRatios','carTypes','numCars','allCarsNumArray',...
    'runTime','dt','t_rng','plotFlag','priority','density','road','numberOfSimRuns','nIterations','sim','-v7.3')

% save real_data
% p = profile('info');
% save myprofiledata5 p

% clear p
% load myprofiledata
% profview(0,p)