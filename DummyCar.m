classdef DummyCar < IdmCar
    properties
    end
    
    methods
        function obj = DummyCar(varargin)
            if nargin == 3
                orientation = varargin{1};
                startPoint = varargin{2};
                Width = varargin{3};
            end
            obj = obj@IdmCar(orientation, startPoint, Width);
        end
        function decide_acceleration(obj,varargin) 
            oppositeRoad = varargin{1};
            crossingBegin = obj.s_in;
            crossingEnd = obj.s_out;
            if (isempty(obj.Prev) || obj.Prev.pose(1) > crossingBegin || obj.Prev.pose(1) < obj.pose(1) ) && (obj.pose(1) < crossingBegin) && (obj.pose(1) >= -30)
                oppositeCars = oppositeRoad.allCars;
                for jCar = 1:oppositeRoad.numCars
                    if (oppositeCars(jCar).pose(1) > crossingBegin) && (oppositeCars(jCar).pose(1) <= crossingEnd) 
                        calculate_idm_accel(obj,oppositeRoad.Length,1)
                    end
                end
            end
            obj.acceleration = obj.idmAcceleration;
        end
    end
end

