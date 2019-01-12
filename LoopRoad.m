classdef LoopRoad < Road
    properties (SetAccess = protected)
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
    end
end

