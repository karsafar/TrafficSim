classdef SpawnCars < handle
    properties
        allCars
        numCars
        
    end
    
    methods
        function obj = SpawnCars(SpawnData,orientation, startPoint, Width,dt)
                if isa(SpawnData,'table')
                    obj.controlled_spawn(SpawnData,orientation, startPoint, Width,dt)
                end
        end
        
        function controlled_spawn(obj,SpawnData,orientation, startPoint, Width,dt)
            %%
            obj.numCars = numel(SpawnData(:,1));
            carTypes = SpawnData{:,4};
            for iCar = 1:obj.numCars
                new_car = carTypes{iCar}(orientation, startPoint, Width,dt);
                new_car.pose(1) = SpawnData{iCar,1};
                new_car.velocity = SpawnData{iCar,2};
                new_car.acceleration = SpawnData{iCar,3};
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
    end
end

