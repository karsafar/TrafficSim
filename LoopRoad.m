
classdef LoopRoad < Road
    properties (SetAccess = public)
        diceDistGen = makedist('uniform','lower',0,'upper',1);
        swapPostionArray = [];
        originalClassArray = [];
        newClassArray = [];
        swapRate = []
        flow = []
        inflow = []
        outflow = []
    end
    
    methods
        function obj = LoopRoad(road_args,loop_road_args)
            obj = obj@Road(road_args);
            
            if numel(loop_road_args) == 1
                obj.numCars = loop_road_args.numCars;
                obj.allCars = loop_road_args.allCars;
%                 obj.averageVelocityHistory = single(NaN(loop_road_args.nIterations,1));
                
%                 obj.flow = single( NaN(loop_road_args.nIterations,1));
%                 obj.inflow = single(NaN(loop_road_args.nIterations,1));
%                 obj.outflow = single(NaN(loop_road_args.nIterations,1));
%                 
%                 obj.variance = single(NaN(loop_road_args.nIterations,1));
            else
                % I don't need this part
                obj.allCarsNumArray = loop_road_args{1};
                obj.numCars = sum(obj.allCarsNumArray);
                obj.FixedSeed = loop_road_args{2};
                obj.spawn_initial_cars(loop_road_args{3});
            end
%             obj.carTypeRatios = ones(2,loop_road_args.nIterations).*[round(obj.numCars/2);round(obj.numCars/2)];
        end
        function spawn_initial_cars(obj,dt)
            %% not used anymore (delete later)
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
                            allCarsArray = [allCarsArray; new_car];
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
            %% check if it used
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
            %%
%             if t >= obj.transientCutOffLength % transient cut
%                 obj.collect_car_history(leaderCar);
%             end
%             leaderCar.historyIndex = 1;
%             leaderCar.History = [];
            
            if obj.numCars > 1
                leaderCar.leaderFlag = false;
                leaderCar.Next.leaderFlag = true;
            end
        end
        function move_all_cars(obj,t,dt,iIteration,nIterations,oppositeArm,oppositeArmLength)
            %%
%             aggregatedVelocities = 0;
            
            for iCar = 1:obj.numCars
                currentCar = obj.allCars(iCar);
                if obj.allCarsStates(1,iCar) > obj.endPoint
                    currentCar.pose(1) = obj.allCarsStates(1,iCar) - (obj.endPoint-obj.startPoint);
                    obj.allCarsStates(1,iCar) = currentCar.pose(1);
                    
                    obj.respawn_car(currentCar,t);
                    currentCar.downStreamEndTime = [currentCar.downStreamEndTime iIteration+1];
                    
%                     currentCar.History = single(NaN(4,nIterations));
                    
                    % morph the car
                    chance = random(obj.diceDistGen);
                    if chance < obj.swapRate && (isempty(obj.swapPostionArray) || (strcmpi(class(obj.allCars(obj.swapPostionArray(end))),class(currentCar))))
  
                        obj.swapPostionArray = [obj.swapPostionArray iCar];
                        
                        morphedCar = morph_car(obj,currentCar,dt);
                        anchorCar = obj.allCars(iCar).Prev;
                        
                        
                        % delete current pre-swapped car object
                        removeNode(currentCar);
                        obj.allCars(iCar) = morphedCar;
                        clear currentCar;
                        if obj.numCars > 1
                            insertAfter(morphedCar,anchorCar);
                        end
                        currentCar = morphedCar;
                    end
                                        
                end
                
                currentCar.move_car(dt);
                
%                 currentCar.decide_acceleration(oppositeArm,oppositeArmLength,t,dt);
%                 currentCar.update_velocity(dt);
            end
%{      
      % check if needed later and delete if not!
            if t >= obj.transientCutOffLength % transient cut
                if obj.numCars > 0
                avVel = sum(obj.allCarsStates(2,:))/obj.numCars;
                obj.flow(iIteration) = (obj.numCars/obj.Length)*avVel;
                                
                % inflow
                nCarsIn = sum(obj.allCarsStates(1,:) <= currentCar.s_in);
                avVelIn = sum(obj.allCarsStates(2,(obj.allCarsStates(1,:) <= currentCar.s_in)))/nCarsIn;
                obj.inflow(iIteration) = (nCarsIn/(currentCar.s_in-obj.startPoint))*avVelIn; 
                
                % outflow
                nCarsOut = obj.numCars - nCarsIn;
                avVelOut = sum(obj.allCarsStates(2,(obj.allCarsStates(1,:) > currentCar.s_in)))/nCarsOut;
                obj.outflow(iIteration) = (nCarsOut/(obj.endPoint-currentCar.s_in))*avVelOut; 
                else
                    avVel = 0;
                    obj.flow(iIteration)    = 0;
                    obj.inflow(iIteration)  = 0;
                    obj.outflow(iIteration) = 0;                
                end
                obj.averageVelocityHistory(iIteration) = avVel;
                deltaV = 0;
                for iCar = 1:obj.numCars
                    deltaV = deltaV + (obj.allCarsStates(2,iCar) - avVel)^2;
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
%}             
        end
        function morphedCar = morph_car(obj,carToMorph,dt)
            
            selectedCarClass = class(carToMorph);
            
            if strcmpi(selectedCarClass,'carTypeA')
                % convert to class B
                if length(obj.carTypes) == 3
                    newCar = add_car(obj,2,dt);
                elseif length(obj.carTypes) == 5
                    newCar = add_car(obj,4,dt);
                elseif length(obj.carTypes) == 6
                    newCar = add_car(obj,3,dt);
                end
                
                morphedCar = LoopRoad.swap_cars(newCar,carToMorph);
                
                obj.originalClassArray = [obj.originalClassArray 1];
                obj.newClassArray = [obj.newClassArray 2];
            else
                % convert to class A
                newCar = add_car(obj,1,dt);
                if length(obj.carTypes) == 3
                    newCar = add_car(obj,1,dt);
                elseif length(obj.carTypes) == 5
                    newCar = add_car(obj,3,dt);
                elseif length(obj.carTypes) == 6
                    newCar = add_car(obj,6,dt);
                end
                morphedCar = LoopRoad.swap_cars(newCar,carToMorph);
                obj.originalClassArray = [obj.originalClassArray 2];
                obj.newClassArray = [obj.newClassArray 1];
            end
            delete(obj.CarsImageHandle);
            obj.CarsImageHandle = [];
        end
        end
    methods (Static)
        function cloneCar = swap_cars(cloneCar,car2)
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
            cloneCar.History = car2.History;
            cloneCar.historyIndex =  car2.historyIndex;
            cloneCar.leaderFlag =  car2.leaderFlag;
            cloneCar.stopIndex = car2.stopIndex;
        end
    end
end

