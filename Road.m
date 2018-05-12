classdef Road < handle
    
    properties (SetAccess = immutable)
        startPoint = 0
        endPoint = 0
        Width = 0
        Length = 0
        priority = false
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
            obj.carTypes = road_args{1};
            theta = road_args{2};
            if theta == 0
                obj.orientation = 'horizontal';
                obj.startPoint = road_args{3}.Start(1);
                obj.endPoint = road_args{3}.End(1);
                obj.Width = road_args{3}.Width(1);
                obj.Length = road_args{3}.Length(1);
            else
                obj.orientation = 'vertical';
                obj.startPoint = road_args{3}.Start(2);
                obj.endPoint = road_args{3}.End(2);
                obj.Width = road_args{3}.Width(2);
                obj.Length = road_args{3}.Length(2);
                obj.priority = road_args{4};
            end
            obj.crossingBeginPosition = -obj.Width/2;
            obj.crossingEndPosition = obj.Width/2;
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

