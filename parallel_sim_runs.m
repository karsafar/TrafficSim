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
fixedSeed = [0 0];
priority = false;

% road dimensions
road.Start = [-600; -600];
road.End = [600; 600];
road.Width = [4; 4];
road.Length = road.End - road.Start;

noSpawnAreaLength = 24.4; % length of no spawn area around the junction + length of a car for safe re-spawn
max_density = 1/6.4;    % number of cars per metre (0.1562)

%%
density = 0.03;
nCars = round(density * road.Length);
RealDensity = nCars/road.Length;


%% avoiding overhead
nCars1 = nCars(1);
nCars2 = nCars(2);

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

%% get the ma
k = 0;
temp = [];
for alpha = 100:-10:0
    idx = round(alpha/10)+1;
    for i = 1:(12-idx)
        beta = (i-1)*10;
        gamma = 100-alpha-beta;
        k = k+1;
        temp = [temp ;alpha, beta, gamma, k];
    end
end

for alpha = 100:-10:0
    idx = round(alpha/10)+1;
    parfor i = 1:(12-idx)
        beta = (i-1)*10;
        gamma = 100-alpha-beta;
        
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
        
        ArmH = SpawnCars([{allCarsNumArray_H},fixedSeed1,{carTypes}],'horizontal',roadStart1,roadEnd1,roadWidth1,dt,nIterations);
        ArmV = SpawnCars([{allCarsNumArray_V},fixedSeed2,{carTypes}],'vertical',roadStart2,roadEnd2,roadWidth2,dt,nIterations);
        
        sim = run_simulation({roadTypes1,roadTypes1},carTypes,ArmH,ArmV,t_rng,plotFlag,priority,road,nIterations,dt);
        
        parsave(carTypeRatios,carTypes,nCars,allCarsNumArray_H,allCarsNumArray_V,runTime,dt,t_rng,plotFlag,priority,density,road,nIterations,sim,alpha,beta,gamma,temp);
    end
end

function parsave(carTypeRatios,carTypes,nCars,allCarsNumArray_H,allCarsNumArray_V,runTime,dt,t_rng,plotFlag,priority,density,road,nIterations,sim,alpha,beta,gamma,temp)

[lia, loc] = ismember([alpha,beta,gamma],temp(:,1:3),'rows');
save(['/Users/robot/.CMVolumes/Karam Safarov/PhD/bulk simulations/test-sim-18/test-' num2str(loc) '.mat'],...
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