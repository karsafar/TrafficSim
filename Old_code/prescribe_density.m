close all
clear

prescription = 'density';
carTypes = {@Car, @IdmCar, @BtCar};
carTypeRatios = [0 0 1;
                 0 0 1];             
plotFlag = true;
runTime = 3600; % in seconds
timeStep = 0.1; % in seconds
priority = true;
roadDimensions = [-200 100 4];
InitNumberOfSimRuns = 25;
noSpawnAreaLength = 20; % length of no spawn area around the junction 

init_density.horizontal = 0.05-logspace(log10(0.001),log10(0.035),InitNumberOfSimRuns);
init_density.vertical = 0.05-logspace(log10(0.001),log10(0.035),InitNumberOfSimRuns);

[numCars.horizontal(:), idx]= unique(round(init_density.horizontal(:) * (roadDimensions(2) - roadDimensions(1) - noSpawnAreaLength)),'first');
[numCars.vertical(:), idx1] = unique(round(init_density.vertical(:) * (roadDimensions(2) - roadDimensions(1) - noSpawnAreaLength)),'first');

numCars.horizontal = flip(numCars.horizontal);
numCars.vertical = flip(numCars.vertical);
% numCars.vertical = numCars.vertical*ones(1,numel(numCars.horizontal));

numberOfSimRuns = numel(numCars.horizontal);
density.horizontal = numCars.horizontal/(roadDimensions(2) - roadDimensions(1));
density.vertical = numCars.vertical/(roadDimensions(2) - roadDimensions(1));

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

for k = 1:numberOfSimRuns
    sim(k) = run_simulation(...
        carTypes,...
        [allCarsNumArray(k).horizontal; allCarsNumArray(k).vertical],...
        runTime,...
        plotFlag,...
        priority,...
        roadDimensions,...
        [numCars.horizontal(k); numCars.vertical(k)],...
        timeStep);
end

save('/Users/robot/car_sim_mat_Files/density_02_05_1_1.mat','prescription','carTypeRatios','carTypes','allCarsNumArray',...
    'runTime','timeStep','plotFlag','density','priority','roadDimensions','k','sim','-v7.3')

% save real_data
% p = profile('info');
% save myprofiledata5 p

% clear p
% load myprofiledata
% profview(0,p)