classdef IdmModel < Car & matlab.mixin.Heterogeneous
    properties (Constant)
        delta = 1
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
        targetVelocity = 13
    end
    
    methods
        function obj = IdmModel(varargin)
            obj = obj@Car(varargin);
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
                obj.s = 1e5;
                dV = 1e-5;
            end

            intelligentBreaking = obj.velocity*obj.timeGap + (obj.velocity*dV)/(2*sqrt(obj.a*obj.b));
            if junc_flag 
                s_star = 0.1 + max(0,intelligentBreaking);
            else
                s_star = obj.minimumGap + max(0,intelligentBreaking);
            end
            
            if obj.velocity == 0 && obj.targetVelocity == 0
                obj.idmAcceleration = -obj.a*(s_star/obj.s)^2;
            else
                obj.idmAcceleration = obj.a*(1 - (obj.velocity/obj.targetVelocity)^obj.delta - (s_star/obj.s)^2);
            end
            
            if obj.idmAcceleration > obj.a_max
                obj.idmAcceleration = obj.a_max;
            elseif obj.idmAcceleration < obj.a_feas_min
                obj.idmAcceleration =  obj.a_feas_min;
            end
        end
        function decide_acceleration(obj,varargin)
            obj.acceleration = obj.idmAcceleration;
            % check for negative velocities
            check_for_negative_velocity(obj,varargin{4});
        end
    end
end

