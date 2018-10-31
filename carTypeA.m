classdef carTypeA < IdmModel
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
        it_future_min_stop_gap
        it_future_gap
        it_comf_dist_to_junc
        it_min_stop_dist_to_junc
        full_tree
        t_in_self = 0
        t_out_self = 0
        it_CarsOpposite
        it_frontCarPassedJunction
        juncExitVelocity = NaN
    end
    properties (SetAccess = public)
        BT_plot_flag = 0
    end
    methods
        function obj = carTypeA(varargin)
            if nargin == 4
                orientation = varargin{1};
                startPoint = varargin{2};
                Width = varargin{3};
                dt = varargin{4};
            end
            obj = obj@IdmModel(orientation, startPoint, Width,dt);
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
            obj.it_min_stop_dist_to_junc = obj.bb.add_item('minStopDistToJunc',0);
            obj.it_future_min_stop_gap = obj.bb.add_item('futureMinGap',0);
            obj.it_future_gap = obj.bb.add_item('futureGap',1e5);
            obj.it_CarsOpposite = obj.bb.add_item('CarsOpposite',true);
%             obj.it_pose = obj.bb.add_item('pose',obj.pose(1));
%             obj.it_s_out = obj.bb.add_item('Sout',obj.s_out);
            
            if isempty(obj.Prev) || obj.Prev.pose(1) > -1.125
                obj.it_frontCarPassedJunction = obj.bb.add_item('frontCarPassedJunction',true);
            else
                obj.it_frontCarPassedJunction = obj.bb.add_item('frontCarPassedJunction',false);
            end
            
            assignBehind = BtAssign(obj.it_accel,obj.it_cruise_idm);
            
            
            passBehind = BtSequence(...
                obj.it_canPassBehind == 1,...
                obj.it_canPassAheadNext == 1,...
                assignBehind);
            assignAhead = BtAssign(obj.it_accel, obj.it_junc_idm);
            passAhead = BtSequence(obj.it_canPassAhead == 1,assignAhead);
            selectAheadOrBehind = BtSelector(passAhead,passBehind);
            doAheadOrBehind = BtSequence(...
                obj.it_future_gap > obj.it_future_min_stop_gap,...
                selectAheadOrBehind);
            
            assignStop = BtAssign(obj.it_accel, obj.it_stop_idm);
            doEmergencyStop = BtSequence(...
                obj.it_dist_to_junc >= obj.it_min_stop_dist_to_junc,...
                assignStop);
            
            assignIdm = BtAssign(obj.it_accel, obj.it_cruise_idm);
            
            cruisepreOrAfterJunction = BtSequence(obj.it_dist_to_junc > obj.it_comf_dist_to_junc,assignIdm);
            stopBeforeJunction = BtSequence(...
                obj.it_frontCarPassedJunction == 1,...
                obj.it_future_gap < obj.it_future_min_stop_gap,...
                assignStop);
            followFrontCar = BtSelector(...
                obj.it_CarsOpposite == 0,...
                obj.it_dist_to_junc >= obj.it_min_stop_dist_to_junc);
            doIdm = BtSequence(...
                obj.it_frontCarPassedJunction == 0,...
                followFrontCar,...
                assignIdm);
            
            obj.full_tree = BtSelector(cruisepreOrAfterJunction,stopBeforeJunction,doIdm,doAheadOrBehind,doEmergencyStop);
        end
        function decide_acceleration(obj,oppositeRoad,roadLength,t,dt)
            oppositeCars = oppositeRoad.allCars;
            
            crossingBegin = obj.s_in;
            crossingEnd = obj.s_out;
            tol = 1e-2;
            
            % impatience parameter
            if obj.historyIndex >= 50 && obj.pose(1) <= crossingBegin && tol > abs(obj.velocity) && tol > abs(obj.acceleration) && obj.a < 5.95 &&...
                    (isempty(obj.Prev) || obj.Prev.pose(1) < obj.pose(1) ||  obj.Prev.pose(1)> crossingEnd ) && oppositeRoad.numCars > 0
                obj.a = obj.a + 0.05;
                obj.a_max = 6;
            elseif obj.a ~= 1 && obj.pose(1) > crossingEnd
                obj.a = 1;
                obj.a_max = 3.5;
            end
            
            %% assign cruising acceleration
            obj.it_cruise_idm.set_value(obj.idmAcceleration);
            
            %% assign junction acceleration
            calculate_idm_accel(obj,roadLength)            
            if obj.pose(1) > crossingBegin && obj.pose(1) < crossingEnd
                obj.it_junc_idm.set_value(obj.acceleration);
                pass_ahead_accel = obj.acceleration;
            else
                obj.it_junc_idm.set_value(obj.idmAcceleration);
                pass_ahead_accel = obj.idmAcceleration;
            end
            
            %% calc and assign self distance to junction
            if obj.pose(1) > crossingBegin
                if obj.pose(1) <= crossingEnd
                    obj.it_dist_to_junc.set_value(0);
                else
                    obj.it_dist_to_junc.set_value(abs(min(0,obj.pose(1)-crossingBegin-roadLength)));
                end
            else
                obj.it_dist_to_junc.set_value(abs(min(0,obj.pose(1)-crossingBegin)));
            end
            
            %% 
            obj.juncExitVelocity = min(obj.maximumVelocity,sqrt(max(0,obj.velocity^2+2*pass_ahead_accel*(crossingEnd-obj.pose(1)))));
            futureMinStopGap = calc_safe_gap(obj.a,obj.b,obj.juncExitVelocity,obj.targetVelocity,obj.timeGap,obj.minimumGap,obj.delta,obj.a_min,1);
            obj.it_future_min_stop_gap.set_value(futureMinStopGap)
           
            %% update t_in_self and t_out_self
            [obj.t_in_self, obj.t_out_self] = calculate_t_in_and_out(obj,pass_ahead_accel,obj.velocity,obj.pose(1),t,roadLength);
            
            if obj.pose(1) < crossingEnd && ~isempty(obj.Prev) && ~isnan(obj.t_out_self)
                sPrev = obj.Prev.pose(1);
                vPrev = obj.Prev.velocity;
                aPrev = obj.Prev.acceleration;
                if sPrev > crossingEnd
                    futureGap = (sPrev + vPrev*(obj.t_out_self-(t+dt)) + 0.5*aPrev*(obj.t_out_self-(t+dt))^2) - crossingEnd;
                elseif sPrev < crossingBegin && sPrev < obj.pose(1)
                    futureGap = (sPrev + roadLength + vPrev*(obj.t_out_self-(t+dt)) + 0.5*aPrev*(obj.t_out_self-(t+dt))^2) - crossingEnd;
                else
                    futureGap = 0;
                end
            else
                futureGap = 1e5;
            end
            obj.it_future_gap.set_value(futureGap)
            
            %%
            comfortableStopGap = calc_safe_gap(obj.a,obj.b,obj.velocity,obj.targetVelocity,obj.timeGap,0.1,obj.delta,-obj.b)+10;
            obj.it_comf_dist_to_junc.set_value(comfortableStopGap);
            
            %%
            minStopDistGapToJunc = calc_safe_gap(obj.a,obj.b,obj.velocity,obj.targetVelocity,obj.timeGap,0,obj.delta,obj.a_min);
            obj.it_min_stop_dist_to_junc.set_value(minStopDistGapToJunc);
            
            %%
            calculate_idm_accel(obj,roadLength,1)
            obj.it_stop_idm.set_value(obj.idmAcceleration);
            
            %% if no cars opposite
            if oppositeRoad.numCars == 0
                % if no cars on competing arm
                notAllCarsPassedJunction = false;
                
                obj.it_canPassAhead.set_value(1);
                obj.it_canPassBehind.set_value(0);
                obj.it_canPassAheadNext.set_value(0);
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

                s_comp = oppositeCars(ind).pose(1);
                v_comp = oppositeCars(ind).velocity;
                a_comp = oppositeCars(ind).acceleration;
                
                tol_op = 0.2;
                [t_in_op, t_out_op] = calculate_t_in_and_out(obj,a_comp,v_comp,s_comp,t,oppositeRoad.Length,tol_op);

                if ~isempty(oppositeCars(ind).Next)
                    
                    s_comp_next = oppositeCars(ind).Next.pose(1);
                    v_comp_next = oppositeCars(ind).Next.velocity;
                    a_comp_next = oppositeCars(ind).Next.acceleration;
                    
                    [t_in_next, ~] = calculate_t_in_and_out(obj,a_comp_next,v_comp_next,s_comp_next,t,oppositeRoad.Length,tol_op);
                else
                    t_in_next = 1e5;
                end
                if obj.pose(1) > crossingBegin && obj.pose(1) < crossingEnd
                    canPassAhead = 1;
                else
                    canPassAhead = (t_in_op > obj.t_out_self);
                end
                obj.it_canPassAhead.set_value(canPassAhead);
                
                canPassBehind = (obj.t_in_self > t_out_op);
                obj.it_canPassBehind.set_value(canPassBehind);
                
                canPassAheadNext = (t_in_next > obj.t_out_self);
                obj.it_canPassAheadNext.set_value(canPassAheadNext);
            end
            
            %%
           % obj.it_pose.set_value(obj.pose(1));
            
            obj.it_CarsOpposite.set_value(notAllCarsPassedJunction);
            
            if isempty(obj.Prev) || obj.Prev.pose(1) > -1.125 || obj.Prev.pose(1) < obj.pose(1)
                frontCarValue = true;
            else
                frontCarValue = false;
            end
            obj.it_frontCarPassedJunction.set_value(frontCarValue);
            
            obj.full_tree.tick;
            obj.acceleration =  obj.it_accel.get_value;
            
                
%             if obj.pose(1) > -8 && obj.pose(1) < crossingEnd
%                 obj.BT_plot_flag = 1;
%             else
%                 obj.BT_plot_flag = 0;
%             end

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
            
            % reduce speed before the junction
            if abs(obj.pose(1)-crossingBegin) < comfortableStopGap && obj.targetVelocity ~= 6 && obj.pose(1) < crossingEnd && frontCarValue == 0
                obj.targetVelocity = 6;
            elseif obj.targetVelocity == 6 && obj.pose(1) > crossingEnd
                obj.targetVelocity = 13;
            end
        end
        function [t_in, t_out] = calculate_t_in_and_out(obj,a,v,s,t,roadLength,varargin)
            s_in = obj.s_in;
            s_out = obj.s_out;
            
            if nargin == 7
                time_tol = varargin{1};
            else
                time_tol = 0;
            end
            
            if s > obj.s_out
                s = s - roadLength;
            end
            
            
            v_f_sqr_in = min(obj.maximumVelocity^2,v^2+2*a*(s_in-s));
            v_f_sqr_out = min(obj.maximumVelocity^2,v^2+2*a*(s_out-s));
            
            if (v_f_sqr_in >=0 || s > s_in) && v_f_sqr_out >= 0 && obj.tol < abs(a)
                if s > s_in
                    t_in = 0;
                else
                    t_in = (-v+sqrt(v_f_sqr_in))/a+t-time_tol;
                end
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

