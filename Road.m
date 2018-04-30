classdef Road < handle 
    
    properties (SetAccess = immutable)
        startPoint = 0
        endPoint = 0
        Width = 0
        BtCarsRatio = 0
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
    end
    methods
        function obj = Road(road_args)
            if nargin == 0
                error('input format should be Road([x1 x2],[y1 y2],theta)')
            else
                obj.startPoint = road_args(1);
                obj.endPoint = road_args(2);
                obj.Width = road_args(3);
                obj.crossingBeginPosition = -obj.Width/2;
                obj.crossingEndPosition = obj.Width/2;
                theta = road_args(4);
                obj.BtCarsRatio = road_args(6);
                if theta == 0
                    obj.orientation = 'horizontal';
                    if road_args(5) == 1
                        obj.priority = true;
                    elseif road_args(5) == 0
                        obj.priority = true;
                    else
                        obj.priority = NaN;
                    end
                else
                    obj.orientation = 'vertical';
                    if road_args(5) == 1
                        obj.priority = false;
                    elseif road_args(5) == 0
                        obj.priority = false;
                    else
                        obj.priority = NaN;
                    end
                end
            end
        end
        function add_car(obj,prescription)
            if obj.carType == 1
                obj.allCars = [obj.allCars  BtCar(obj.orientation, prescription, obj.startPoint, obj.Width)];
            else
                obj.allCars = [obj.allCars  IdmCar(obj.orientation, prescription, obj.startPoint, obj.Width)];
            end
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

