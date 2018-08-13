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
            if isa(SpawnData,'table')
                obj.controlled_spawn(SpawnData,dt)
            else
                everyCarNum = SpawnData{1};
                obj.numCars = sum(everyCarNum);
                FixedSeed = SpawnData{2};
                carTypes = SpawnData{3};
                obj.randomSpawn(everyCarNum,carTypes,FixedSeed,dt)
                obj.nIterations = nIterations;
            end
        end
        
        function controlled_spawn(obj,SpawnData,dt)
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
        function randomSpawn(obj,everyCarNum,carTypes,FixedSeed,dt)
            %%
            minimumSpacing = IdmCar.minimumGap;
            if obj.numCars ~= 0
                allCarsPoseArray = NaN(obj.numCars,1);
                for iCar = 1:obj.numCars
                    if iCar == 1
                        allCarsPoseArray(iCar) = obj.roadStart;
                    else
                        allCarsPoseArray(iCar) = allCarsPoseArray(iCar-1) + minimumSpacing;
                    end
                end
                unoccupiedSpace =  obj.roadEnd - allCarsPoseArray(end) - 24.4;
                if FixedSeed
                    rng(1);
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
                    if allCarsPoseArray(iCar) > -10 && allCarsPoseArray(iCar) < 10
                        diff = 10 - allCarsPoseArray(iCar);
                        allCarsPoseArray(iCar:end) = allCarsPoseArray(iCar:end)+diff;
                    end
                end
                allCarsArray = [];
                for i = 1:numel(everyCarNum)
                    if everyCarNum(i) > 0
                        for j = 1:everyCarNum(i)
                             new_car = carTypes{i}(obj.roadOrientation, obj.roadStart,obj.roadWidth,dt);
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
    end
end

