classdef Car < dlnode
    properties (SetAccess = protected)
        maximumAcceleration = [3.5 -3.5]
    end
    properties (Access = public)
        priority = 0
        dt = 0
        pose = NaN(1,2)
        velocity = 0
        maximumVelocity = 13
        acceleration = 1.0
        locationHistory = NaN(1,100000)
        velocityHistory = NaN(1,100000)
        accelerationHistory = NaN(1,100000)
        timeHistory = NaN(1,100000)
        historyIndex = 1.0
        leaderFlag = true
    end
    properties (SetAccess = immutable)
        ownDistfromRearToBack = NaN
        ownDistfromRearToFront = NaN
        parentRoad = ''
        s_in = []
        s_out = []
    end
    properties (Constant)
        dimension = [2.16 4.4 2.75];
        tol = 1e-1
    end
    methods
        
        function obj = Car(car_args)
            if numel(car_args) == 2
                obj.pose(1) = car_args(1);
                obj.velocity = car_args(2);
            else
                obj.parentRoad = car_args{1};
                obj.pose(1) = car_args{2};
                if strcmpi(obj.parentRoad,'horizontal')
                    obj.pose(2) = 0;
                else
                    obj.pose(2) = 90;
                end
                obj.ownDistfromRearToBack = (obj.dimension(2) - obj.dimension(3))/2;
                obj.ownDistfromRearToFront = obj.dimension(3) + obj.ownDistfromRearToBack;
                roadWidth = car_args{3};
                obj.dt = car_args{4};
                obj.s_in = -roadWidth/2-obj.ownDistfromRearToFront;
                obj.s_out = roadWidth/2+obj.ownDistfromRearToBack;
            end
        end
        
        function move_car(obj,dt)
            obj.pose(1) = obj.pose(1) + obj.velocity*dt + 0.5*obj.acceleration*dt^2;
            obj.velocity = obj.velocity + obj.acceleration*dt;
            if obj.velocity > obj.maximumVelocity
                obj.velocity = obj.maximumVelocity;
            elseif obj.velocity < 0 
                obj.acceleration = -(obj.velocityHistory(obj.historyIndex-1)/dt);
                obj.accelerationHistory(obj.historyIndex-1) = obj.acceleration;
                obj.velocity = 0;
            end
        end
        
        function store_state_data(obj,t)
            i = obj.historyIndex;
            obj.locationHistory(i) = obj.pose(1);
            obj.velocityHistory(i) = obj.velocity;
            obj.accelerationHistory(i) = obj.acceleration;
            obj.timeHistory(i) = t;
            obj.historyIndex = i + 1;
            
            % unit test the constraints
            assert(obj.velocity >= 0 && obj.velocity <= obj.maximumVelocity,'Velocity is out of limit');
            assert(obj.acceleration >=(obj.maximumAcceleration(2) - obj.tol) && obj.acceleration <= (obj.tol + 8) ,'Acceleration contraints are violated');            
        end
    end
end
