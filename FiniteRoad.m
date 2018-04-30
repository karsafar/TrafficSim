classdef FiniteRoad < Road
    
    properties (SetAccess = protected)
        nextEntry = 0
        pd = 0
        carTypePd = 0
        verticalQueue = []
        numCarsHistory
    end
    
    methods
        function obj = FiniteRoad(road_args, distributionMean,nIterations)
            if nargin == 0
                % Assign values to road_args
            end
            obj = obj@Road(road_args);
            % distribution - mean interval is distributionMean secs
            obj.pd = makedist('Exponential','mu',distributionMean);
            obj.numCarsHistory = NaN(nIterations,1);
            obj.averageVelocityHistory = NaN(nIterations,1);
            obj.carTypePd = makedist('uniform',0,1);
        end
        function spawn_car(obj,globalTime)
            isTimeForNewEntry = (globalTime >= obj.nextEntry);
            isVerticalQueueNotEmpty = (~isempty(obj.verticalQueue));
            if isempty(obj.allCars)
                isEnoughSpace = true;
            else
                isEnoughSpace = (obj.allCars(end).pose(1) - obj.startPoint) >= 4*obj.allCars(end).minimumGap;
            end
            if isTimeForNewEntry
                obj.carType = (random(obj.carTypePd)<=obj.BtCarsRatio);
                interval = random(obj.pd);
                obj.nextEntry = globalTime + interval;
            end
            if isEnoughSpace && (isTimeForNewEntry || isVerticalQueueNotEmpty)
                if isVerticalQueueNotEmpty
                    obj.carType = obj.verticalQueue(1);
                    obj.verticalQueue(1) = [];
                end
                obj.add_car('flow');
                obj.numCars = obj.numCars + 1;
                
                if numel(obj.allCars) > 1
                    insertAfter(obj.allCars(end),obj.allCars(end-1));
                    obj.allCars(end).leaderFlag = false;
                    obj.allCars(1).Prev = obj.allCars(end);
                    obj.allCars(end).Next = obj.allCars(1);
                else
                    obj.allCars(1).targetVelocity = obj.allCars(1).velocity;
                end
            elseif isTimeForNewEntry && ~isEnoughSpace
                obj.verticalQueue = [obj.verticalQueue  obj.carType];
            end
        end
        function move_all_cars(obj,t,dt,iIteration,nIterations)
            if obj.numCars > 0
                if obj.allCars(1).pose(1) >= obj.endPoint
                    obj.delete_car()
                end
                aggregatedVelocities = 0;
                for iCar = 1:obj.numCars
                    obj.allCars(iCar).move_car(t,dt)
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
        function delete_car(obj)
            if obj.numCars > 1
                obj.allCars(1).Next.leaderFlag = true;
            end
            obj.collect_car_history(obj.allCars(1));
            obj.allCars(1).removeNode;
            obj.allCars(1) = [];
            if numel(obj.allCars) > 1
                obj.allCars(1).Prev = obj.allCars(end);
                obj.allCars(end).Next = obj.allCars(1);
                obj.numCars = obj.numCars - 1;
            else
                obj.numCars = obj.numCars - 1;
            end
        end
        function store_num_cars(obj,iIteration)
            obj.numCarsHistory(iIteration,1) = obj.numCars;
        end
    end
end

