clear
close all
clc


load('/Users/robot/OneDrive - University of Bristol/PhD/bulk simulations/Scenarios/scenario 6 - density range/Initial_range_data_2h.mat')

%% avoiding overhead
% 
% fixedSeed = [1:nSeeds;
%              1:nSeeds];
 
fixedSeed1 = fixedSeed(1);
fixedSeed2 = fixedSeed(2);

roadTypes1 = roadTypes{1};
roadTypes2 = roadTypes{2};

roadStart1 = road.Start(1);
roadEnd1 = road.End(1);
roadWidth1 = road.Width(1);
roadLength1 = road.Length(1);

roadStart2 = road.Start(2);
roadEnd2 = road.End(2);
roadWidth2 = road.Width(2);
roadLength2 = road.Length(2);

% allCarsNumArray_H = zeros(1,numel(carTypes));
% allCarsNumArray_V = zeros(1,numel(carTypes));

p = parpool('local',4);
parfor i = 1:32
    init_density = 0.01+(i-1)*(0.01*1/3);
    nCars1 = round(init_density * roadLength1);
    nCars2 = round(init_density * roadLength2);
    density = nCars1/roadLength1;
    
    allCarsNumArray_H = zeros(1,numel(carTypes));
    allCarsNumArray_V = zeros(1,numel(carTypes));
    for j = 1:numel(carTypes)
        if j == numel(carTypes)
            allCarsNumArray_H(j) = nCars1 - sum(allCarsNumArray_H(1:j-1));
            allCarsNumArray_V(j) = nCars2 - sum(allCarsNumArray_V(1:j-1));
        else
            allCarsNumArray_H(j) = round(nCars1*carTypeRatios(1,j));
            allCarsNumArray_V(j) = round(nCars2*carTypeRatios(2,j));
        end
    end
    
    ArmH = SpawnCars([{allCarsNumArray_H},fixedSeed1,{carTypes}],'horizontal',roadStart1,roadEnd1,roadWidth1,dt,nIterations);
    ArmV = SpawnCars([{allCarsNumArray_V},fixedSeed2,{carTypes}],'vertical',roadStart2,roadEnd2,roadWidth2,dt,nIterations);
    
    ringType = rng('shuffle','combRecursive');
    
    sim = run_simulation({roadTypes1,roadTypes1},carTypes,ArmH,ArmV,t_rng,plotFlag,priority,road,nIterations,dt);
    
    parsave(carTypeRatios,carTypes,[nCars1,nCars2],allCarsNumArray_H,allCarsNumArray_V,runTime,...
        dt,t_rng,plotFlag,priority,density,road,nIterations,sim,alpha,beta,gamma,i);

end
delete(gcp);



%%

function parsave(carTypeRatios,carTypes,nCars,allCarsNumArray_H,allCarsNumArray_V,runTime,...
    dt,t_rng,plotFlag,priority,density,road,nIterations,sim,alpha,beta,gamma,i)

fnm = sprintf('test-%s.mat',num2str(i));

save(fullfile('/Users/robot/OneDrive - University of Bristol/PhD/bulk simulations/Scenarios/scenario 6 - density range/tests',fnm),...
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

fnm1 = sprintf('CrossOrders-%s.mat',num2str(i));
crossOrder = sim.crossOrder;
save(fullfile('/Users/robot/OneDrive - University of Bristol/PhD/bulk simulations/Scenarios/scenario 6 - density range/tests',fnm1),'crossOrder','nCars');
end


