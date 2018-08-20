classdef FiniteRoad < Road
    
    properties (SetAccess = protected)
        nextEntry = 0
        spawnTimeProbDist = 0
        carTypePd = 0
        verticalQueue = []
        numCarsHistory = []
        carRatios
        spawningInterval
        tolerance = 0
        testFlag = 1
    end
    
    methods
        function obj = FiniteRoad(road_args,finite_road_args)
            obj = obj@Road(road_args);          
            if numel(finite_road_args) == 1
                obj.numCars = finite_road_args.numCars;
                obj.allCars = finite_road_args.allCars;
            else
                % distribution - mean interval is distributionMean secs
                obj.carRatios = finite_road_args{1};
                obj.FixedSeed = finite_road_args{3};
                if obj.FixedSeed
                    rng(1);
                end
                obj.spawnTimeProbDist = makedist('Exponential','mu',finite_road_args{2});
                obj.carTypePd = makedist('uniform',0,1);
                obj.spawn_car(0,finite_road_args{4});
                obj.numCarsHistory = NaN(int8(finite_road_args{5}),1);
                obj.averageVelocityHistory = NaN(int8(finite_road_args{5}),1);
            end
        end
        function spawn_car(obj,time,dt)
            if time == 0
                obj.testFlag = 0;
            end
            isTimeForNewEntry = (time >= obj.nextEntry);
            isVerticalQueueNotEmpty = (~isempty(obj.verticalQueue));
            if isempty(obj.allCars)
                isEnoughSpace = true;
            else
                isEnoughSpace = (obj.allCars(end).pose(1) - obj.startPoint) >= 4*obj.allCars(end).minimumGap;
            end
            if isTimeForNewEntry
                nTypeCarChance = random(obj.carTypePd);
                for i = 1:numel(obj.carTypes)
                    if nTypeCarChance<sum(obj.carRatios(1:i))
                        obj.carType = i;
                        break;
                    end
                end
                interval = random(obj.spawnTimeProbDist);
                obj.nextEntry = time + interval;
            end
            if isEnoughSpace && (isTimeForNewEntry || isVerticalQueueNotEmpty)
                if isVerticalQueueNotEmpty
                    obj.carType = obj.verticalQueue(1);
                    obj.verticalQueue(1) = [];
                end
                new_car = obj.add_car(obj.carType,dt);
                new_car.velocity = 6;
                obj.allCars = [obj.allCars new_car];
                obj.numCars = obj.numCars + 1;
                
                if numel(obj.allCars) > 1
                    insertAfter(obj.allCars(end),obj.allCars(end-1));
                    obj.allCars(end).leaderFlag = false;
                    if numel(obj.allCars) == 2
                        obj.allCars(1).Prev = obj.allCars(end);
                        obj.allCars(end).Next = obj.allCars(1);
                        %obj.allCars(1).Prev = Car([obj.endPoint,nanmean(obj.averageVelocityHistory)]);
                    end
                    
                end
            elseif isTimeForNewEntry && ~isEnoughSpace
                obj.verticalQueue = [obj.verticalQueue  obj.carType];
            end
        end
        function delete_car(obj,t)
            if obj.numCars > 1
                obj.allCars(1).Next.leaderFlag = true;
            end
            if t >= obj.tolerance && any(~isnan(obj.allCars(1).timeHistory))
                obj.collect_car_history(obj.allCars(1));
            end
            obj.allCars(1).removeNode;
            obj.allCars(1) = [];
%             if numel(obj.allCars) > 1
%                 %obj.allCars(1).targetVelocity = nanmean(obj.averageVelocityHistory);
%                 obj.allCars(1).Prev = obj.allCars(end);
%                 obj.allCars(end).Next = obj.allCars(1);
%                 %obj.allCars(1).Prev = Car([obj.endPoint,nanmean(obj.averageVelocityHistory)]);
%             else
%                 obj.allCars(1).Prev = Car([obj.endPoint,nanmean(obj.averageVelocityHistory)]);
%                 obj.allCars(1).targetVelocity = nanmean(obj.averageVelocityHistory);
%             end
            obj.numCars = obj.numCars - 1;
        end
        function move_all_cars(obj,t,dt,iIteration,nIterations)
            if obj.testFlag == 0
                obj.spawn_car(t,dt);
            end
            for iCar = 1:obj.numCars
                if obj.allCars(1).pose(1) >= obj.endPoint
                    obj.delete_car(t)
                end
            end
            aggregatedVelocities = 0;
            cutNumCars = 0;
            for iCar = 1:obj.numCars
                
                if t >= obj.tolerance %&& obj.allCars(iCar).pose(1) >= (obj.startPoint+50) && obj.allCars(iCar).pose(1) <= (obj.endPoint-50)
                    aggregatedVelocities = aggregatedVelocities + obj.allCars(iCar).velocity;
                    cutNumCars = cutNumCars + 1;
                end
            end
            for iCar = 1:obj.numCars
                obj.allCars(iCar).store_state_data(t)
                obj.allCars(iCar).move_car(dt)
            end
            if t >= obj.tolerance
                obj.averageVelocityHistory(iIteration) = aggregatedVelocities/cutNumCars;
                obj.numCarsHistory(iIteration) = cutNumCars;
            end
            deltaV = 0;
            
            for iCar = 1:obj.numCars
                deltaV = deltaV + (obj.allCars(iCar).velocity - obj.averageVelocityHistory(iIteration))^2;
            end
            obj.variance(iIteration) = deltaV/obj.numCars;
            if iIteration == nIterations
                for iCar = 1:obj.numCars
                    if obj.allCars(iCar).pose(1) >= (obj.startPoint+50) && obj.allCars(iCar).pose(1) <= (obj.endPoint-50)
                        obj.collect_car_history(obj.allCars(iCar));
                    end
                end
            end
        end
    end
end

