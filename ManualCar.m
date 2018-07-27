classdef ManualCar < HdmCar
    properties(SetAccess = private)
        bb
        it_accel
        it_cruise_idm
        it_stop_idm
        it_junc_idm
        it_canPassAhead
        it_canPassBehind
        it_canPassAheadNext
        it_isJunctionCrossingTime
        full_tree
    end
    
    methods
        function obj = ManualCar(varargin)
            if nargin == 4
                orientation = varargin{1};
                startPoint = varargin{2};
                Width = varargin{3};
                dt = varargin{4};
            end
            obj = obj@HdmCar(orientation, startPoint, Width,dt);
            
            %-----------------Initialize Blackboard------------------
            obj.bb = BtBlackboard;
            obj.it_accel = obj.bb.add_item('A',obj.acceleration);
            obj.it_cruise_idm = obj.bb.add_item('Acruise',obj.idmAcceleration);
            obj.it_stop_idm = obj.bb.add_item('Astop',obj.idmAcceleration);
            obj.it_junc_idm = obj.bb.add_item('AJunc',obj.idmAcceleration);
            obj.it_canPassAhead = obj.bb.add_item('canPassAhead',false);
            obj.it_canPassBehind = obj.bb.add_item('canPassBehind',false);
            obj.it_canPassAheadNext = obj.bb.add_item('canPassAheadNext',false);
            
            if obj.pose(1) > -40 && obj.pose(1) < obj.s_out && (isempty(obj.Prev) || obj.Prev.pose(1) > obj.s_out || obj.Prev.pose(1) < obj.pose(1))
                obj.it_isJunctionCrossingTime = obj.bb.add_item('isJunctionCrossingTime',true);
            else
                obj.it_isJunctionCrossingTime = obj.bb.add_item('isJunctionCrossingTime',false);
            end
            
            Seq1 = BtSequence(obj.it_canPassBehind == 1, obj.it_canPassAheadNext == 1);
            Sel1 = BtSelector(obj.it_canPassAhead == 1, Seq1);
            
            A1 = BtAssign(obj.it_accel, obj.it_junc_idm);
            Seq2 = BtSequence(Sel1,A1);
            
            A2 = BtAssign(obj.it_accel, obj.it_stop_idm);
            Sel2 = BtSelector(Seq2, A2);
            
            Seq3 = BtSequence(obj.it_isJunctionCrossingTime == 1, Sel2);
            
            A3 = BtAssign(obj.it_accel, obj.it_cruise_idm);
            obj.full_tree = BtSelector(Seq3, A3);
        end
        function decide_acceleration(obj,oppositeRoad,t,dt)
            oppositeCars = oppositeRoad.allCars;
            if oppositeRoad.numCars ~= 0
                
                crossingBegin = obj.s_in;
                crossingEnd = obj.s_out;
                
                obj.it_cruise_idm = obj.bb.add_item('Acruise',obj.idmAcceleration);
                
                obj.modifyIdm(1);
                calculate_idm_accel(obj,oppositeRoad.Length)
                obj.it_junc_idm = obj.bb.add_item('AJunc',obj.idmAcceleration);
                
                calculate_idm_accel(obj,oppositeRoad.Length,1)
                obj.it_stop_idm = obj.bb.add_item('Astop',obj.idmAcceleration);
                
                obj.modifyIdm(0);
                for jCar = 1:oppositeRoad.numCars
                    oppositeDistToJunc(jCar) = crossingEnd - oppositeCars(jCar).pose(1);
                end
                oppositeDistToJunc(oppositeDistToJunc<0) = inf;
                [m, ind] = min(oppositeDistToJunc);
                oppositeCarPose = oppositeCars(ind).pose(1);
                if strcmpi(obj.parentRoad,'horizontal') || t == 0
                    oppositeCarAcceleration = oppositeCars(ind).acceleration;
                    if ~isempty(oppositeCars(ind).Next)
                        oppositeNextCarAcceleration = oppositeCars(ind).Next.acceleration;
                    end
                else
                    oppositeCarAcceleration = oppositeCars(ind).accelerationHistory(oppositeCars(ind).historyIndex-1);
                    if ~isempty(oppositeCars(ind).Next)
                        oppositeNextCarAcceleration = oppositeCars(ind).Next.accelerationHistory(oppositeCars(ind).Next.historyIndex-1);
                    end
                end
                
                T_safe = 0.1;
                pass_ahead_accel = obj.it_junc_idm.get_value;
                cruise_accel = obj.it_cruise_idm.get_value;
                if 0.1 > abs(crossingBegin - obj.pose(1)-0.1) && 0.01 > abs(obj.acceleration)
                    if 0.01 > abs(obj.velocity)
                        t_in_self = (-obj.velocity+sqrt((obj.velocity)^2+2*pass_ahead_accel...
                            *(crossingBegin-obj.pose(1))))/pass_ahead_accel+t;
                        t_out_self = (-obj.velocity+sqrt((obj.velocity)^2+2*pass_ahead_accel...
                            *(crossingEnd-obj.pose(1))))/pass_ahead_accel+t;
                    else
                        t_in_self = (-obj.velocity+sqrt((obj.velocity)^2+2*cruise_accel...
                            *(crossingBegin-obj.pose(1))))/cruise_accel+t;
                        t_out_self = (-obj.velocity+sqrt((obj.velocity)^2+2*cruise_accel...
                            *(crossingEnd-obj.pose(1))))/cruise_accel+t;
                    end
                    
                else
                    t_in_self = (-obj.velocity+sqrt((obj.velocity)^2+2*cruise_accel...
                        *(crossingBegin-obj.pose(1))))/cruise_accel+t;
                    t_out_self = (-obj.velocity+sqrt((obj.velocity)^2+2*cruise_accel...
                        *(crossingEnd-obj.pose(1))))/cruise_accel+t;
                end
                
                if 0.01 < abs(oppositeCarAcceleration)
                    t_in = (-oppositeCars(ind).velocity+sqrt((oppositeCars(ind).velocity)^2+2*oppositeCarAcceleration...
                        *(crossingBegin-oppositeCarPose)))/oppositeCarAcceleration+t-3*T_safe;
                    t_out = (-oppositeCars(ind).velocity+sqrt((oppositeCars(ind).velocity)^2+2*oppositeCarAcceleration...
                        *(crossingEnd-oppositeCarPose)))/oppositeCarAcceleration+t+3*T_safe;
                elseif eps > abs(oppositeCarAcceleration) && eps > oppositeCars(ind).velocity
                    if oppositeCarPose > crossingBegin && oppositeCarPose < crossingEnd
                        t_in = -99999;
                        t_out = 999999;
                    else
                        t_in = 99999;
                        t_out = 99999;
                    end
                else
                    t_in = (crossingBegin - oppositeCarPose)/oppositeCars(ind).velocity+t-3*T_safe;
                    t_out = (crossingEnd - oppositeCarPose)/oppositeCars(ind).velocity+t+3*T_safe;
                end
                
                if ~isempty(oppositeCars(ind).Next) && oppositeCars(ind).Next.pose(1) <= crossingBegin
                    if 0.01 < abs(oppositeNextCarAcceleration)
                        t_in_next = (-oppositeCars(ind).Next.velocity+sqrt((oppositeCars(ind).Next.velocity)^2+2*oppositeNextCarAcceleration...
                            *(crossingBegin-oppositeCars(ind).Next.pose(1))))/oppositeNextCarAcceleration+t-3*T_safe;
                    else
                        t_in_next = (crossingBegin - oppositeCars(ind).Next.pose(1))/oppositeCars(ind).Next.velocity+t-3*T_safe;
                    end
                else
                    t_in_next = inf;
                end
                
                canPassAhead = (t_in > t_out_self);
                obj.it_canPassAhead = obj.bb.add_item('canPassAhead',canPassAhead);
                
                canPassBehind = (t_in_self > t_out);
                obj.it_canPassBehind = obj.bb.add_item('canPassBehind',canPassBehind);
                
                canPassAheadNext = (t_in_next > t_out_self);
                obj.it_canPassAheadNext = obj.bb.add_item('canPassAheadNext',canPassAheadNext);
                
                if obj.pose(1) > -40 && obj.pose(1) < crossingEnd && (isempty(obj.Prev) || obj.Prev.pose(1) > crossingEnd || obj.Prev.pose(1) < obj.pose(1))
                    obj.it_isJunctionCrossingTime = obj.bb.add_item('isJunctionCrossingTime',true);
                else
                    obj.it_isJunctionCrossingTime = obj.bb.add_item('isJunctionCrossingTime',false);
                end
                
                obj.full_tree.tick;
                obj.acceleration =  obj.it_accel.get_value;
                
                %             h5 = figure(5);
                %             plot(obj.full_tree,0);
                
                %             %% add this outside BT
                %             if obj.acceleration < 0 && eps > abs(obj.velocity)
                %                 obj.acceleration = 0;
                %             end
            else
                obj.acceleration = obj.idmAcceleration;
            end
        end
    end
end

