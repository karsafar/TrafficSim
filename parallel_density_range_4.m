% clear
% close all
% clc


load('prescribe_range_density.mat')
% load('/newhome/ks14203/Scenarios/scenario-10/E-A-N-A.mat')

%% avoiding overhead

% fixedSeed1 = str2double(getenv('seedNum'));
% fixedSeed2 = str2double(getenv('seedNum'));
fixedSeed1 = 1;
fixedSeed2 = 1;

roadTypes1 = roadTypes{1};
roadTypes2 = roadTypes{2};

nCars1 = nCars(1);
nCars2 = nCars(2);
roadWidth1 = road.Width(1);
roadWidth2 = road.Width(2);


rLength1 = round(nCars(1)./density(1,:));  
half_length = rLength1/2;
rStart1 = [-half_length];
rEnd1 = [half_length];

rLength2 = round(nCars(1)./density(1,:));  
half_length = rLength2/2;
rStart2 = [-half_length];
rEnd2 = [half_length];



% swapRate = str2double(getenv('swapRate'));
swapRate = 0;

transientCutOffLength = 0;

gcp('nocreate');
% create a local cluster object
pc = parcluster('local');

% explicitly set the JobStorageLocation to the temp directory that was created in your bash script
% tmpdir = strcat(tempname('/newhome/ks14203/matlab_temp_dir/'),'/', getenv('PBS_JOBID'));
% mkdir(tmpdir)
% pc.JobStorageLocation = tmpdir;

numCores = 4;
parpool(pc,numCores);
nIter = length(density);
parfor i = 1:nIter
    
    roadLength1 = rLength1(i);  
    roadStart1 = rStart1(i);
    roadEnd1 = rEnd1(i);
    
    roadLength2 = rLength2(i);  
    roadStart2 = rStart2(i);
    roadEnd2 = rEnd2(i);
       
    road = struct();
    road.Start = [rStart1(i); rStart2(i)];
    road.End = [rEnd1(i); rEnd2(i)];
    road.Length = [rLength1(i); rLength2(i)];
    road.Width = [roadWidth1; roadWidth2];
    
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
    
    sim = run_simulation({roadTypes1,roadTypes1},carTypes,ArmH,ArmV,t_rng,plotFlag,priority,road,nIterations,transientCutOffLength,swapRate,dt);
    
    parsave(carTypeRatios,carTypes,[nCars1,nCars2],allCarsNumArray_H,allCarsNumArray_V,runTime,...
        dt,t_rng,plotFlag,priority,density,road,nIterations,sim,alpha,beta,gamma,transientCutOffLength,swapRate,i,fixedSeed1);

end
delete(gcp);

rmdir(tmpdir, 's');

%%

function parsave(carTypeRatios,carTypes,nCars,allCarsNumArray_H,allCarsNumArray_V,runTime,...
    dt,t_rng,plotFlag,priority,density,road,nIterations,sim,alpha,beta,gamma,transientCutOffLength,swapRate,i,fixedSeed1)

k = round(swapRate*100);
% dir_swap = sprintf('%s-percent',num2str(k));
fnm = sprintf('test-%s.mat',num2str(i));
dir_swap = sprintf('seed-%s',num2str(fixedSeed1));

% save(fullfile('/newhome/ks14203/Scenarios/scenario-30/phased/dt-0.1/a-1/',dir_swap,fnm),...
save(fullfile(fnm),...
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
% 
% fnm1 = sprintf('CrossOrders-%s.mat',num2str(i));
% crossOrder = sim.crossOrder;
% save(fullfile('/newhome/ks14203/Scenarios/scenario-30/dt-0.1/a-0.2/',dir_swap,fnm1),'crossOrder','nCars');
end

