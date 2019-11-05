classdef Car < dlnode & matlab.mixin.Copyable
    properties (SetAccess = protected)
    end
    properties (Access = public)
        priority = 0
        dt = 0
        pose = NaN(1,2)
        velocity = 0
        maximumVelocity = 13
        acceleration = 0.0
        a_max = 3.5
        a_min = -3.5
        a_feas_min = -9
        History = []
        historyIndex = 1.0
        leaderFlag = true
        stopIndex = 0
        downStreamEndTime = 1
        tempAccel
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
        tol = 1e-4
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
                obj.Prev = obj;
                obj.Next = obj;
            end
        end
        
        function move_car(obj,dt)
            %% profile these two methods to find out which is faster
%             obj.pose(1) = obj.pose(1) + obj.velocity*dt + 0.5*obj.acceleration*dt^2;
%             
% %             obj.tempAccel = obj.acceleration;
%             obj.velocity = obj.velocity + obj.acceleration*dt;
%             if obj.velocity < obj.tol && obj.velocity > 0
%                 obj.velocity = 0;
%             end

        vel_prev = obj.velocity;
        vel_new = vel_prev + obj.acceleration*dt;
        obj.velocity = vel_new;
        obj.pose(1) = obj.pose(1) + 0.5*(vel_prev + vel_new)*dt;
        end
        function update_velocity(obj,dt)
            obj.velocity = obj.velocity + 0.5*(obj.tempAccel+obj.acceleration)*dt;
        end

        function store_state_data(obj,t,currentStates)

            i = obj.historyIndex;
            obj.History(:,i) = [t;currentStates];
            obj.historyIndex = i + 1;
            
            % unit test the constraints
%             tolerance = 5e-2;
%             assert(obj.velocity >= 0-tolerance && obj.velocity <= obj.maximumVelocity+tolerance,'Velocity is out of limit');
%             assert(obj.acceleration >=(obj.a_feas_min - tolerance) && obj.acceleration <= (tolerance + obj.a_max) ,'Acceleration contraints are violated');            
        end
        function check_for_negative_velocity(obj,dt)
            if (obj.velocity + obj.acceleration*dt) < 0
                if obj.velocity == 0
                    obj.acceleration = 0;
                else
                    obj.acceleration = - obj.velocity/dt;
                end
            elseif (obj.velocity + obj.acceleration*dt) > obj.maximumVelocity
                obj.acceleration = (obj.maximumVelocity - obj.velocity)/dt;
            end
        end
    end
end
