classdef IdmCar < Car & matlab.mixin.Heterogeneous
    properties (Constant)
        a = 1
        b = 1.5
        delta = 2
        timeGap  = 1.6
        minimumGap = 6
    end
    properties (SetAccess = protected)
        idmAcceleration = NaN
    end
    properties (Access = public)
        leaderFlag = true
        targetVelocity = 8
    end
    
    methods
        function obj = IdmCar(varargin)
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
                s = obj.s_in - obj.pose(1);
                dV = obj.velocity; 
            elseif obj.leaderFlag == 0 
                s = obj.Prev.pose(1) - obj.pose(1);
                dV = (obj.velocity - obj.Prev.velocity);
            elseif ~isempty(obj.Prev)
                s = obj.Prev.pose(1) - obj.pose(1) + roadLength;
                dV = (obj.velocity - obj.Prev.velocity);
            else
                s = Inf;
                dV = 0;
            end
            
            dynamicBehaviour = obj.velocity*obj.timeGap + (obj.velocity*dV)/(2*sqrt(obj.a*obj.b));
            if junc_flag
                ss = dynamicBehaviour;
            elseif dynamicBehaviour > 0
                ss = obj.minimumGap + dynamicBehaviour;
            else
                ss = obj.minimumGap;
            end
            
            obj.idmAcceleration = obj.a*(1 - (obj.velocity/obj.targetVelocity)^obj.delta - (ss/s)^2);
            
            if obj.idmAcceleration > obj.maximumAcceleration(1)
                obj.idmAcceleration = obj.maximumAcceleration(1);
            elseif obj.idmAcceleration < obj.maximumAcceleration(2)
                obj.idmAcceleration =  obj.maximumAcceleration(2);
            end
        end
        function decide_acceleration(obj,varargin)
            obj.acceleration = obj.idmAcceleration;
        end
    end
end

