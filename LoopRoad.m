classdef LoopRoad < Road
    properties (SetAccess = protected)
        storeSwappedIndices = []
        diceDistGen = makedist('uniform','lower',0,'upper',1);
        %          initPoseProbDist = []
        %          allCarsNumArray = 0
    end
    
    methods
        function obj = LoopRoad(road_args,loop_road_args)
            obj = obj@Road(road_args);
            
            if numel(loop_road_args) == 1
                obj.numCars = loop_road_args.numCars;
                obj.allCars = loop_road_args.allCars;
                obj.averageVelocityHistory = NaN(loop_road_args.nIterations,1);
                obj.variance = NaN(loop_road_args.nIterations,1);
            else
                %% I don't need this part
                obj.allCarsNumArray = loop_road_args{1};
                obj.numCars = sum(obj.allCarsNumArray);
                obj.FixedSeed = loop_road_args{2};
                obj.spawn_initial_cars(loop_road_args{3});
            end
        end
        function spawn_initial_cars(obj,dt)
            %%
            minimumSpacing = IdmCar.minimumGap;
            if obj.numCars ~= 0
                allCarsPoseArray = NaN(obj.numCars,1);
                for iCar = 1:obj.numCars
                    if iCar == 1
                        allCarsPoseArray(iCar) = obj.startPoint;
                    else
                        allCarsPoseArray(iCar) = allCarsPoseArray(iCar-1) + minimumSpacing;
                    end
                end
                unoccupiedSpace =  obj.endPoint - allCarsPoseArray(end) - 24.4;
                if obj.FixedSeed
                    rng(1);
                end
                obj.initPoseProbDist = makedist('uniform','lower',0,'upper',unoccupiedSpace);
                addonPositions = NaN(1,obj.numCars);
                for iCar = 1:obj.numCars
                    addonPositions(iCar) = random(obj.initPoseProbDist);
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
                for i = 1:numel(obj.allCarsNumArray)
                    if obj.allCarsNumArray(i) > 0
                        for j = 1:obj.allCarsNumArray(i)
                            new_car = add_car(obj,i,dt);
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
        function controlled_spawn(obj,nCars,positions,velocities,accelerations,types,dt)
            %%
            obj.numCars = nCars;
            for iCar = 1:nCars
                new_car = add_car(obj,types(iCar),dt);
                new_car.pose(1) = positions(iCar);
                new_car.velocity = velocities(iCar);
                new_car.acceleration = accelerations(iCar);
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
        function respawn_car(obj,leaderCar,t)
            leaderCar.pose(1) = leaderCar.pose(1) - (obj.endPoint-obj.startPoint);
            
            if t >= 500
                obj.collect_car_history(leaderCar);
            end
            
            leaderCar.historyIndex = 1;
            leaderCar.locationHistory = leaderCar.locationHistory*NaN;
            leaderCar.velocityHistory = leaderCar.velocityHistory*NaN;
            leaderCar.accelerationHistory = leaderCar.accelerationHistory*NaN;
            leaderCar.timeHistory = leaderCar.timeHistory*NaN;
            
            if obj.numCars > 1
                leaderCar.leaderFlag = false;
                leaderCar.Next.leaderFlag = true;
            end
        end
        function move_all_cars(obj,t,dt,iIteration,nIterations)
            aggregatedVelocities = 0;
           
            % swap two cars 
            chance = random(obj.diceDistGen);
            if mod(iIteration,100) == 0 && chance <= 0.5
                convert_car_classes(obj)
            end
            for iCar = 1:obj.numCars
                currentCar = obj.allCars(iCar);
                if currentCar.pose(1) > obj.endPoint
                    obj.respawn_car(currentCar,t);
                end
                currentCar.store_state_data(currentCar.pose(1),currentCar.velocity,currentCar.acceleration,t)
                currentCar.move_car(dt);
                if t >= 500
                    aggregatedVelocities = aggregatedVelocities + currentCar.velocity;
                end
            end
            if t >= 500
                avVel = aggregatedVelocities/obj.numCars;
                obj.averageVelocityHistory(iIteration) = avVel;
                deltaV = 0;
                for iCar = 1:obj.numCars
                    v = obj.allCars(iCar).velocity;
                    deltaV = deltaV + (v - avVel)^2;
                end
                obj.variance(iIteration) = deltaV/obj.numCars;
                if iIteration == nIterations
                    for iCar = 1:obj.numCars
                        obj.collect_car_history(obj.allCars(iCar));
                    end
                end
            else
                obj.variance(iIteration) = NaN;
            end
        end
        function convert_car_classes(obj)
            if obj.numCars > 3
                firstIndex = randi(obj.numCars,1);
                car1 = obj.allCars(firstIndex);
                selectedCarClass = class(car1);
                breakIdx = 0;
                secondIndex = 0;
                while breakIdx == 0
                    secondIndex = randi(obj.numCars);
                    if isa(obj.allCars(secondIndex),selectedCarClass) == 0 && secondIndex ~= firstIndex
                        car2 = obj.allCars(secondIndex);
                        breakIdx = 1;
                    end
                end
                
                % store swapped pair
                obj.storeSwappedIndices = [obj.storeSwappedIndices; firstIndex secondIndex];
                
                if car1.Prev.pose(1) ~= car2.pose(1)
                    tempPreCar1 = car1.Prev;
                else
                    tempPreCar1 = car1.Prev.Prev;
                end
                if car2.Prev.pose(1) ~= car1.pose(1)
                    tempPreCar2 = car2.Prev;
                else
                    tempPreCar2 = car2.Prev.Prev;
                end
                          
                % detach both nodes from dlnode
                removeNode(car1);
                removeNode(car2);

                % swap properties of two cars 
                newCar2 = LoopRoad.swap_cars(car1,car2);
                newCar1 = LoopRoad.swap_cars(car2,car1);
                
                % delete old objects
                delete(car1);
                delete(car2);
                
                insertAfter(newCar1,tempPreCar1)
                obj.allCars(firstIndex) = newCar1;
                
                % update preCar2 in case if newCar1 is newpreCar2
                if (firstIndex+1)==secondIndex || (firstIndex-obj.numCars+1)==secondIndex
                    tempPreCar2 = newCar1;
                end
                
                insertAfter(newCar2,tempPreCar2)
                obj.allCars(secondIndex) = newCar2;
                
                delete(obj.CarsImageHandle);
                obj.CarsImageHandle = [];
            end
        end
    end
    methods (Static)
        function cloneCar = swap_cars(car1,car2)
            
            cloneCar = copy(car1);
            
            cloneCar.juncExitVelocity = car2.juncExitVelocity;
            cloneCar.idmAcceleration =  car2.idmAcceleration;
            cloneCar.s = car2.s;
            cloneCar.a = car2.a;
            cloneCar.b = car2.b;
            cloneCar.timeGap = car2.timeGap ;
            cloneCar.targetVelocity = car2.targetVelocity;
            cloneCar.priority = car2.priority;
            cloneCar.dt =  car2.dt;
            cloneCar.pose =  car2.pose;
            cloneCar.velocity =  car2.velocity;
            cloneCar.maximumVelocity =  car2.maximumVelocity;
            cloneCar.acceleration =  car2.acceleration;
            cloneCar.a_max =  car2.a_max;
            cloneCar.a_min =  car2.a_min;
            cloneCar.a_feas_min =  car2.a_feas_min;
            cloneCar.locationHistory =  car2.locationHistory;
            cloneCar.velocityHistory =  car2.velocityHistory;
            cloneCar.accelerationHistory = car2.accelerationHistory;
            cloneCar.timeHistory =  car2.timeHistory;
            cloneCar.historyIndex =  car2.historyIndex;
            cloneCar.leaderFlag =  car2.leaderFlag;
            cloneCar.stopIndex = car2.stopIndex;
        end
    end
end

