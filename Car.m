classdef Car < dlnode
    properties (SetAccess = protected)
        velocity = NaN
        acceleration = 0
    end
    properties (Access = public)
        pose = NaN(1,2)
        locationHistory = NaN(1,100000)
        velocityHistory = NaN(1,100000)
        accelerationHistory = NaN(1,100000)
        timeHistory = NaN(1,100000)
        historyIndex = 1
    end
    properties (SetAccess = immutable)
        ownDistfromRearToBack = NaN
        ownDistfromRearToFront = NaN
        parentRoad = ''
        s_in = []
        s_out = []
    end
    properties (Constant)
        maximumAcceleration = [3.5 -9]
        maximumVelocity = 13
        dimension = [2.16 4.4 2.75];
    end
    methods
        function obj = Car(car_args)
            if nargin == 0
                % assign values
            else
                obj.parentRoad = car_args{1};
                if strcmpi(car_args{2},'flow')
                    obj.velocity = 8;
                else
                    obj.velocity = 0;
                end
                
                obj.pose(1) = car_args{3};
                if strcmpi(obj.parentRoad,'horizontal')
                    obj.pose(2) = 0;
                else
                    obj.pose(2) = 90;
                end
                obj.ownDistfromRearToBack = (obj.dimension(2) - obj.dimension(3))/2;
                obj.ownDistfromRearToFront = obj.dimension(3) + obj.ownDistfromRearToBack;
                roadWidth = car_args{4};
                obj.s_in = -roadWidth/2-obj.ownDistfromRearToFront;
                obj.s_out = roadWidth/2+obj.ownDistfromRearToBack;
            end
        end
        function move_car(obj,t,dt)
            
            obj.store_state_data(t)
            
            obj.pose(1) = obj.pose(1) + obj.velocity*dt + 0.5*obj.acceleration*dt^2;
            obj.velocity = obj.velocity + obj.acceleration*dt;
            if obj.velocity > obj.maximumVelocity
                obj.velocity = obj.maximumVelocity;
            elseif obj.velocity < 0
                obj.velocity = 0;
            else
                obj.velocity = obj.velocity;
            end
        end
        function store_state_data(obj,t)
            i = obj.historyIndex;
            obj.locationHistory(i) = obj.pose(1);
            obj.velocityHistory(i) = obj.velocity;
            obj.accelerationHistory(i) = obj.acceleration;
            obj.timeHistory(i) = t;
            obj.historyIndex = i + 1;
        end
    end
end
