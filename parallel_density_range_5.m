clear
close all
clc


load('E-A-N-A.mat')

%% avoiding overhead
 
fixedSeed1 = 1;
fixedSeed2 = 1;

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


% swapRate = str2double(getenv('swapRate'));
transientCutOffLength = 50;
swapRate = 0;
gcp('nocreate');
% create a local cluster object
pc = parcluster('local');

% explicitly set the JobStorageLocation to the temp directory that was created in your bash script
% tmpdir = strcat(tempname('/newhome/ks14203/matlab_temp_dir/'),'/', getenv('PBS_JOBID'));
% mkdir(tmpdir)
% pc.JobStorageLocation = tmpdir;

% numCores = 2;
% parpool(pc,numCores);
plotFlag = 1;
for i = 1:1
%     i = k(ii);
    init_density = 0.02+(i-1)*0.004;
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
    
    sim = run_simulation_1({roadTypes1,roadTypes1},carTypes,ArmH,ArmV,t_rng,plotFlag,priority,road,nIterations,transientCutOffLength,swapRate,dt);
    
    parsave(carTypeRatios,carTypes,[nCars1,nCars2],allCarsNumArray_H,allCarsNumArray_V,runTime,...
        dt,t_rng,plotFlag,priority,density,road,nIterations,sim,alpha,beta,gamma,transientCutOffLength,swapRate,i,fixedSeed1);

end
delete(gcp);

% rmdir(tmpdir, 's');

%%

function parsave(carTypeRatios,carTypes,nCars,allCarsNumArray_H,allCarsNumArray_V,runTime,...
    dt,t_rng,plotFlag,priority,density,road,nIterations,sim,alpha,beta,gamma,transientCutOffLength,swapRate,i,fixedSeed1)

k = round(swapRate*100);
% dir_swap = sprintf('%s-percent',num2str(k));
fnm = sprintf('test-%s.mat',num2str(i));
dir_swap = sprintf('seed-%s',num2str(fixedSeed1));

save(fullfile(dir_swap,fnm),...
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
    'transientCutOffLength',...
    'swapRate',...
    '-v7.3')

fnm1 = sprintf('CrossOrders-%s.mat',num2str(i));
crossOrder = sim.crossOrder;
save(fullfile(dir_swap,fnm1),'crossOrder','nCars');
end

