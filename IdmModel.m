classdef IdmModel < Car & matlab.mixin.Heterogeneous
    properties (Constant)
        delta = 1
        minimumGap = 2
    end
    properties (SetAccess = public)
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
        function calculate_idm_accel(obj,roadLength)
            
            if  obj.leaderFlag == 0
                obj.s = obj.Prev.pose(1) - obj.pose(1);
            else
                obj.s = obj.Prev.pose(1) - obj.pose(1) + roadLength;
            end
            dV = (obj.velocity - obj.Prev.velocity);
            
            
            intelligentBreaking = obj.velocity*obj.timeGap + (obj.velocity*dV)/(2*sqrt(obj.a*obj.b));
            s_star = obj.minimumGap+obj.dimension(2) + max(0,intelligentBreaking);
            
            velDif = obj.velocity/obj.targetVelocity;
            if isnan(velDif)
                velDif = 1;
            end
            
            
            a_idm = obj.a*(1 - (velDif)^obj.delta - (s_star/(obj.s))^2);
            
            if a_idm < obj.a_feas_min
                a_idm =  obj.a_feas_min;
            end
            
            
             obj.idmAcceleration = a_idm;
        end
        function decide_acceleration(obj,varargin)
            obj.acceleration = obj.idmAcceleration;
            % check for negative velocities
            check_for_negative_velocity(obj,varargin{4});
        end
    end
end

