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
        it_dist_to_junc
        it_future_min_stop_gap
        it_future_gap
        it_comf_dist_to_junc
        it_min_stop_dist_to_junc
        it_CarsOpposite
        it_frontCarPassedJunction
        it_backOffTime
        it_currentTime
        it_deadlock
        it_zero
        full_tree
        t_in_self = 0
        t_out_self = 0
        juncExitVelocity = NaN
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
            
            %% -----------------Initialize Blackboard------------------
            obj.bb = BtBlackboard;
            
%             obj.bb.addprop('A');
%             obj.bb.addprop('Afollow');
%             obj.bb.addprop('AemergStop');
%             obj.bb.addprop('AjuncStop');
%             obj.bb.addprop('Aahead');
%             obj.bb.addprop('canPassAhead');
%             obj.bb.addprop('canPassBehind');
%             obj.bb.addprop('distToJunc');
%             obj.bb.addprop('comfDistToJunc');
%             obj.bb.addprop('minStopDistToJunc');
%             obj.bb.addprop('futureMinGap');
%             obj.bb.addprop('futureGap');
%             obj.bb.addprop('CarsOpposite');
%             obj.bb.addprop('backOffTime');
%             obj.bb.addprop('t');
%             obj.bb.addprop('isDeadlock');
%             obj.bb.addprop('Zero');
%             obj.bb.addprop('frontCarPassedJunction');
%             
%             obj.bb.A = obj.acceleration;
%             obj.bb.Afollow = obj.idmAcceleration;
%             obj.bb.AemergStop = obj.idmAcceleration;
%             obj.bb.AjuncStop = obj.idmAcceleration;
%             obj.bb.Aahead = obj.idmAcceleration;
%             obj.bb.canPassAhead = false;
%             obj.bb.canPassBehind = false;
%             obj.bb.distToJunc = 1e5;
%             obj.bb.comfDistToJunc = 0;
%             obj.bb.minStopDistToJunc = 0;
%             obj.bb.futureMinGap = 0;
%             obj.bb.futureGap = 1e5;
%             obj.bb.CarsOpposite = true;
%             obj.bb.backOffTime = 0;
%             obj.bb.t = 0;
%             obj.bb.isDeadlock = 0;
%             obj.bb.Zero = 0;
%             obj.bb.frontCarPassedJunction = 0;
            
            %{ 
            
             followFrontCar = BtSelector(...
                obj.bb.CarsOpposite == 0,...
                obj.bb.distToJunc >= obj.bb.minStopDistToJunc);
            clearedJunction = BtSequence(...
                obj.bb.it_frontCarPassedJunction == 0,...
                followFrontCar);
            CruisePreOrAfterJunction = BtSelector(...
                obj.bb.distToJunc > obj.bb.comfDistToJunc,...
                clearedJunction);
            assignIdm = BtAssign(obj.bb.A, obj.bb.Afollow);
            DoCruise = BtSequence(CruisePreOrAfterJunction,assignIdm);
            
            %% 'Junction' Tree
            % 'Stop at Junction' Tree
            assignJuncStop = BtAssign(obj.bb.A, obj.bb.AjuncStop);
            keepJunctionClear = BtSequence(...
                obj.bb.frontCarPassedJunction == 1,...
                obj.bb.CarsOpposite == 1,...
                obj.bb.futureGap < obj.bb.futureMinGap,...
                assignJuncStop);
            stopBeforeJunction = BtSequence(...
                obj.bb.distToJunc >= obj.bb.minStopDistToJunc,...
                assignJuncStop);
            % 'Cross Behind' Tree
            assignBehind = BtAssign(obj.bb.A,obj.bb.Afollow);
            passBehind = BtSequence(...
                obj.bb.canPassBehind == 1,...
                assignBehind);
            % 'Cross Ahead' Tree
            assignAhead = BtAssign(obj.bb.A, obj.bb.Aahead);
            passAhead = BtSequence(obj.bb.canPassAhead == 1,assignAhead);
            % Choose 'Ahead or Behind' Tree
            selectAheadOrBehind = BtSelector(passAhead,passBehind,stopBeforeJunction);
            %             selectAheadOrBehind = BtSelector(passAhead,passBehind);
            doAheadOrBehind = BtSequence(...
                obj.bb.futureGap > obj.bb.futureMinGap,...
                selectAheadOrBehind);
            
            
            %% 'Emengency Stop' Tree
            assignStop = BtAssign(obj.bb.A, obj.bb.AemergStop);
            
            %% random back-off
            assignZero = BtAssign(obj.bb.A, obj.bb.it_zero);
            backOff = BtSequence(obj.bb.isDeadlock == 1, obj.bb.backOffTime > obj.bb.t,assignZero);
            %% Full Behaviour Tree
            obj.full_tree = BtSelector(DoCruise,keepJunctionClear,backOff,doAheadOrBehind,assignStop);
            %}
           
            obj.it_accel = obj.bb.add_item('A',obj.acceleration);
            obj.it_a_follow = obj.bb.add_item('Afollow',obj.idmAcceleration);
            obj.it_a_emerg_stop = obj.bb.add_item('AemergStop',obj.idmAcceleration);
            obj.it_a_junc_stop = obj.bb.add_item('AjuncStop',obj.idmAcceleration);
            obj.it_a_ahead = obj.bb.add_item('Aahead',obj.idmAcceleration);
            obj.it_canPassAhead = obj.bb.add_item('canPassAhead',false);
            obj.it_canPassBehind = obj.bb.add_item('canPassBehind',false);
            obj.it_dist_to_junc = obj.bb.add_item('distToJunc',1e5);
            obj.it_comf_dist_to_junc = obj.bb.add_item('comfDistToJunc',0);
            obj.it_min_stop_dist_to_junc = obj.bb.add_item('minStopDistToJunc',0);
            obj.it_future_min_stop_gap = obj.bb.add_item('futureMinGap',0);
            obj.it_future_gap = obj.bb.add_item('futureGap',1e5);
            obj.it_CarsOpposite = obj.bb.add_item('CarsOpposite',true);
            obj.it_backOffTime = obj.bb.add_item('backOffTime',0);
            obj.it_currentTime = obj.bb.add_item('t',0);
            obj.it_deadlock = obj.bb.add_item('isDeadlock',0);
            obj.it_zero = obj.bb.add_item('Zero',0);
            obj.it_frontCarPassedJunction = obj.bb.add_item('frontCarPassedJunction',0);
            
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
            assignZero = BtAssign(obj.it_accel, obj.it_zero);
            backOff = BtSequence(obj.it_deadlock == 1,obj.it_backOffTime > obj.it_currentTime,assignZero);
            %% Full Behaviour Tree
            obj.full_tree = BtSelector(DoCruise,keepJunctionClear,backOff,doAheadOrBehind,assignStop);
            %}
            
            
            %% test
            %             obj.full_tree = BtSelector(DoCruise,backOff,selectAheadOrBehind);
            %             obj.full_tree = BtSelector(DoCruise,backOff,selectAheadOrBehind,assignStop);
            
            %             obj.full_tree = BtSelector(DoCruise,backOff,selectAheadOrBehind,assignStop);
%                         figure(5)
%                         tempGraph = gca;
%                         plot(obj.full_tree,tempGraph)
        end
        function decide_acceleration(obj,oppositeRoad,roadLength,t,dt,iIteration)
            
            %% if no cars opposite
            if oppositeRoad.numCars > 0
                oppositeCars = oppositeRoad.allCars;
                crossingBegin = obj.s_in;
                crossingEnd = obj.s_out;
                s = obj.pose(1);
                v = obj.velocity;
                v0 = obj.targetVelocity;
                %% calc and assign self distance to junction
                if s > crossingBegin
                    selfDistToJunc = crossingBegin-s+roadLength;
                else
                    selfDistToJunc = crossingBegin-s;
                end
                
                %% assign junction acceleration
                if s < crossingEnd
                    calculate_junc_accel(obj,roadLength)  ;
                    pass_ahead_accel = obj.juncAccel;
                else
                    pass_ahead_accel = obj.idmAcceleration;
                end
                
                %% Future space gap
                obj.juncExitVelocity = min(obj.maximumVelocity,sqrt(max(0,v^2+2*pass_ahead_accel*(crossingEnd-s))));
                futureMinStopGap = calc_safe_gap(obj.a,obj.b,obj.juncExitVelocity,v0,obj.timeGap,obj.minimumGap,obj.delta,obj.a_min,1)+(obj.minimumGap+obj.dimension(2));
                
                % self t_in and t_out
                [obj.t_in_self, obj.t_out_self] = calculate_t_in_and_out(obj,pass_ahead_accel,v,s,t,roadLength);
                
                if s < crossingEnd  && ~isnan(obj.t_out_self) && obj.Prev.pose(1) ~= s
                    sPrev = obj.Prev.pose(1);
                    vPrev = obj.Prev.velocity;
                    if sPrev > crossingBegin
                        futureGap = (sPrev + vPrev*(obj.t_out_self-(t+dt))) - crossingEnd;
                    elseif sPrev < crossingBegin && sPrev < s
                        futureGap = (sPrev + roadLength + vPrev*(obj.t_out_self-(t+dt))) - crossingEnd;
                    else
                        futureGap = 0;
                    end
                else
                    futureGap = 1e5;
                end
                
                %% Comf stop gap
                if s <= crossingEnd && s >= crossingBegin
                    comfortableStopGap = 1e5;
                else
                    comfortableStopGap = calc_safe_gap(obj.a,obj.b,v,v0,obj.timeGap,0.1,obj.delta,-obj.b)+10;
                end
                
                %% Min stop gap
                minStopDistGapToJunc = calc_safe_gap(obj.a,obj.b,v,v0,obj.timeGap,0,obj.delta,obj.a_min);
                
                %% longic for junc stop
                calculate_junc_accel(obj,roadLength,2)
                juncStop = obj.juncAccel;  
                
                %% logic for emergency stop
                if s < crossingBegin
                    calculate_junc_accel(obj,roadLength,1)
                else
                    calculate_junc_accel(obj,roadLength,3)
                end
                emergStop = obj.juncAccel;  
                
                % get all opposite arm cars' positions
                s_op = oppositeRoad.allCarsStates(1,:);
                
                % convert positions to distances to junction
                oppositeDistToJunc = crossingEnd - s_op;
                
                % inf - passed junction
                oppositeDistToJunc(oppositeDistToJunc<0) = inf;
                [~, ind] = min(oppositeDistToJunc);
                
                % competing car t_in and t_out
                tol_op = 0;
                s_comp = oppositeRoad.allCarsStates(1,ind);
                v_comp = oppositeRoad.allCarsStates(2,ind);
                a_comp = oppositeRoad.allCarsStates(3,ind);
                [t_in_op, t_out_op] = calculate_t_in_and_out(obj,a_comp,v_comp,s_comp,t,oppositeRoad.Length,tol_op);
                
                % next car after competing car t_in and t_out
                s_comp_next = oppositeCars(ind).Next.pose(1);
                v_comp_next = oppositeCars(ind).Next.velocity;
                a_comp_next = oppositeCars(ind).Next.History(4,round(t*10+1));
                [t_in_next, ~] = calculate_t_in_and_out(obj,a_comp_next,v_comp_next,s_comp_next,t,oppositeRoad.Length,tol_op);
                t_in_next(t_in_next== t_in_op) = 1e5;
                
                % 1 - enough gap to go ahead of competing car
                if s > crossingBegin && s < crossingEnd
                    isEnoughGapAhead = 1;
                else
                    isEnoughGapAhead = (t_in_op > obj.t_out_self);
                end
                
                % 1 - enough gap between current leaving and next car entering junction
                isEnoughGapBehind = (obj.t_in_self > t_out_op) && (t_in_next > obj.t_out_self);
                

                
                % 1 - passed, 0 - not passed
                isFrontCarPassedJunction = (obj.Prev.pose(1) == s || obj.Prev.pose(1) > 0.825 || obj.Prev.pose(1) < s);

                %% Update values of the Blackboard
                obj.bb.AemergStop = emergStop;
                obj.bb.AjuncStop = juncStop;
                obj.bb.Aahead = pass_ahead_accel;
                obj.bb.canPassAhead = isEnoughGapAhead;
                obj.bb.canPassBehind = isEnoughGapBehind;
                obj.bb.distToJunc = selfDistToJunc;
                obj.bb.comfDistToJunc = comfortableStopGap;
                obj.bb.minStopDistToJunc = minStopDistGapToJunc;
                obj.bb.futureMinGap = futureMinStopGap;
                obj.bb.futureGap = futureGap;
                obj.bb.CarsOpposite = any(oppositeDistToJunc > 0);
                timeDiff = obj.bb.backOffTime - t;
                % 1 - if both cars stopped; 0 - if either or both move
                if timeDiff < 0
                    if (abs(v) < 0.001 && abs(selfDistToJunc) < 0.6 &&...
                            abs(oppositeCars(ind).velocity) < 0.001 && abs(s_op(ind)-obj.s_in) < 0.6)
                        obj.bb.isDeadlock = 1;
                        obj.bb.backOffTime = t + (randi(21)-1)/10;
                    
                    end
                elseif timeDiff == 0
                    obj.bb.isDeadlock = 0;
                end
                obj.bb.t = t;
                obj.bb.frontCarPassedJunction = isFrontCarPassedJunction;
                

                %                 obj.it_dist_to_junc.set_value(selfDistToJunc);
                %                 obj.it_comf_dist_to_junc.set_value(comfortableStopGap);
                %                 obj.it_frontCarPassedJunction.set_value(isFrontCarPassedJunction);
                %                 obj.it_a_junc_stop.set_value(obj.juncAccel);
                
                %                 obj.it_CarsOpposite.set_value(any(oppositeDistToJunc > 0));
                %                 obj.it_min_stop_dist_to_junc.set_value(minStopDistGapToJunc);
                %                 obj.it_currentTime.set_value(t);
                %                 obj.it_deadlock.set_value(isDeadlock);
                %                 if abs(obj.it_backOffTime.get_value - t) > 0.01
                %                     obj.it_backOffTime.set_value(t + (randi(21)-1)/10);
                %                 end
                %                 obj.it_future_gap.set_value(futureGap);
                %                 obj.it_future_min_stop_gap.set_value(futureMinStopGap);
                %                 obj.it_canPassAhead.set_value(isEnoughGapAhead);
                %                 obj.it_a_ahead.set_value(pass_ahead_accel);
                %                 obj.it_canPassBehind.set_value(isEnoughGapBehind);
            end

            %% Update cruising acceleration
%             obj.it_a_follow.set_value(obj.idmAcceleration);
            obj.bb.Afollow = obj.idmAcceleration;
            
            %% update BT
            obj.full_tree.tick;
%             obj.acceleration =  obj.it_accel.get_value;
            obj.acceleration =  obj.bb.A;
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
            %%
            check_for_negative_velocity(obj,dt);
        end
        function [t_in, t_out] = calculate_t_in_and_out(obj,a,v,s,t,roadLength,varargin)
            
            crossingBegin = obj.s_in;
            crossingEnd = obj.s_out;
            if s > crossingEnd
                s = s - roadLength;
            end
            
            if nargin == 7
                % opposite car time gap
                if obj.tol < abs(v)
                    if (s < crossingBegin || s > crossingBegin)
                        t_in = (crossingBegin - s)/v + t;
                    else
                        t_in = 0;
                    end
                    t_out = (crossingEnd - s)/v + t;
                else
                    t_in = 1e5;
                    t_out = 1e5;
                end
            else
                % self time gap
                if obj.tol < abs(a)
                    if (s < crossingBegin || s > crossingBegin)
                        v_f_in = min(obj.maximumVelocity,sqrt(max(0,v^2 + 2*a*(crossingBegin - s))));
                    else
                        v_f_in = v;
                    end
                    v_f_out = min(obj.maximumVelocity,sqrt(max(0,v^2 + 2*a*(crossingEnd - s))));
                    t_in = (-v + v_f_in)/a + t;
                    t_out = (-v + v_f_out)/a + t;
                elseif obj.tol < abs(a) && obj.tol < abs(v)
                    t_in = (crossingBegin - s)/v + t;
                    t_out = (crossingEnd - s)/v + t;
                else
                    t_in = 1e5;
                    t_out = 1e5;
                end
            end
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
            else
                s = 1e5;
                dV = 1e-5;
            end
            
            intelligentBreaking = obj.velocity*obj.timeGap + (obj.velocity*dV)/(2*sqrt(obj.a_max*obj.b));
            if stop_flag || junc_flag
                s_star = 0.1 + max(0,intelligentBreaking);
            else
                s_star = (obj.minimumGap+obj.dimension(2)) + max(0,intelligentBreaking);
            end
            
            if obj.velocity == 0 && obj.targetVelocity == 0
                obj.juncAccel = -obj.a_max*(s_star/s)^2;
            else
                obj.juncAccel = obj.a_max*(1 - (obj.velocity/obj.targetVelocity)^obj.delta - (s_star/s)^2);
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

