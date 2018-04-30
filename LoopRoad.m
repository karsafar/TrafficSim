classdef LoopRoad < Road 
    properties (SetAccess = protected)
        pd = []
        prescribedDensity = []
    end
    
    methods
        function obj = LoopRoad(road_args,occupancy,nIterations)
            if nargin == 0
                % Assign values to road_args
            end
            obj = obj@Road(road_args);
            obj.prescribedDensity = occupancy;
            obj.pd = makedist('uniform','lower',obj.startPoint,'upper',obj.endPoint);
            obj.averageVelocityHistory = NaN(nIterations,1);
        end
        function instant_spawn(obj)
            minimumSpacing = 6;
            maxNumOfCars = abs(ceil((obj.endPoint - obj.startPoint - 20)/minimumSpacing));
            obj.numCars = round(obj.prescribedDensity*maxNumOfCars);
            allCarsPoseArray = nan(obj.numCars,1);
            iCar = 1;
            while iCar <= obj.numCars
                randomPosition = random(obj.pd);
                if randomPosition <= -10 || randomPosition >= 10
                    if iCar == 1
                        allCarsPoseArray(iCar) = randomPosition;
                        iCar = iCar + 1;
                    elseif abs(allCarsPoseArray(1:iCar-1) - randomPosition) > minimumSpacing
                        allCarsPoseArray(iCar) = randomPosition;
                        iCar = iCar + 1;
                    end
                end
            end
            allCarsPoseArray =  sort(allCarsPoseArray,'descend');
            
            for iCar = 1:obj.numCars
                obj.carType = (rand()<=obj.BtCarsRatio);
                obj.add_car('density');
                
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
                obj.allCars(iCar).move_car(t,dt);
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

