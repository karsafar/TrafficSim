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
                dV = (obj.velocity - 0); 
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
                ss = obj.ownDistfromRearToFront;
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
        function decide_acceleration(obj,oppositeRoad,t,dt)
%             crossingBegin = obj.s_in;
%             crossingEnd = obj.s_out;
%             if (isempty(obj.Prev) || obj.Prev.pose(1)>crossingBegin) && obj.pose(1) <= crossingBegin
%                 oppositeCars = oppositeRoad.allCars;
%                 for jCar = 1:oppositeRoad.numCars
%                     if oppositeCars(jCar).pose(1) > crossingBegin && oppositeCars(jCar).pose(1) < crossingEnd
%                         roadLength = oppositeRoad.endPoint - oppositeRoad.startPoint;
%                         calculate_idm_accel(obj,roadLength,1)    
%                     end
%                 end
% 
%             end
            obj.acceleration = obj.idmAcceleration;
        end
    end
end

