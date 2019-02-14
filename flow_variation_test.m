clear
close all
clc

roadTypes = {@LoopRoad @FiniteRoad};
carTypes = {@carTypeA, @carTypeB, @carTypeC};

plotFlag = false;
runTime = 7200;
dt = 0.1;
nIterations = (runTime/dt)+1;
nDigits = numel(num2str(dt))-2;
t_rng = 0:dt:runTime;
fixedSeed = [1 1];
ringType = rng(fixedSeed(1));
%ringType = rng('shuffle','combRecursive');
priority = false;

% road dimensions
road.Start = [-500; -500];
road.End = [500; 500];
road.Width = [4; 4];
road.Length = road.End - road.Start;

noSpawnAreaLength = 24.4; % length of no spawn area around the junction + length of a car for safe re-spawn
max_density = 1/6.4;    % number of cars per metre (0.1562)

%%
% density = 0.03;
% nCars = round(density * road.Length);
% RealDensity = nCars/road.Length;
k = 0;


%% avoiding overhead
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


spmd
end

for i = 1:50
    init_density(i) = 0.03;
    init_nCars1(i) = round(init_density(i) * roadLength1);
    init_nCars2(i) = round(init_density(i) * roadLength2);
    init_RealDensity1(i) = init_nCars1(i)/roadLength1;
    init_RealDensity2(i) = init_nCars1(i)/roadLength2;
        
    
    density = init_density(i);
    nCars1 = init_nCars1(i);
    nCars2 = init_nCars2(i);
    
    alpha = 50;
    beta  = 50;
    gamma =  0;
    
    carTypeRatios = [alpha/100 beta/100 gamma/100; alpha/100 beta/100 gamma/100];
    
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
    
    
    Arm.H(i) = SpawnCars([{allCarsNumArray_H},fixedSeed1,{carTypes}],'horizontal',roadStart1,roadEnd1,roadWidth1,dt,nIterations);
    Arm.V(i) = SpawnCars([{allCarsNumArray_V},fixedSeed2,{carTypes}],'vertical',roadStart2,roadEnd2,roadWidth2,dt,nIterations);
    
end

parfor i = 1:50
    
    ArmH = Arm.H(i);
    ArmV = Arm.V(i);
    
    sim = run_simulation({roadTypes1,roadTypes1},carTypes,ArmH,ArmV,t_rng,plotFlag,priority,road,nIterations,dt);
    
    parsave(carTypeRatios,carTypes,[nCars1,nCars2],allCarsNumArray_H,allCarsNumArray_V,runTime,...
            dt,t_rng,plotFlag,priority,density,road,nIterations,sim,alpha,beta,gamma,i);
end
delete(gcp);



%%

function parsave(carTypeRatios,carTypes,nCars,allCarsNumArray_H,allCarsNumArray_V,runTime,...
    dt,t_rng,plotFlag,priority,density,road,nIterations,sim,alpha,beta,gamma,i)

save(['/Users/robot/Desktop/test-sim-37/test-' num2str(i) '.mat'],...
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
