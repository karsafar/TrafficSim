clear
close all
clc


load('Initial_data_test_10min.mat')

%% avoiding overhead
nCars1 = nCars(1);
nCars2 = nCars(2);

fixedSeed = [1:nSeeds;
             1:nSeeds];
 
fixedSeed1 = fixedSeed(1);
fixedSeed2 = fixedSeed(2);

roadTypes1 = roadTypes{1};
roadTypes2 = roadTypes{2};

roadStart1 = road.Start(1);
roadEnd1 = road.End(1);
roadWidth1 = road.Width(1);

roadStart2 = road.Start(2);
roadEnd2 = road.End(2);
roadWidth2 = road.Width(2);

allCarsNumArray_H = zeros(1,numel(carTypes));
allCarsNumArray_V = zeros(1,numel(carTypes));

% p = parpool('local',4);
plotFlag = 1;

for i = 1:1
    fixedSeed1 = fixedSeed(1,i);
    fixedSeed2 = fixedSeed(2,i);
    for k = 1:numel(carTypes)
        if k == numel(carTypes)
            allCarsNumArray_H(k) = nCars1 - sum(allCarsNumArray_H(1:k-1));
            allCarsNumArray_V(k) = nCars2 - sum(allCarsNumArray_V(1:k-1));
        else
            allCarsNumArray_H(k) = round(nCars1*carTypeRatios(1,k));
            allCarsNumArray_V(k) = round(nCars2*carTypeRatios(2,k));
        end
    end
    for j = 1:1
        
        ArmH = SpawnCars([{allCarsNumArray_H},fixedSeed1,{carTypes}],'horizontal',roadStart1,roadEnd1,roadWidth1,dt,nIterations);
        ArmV = SpawnCars([{allCarsNumArray_V},fixedSeed2,{carTypes}],'vertical',roadStart2,roadEnd2,roadWidth2,dt,nIterations);
        
        ringType = rng('shuffle','combRecursive');
        
        sim = run_simulation({roadTypes1,roadTypes1},carTypes,ArmH,ArmV,t_rng,plotFlag,priority,road,nIterations,transientCutOffLength,swapRate,dt);
        
        parsave(carTypeRatios,carTypes,[nCars1,nCars2],allCarsNumArray_H,allCarsNumArray_V,runTime,...
            dt,t_rng,plotFlag,priority,density,road,nIterations,sim,alpha,beta,gamma,j,i);
    end
end
% end
delete(gcp);



%%

function parsave(carTypeRatios,carTypes,nCars,allCarsNumArray_H,allCarsNumArray_V,runTime,...
    dt,t_rng,plotFlag,priority,density,road,nIterations,sim,alpha,beta,gamma,j,i)

dir_name = sprintf('seed-%s/20-percent/',num2str(i));
fnm = sprintf('test-%s.mat',num2str(j));

save(fullfile('/Users/robot/OneDrive - University of Bristol/PhD/bulk simulations/Scenarios/scenario 5 - long simulations/',dir_name,fnm),...
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
    'alpha',...
    'beta',...
    'gamma',...
    '-v7.3')

end
