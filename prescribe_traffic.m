function [subRoadArgs,numberOfSimRuns] = prescribe_traffic(selectRoadTypes,numberOfSimRuns,carTypes,carTypeRatios,fixedSeed,roadDims,densityRange,distMeanRange,dt,nIterations)

%%
for i = 1:numel(selectRoadTypes)
    if selectRoadTypes(i) == 1
        %%
        noSpawnAreaLength = 24.4;   % length of no spawn area around the junction + length of a car for safe respawn
        max_density = 1/6.4;        % number of cars per metre (0.1562)
        
        assert(all(densityRange(:,2) <= max_density),'wrong max limit of densities. Have to be 0.1562 max');
        assert(all(densityRange(:,1) >= 0),'wrong min limit of densities. have to be positive');
        
        init_density = [];
        init_density = sum(densityRange(i,:))-logspace(log10(densityRange(i,1)),log10(densityRange(i,2)),numberOfSimRuns);
        
        numCars = [];
        [numCars, idx]= unique(round(init_density(:) * (roadDims.Length(1) - noSpawnAreaLength)),'first');
        
        numCars = flip(numCars);
        if all(numCars) == 0 && numberOfSimRuns > 0
            numberOfSimRuns = numberOfSimRuns;
            allCarsNumArray = zeros(numberOfSimRuns,numel(carTypes));
        else
            numberOfSimRuns = min(numberOfSimRuns,numel(numCars));
            
            density = numCars/roadDims.Length(1);
            fprintf('Real density values for the arm %i :\n',i);
            fprintf('%.3g\n',density);
            allCarsNumArray = zeros(numberOfSimRuns,numel(carTypes));
            for k = 1:numberOfSimRuns
                for j = 1:numel(carTypes)
                    if j == numel(carTypes)
                        allCarsNumArray(k,j) = numCars(k) - sum(allCarsNumArray(k,1:j-1));
                    else
                        allCarsNumArray(k,j) = round(numCars(k)*carTypeRatios(i,j));
                    end
                end
            end
        end
        for k = 1:numberOfSimRuns
            if i == 1
                subRoadArgs(k).H = SpawnCars([{allCarsNumArray(k,:)},fixedSeed(1),{carTypes}],'horizontal',roadDims.Start(1),roadDims.End(1),roadDims.Width(1),dt,nIterations);
            elseif i == 2
                subRoadArgs(k).V = SpawnCars([{allCarsNumArray(k,:)},fixedSeed(2),{carTypes}],'vertical',roadDims.Start(2),roadDims.End(2),roadDims.Width(2),dt,nIterations);
            end
        end
    elseif selectRoadTypes(i) == 2
        
        distributionMean = logspace(log10(distMeanRange(i,1)),log10(distMeanRange(i,2)),numberOfSimRuns);
        
        for k = 1:numberOfSimRuns
            if i == 1
                subRoadAorgs(k).H = [{carTypeRatios(1,:)},distributionMean(k),fixedSeed(1),dt,nIterations];
            elseif i == 2
                subRoadArgs(k).V = [{carTypeRatios(2,:)},distributionMean(k),fixedSeed(2),dt,nIterations];
            end
        end
    end
end
end

