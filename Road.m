classdef Road < handle
    
    properties (SetAccess = immutable)
        startPoint = 0
        endPoint = 0
        Width = 0
        priority
        orientation = ''
        crossingBeginPosition = NaN
        crossingEndPosition = NaN
    end
    properties (SetAccess = protected)
        numCars = 0
        allCars = []
        nextCarApproachingCrossing = []
        carHistory = {}
        nCarHistory = 0
        averageVelocityHistory = []
        carType = 0
        carTypes = {}
    end
    methods
        function obj = Road(road_args)
            obj.startPoint = road_args{1};
            obj.endPoint = road_args{2};
            obj.Width = road_args{3};
            obj.crossingBeginPosition = -obj.Width/2;
            obj.crossingEndPosition = obj.Width/2;
            theta = road_args{4};
            if theta == 0
                obj.orientation = 'horizontal';
                if road_args{5} == 1
                    obj.priority = true;
                elseif road_args{5} == 0
                    obj.priority = true;
                else
                    obj.priority = NaN;
                end
            else
                obj.orientation = 'vertical';
                if road_args{5} == 1
                    obj.priority = false;
                elseif road_args{5} == 0
                    obj.priority = false;
                else
                    obj.priority = NaN;
                end
            end
            obj.carTypes = road_args{6};
        end
        function new_car = add_car(obj,i)
            new_car = obj.carTypes{i}(obj.orientation, obj.startPoint, obj.Width);
        end
        function move_all_cars(obj,dt)
            for iCar = 1:obj.numCars
                obj.allCars(iCar).move_car(dt)
            end
        end
        function collect_car_history(obj,iCar)
            i = obj.nCarHistory + 1;
            obj.carHistory{i} = [iCar.timeHistory; iCar.locationHistory; iCar.velocityHistory; iCar.accelerationHistory];
            obj.nCarHistory = i;
        end
    end
end

