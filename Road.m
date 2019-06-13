classdef Road < handle
    properties (SetAccess = immutable)
        startPoint = 0
        endPoint = 0
        Width = 0
        Length = 0
        orientation = ''
        crossingBeginPosition = NaN
        crossingEndPosition = NaN
    end
    properties (SetAccess = public)
        numCars = 0
        allCars = []
        allCarsStates = []
        carHistory = []
        CarsImageHandle = []
        nCarHistory = 0
        averageVelocityHistory = []
        variance
        carType = 0
        carTypes = {}
        FixedSeed = false
        numEmergBreaks = 0
        transientCutOffLength = 0
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
            end
            obj.crossingBeginPosition = -obj.Width/2;
            obj.crossingEndPosition = obj.Width/2;
        end
        function new_car = add_car(obj,i,dt)
            new_car = obj.carTypes{i}(obj.orientation, obj.startPoint, obj.Width,dt);
        end
        function move_all_cars(obj,dt)
            for iCar = 1:obj.numCars
                obj.allCars(iCar).move_car(dt)
            end
        end
        function collect_car_history(obj,iCar)
            % not used
            i = obj.nCarHistory + 1;
            obj.clone_cars(iCar);
            obj.nCarHistory = i;
        end
        function count_emegrency_breaks(obj)
            for iCar = 1:obj.numCars
                currentCar = obj.allCars(iCar);
                a = currentCar.acceleration;
                a_f = currentCar.a_feas_min;
                sIdx = currentCar.stopIndex;
                if  (round(a,2)) < a_f && sIdx == 0
                    obj.numEmergBreaks = obj.numEmergBreaks + 1;
                    currentCar.stopIndex = 1;
                elseif a > a_f && sIdx == 1
                    currentCar.stopIndex = 0;
                end
                
            end
        end
        function clone_cars(obj,car2)
            % not used
            obj.carHistory(end+1).juncExitVelocity = car2.juncExitVelocity;
            obj.carHistory(end).idmAcceleration =  car2.idmAcceleration;
            obj.carHistory(end).s = car2.s;
            obj.carHistory(end).a = car2.a;
            obj.carHistory(end).b = car2.b;
            obj.carHistory(end).timeGap = car2.timeGap ;
            obj.carHistory(end).targetVelocity = car2.targetVelocity;
            obj.carHistory(end).priority = car2.priority;
            obj.carHistory(end).dt =  car2.dt;
            obj.carHistory(end).pose =  car2.pose;
            obj.carHistory(end).velocity =  car2.velocity;
            obj.carHistory(end).maximumVelocity =  car2.maximumVelocity;
            obj.carHistory(end).acceleration =  car2.acceleration;
            obj.carHistory(end).a_max =  car2.a_max;
            obj.carHistory(end).a_min =  car2.a_min;
            obj.carHistory(end).a_feas_min =  car2.a_feas_min;
            obj.carHistory(end).History = car2.History(:,1:(car2.historyIndex-1));
            obj.carHistory(end).historyIndex =  car2.historyIndex;
            obj.carHistory(end).leaderFlag =  car2.leaderFlag;
            obj.carHistory(end).stopIndex = car2.stopIndex;
            obj.carHistory(end).Type = class(car2);
        end
    end
end

