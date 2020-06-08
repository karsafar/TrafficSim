classdef IdmModel < Car & matlab.mixin.Heterogeneous
    properties (Constant)
        delta = 4
        minimumGap = 2
    end
    properties (SetAccess = public)
        idmAcceleration = NaN
        s = NaN
        a = getappdata(0,'a_idm');
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

            gap = obj.Prev.pose(1) - obj.pose(1);
            if gap > 0
                % following car is ahead
                obj.s = gap;
            elseif gap == 0
                % no cars to follow
                obj.s = inf; 
            else
                % following car is behind  !!! ONLY FOR RING-ROAD CASE !!!! 
                obj.s = gap + roadLength;
            end
            
            
            dV = (obj.velocity - obj.Prev.velocity);
            
            
            intelligentBreaking = obj.velocity*obj.timeGap + (obj.velocity*dV)/(2*sqrt(obj.a*obj.b));
            s_star = obj.minimumGap + max(0,intelligentBreaking);
            
            velDif = obj.velocity/obj.targetVelocity;
            if isnan(velDif)
                velDif = 1;
            end
            
            
            a_idm = obj.a*(1 - (velDif)^obj.delta - (s_star/(obj.s-obj.dimension(2)))^2);
           
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

