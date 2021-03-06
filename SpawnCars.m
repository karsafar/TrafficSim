classdef SpawnCars < handle
    properties
        allCars
        numCars
        roadOrientation
        roadStart
        roadEnd
        roadWidth
        nIterations
    end
    
    methods
        function obj = SpawnCars(SpawnData,orientation, startPoint,endPoint, Width,dt,nIterations)
            obj.roadOrientation = orientation;
            obj.roadStart = startPoint;
            obj.roadEnd = endPoint;
            obj.roadWidth = Width;
            obj.nIterations = nIterations;
            if isa(SpawnData,'table')
                obj.manual_spawn(SpawnData,dt)
            else
                everyCarNum = SpawnData{1};
                obj.numCars = sum(everyCarNum);
                FixedSeed = SpawnData{2};
                carTypes = SpawnData{3};
                
                spaceTolerance = 0.01;% start and end of the junction with added tolerance to avoid collision
                s_in = -obj.roadWidth/2-(Car.dimension(3)+(Car.dimension(2) - Car.dimension(3))/2)-spaceTolerance;
                s_out = obj.roadWidth/2+(Car.dimension(2) - Car.dimension(3))/2+spaceTolerance;
                
                spawnType = getappdata(0,'spawnType');
                if spawnType == 0
                    obj.randomSpawn(everyCarNum,carTypes,FixedSeed,dt,s_in,s_out)
                else
                    v_equil = getappdata(0,'v_euil');
                    if strcmpi(orientation,'horizontal')
                        obj.controlled_spacing_spawn(everyCarNum,carTypes,FixedSeed,dt,s_in,s_out,v_equil(1))
                    else
                        obj.controlled_spacing_spawn(everyCarNum,carTypes,FixedSeed,dt,s_in,s_out,v_equil(2))
                    end
                end
            end
        end
        
        function manual_spawn(obj,SpawnData,dt)
            %%
            SpawnData = sortrows(SpawnData,{'position'},{'descend'});
            obj.numCars = numel(SpawnData(:,1));
            carTypes = SpawnData{:,5};
            for iCar = 1:obj.numCars
                new_car = carTypes{iCar}(obj.roadOrientation, obj.roadStart,obj.roadWidth,dt);
                new_car.pose(1) = SpawnData{iCar,1};
                new_car.velocity = SpawnData{iCar,2};
                new_car.targetVelocity = SpawnData{iCar,3};
                new_car.acceleration = SpawnData{iCar,4};
                new_car.priority = SpawnData{iCar,6};
                new_car.maximumVelocity = SpawnData{iCar,7};
                UpdateRate = dt*randi(1,1);
                new_car.UpdateRate = UpdateRate;
                obj.allCars = [obj.allCars new_car];
                if iCar  > 1
                    insertAfter(obj.allCars(iCar),obj.allCars(iCar-1));
                    obj.allCars(iCar).leaderFlag = false;
                end
            end
            leaderCar = obj.allCars(1);
            if obj.numCars > 1
                leaderCar.Prev = obj.allCars(iCar);
                obj.allCars(iCar).Next = leaderCar;
            end
        end
        function randomSpawn(obj,everyCarNum,carTypes,FixedSeed,dt,s_in,s_out)
            %%
            minimumSpacing = IdmModel.minimumGap+Car.dimension(2);
            if obj.numCars ~= 0
                allCarsPoseArray = NaN(obj.numCars,1);
                for iCar = 1:obj.numCars
                    if iCar == 1
                        allCarsPoseArray(iCar) = obj.roadStart;
                    else
                        allCarsPoseArray(iCar) = allCarsPoseArray(iCar-1) + minimumSpacing;
                    end
                end
                unoccupiedSpace =  obj.roadEnd - allCarsPoseArray(end) - (obj.roadWidth+Car.dimension(2));
                if FixedSeed > 0
                    rng(FixedSeed);
                end
                initPoseProbDist = makedist('uniform','lower',0,'upper',unoccupiedSpace);
                addonPositions = NaN(1,obj.numCars);
                for iCar = 1:obj.numCars
                    addonPositions(iCar) = random(initPoseProbDist);
                end
                addonPositions = sort(addonPositions);
                deltaD = NaN(1,obj.numCars);
                for iCar = 1:obj.numCars
                    if iCar == 1
                        deltaD(iCar) = addonPositions(iCar);
                    elseif iCar == obj.numCars
                        deltaD(iCar) = unoccupiedSpace - addonPositions(iCar);
                    else
                        deltaD(iCar) = addonPositions(iCar) - addonPositions(iCar-1);
                    end
                end
                
                for iCar = 1:obj.numCars
                    allCarsPoseArray(iCar:end) = allCarsPoseArray(iCar:end)+deltaD(iCar);
                end    
                
%                 passedJunc = allCarsPoseArray(allCarsPoseArray > s_in);
                idx = find(allCarsPoseArray > s_in);
                if ~isempty(idx) && allCarsPoseArray(idx(1)) < s_out
                    allCarsPoseArray(idx(1):end) = allCarsPoseArray(idx(1):end) + (s_out-allCarsPoseArray(idx(1)));
                end
                
                allCarsArray = [];
                for i = 1:numel(everyCarNum)
                    if everyCarNum(i) > 0
                        for j = 1:everyCarNum(i)
                             new_car = carTypes{i}(obj.roadOrientation, obj.roadStart,obj.roadWidth,dt);
                             UpdateRate = dt*randi(1,1);
                             new_car.UpdateRate = UpdateRate;
                             new_car.velocity = 5 + (10-5).*rand(1,1);
                             allCarsArray = [allCarsArray new_car];
                        end
                    end
                end                    
                    
                obj.allCars = allCarsArray(randperm(length(allCarsArray)));      
                allCarsPoseArray = flip(allCarsPoseArray);
                for iCar = 1:obj.numCars
                    obj.allCars(iCar).pose(1) = allCarsPoseArray(iCar);
                    if iCar > 1
                        insertAfter(obj.allCars(iCar),obj.allCars(iCar-1));
                        obj.allCars(iCar).leaderFlag = false;
                    end
                end
                leaderCar = obj.allCars(1);
                if obj.numCars > 1
                    leaderCar.Prev = obj.allCars(iCar);
                    obj.allCars(iCar).Next = leaderCar;
                end
            end
        end
        function controlled_spacing_spawn(obj,everyCarNum,carTypes,~,dt,s_in,s_out,v_equil)
            %%
            
            if obj.numCars ~= 0
                allCarsPoseArray = NaN(obj.numCars,1);
                for iCar = 1:obj.numCars
                    if iCar == 1
                        allCarsPoseArray(iCar) = obj.roadStart;
                    else
                        allCarsPoseArray(iCar) = allCarsPoseArray(iCar-1) + (obj.roadEnd-obj.roadStart)/obj.numCars;
                    end
                end
                if strcmpi(obj.roadOrientation,'vertical')
%                     allCarsPoseArray = allCarsPoseArray + (obj.roadEnd-obj.roadStart)/(obj.numCars) + s_in;
                    allCarsPoseArray = allCarsPoseArray + (obj.roadEnd-obj.roadStart)/(obj.numCars)/2+ s_out;
                else
%                     allCarsPoseArray = allCarsPoseArray + s_out;
%                     temp = diff(allCarsPoseArray);
                    allCarsPoseArray = allCarsPoseArray + s_out ;
                end
                
                allCarsArray = [];
                for i = 1:numel(everyCarNum)
                    if everyCarNum(i) > 0
                        for j = 1:everyCarNum(i)
                            new_car = carTypes{i}(obj.roadOrientation, obj.roadStart,obj.roadWidth,dt);
                            UpdateRate = dt*randi(1,1);
                            new_car.UpdateRate = UpdateRate;
                            allCarsArray = [allCarsArray; new_car];
                            allCarsArray(end).velocity = v_equil;
                        end
                    end
                end                    
                    
                obj.allCars = allCarsArray(randperm(length(allCarsArray)));      
                allCarsPoseArray = flip(allCarsPoseArray);
                for iCar = 1:obj.numCars
                    obj.allCars(iCar).pose(1) = allCarsPoseArray(iCar);
                    if iCar > 1
                        insertAfter(obj.allCars(iCar),obj.allCars(iCar-1));
                        obj.allCars(iCar).leaderFlag = false;
                    end
                end
                leaderCar = obj.allCars(1);
                if obj.numCars > 1
                    leaderCar.Prev = obj.allCars(iCar);
                    obj.allCars(iCar).Next = leaderCar;
                end
            end
        end
    end
end

