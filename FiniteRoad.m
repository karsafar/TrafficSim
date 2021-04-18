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
        
        flow = []
        inflow = []
        outflow = []
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
                obj.numCarsHistory = NaN(finite_road_args{5},1);
                obj.averageVelocityHistory = NaN(finite_road_args{5},1);
                obj.flow = NaN(finite_road_args{5},1);
                obj.inflow = NaN(finite_road_args{5},1);
                obj.outflow = NaN(finite_road_args{5},1);
                obj.variance = NaN(finite_road_args{5},1);
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
            elseif isTimeForNewEntry
                lastCar = obj.allCars(end);
                
                currentSpace = lastCar.pose(1) - obj.startPoint;
                intelligentBreaking = lastCar.velocity*lastCar.timeGap;
                s_star = (lastCar.minimumGap+lastCar.dimension(2)) + max(0,intelligentBreaking);
                isEnoughSpace = (s_star<=currentSpace);
            else
               isEnoughSpace = false; 
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
                
                if isempty(obj.allCars)
                     new_car.velocity = new_car.targetVelocity;
                else
                    new_car.velocity = lastCar.velocity;
                end
%                 new_car.demand_tol = 15;
                obj.allCars = [obj.allCars new_car];
                obj.numCars = obj.numCars + 1;
                
                if numel(obj.allCars) > 1
                    insertAfter(obj.allCars(end),obj.allCars(end-1));
                    obj.allCars(end).leaderFlag = false;
                    if numel(obj.allCars) == 2
                        obj.allCars(1).Prev = obj.allCars(end);
                        %% full doubly linked list
%                         obj.allCars(end).Next = obj.allCars(1);
                        
                    end
                    % update pos and vel arrays for easy access
                    obj.allCarsStates(1,end+1) = new_car.pose(1);
                    obj.allCarsStates(2,end) = new_car.velocity;
                    obj.allCarsStates(3,end) = new_car.acceleration;
                end
            elseif isTimeForNewEntry && ~isEnoughSpace
                obj.verticalQueue = [obj.verticalQueue  obj.carType];
            end
        end
        function delete_car(obj,t)
            if obj.numCars > 1
                obj.allCars(1).Next.leaderFlag = true;
            end
            if t >= obj.transientCutOffLength && any(~isnan(obj.allCars(1).History(1,:)))
                obj.collect_car_history(obj.allCars(1));
            end
            obj.allCars(1).removeNode;
            obj.allCars(1) = [];
            if numel(obj.allCars) == 1
                obj.allCars(1).removeNode;
            end
%{
%                 %obj.allCars(1).targetVelocity = nanmean(obj.averageVelocityHistory);
%                 obj.allCars(1).Prev = obj.allCars(end);
%                 obj.allCars(end).Next = obj.allCars(1);
%                 %obj.allCars(1).Prev = Car([obj.endPoint,nanmean(obj.averageVelocityHistory)]);
%             else
%                 obj.allCars(1).Prev = Car([obj.endPoint,nanmean(obj.averageVelocityHistory)]);
%                 obj.allCars(1).targetVelocity = nanmean(obj.averageVelocityHistory);
%             end
%}
            obj.numCars = obj.numCars - 1;
            
            % update pos and vel arrays for easy access
            obj.allCarsStates(:,1) = [];
        end
        function move_all_cars(obj,t,dt,iIteration,nIterations)
            if obj.testFlag == 0 % what does testFlag mean??? 
                obj.spawn_car(t,dt); 
            end
%             for iCar = 1:obj.numCars
%                 if obj.allCarsStates(1,iCar) > obj.endPoint
%                     obj.delete_car(t)
%                 end
%             end
%             aggregatedVelocities = 0;
%             cutNumCars = 0;
%             if t >= obj.transientCutOffLength % transient cut
%                 for iCar = 1:obj.numCars
%                     aggregatedVelocities = aggregatedVelocities + obj.allCarsStates(2,iCar);
%                     cutNumCars = cutNumCars + 1;
%                 end
%             end
%             for iCar = 1:obj.numCars
                iCar = 1;
           while iCar <= obj.numCars
                if obj.allCarsStates(1,iCar) > obj.endPoint
%                     currentCar.pose(1) = obj.allCarsStates(1,iCar) - (obj.endPoint-obj.startPoint);
%                     obj.allCarsStates(1,iCar) = currentCar.pose(1);
                    obj.delete_car(t);
%                     iCar = iCar-1;
                end
                currentCar = obj.allCars(iCar);
                currentCar.move_car(dt)
%                 
%                 % update pos and vel arrays for easy access
%                 obj.allCarsStates(1,iCar) = currentCar.pose(1);
%                 obj.allCarsStates(2,iCar) = currentCar.velocity;
%                 obj.allCarsStates(3,iCar) = currentCar.acceleration;
%                 
%                 currentCar.store_state_data(t,obj.allCarsStates(:,iCar))

                iCar = iCar+1;
            end
            if t >= obj.transientCutOffLength % transient cut
                avVel = sum(obj.allCarsStates(2,:))/obj.numCars;
                obj.flow(iIteration) = (obj.numCars/obj.Length)*avVel;
                obj.averageVelocityHistory(iIteration) = avVel;
                obj.numCarsHistory(iIteration) = obj.numCars;
                %% inflow
                nCarsIn = sum(obj.allCarsStates(1,:) <= currentCar.s_in);
                avVelIn = sum(obj.allCarsStates(2,(obj.allCarsStates(1,:) <= currentCar.s_in)))/nCarsIn;
                obj.inflow(iIteration) = (nCarsIn/(currentCar.s_in-obj.startPoint))*avVelIn; 
                %% outflow
                nCarsOut = obj.numCars - nCarsIn;
                avVelOut = sum(obj.allCarsStates(2,(obj.allCarsStates(1,:) > currentCar.s_in)))/nCarsOut;
                obj.outflow(iIteration) = (nCarsOut/(obj.endPoint-currentCar.s_in))*avVelOut; 
                
                deltaV = 0;
                for iCar = 1:obj.numCars
                    deltaV = deltaV + (obj.allCarsStates(2,iCar) - avVel)^2;
                end
                obj.variance(iIteration) = deltaV/obj.numCars;
            end
            if iIteration == nIterations
                for iCar = 1:obj.numCars
                    if obj.allCarsStates(1,iCar) >= (obj.startPoint) && obj.allCarsStates(1,iCar) <= (obj.endPoint)
                        obj.collect_car_history(obj.allCars(iCar));
                    end
                end
            end
        end
    end
end

