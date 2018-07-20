function [subRoadArgs,numberOfSimRuns] = prescribe_traffic(selectRoadTypes,numberOfFlowValues,carTypes,carTypeRatios,fixedSeed,roadDims,densityRange,distMeanRange,dt,nIterations)

%%
for i = 1:numel(selectRoadTypes)
    if selectRoadTypes(i) == 1
        %%
        noSpawnAreaLength = 24.4;   % length of no spawn area around the junction + length of a car for safe respawn
        max_density = 1/6.4;        % number of cars per metre (0.1562)
        
%         init_density = [];
%         init_density = sum(densityRange(i,:))-logspace(log10(densityRange(i,1)),log10(densityRange(i,2)),numberOfSimRuns);
%         
        initNumCars = round(densityRange(i,1) * (roadDims.Length(1) - noSpawnAreaLength));
        endNumCars = round(densityRange(i,2) * (roadDims.Length(1) - noSpawnAreaLength));
        nCarsRange = initNumCars:1:endNumCars;
        RealDensityRange = nCarsRange/roadDims.Length(1);
       
        assert(all(RealDensityRange(end) <= max_density),'wrong max limit of densities. Have to be 0.1562 max');
        assert(all(RealDensityRange(1) >= 0),'wrong min limit of densities. have to be positive');
        
        if all(nCarsRange)  
            numberOfSimRuns(i) = 1;
            allCarsNumArray = zeros(1,numel(carTypes));
        else
            numberOfSimRuns(i) = numel(nCarsRange);
            
            fprintf('Real density values for the arm %i :\n',i);
            fprintf('[ ');
            fprintf('%.3g ',RealDensityRange);
            fprintf(']\n, ');
            
            allCarsNumArray = zeros(numberOfSimRuns(i),numel(carTypes));
            for k = 1:numberOfSimRuns(i)
                for j = 1:numel(carTypes)
                    if j == numel(carTypes)
                        allCarsNumArray(k,j) = nCarsRange(k) - sum(allCarsNumArray(k,1:j-1));
                    else
                        allCarsNumArray(k,j) = round(nCarsRange(k)*carTypeRatios(i,j));
                    end
                end
            end
        end
        for k = 1:numberOfSimRuns(i)
            if i == 1
                subRoadArgs(k).H = SpawnCars([{allCarsNumArray(k,:)},fixedSeed(1),{carTypes}],'horizontal',roadDims.Start(1),roadDims.End(1),roadDims.Width(1),dt,nIterations);
            elseif i == 2
                subRoadArgs(k).V = SpawnCars([{allCarsNumArray(k,:)},fixedSeed(2),{carTypes}],'vertical',roadDims.Start(2),roadDims.End(2),roadDims.Width(2),dt,nIterations);
            end
        end
    elseif selectRoadTypes(i) == 2
        numberOfSimRuns(i) = numberOfFlowValues;
        distributionMean = logspace(log10(distMeanRange(i,1)),log10(distMeanRange(i,2)),numberOfFlowValues);
        
        for k = 1:numberOfFlowValues
            if i == 1
                subRoadArgs(k).H = [{carTypeRatios(1,:)},distributionMean(k),fixedSeed(1),dt,nIterations];
            elseif i == 2
                subRoadArgs(k).V = [{carTypeRatios(2,:)},distributionMean(k),fixedSeed(2),dt,nIterations];
            end
        end
    end
end
end

