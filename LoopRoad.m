classdef LoopRoad < Road
    properties (SetAccess = protected)
        initPoseProbDist = []
        allCarsNumArray = 0
    end
    
    methods
        function obj = LoopRoad(road_args,loop_road_args)
            obj = obj@Road(road_args);
            
            obj.allCarsNumArray = loop_road_args{1};
            obj.numCars = loop_road_args{2};
            obj.averageVelocityHistory = NaN(loop_road_args{3},1);
            obj.FixedDistr = loop_road_args{4};
            obj.spawn_initial_cars();
        end
        function spawn_initial_cars(obj)
            minimumSpacing = IdmCar.minimumGap+Car.dimension(2);
            allCarsPoseArray = NaN(obj.numCars,1);
            for iCar = 1:obj.numCars
                if iCar == 1
                    allCarsPoseArray(iCar) = obj.startPoint;
                else
                    allCarsPoseArray(iCar) = allCarsPoseArray(iCar-1) + minimumSpacing;
                end
            end
            unoccupiedSpace =  obj.endPoint - allCarsPoseArray(end) - 20;
            if obj.FixedDistr
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
                        new_car = add_car(obj,i);
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
        function respawn_car(obj,leaderCar)
            leaderCar.pose(1) = leaderCar.pose(1) - (obj.endPoint-obj.startPoint);
            
            obj.collect_car_history(leaderCar);
            
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
                if obj.allCars(iCar).pose(1) >= obj.endPoint
                    obj.respawn_car(obj.allCars(iCar));
                end
                obj.allCars(iCar).store_state_data(t)
                obj.allCars(iCar).move_car(dt);
                aggregatedVelocities = aggregatedVelocities + obj.allCars(iCar).velocity;
            end
            obj.averageVelocityHistory(iIteration) = aggregatedVelocities/obj.numCars;
            
            if iIteration == nIterations
                for iCar = 1:obj.numCars
                    obj.collect_car_history(obj.allCars(iCar));
                end
            end
        end
    end
end

