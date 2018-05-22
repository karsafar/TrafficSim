classdef FiniteRoad < Road
    
    properties (SetAccess = protected)
        nextEntry = 0
        spawnTimeProbDist = 0
        carTypePd = 0
        verticalQueue = []
        numCarsHistory
        carRatios
        spawningInterval
    end
    
    methods
        function obj = FiniteRoad(road_args,finite_road_args)
            obj = obj@Road(road_args);
            
            % distribution - mean interval is distributionMean secs
            obj.carRatios = finite_road_args{1};
            obj.FixedDistr = finite_road_args{4};
            if obj.FixedDistr
                rng(1);
            end
            obj.spawnTimeProbDist = makedist('Exponential','mu',finite_road_args{2});
            obj.numCarsHistory = NaN(finite_road_args{3},1);
            obj.averageVelocityHistory = NaN(finite_road_args{3},1);
            obj.carTypePd = makedist('uniform',0,1);
        end
        function spawn_car(obj,time)
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
                    if nTypeCarChance<obj.carRatios(i)
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
                new_car = obj.add_car(obj.carType);
                new_car.velocity = 8;
                obj.allCars = [obj.allCars new_car];
                obj.numCars = obj.numCars + 1;
                
                if numel(obj.allCars) > 1
                    insertAfter(obj.allCars(end),obj.allCars(end-1));
                    obj.allCars(end).leaderFlag = false;
                    if numel(obj.allCars) == 2
                        obj.allCars(1).Prev = obj.allCars(end);
                        obj.allCars(end).Next = obj.allCars(1);
                        %                                             obj.allCars(1).Prev = Car([obj.endPoint,nanmean(obj.averageVelocityHistory)]);
                    end
                    %                     obj.allCars(1).targetVelocity = nanmean(obj.averageVelocityHistory);
                else
                    obj.allCars(1).targetVelocity = obj.allCars(1).velocity;
                end
            elseif isTimeForNewEntry && ~isEnoughSpace
                obj.verticalQueue = [obj.verticalQueue  obj.carType];
            end
        end
        function delete_car(obj,t)
            if obj.numCars > 1
                obj.allCars(1).Next.leaderFlag = true;
            end
            if t > 1000 && any(~isnan(obj.allCars(1).timeHistory))
                obj.collect_car_history(obj.allCars(1));
            end
            obj.allCars(1).removeNode;
            obj.allCars(1) = [];
            if numel(obj.allCars) > 1
%                 obj.allCars(1).targetVelocity = nanmean(obj.averageVelocityHistory);
                obj.allCars(1).Prev = obj.allCars(end);
                obj.allCars(end).Next = obj.allCars(1);
                %                 obj.allCars(1).Prev = Car([obj.endPoint,nanmean(obj.averageVelocityHistory)]);
                obj.numCars = obj.numCars - 1;
            else
                obj.numCars = obj.numCars - 1;
                obj.allCars(1).Prev = Car([obj.endPoint,nanmean(obj.averageVelocityHistory)]);
                obj.allCars(1).targetVelocity = nanmean(obj.averageVelocityHistory);
                
            end
        end
        function move_all_cars(obj,t,dt,iIteration,nIterations)
            
            obj.spawn_car(t);
            
            if obj.numCars > 0
                if obj.allCars(1).pose(1) >= obj.endPoint
                    obj.delete_car(t)
                end
                aggregatedVelocities = 0;
                cutNumCars = 0;
                for iCar = 1:obj.numCars
                    if t > 1000 &&  obj.allCars(iCar).pose(1) >= (obj.startPoint+100) && obj.allCars(iCar).pose(1) <= (obj.endPoint-100)
                        obj.allCars(iCar).store_state_data(t)
                        aggregatedVelocities = aggregatedVelocities + obj.allCars(iCar).velocity;
                        cutNumCars = cutNumCars + 1;
                    end
                    obj.allCars(iCar).move_car(dt)
                end
                if t > 1000 
                    obj.averageVelocityHistory(iIteration) = aggregatedVelocities/cutNumCars;
                    obj.numCarsHistory(iIteration,1) = cutNumCars;
                end
                if iIteration == nIterations
                    for iCar = 1:obj.numCars
                        if obj.allCars(iCar).pose(1) >= (obj.startPoint+100) && obj.allCars(iCar).pose(1) <= (obj.endPoint-100)
                            obj.collect_car_history(obj.allCars(iCar));
                        end
                    end
                end
                
            end
        end
    end
end

