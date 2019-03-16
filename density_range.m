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
fixedSeed = [1 1];
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

%%
% if plotFlag == 0
%     f = waitbar(0,'','Name','Running simulation',...
%         'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
%     
%     setappdata(f,'canceling',0);
%     waitbar(k/11,f,sprintf('%d out of %d simulations finished',k,11))
% end
for i = 1:19
    density = 0.01+k*(0.01*1/3);
    nCars = round(density * road.Length);
    RealDensity = nCars/road.Length;
    
    alpha = 50;
    beta  = 50;
    gamma =  0;
    
    carTypeRatios = [alpha/100 beta/100 gamma/100; alpha/100 beta/100 gamma/100];
    
    allCarsNumArray_H = zeros(1,numel(carTypes));
    allCarsNumArray_V = zeros(1,numel(carTypes));
    for j = 1:numel(carTypes)
        if j == numel(carTypes)
            allCarsNumArray_H(j) = nCars(1) - sum(allCarsNumArray_H(1:j-1));
            allCarsNumArray_V(j) = nCars(2) - sum(allCarsNumArray_V(1:j-1));
        else
            allCarsNumArray_H(j) = round(nCars(1)*carTypeRatios(1,j));
            allCarsNumArray_V(j) = round(nCars(2)*carTypeRatios(2,j));
        end
    end
    
    
    Arm.H = SpawnCars([{allCarsNumArray_H},fixedSeed(1),{carTypes}],'horizontal',road.Start(1),road.End(1),road.Width(1),dt,nIterations);
    Arm.V = SpawnCars([{allCarsNumArray_V},fixedSeed(2),{carTypes}],'vertical',road.Start(2),road.End(2),road.Width(2),dt,nIterations);
    
    
    sim = run_simulation({roadTypes{1},...
        roadTypes{1}},...
        carTypes,...
        Arm.H,...
        Arm.V,...
        t_rng,...
        plotFlag,...
        priority,...
        road,...
        nIterations,...
        dt);
    
    k = k + 1;
%     waitbar(k/11,f,sprintf('%d out of %d simulations finished',k,11))
    
    save(['/Users/robot/Desktop/density-range/swappings/test-' num2str(k) '.mat'],...
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
        'RealDensity',...
        'road',...
        'nIterations',...
        'sim',...
        'alpha',...
        'beta',...
        'gamma',...
        '-v7.3')
    
%     if getappdata(f,'canceling')
%         break;
%     end
end

if plotFlag == 0
    f = findall(0,'type','figure','tag','TMWWaitbar');
    delete(f)
end

