classdef carTypeA < IdmModel
    properties(SetAccess = public)
        bb
        it_accel
        it_a_follow
        it_a_emerg_stop
        it_a_junc_stop
        it_a_ahead
        it_canPassAhead
        it_canPassBehind
        it_canPassAheadNext
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
        it_backOffTime
        it_currentTime
    end
    
    properties (SetAccess = public)
        BT_plot_flag = 0
        juncAccel = 0
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
%             obj.temp_a = obj.a;
            
            %% -----------------Initialize Blackboard------------------
            obj.bb = BtBlackboard;
            obj.it_accel = obj.bb.add_item('A',obj.acceleration);
            obj.it_a_follow = obj.bb.add_item('Afollow',obj.idmAcceleration);
            obj.it_a_emerg_stop = obj.bb.add_item('AemergStop',obj.idmAcceleration);
            obj.it_a_junc_stop = obj.bb.add_item('AjuncStop',obj.idmAcceleration);
            obj.it_a_ahead = obj.bb.add_item('Aahead',obj.idmAcceleration);
            obj.it_canPassAhead = obj.bb.add_item('canPassAhead',false);
            obj.it_canPassBehind = obj.bb.add_item('canPassBehind',false);
            obj.it_canPassAheadNext = obj.bb.add_item('canPassAheadNext',false);
            obj.it_dist_to_junc = obj.bb.add_item('distToJunc',abs(obj.pose(1)-obj.s_in));
            obj.it_comf_dist_to_junc = obj.bb.add_item('comfDistToJunc',0);
            obj.it_min_stop_dist_to_junc = obj.bb.add_item('minStopDistToJunc',0);
            obj.it_future_min_stop_gap = obj.bb.add_item('futureMinGap',0);
            obj.it_future_gap = obj.bb.add_item('futureGap',1e5);
            obj.it_CarsOpposite = obj.bb.add_item('CarsOpposite',true);
            obj.it_backOffTime = obj.bb.add_item('backOffTime',0);
            obj.it_currentTime = obj.bb.add_item('t',0);
            obj.it_frontCarPassedJunction = obj.bb.add_item('frontCarPassedJunction',isempty(obj.Prev) || obj.Prev.pose(1) > 0.825);
            
            %% 'Follow Front Car' Tree
            followFrontCar = BtSelector(...
                obj.it_CarsOpposite == 0,...
                obj.it_dist_to_junc >= obj.it_min_stop_dist_to_junc);
            clearedJunction = BtSequence(...
                obj.it_frontCarPassedJunction == 0,...
                followFrontCar);
            CruisePreOrAfterJunction = BtSelector(...
                obj.it_dist_to_junc > obj.it_comf_dist_to_junc,...
                clearedJunction);
            assignIdm = BtAssign(obj.it_accel, obj.it_a_follow);
            DoCruise = BtSequence(CruisePreOrAfterJunction,assignIdm);
            
            %% 'Junction' Tree
            % 'Stop at Junction' Tree
            assignJuncStop = BtAssign(obj.it_accel, obj.it_a_junc_stop);
            keepJunctionClear = BtSequence(...
                obj.it_frontCarPassedJunction == 1,...
                obj.it_CarsOpposite == 1,...
                obj.it_future_gap < obj.it_future_min_stop_gap,...
                assignJuncStop);
            stopBeforeJunction = BtSequence(...
                obj.it_dist_to_junc >= obj.it_min_stop_dist_to_junc,...
                assignJuncStop);
            % 'Cross Behind' Tree
            assignBehind = BtAssign(obj.it_accel,obj.it_a_follow);
            passBehind = BtSequence(...
                obj.it_canPassBehind == 1,...
                obj.it_canPassAheadNext == 1,...
                assignBehind);
            % 'Cross Ahead' Tree
            assignAhead = BtAssign(obj.it_accel, obj.it_a_ahead);
            passAhead = BtSequence(obj.it_canPassAhead == 1,assignAhead);
            % Choose 'Ahead or Behind' Tree
            selectAheadOrBehind = BtSelector(passAhead,passBehind,stopBeforeJunction);
%             selectAheadOrBehind = BtSelector(passAhead,passBehind);
            doAheadOrBehind = BtSequence(...
                obj.it_future_gap > obj.it_future_min_stop_gap,...
                selectAheadOrBehind);
            
            %% 'Emengency Stop' Tree
            assignStop = BtAssign(obj.it_accel, obj.it_a_emerg_stop);
            
            %% random back-off
            assignZero = BtAssign(obj.it_accel, 0);
            backOff = BtSequence(obj.it_backOffTime > obj.it_currentTime,assignZero);
            %% Full Behaviour Tree
            obj.full_tree = BtSelector(DoCruise,keepJunctionClear,backOff,doAheadOrBehind,assignStop);
% 
%% test
%             obj.full_tree = BtSelector(DoCruise,backOff,selectAheadOrBehind);
%             obj.full_tree = BtSelector(DoCruise,backOff,selectAheadOrBehind,assignStop);

%             obj.full_tree = BtSelector(DoCruise,backOff,selectAheadOrBehind,assignStop);
%             figure(5)
%             tempGraph = gca;
%             plot(obj.full_tree,tempGraph)
        end
        function decide_acceleration(obj,oppositeRoad,roadLength,t,dt)
            oppositeCars = oppositeRoad.allCars;
            
            crossingBegin = obj.s_in;
            crossingEnd = obj.s_out;
            
            %% assign cruising acceleration
            obj.it_a_follow.set_value(obj.idmAcceleration);
            
            %% assign junction acceleration
            if obj.pose(1) < crossingEnd
%                 modifyIdm(obj,obj.temp_a);
                calculate_junc_accel(obj,roadLength)  ;
                pass_ahead_accel = obj.juncAccel;
                % return value of IDM to follow mode with a = 1
%                 modifyIdm(obj,1);
%                 calculate_idm_accel(obj,roadLength);
            else
                pass_ahead_accel = obj.idmAcceleration;
            end
            obj.it_a_ahead.set_value(pass_ahead_accel);
            
            %% calc and assign self distance to junction
           if obj.pose(1) > crossingBegin
                selfDistToJunc = crossingBegin-obj.pose(1)+roadLength;
            else
                selfDistToJunc = crossingBegin-obj.pose(1);
           end
           
           obj.it_dist_to_junc.set_value(selfDistToJunc);
           
            
            %%
            obj.juncExitVelocity = min(obj.maximumVelocity,sqrt(max(0,obj.velocity^2+2*pass_ahead_accel*(crossingEnd-obj.pose(1)))));
            futureMinStopGap = calc_safe_gap(obj.a,obj.b,obj.juncExitVelocity,obj.targetVelocity,obj.timeGap,obj.minimumGap,obj.delta,obj.a_min,1)+obj.minimumGap;
            obj.it_future_min_stop_gap.set_value(futureMinStopGap)
            
            %% update t_in_self and t_out_self
            [obj.t_in_self, obj.t_out_self] = calculate_t_in_and_out(obj,pass_ahead_accel,obj.velocity,obj.pose(1),t,roadLength);
            
            if obj.pose(1) < crossingEnd && ~isempty(obj.Prev) && ~isnan(obj.t_out_self)
                sPrev = obj.Prev.pose(1);
                vPrev = obj.Prev.velocity;
                if sPrev > crossingBegin
                    futureGap = (sPrev + vPrev*(obj.t_out_self-(t+dt))) - crossingEnd;
                elseif sPrev < crossingBegin && sPrev < obj.pose(1)
                    futureGap = (sPrev + roadLength + vPrev*(obj.t_out_self-(t+dt))) - crossingEnd;
                else
                    futureGap = 0;
                end
            else
                futureGap = 1e5;
            end
            obj.it_future_gap.set_value(futureGap)
            
            %%
            if obj.pose(1) <= crossingEnd && obj.pose(1) >= crossingBegin
                comfortableStopGap = 9999;
            else
                comfortableStopGap = calc_safe_gap(obj.a,obj.b,obj.velocity,obj.targetVelocity,obj.timeGap,0.1,obj.delta,-obj.b)+10;
            end
            obj.it_comf_dist_to_junc.set_value(comfortableStopGap);
            
            %%
            minStopDistGapToJunc = calc_safe_gap(obj.a,obj.b,obj.velocity,obj.targetVelocity,obj.timeGap,0,obj.delta,obj.a_min);
            obj.it_min_stop_dist_to_junc.set_value(minStopDistGapToJunc);
            
            %%
            calculate_junc_accel(obj,roadLength,2)
            obj.it_a_junc_stop.set_value(obj.juncAccel);
            
            %% Change this logic for emergency stop
            if obj.pose(1) < crossingBegin
                calculate_junc_accel(obj,roadLength,1)
            else
                calculate_junc_accel(obj,roadLength,3)
            end
            obj.it_a_emerg_stop.set_value(obj.juncAccel);

            %% if no cars opposite
            if oppositeRoad.numCars == 0
                % if no cars on competing arm
                obj.it_CarsOpposite.set_value(0);
                obj.it_canPassAhead.set_value(1);
                obj.it_canPassBehind.set_value(0);
                obj.it_canPassAheadNext.set_value(0);
                
            else

                % get all opposite arm cars' positions
                s_op = oppositeRoad.allCarsStates(1,:);
                
                % convert positions to distances to junction
                oppositeDistToJunc = crossingEnd - s_op;
                
                % '0' - all competing cars passed junction; '1' - not all passed
                obj.it_CarsOpposite.set_value(any(oppositeDistToJunc > 0));
                
                % inf - passed junction
                oppositeDistToJunc(oppositeDistToJunc<0) = inf;
                [~, ind] = min(oppositeDistToJunc);
                
                s_comp = oppositeRoad.allCarsStates(1,ind);
                v_comp = oppositeRoad.allCarsStates(2,ind);
                a_comp = oppositeRoad.allCarsStates(3,ind);
                
%                 tol_op = 0.4;
                tol_op = 0.0;
                [t_in_op, t_out_op] = calculate_t_in_and_out(obj,a_comp,v_comp,s_comp,t,oppositeRoad.Length,tol_op);
                
                if ~isempty(oppositeCars(ind).Next)
                    
                    s_comp_next = oppositeCars(ind).Next.pose(1);
                    v_comp_next = oppositeCars(ind).Next.velocity;
                    %                     a_comp_next = oppositeCars(ind).Next.acceleration;
                    a_comp_next = oppositeCars(ind).Next.History(4,oppositeCars(ind).Next.historyIndex-1);
                    
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

            obj.it_frontCarPassedJunction = obj.bb.add_item('frontCarPassedJunction',...
                (isempty(obj.Prev) || obj.Prev.pose(1) > 0.825 || obj.Prev.pose(1) < obj.pose(1)));

            obj.it_currentTime.set_value(t);
            if abs(obj.velocity)< 0.001 && abs(selfDistToJunc) < 0.1 ...
                    && abs(oppositeCars(ind).velocity)< 0.001 &&...
                    abs(s_op(ind)-obj.s_in) < 0.1 && abs(obj.it_backOffTime.get_value - t) > 0.01
                obj.it_backOffTime.set_value(t + (randi(21)-1)/10);
            end
            
            
            obj.full_tree.tick;
            obj.acceleration =  obj.it_accel.get_value;
            
            %% draw behaviour tree
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
            
            %% print decision data
            
            
            
            
            
            
            check_for_negative_velocity(obj,dt);
        end
        function [t_in, t_out] = calculate_t_in_and_out(obj,a,v,s,t,roadLength,varargin)
            crossingBegin = obj.s_in;
            crossingEnd = obj.s_out;
            
            if nargin == 7
                time_tol = varargin{1};
            else
                time_tol = 0;
            end
            
            if s > crossingEnd
                s = s - roadLength;
            end
          
            v_f_sqr_in = min(obj.maximumVelocity^2,v^2+2*a*(crossingBegin-s));
            v_f_sqr_out = min(obj.maximumVelocity^2,v^2+2*a*(crossingEnd-s));
 %{ 
            if s > crossingBegin && s < crossingEnd
                t_in = 0;
                t_out = (-v+sqrt(v_f_sqr_out))/a+t+time_tol;
            elseif (v_f_sqr_in >= 0 || s > crossingBegin) && v_f_sqr_out >= 0 && obj.tol < abs(a)
                t_in = (-v+sqrt(v_f_sqr_in))/a+t-time_tol;
                t_out = (-v+sqrt(v_f_sqr_out))/a+t+time_tol;
            elseif obj.tol >= abs(a) && obj.tol < abs(v)
                t_in = (crossingBegin - s)/v+t-time_tol;
                t_out = (crossingEnd - s)/v+t+time_tol;
            else
                t_in = 1e5;
                t_out = 1e5;
            end
%}
% %{            
            if nargin == 7
                % opposite car time gap
                if s > crossingBegin && s < crossingEnd
                    t_in = 0;
                    t_out = (crossingEnd - s)/v+t+time_tol;
                elseif obj.tol < abs(v)
                    t_in = (crossingBegin - s)/v+t-time_tol;
                    t_out = (crossingEnd - s)/v+t+time_tol;
                else
                    t_in = 1e5;
                    t_out = 1e5;
                end
            else
                % self time gap
                if s > crossingBegin && s < crossingEnd
                    t_in = 0;
                    t_out = (-v+sqrt(v_f_sqr_out))/a+t+time_tol;
                elseif (v_f_sqr_in >= 0 || s > crossingBegin) && v_f_sqr_out >= 0 && obj.tol < abs(a)
                    t_in = (-v+sqrt(v_f_sqr_in))/a+t-time_tol;
                    t_out = (-v+sqrt(v_f_sqr_out))/a+t+time_tol;
                elseif obj.tol >= abs(a) && obj.tol < abs(v)
                    t_in = (crossingBegin - s)/v+t-time_tol;
                    t_out = (crossingEnd - s)/v+t+time_tol;
                else
                    t_in = 1e5;
                    t_out = 1e5;
                end
            end
%}
     
        end
        function calculate_junc_accel(obj,varargin)
            roadLength = varargin{1};
            if nargin == 2
                stop_flag = 0;
                junc_flag = 0;
                emerg_flag = 0;
            elseif varargin{2} == 1
                stop_flag = 1;
                junc_flag = 0;
                emerg_flag = 0;
            elseif varargin{2} == 2
                junc_flag = 1;
                stop_flag = 0;
                emerg_flag = 0;
            elseif varargin{2} == 3
                stop_flag = 0;
                junc_flag = 0;
                emerg_flag = 1;
            end
            
            if stop_flag ||junc_flag
                s = obj.s_in - obj.pose(1);
                dV = obj.velocity;
            elseif obj.leaderFlag == 0
                s = obj.Prev.pose(1) - obj.pose(1);
                dV = (obj.velocity - obj.Prev.velocity);
            elseif ~isempty(obj.Prev)
                s = obj.Prev.pose(1) - obj.pose(1)+ roadLength;
                dV = (obj.velocity - obj.Prev.velocity);
            else
                s = 1e5;
                dV = 1e-5;
            end
            
            intelligentBreaking = obj.velocity*obj.timeGap + (obj.velocity*dV)/(2*sqrt(obj.a*obj.b));
            if stop_flag || junc_flag
                s_star = 0.1 + max(0,intelligentBreaking);
            else
                s_star = (obj.minimumGap+obj.dimension(2)) + max(0,intelligentBreaking);
            end
            
            if obj.velocity == 0 && obj.targetVelocity == 0
                obj.juncAccel = -obj.a*(s_star/s)^2;
            else
                obj.juncAccel = obj.a*(1 - (obj.velocity/obj.targetVelocity)^obj.delta - (s_star/s)^2);
            end
            
            if obj.juncAccel > obj.a_max
                obj.juncAccel = obj.a_max;
            elseif obj.juncAccel < obj.a_min
                if (emerg_flag == 0 && stop_flag == 0)
                    if obj.juncAccel < obj.a_feas_min
                        obj.juncAccel =  obj.a_feas_min;
                    end
                elseif (emerg_flag || stop_flag)  && obj.juncAccel < obj.a_feas_min
                    obj.juncAccel = -Lennard_Jones(s ,obj.a_feas_min);
                else
                    obj.juncAccel =  obj.a_feas_min;
                end
            end
        end
    end
end

