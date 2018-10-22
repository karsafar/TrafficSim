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
        it_dist_to_junc
        it_future_emerg_gap
        it_future_gap
        it_comf_dist_to_junc
        it_emerg_dist_to_junc
        full_tree
        t_in_self = 0
        t_out_self = 0
        it_CarsOpposite
        it_pose
        it_frontCarPassedJunction
        juncExitVelocity = NaN
    end
    properties (SetAccess = public)
        BT_plot_flag = 0
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
            obj.priority = 1;
            
            %-----------------Initialize Blackboard------------------
            obj.bb = BtBlackboard;
            obj.it_accel = obj.bb.add_item('A',obj.acceleration);
            obj.it_cruise_idm = obj.bb.add_item('Acruise',obj.idmAcceleration);
            obj.it_stop_idm = obj.bb.add_item('Astop',obj.idmAcceleration);
            obj.it_junc_idm = obj.bb.add_item('AJunc',obj.idmAcceleration);
            obj.it_canPassAhead = obj.bb.add_item('canPassAhead',false);
            obj.it_canPassBehind = obj.bb.add_item('canPassBehind',false);
            obj.it_canPassAheadNext = obj.bb.add_item('canPassAheadNext',false);
            obj.it_dist_to_junc = obj.bb.add_item('distToJunc',abs(obj.pose(1)-obj.s_in));
            obj.it_comf_dist_to_junc = obj.bb.add_item('comfDistToJunc',0);
            obj.it_emerg_dist_to_junc = obj.bb.add_item('emergDistToJunc',0);
            obj.it_future_emerg_gap = obj.bb.add_item('futureEmergGap',0);
            obj.it_future_gap = obj.bb.add_item('futureGap',1e5);
            obj.it_CarsOpposite = obj.bb.add_item('CarsOpposite',true);
            obj.it_pose = obj.bb.add_item('pose',obj.pose(1));
            
            if isempty(obj.Prev) || obj.Prev.pose(1) > obj.s_out
                obj.it_frontCarPassedJunction = obj.bb.add_item('frontCarPassedJunction',true);
            else
                obj.it_frontCarPassedJunction = obj.bb.add_item('frontCarPassedJunction',false);
            end
            
            assignBehind = BtAssign(obj.it_accel,obj.acceleration);
            passBehind = BtSequence(...
                obj.it_future_gap > obj.it_future_emerg_gap,...
                obj.it_canPassBehind == 1,...
                obj.it_canPassAheadNext == 1,...
                assignBehind);
            assignAhead = BtAssign(obj.it_accel, obj.it_junc_idm);
            passAhead = BtSequence(...
                obj.it_future_gap > obj.it_future_emerg_gap,...
                obj.it_canPassAhead == 1,assignAhead);
            
            assignStop = BtAssign(obj.it_accel, obj.it_stop_idm);
            doEmergencyStop = BtSequence(obj.it_dist_to_junc >= obj.it_emerg_dist_to_junc,assignStop);
            doJunctionAvoid = BtSelector(passAhead,passBehind,doEmergencyStop);
            
            assignIdm = BtAssign(obj.it_accel, obj.it_cruise_idm);
            
            cruiseOutsideJunction = BtSequence(...
                obj.it_dist_to_junc > obj.it_comf_dist_to_junc,...
                obj.it_pose > obj.s_out,...
                assignIdm);
            stopBeforeJunction = BtSequence(...
                obj.it_frontCarPassedJunction == 1,...
                obj.it_future_gap < obj.it_future_emerg_gap,...
                assignStop);
            followFrontCar = BtSelector(obj.it_CarsOpposite == 0,obj.it_dist_to_junc >= obj.it_emerg_dist_to_junc);
            doIdm = BtSequence(obj.it_frontCarPassedJunction == 0,followFrontCar,assignIdm);

            doCruiseIdm = BtSelector(cruiseOutsideJunction,stopBeforeJunction,doIdm);
            
            obj.full_tree = BtSelector(doCruiseIdm, doJunctionAvoid);
        end
        function decide_acceleration(obj,oppositeRoad,roadLength,t,dt)
            oppositeCars = oppositeRoad.allCars;
            
            crossingBegin = obj.s_in;
            crossingEnd = obj.s_out;
            tol = 1e-2;
            
            % impatience parameter
            if obj.historyIndex >= 50 && obj.pose(1) <= crossingBegin && tol > abs(obj.velocity) && tol > abs(obj.acceleration) && obj.a < 6 &&...
                    (isempty(obj.Prev) || obj.Prev.pose(1) < obj.pose(1) ||  obj.Prev.pose(1)> crossingEnd )
                obj.a = obj.a + 0.05;
                obj.maximumAcceleration(1) = 6;
            elseif obj.a ~= 1 && obj.pose(1) > crossingEnd
                obj.a = 1;
                obj.maximumAcceleration(1) = 3.5;
            end
            
            obj.it_cruise_idm.set_value(obj.idmAcceleration);
            
            calculate_idm_accel(obj,roadLength)
            obj.it_junc_idm.set_value(obj.idmAcceleration);
            
            pass_ahead_accel = obj.idmAcceleration;
            
            if obj.pose(1) > obj.s_in
                obj.it_dist_to_junc.set_value(abs(min(0,obj.pose(1)-obj.s_in-roadLength)));
            else
                obj.it_dist_to_junc.set_value(abs(min(0,obj.pose(1)-obj.s_in)));
            end
            
            %%
            obj.juncExitVelocity = min(obj.maximumVelocity,sqrt(max(0,obj.velocity^2+2*pass_ahead_accel*(obj.s_out-obj.pose(1)))));
            futureEmergencyStopGap = calc_safe_gap(obj.a,obj.b,obj.juncExitVelocity,obj.targetVelocity,obj.timeGap,obj.minimumGap,obj.delta,obj.maximumAcceleration(2),1);
            obj.it_future_emerg_gap.set_value(futureEmergencyStopGap)
            [~, t_out_self_ahead] = calculate_t_in_and_out(obj,pass_ahead_accel,obj.velocity,obj.pose(1),t);
            if obj.pose(1) < obj.s_out && ~isempty(obj.Prev) && ~isnan(obj.t_out_self)
                if obj.Prev.pose(1) > 0
                    futureGap = obj.Prev.pose(1) + obj.Prev.velocity*(t_out_self_ahead-(t+dt)) + 0.5*obj.Prev.acceleration*(t_out_self_ahead-(t+dt))^2 - obj.s_out;
                elseif obj.Prev.pose(1) < 0
                    futureGap = obj.Prev.pose(1) + roadLength + obj.Prev.velocity*(t_out_self_ahead-(t+dt)) + 0.5*obj.Prev.acceleration*(t_out_self_ahead-(t+dt))^2 - obj.s_out;
                end
            elseif ~isempty(obj.Prev)
                futureGap = obj.Prev.pose(1) + obj.Prev.velocity*dt + 0.5*obj.Prev.acceleration*dt^2 - obj.s_out;
            else
                futureGap = 1e5;
            end
            obj.it_future_gap.set_value(futureGap)
            
            %%
            comfortableStopGap = calc_safe_gap(obj.a,obj.b,obj.velocity,obj.targetVelocity,obj.timeGap,0.1,obj.delta,-obj.b)+10;
            obj.it_comf_dist_to_junc.set_value(comfortableStopGap);
            
            %%
            emergencyStopGap = calc_safe_gap(obj.a,obj.b,obj.velocity,obj.targetVelocity,obj.timeGap,0,obj.delta,obj.maximumAcceleration(2));
            obj.it_emerg_dist_to_junc.set_value(emergencyStopGap);
            %%
            calculate_idm_accel(obj,roadLength,1)
            obj.it_stop_idm.set_value(obj.idmAcceleration);
            
            
            if oppositeRoad.numCars == 0
                % if no cars on competing arm
                notAllCarsPassedJunction = false;
            else
                oppositeDistToJunc = NaN(1,oppositeRoad.numCars);
                for jCar = 1:numel(oppositeDistToJunc)
                    oppositeDistToJunc(jCar) = crossingEnd - oppositeCars(jCar).pose(1);
                end
                
                % 0 - all competing cars passed junction 1 - not all passed
                notAllCarsPassedJunction = any(oppositeDistToJunc > 0);
                
                % inf - passed junction
                oppositeDistToJunc(oppositeDistToJunc<0) = inf;
                
                [~, ind] = min(oppositeDistToJunc);
                oppositeCarPose = oppositeCars(ind).pose(1);
                
                
                if strcmpi(obj.parentRoad,'horizontal') || t == 0
                    oppositeCarAcceleration = oppositeCars(ind).acceleration;
                    if ~isempty(oppositeCars(ind).Next)
                        oppositeNextCarAcceleration = oppositeCars(ind).Next.acceleration;
                    end
                else
                    % what is this stuff?????
                    oppositeCarAcceleration = oppositeCars(ind).accelerationHistory(oppositeCars(ind).historyIndex-1);
                    if ~isempty(oppositeCars(ind).Next)
                        oppositeNextCarAcceleration = oppositeCars(ind).Next.accelerationHistory(oppositeCars(ind).Next.historyIndex-1);
                    end
                end
                
                [t_in_op, t_out_op] = calculate_t_in_and_out(obj,oppositeCarAcceleration,oppositeCars(ind).velocity,oppositeCarPose,t);
                
                [t_in_next, ~] = calculate_t_in_and_out(obj,oppositeNextCarAcceleration,oppositeCars(ind).Next.velocity,oppositeCars(ind).Next.pose(1),t);                
                
                canPassAhead = (t_in_op > t_out_self_ahead);
                obj.it_canPassAhead.set_value(canPassAhead);
                
                canPassBehind = (obj.t_in_self > t_out_op);
                obj.it_canPassBehind.set_value(canPassBehind);
                
                canPassAheadNext = (t_in_next > obj.t_out_self);
                obj.it_canPassAheadNext.set_value(canPassAheadNext);
               
            end
            
            obj.it_pose.set_value(obj.pose(1));
            
            obj.it_CarsOpposite.set_value(notAllCarsPassedJunction);
            
            if isempty(obj.Prev) || obj.Prev.pose(1) > crossingEnd || obj.Prev.pose(1) < obj.pose(1)
                frontCarValue = true;
            else
                frontCarValue = false;
            end
            obj.it_frontCarPassedJunction.set_value(frontCarValue);
            
            obj.full_tree.tick;
            obj.acceleration =  obj.it_accel.get_value;
            
            % draw behaviour tree
            if obj.BT_plot_flag
                tempGraph = gca;
                if isempty(tempGraph.Parent.Number) || tempGraph.Parent.Number ~= 5
                    figure(5)
                else
                    clf(tempGraph.Parent)
                end
                plot(obj.full_tree,tempGraph)
                obj.bb
            end
            
            % check for negative velocities
            check_for_negative_velocity(obj,dt);
            
            % update t_in_self and t_out_self
            [obj.t_in_self, obj.t_out_self] = calculate_t_in_and_out(obj,obj.acceleration,obj.velocity,obj.pose(1),t);
            
            % reduce speed before the junction
            if abs(obj.pose(1)-obj.s_in) < comfortableStopGap && obj.targetVelocity ~= 6 && obj.pose(1) < obj.s_out && frontCarValue == 0
                obj.targetVelocity = 6;
            elseif obj.targetVelocity == 6 && obj.pose(1) > obj.s_out
                obj.targetVelocity = 13;
            end
        end
        function [t_in, t_out] = calculate_t_in_and_out(obj,a,v,s,t)
            s_in = obj.s_in;
            s_out = obj.s_out;
            time_tol = 0.1;
            
            v_f_sqr_in = v^2+2*a*(s_in-s);
            v_f_sqr_out = v^2+2*a*(s_out-s);
            
            if v_f_sqr_in >=0 && v_f_sqr_out >= 0 && obj.tol < abs(a)
                t_in = (-v+sqrt(v_f_sqr_in))/a+t-time_tol;
                t_out = (-v+sqrt(v_f_sqr_out))/a+t+time_tol;
            elseif obj.tol >= abs(a) && obj.tol < abs(v)
                t_in = (s_in - s)/v+t-time_tol;
                t_out = (s_out - s)/v+t+time_tol;
            else
                t_in = 1e5;
                t_out = 1e5;
            end
        end
    end
end

