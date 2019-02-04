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
    end
    
    properties (SetAccess = public)
        BT_plot_flag = 0
        temp_a = 0 % temporary accel for upperIDM
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
            obj.temp_a = obj.a;

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
            if isempty(obj.Prev) || obj.Prev.pose(1) > -1.125
                obj.it_frontCarPassedJunction = obj.bb.add_item('frontCarPassedJunction',true);
            else
                obj.it_frontCarPassedJunction = obj.bb.add_item('frontCarPassedJunction',false);
            end
            

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
            doAheadOrBehind = BtSequence(...
                obj.it_future_gap > obj.it_future_min_stop_gap,...
                selectAheadOrBehind);
            
            %% 'Emengency Stop' Tree
            assignStop = BtAssign(obj.it_accel, obj.it_a_emerg_stop);
            
            %% Full Behaviour Tree
            obj.full_tree = BtSelector(DoCruise,keepJunctionClear,doAheadOrBehind,assignStop);
        end
        function decide_acceleration(obj,oppositeRoad,roadLength,t,dt)
            oppositeCars = oppositeRoad.allCars;
            
            crossingBegin = obj.s_in;
            crossingEnd = obj.s_out;
            tol = 1e-2;
            
            % impatience parameter
            if obj.historyIndex >= 50 && obj.pose(1) <= crossingBegin && tol > abs(obj.velocity) && tol > abs(obj.acceleration) && (obj.temp_a+obj.tol) < obj.a_max &&...
                    (isempty(obj.Prev) || obj.Prev.pose(1) < obj.pose(1) ||  obj.Prev.pose(1)> crossingEnd ) && oppositeRoad.numCars > 0
                obj.temp_a = obj.temp_a + 0.10;
            elseif obj.temp_a ~= 1 && obj.pose(1) > crossingEnd
                obj.temp_a = 1;
            end
            
            %% assign cruising acceleration
            obj.it_a_follow.set_value(obj.idmAcceleration);
            
            %% assign junction acceleration
            if obj.pose(1) < crossingEnd
                modifyIdm(obj,obj.temp_a);
                calculate_idm_accel(obj,roadLength)  ;
                pass_ahead_accel = obj.idmAcceleration;
                % return value of IDM to follow mode with a = 1
                modifyIdm(obj,1);
                calculate_idm_accel(obj,roadLength);
            else
                pass_ahead_accel = obj.idmAcceleration;
            end
            obj.it_a_ahead.set_value(pass_ahead_accel);

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
            futureMinStopGap = calc_safe_gap(obj.a,obj.b,obj.juncExitVelocity,obj.targetVelocity,obj.timeGap,obj.minimumGap,obj.delta,obj.a_min,1)+obj.minimumGap;
            obj.it_future_min_stop_gap.set_value(futureMinStopGap)
           
            %% update t_in_self and t_out_self
            [obj.t_in_self, obj.t_out_self] = calculate_t_in_and_out(obj,pass_ahead_accel,obj.velocity,obj.pose(1),t,roadLength);
            
            if obj.pose(1) < crossingEnd && ~isempty(obj.Prev) && ~isnan(obj.t_out_self)
                sPrev = obj.Prev.pose(1);
                vPrev = obj.Prev.velocity;
              %  aPrev = obj.Prev.acceleration;
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
            comfortableStopGap = calc_safe_gap(obj.a,obj.b,obj.velocity,obj.targetVelocity,obj.timeGap,0.1,obj.delta,-obj.b)+10;
            obj.it_comf_dist_to_junc.set_value(comfortableStopGap);
            
            %%
            minStopDistGapToJunc = calc_safe_gap(obj.a,obj.b,obj.velocity,obj.targetVelocity,obj.timeGap,0,obj.delta,obj.a_min);
            obj.it_min_stop_dist_to_junc.set_value(minStopDistGapToJunc);
            
            %%
            calculate_idm_accel(obj,roadLength,2)
            obj.it_a_junc_stop.set_value(obj.idmAcceleration);
            
            %% Change this logic for emergency stop
            if obj.pose(1) < crossingBegin
                calculate_idm_accel(obj,roadLength,1)
                obj.it_a_emerg_stop.set_value(obj.idmAcceleration);
            else
                calculate_idm_accel(obj,roadLength,3)
                obj.it_a_emerg_stop.set_value(obj.idmAcceleration);
            end
            %% if no cars opposite
            if oppositeRoad.numCars == 0
                % if no cars on competing arm
                notAllCarsPassedJunction = false;
                
                obj.it_canPassAhead.set_value(1);
                obj.it_canPassBehind.set_value(0);
                obj.it_canPassAheadNext.set_value(0);
            else
%                 oppositeDistToJunc = NaN(1,oppositeRoad.numCars);
%                 for jCar = 1:numel(oppositeDistToJunc)
%                     s_op = oppositeCars(jCar).pose(1);
%                     oppositeDistToJunc(jCar) = crossingEnd - s_op;
%                 end
                s_op = [ oppositeCars(:).pose];
                s_op(:,2:2:end) = [];
                oppositeDistToJunc = crossingEnd - s_op;
                % 0 - all competing cars passed junction 1 - not all passed
                notAllCarsPassedJunction = any(oppositeDistToJunc > 0);
                
                % inf - passed junction
                oppositeDistToJunc(oppositeDistToJunc<0) = inf;
                [~, ind] = min(oppositeDistToJunc);                

                s_comp = oppositeCars(ind).pose(1);
                v_comp = oppositeCars(ind).velocity;
                a_comp = oppositeCars(ind).acceleration;
                
                tol_op = 0.4;
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
            obj.it_CarsOpposite.set_value(notAllCarsPassedJunction);
            
            if isempty(obj.Prev) || obj.Prev.pose(1) > -1.125 || obj.Prev.pose(1) < obj.pose(1)
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
    end
end

