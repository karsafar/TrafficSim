function [Arm] = decide_input(carTypes,roadDims,dt)
title = 'Select road type';
prompt = {'Horizontal arm','Veritcal arm'};
dims = [1 50; 1 50;];
definput = {'1', '1'};
answer = inputdlg(prompt,title,dims,definput);
selectRoadTypes = [str2num(answer{1}); str2num(answer{2})];


title = 'Select sim input type';
prompt = {'Horizontal arm ','Vertical arm'};
dims = [1 50; 1 50;];
definput = {'1 - manual, 0 - prescribed density', '1 - manual, 0 - prescribed density'};
answer = inputdlg(prompt,title,dims,definput);
manualFlag = [str2num(answer{1}); str2num(answer{2})];



for i = 1:2
    if selectRoadTypes(i) == 1
        if manualFlag(i)
            if i == 1
                msg = ('Horizontal arm input');
            else
                msg = ('Vertical arm input');
            end
            title = msg;
            prompt = {'Number of vehicles','Positions','Velocites','Accelerations',' Control types'};
            dims = [1 50; 1 50; 1 50; 1 50; 1 50];
            definput = {'2', '20 -20', '5 7', '1 1','3 3'};
            answer = inputdlg(prompt,title,dims,definput);
            
            sz = [str2num(answer{1}) 4];
            varTypes = {'double','double','double','function_handle'};
            varNames = {'position','velocity','acceleration','carType'};
            
            T = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
            T.position = [str2num(answer{2})'];
            T.velocity = [str2num(answer{3})'];
            T.acceleration = [str2num(answer{4})'];
            T.carType = {carTypes{str2num(answer{5})'}}';
            
            if i == 1
                Arm.H = SpawnCars(T,'horizontal',roadDims.Start(1),roadDims.End(1),roadDims.Width(1),dt);
            else
                Arm.V = SpawnCars(T,'vertical',roadDims.Start(2),roadDims.End(2),roadDims.Width(2),dt);
            end
        else
            noSpawnAreaLength = 24.4;   % length of no spawn area around the junction + length of a car for safe respawn
            max_density = 1/6.4;        % number of cars per metre (0.1562)
            
            assert(all(densityRange(:,2) <= max_density),'wrong max limit of densities. Have to be 0.1562 max');
            assert(all(densityRange(:,1) >= 0),'wrong min limit of densities. have to be positive');
            
            init_density = [];
            init_density = sum(densityRange(i,:))-logspace(log10(densityRange(i,1)),log10(densityRange(i,2)),numberOfSimRuns);
            
            numCars = [];
            [numCars, idx]= unique(round(init_density(:) * (roadDims.Length(1) - noSpawnAreaLength)),'first');
            
            numCars = flip(numCars);
            
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
            if i == 1
                Arm.H = SpawnCars([{allCarsNumArray(k,:)},fixedSeed(1),{carTypes}],'horizontal',roadDims.Start(1),roadDims.End(1),roadDims.Width(1),dt);
            elseif i == 2
                Arm.V = SpawnCars([{allCarsNumArray(k,:)},fixedSeed(2),{carTypes}],'vertical',roadDims.Start(2),roadDims.End(2),roadDims.Width(2),dt);
            end
        end
    elseif selectRoadTypes(i) == 0
        %% need to fix this before running the code
        
%         distributionMean = logspace(log10(distMeanRange(i,1)),log10(distMeanRange(i,2)),numberOfSimRuns);
%         
%         for k = 1:numberOfSimRuns
%             if i == 1
%                 subRoadArgs(k).Horizontal = [{carTypeRatios(1,:)},distributionMean(k),fixedSeed(1)];
%             elseif i == 2
%                 subRoadArgs(k).Vertical = [{carTypeRatios(2,:)},distributionMean(k),fixedSeed(2)];
%             end
%         end
    end
end
end

