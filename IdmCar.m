classdef IdmCar < Car & matlab.mixin.Heterogeneous
    properties (Constant)
        delta = 2
        minimumGap = 6.4
    end
    properties (SetAccess = protected)
        idmAcceleration = NaN
        s = NaN
        a = 1;
        b = 1.5;
        timeGap  = 1.6;
    end
    properties (Access = public)
        targetVelocity = 6
    end
    
    methods
        function obj = IdmCar(varargin)
            obj = obj@Car(varargin);
        end
        function obj = modifyIdm(obj,flag)
            if flag
                obj.a = 1;
                obj.b = 1.5;
                obj.timeGap  = 1.6;
            else
                obj.a = 1;
                obj.b = 1.5;
                obj.timeGap = 1.6;
            end
        end
        function calculate_idm_accel(obj,varargin)
            roadLength = varargin{1};
            if nargin == 2
                junc_flag = 0;
            else
               junc_flag = varargin{2};
            end

            if junc_flag
                obj.s = obj.s_in - obj.pose(1);
                dV = obj.velocity; 
            elseif obj.leaderFlag == 0 
                obj.s = obj.Prev.pose(1) - obj.pose(1);
                dV = (obj.velocity - obj.Prev.velocity);
            elseif ~isempty(obj.Prev)
                obj.s = obj.Prev.pose(1) - obj.pose(1) + roadLength+obj.demand_tol;
                dV = (obj.velocity - obj.Prev.velocity);
            else
                obj.s = Inf;
                dV = 0;
            end

            intelligentBreaking = obj.velocity*obj.timeGap + (obj.velocity*dV)/(2*sqrt(obj.a*obj.b));
            if junc_flag
                s_star = 0.5 + max(0,intelligentBreaking);
            else
                s_star = obj.minimumGap + max(0,intelligentBreaking);
            end
            
            if obj.tol > abs(obj.velocity - obj.targetVelocity)
                obj.idmAcceleration = obj.a*(1 - 1 - (s_star/obj.s)^2);
            else
                obj.idmAcceleration = obj.a*(1 - (obj.velocity/obj.targetVelocity)^obj.delta - (s_star/obj.s)^2);
            end
            
            if obj.idmAcceleration > obj.maximumAcceleration(1)
                obj.idmAcceleration = obj.maximumAcceleration(1);
            elseif obj.idmAcceleration < obj.maximumAcceleration(2)
                obj.idmAcceleration =  obj.maximumAcceleration(2);
            end
        end
        function decide_acceleration(obj,varargin)
            obj.acceleration = obj.idmAcceleration;
            % check for negative velocities
            check_for_negative_velocity(obj,varargin{3});
        end
    end
end

