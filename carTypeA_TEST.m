classdef carTypeA_TEST < IdmModel
    properties(SetAccess = public)
        bb
        
        bbStore = []
        
        cond1
        cond2
%         followFrontCar
        cond3
%         clearedJunction
        cond4
%         CruisePreOrAfterJunction
        act1
%         DoCruise
        
        
%         assignJuncStop
        cond5
        cond6
        cond7
%         keepJunctionClear
        
%         assignJuncStop1
        cond8
%         stopBeforeJunction
        
%         assignBehind
        cond9
%         passBehind
        
%         assignAhead
        cond10
%         passAhead
        
%         selectAheadOrBehind
        cond11
%         doAheadOrBehind
        
%         assignStop
        
%         assignZero
        cond12
        cond13
%         backOff

        actStore
        full_select
        Fig = []
        
        t_in_self = 0
        t_out_self = 0
        juncExitVelocity = NaN
    end
    
    properties (SetAccess = public)
        BT_plot_flag = 0
        juncAccel = 0
    end
    methods
        function obj = carTypeA_TEST(varargin)
            if nargin == 4
                orientation = varargin{1};
                startPoint = varargin{2};
                Width = varargin{3};
                dt = varargin{4};
            end
            obj = obj@IdmModel(orientation, startPoint, Width,dt);
            obj.priority = 1;
            
            %% -----------------Initialize Blackboard------------------
            obj.bb = BlackBoard;
            obj.bb.add_item('A',obj.acceleration);
            obj.bb.add_item('Afollow',obj.idmAcceleration);
            obj.bb.add_item('AemergStop',obj.idmAcceleration);
            obj.bb.add_item('AjuncStop',obj.idmAcceleration);
            obj.bb.add_item('Aahead',obj.idmAcceleration);
            obj.bb.add_item('canPassAhead',false);
            obj.bb.add_item('canPassBehind',false);
            obj.bb.add_item('distToJunc',1e5);
            obj.bb.add_item('comfDistToJunc',0);
            obj.bb.add_item('minStopDistToJunc',0);
            obj.bb.add_item('futureMinGap',0);
            obj.bb.add_item('futureGap',1e5);
            obj.bb.add_item('CarsOpposite',true);
            obj.bb.add_item('backOffTime',0);
            obj.bb.add_item('t',0);
            obj.bb.add_item('isDeadlock',0);
            obj.bb.add_item('Zero',0);
            obj.bb.add_item('frontCarPassedJunction',0);
            
            %% 'Follow Front Car' Tree
            obj.cond1 = ConditionNode(obj.bb.CarsOpposite == 0,'CarsOpposite == 0');
            obj.cond2 = ConditionNode(obj.bb.distToJunc >= obj.bb.minStopDistToJunc,'distToJunc >= minStopDistToJunc');
            followFrontCar = SelectorNode([obj.cond1,obj.cond2],obj.bb);
            
            obj.cond3 = ConditionNode(obj.bb.frontCarPassedJunction == 0,'frontCarPassedJunction == 0');
            clearedJunction = SequenceNode([obj.cond3,followFrontCar],obj.bb);
            
            obj.cond4 = ConditionNode(obj.bb.distToJunc > obj.bb.comfDistToJunc,'distToJunc > comfDistToJunc');
            CruisePreOrAfterJunction = SelectorNode([obj.cond4,clearedJunction],obj.bb);
            
            
            act1 = ActionNode('A','Afollow',obj.bb);
            DoCruise = SequenceNode([CruisePreOrAfterJunction, act1],obj.bb);
            %% 'Junction' Tree
            % 'Stop at Junction' Tree
            assignJuncStop = ActionNode('A','AjuncStop',obj.bb);
            obj.cond5 = ConditionNode(obj.bb.frontCarPassedJunction == 1,'frontCarPassedJunction == 1');
            obj.cond6 = ConditionNode(obj.bb.CarsOpposite == 1,'CarsOpposite == 1');
            obj.cond7 = ConditionNode(obj.bb.futureGap < obj.bb.futureMinGap,'futureGap < futureMinGap');
            
            keepJunctionClear = SequenceNode([obj.cond5, obj.cond6,obj.cond7, assignJuncStop],obj.bb);
            
            assignJuncStop1 = ActionNode('A','AjuncStop',obj.bb);
            obj.cond8 = ConditionNode(obj.bb.distToJunc >= obj.bb.minStopDistToJunc,'distToJunc >= minStopDistToJunc');
            stopBeforeJunction = SequenceNode([obj.cond8, assignJuncStop1],obj.bb);
            
            % 'Cross Behind' Tree
            assignBehind =  ActionNode('A','Afollow',obj.bb);
            obj.cond9 = ConditionNode(obj.bb.canPassBehind == 1,'canPassBehind == 1');
            passBehind = SequenceNode([obj.cond9, assignBehind],obj.bb);
            
            % 'Cross Ahead' Tree
            assignAhead =  ActionNode('A','Aahead',obj.bb);
            obj.cond10 = ConditionNode(obj.bb.canPassAhead == 1,'canPassAhead == 1');
            passAhead = SequenceNode([obj.cond10, assignAhead],obj.bb);
            
            % Choose 'Ahead or Behind' Tree
            selectAheadOrBehind = SelectorNode([passAhead,passBehind,stopBeforeJunction],obj.bb);
            
            obj.cond11 = ConditionNode(obj.bb.futureGap >= obj.bb.futureMinGap,'futureGap >= futureMinGap');
            doAheadOrBehind = SequenceNode([obj.cond11, selectAheadOrBehind],obj.bb);
            
            %% 'Emengency Stop' Tree
            assignStop = ActionNode('A','AemergStop',obj.bb);
            
            
            %% random back-off
            assignZero = ActionNode('A','Zero',obj.bb);
            obj.cond12 = ConditionNode(obj.bb.isDeadlock == 1,'isDeadlock == 1');
            obj.cond13 = ConditionNode(obj.bb.backOffTime >= obj.bb.t,'backOffTime >= t');
            backOff = SequenceNode([obj.cond12, obj.cond13,assignZero],obj.bb);
            
            %% Full Behaviour Tree
            obj.full_select = SelectorNode([DoCruise,backOff,keepJunctionClear,doAheadOrBehind,assignStop],obj.bb);

            
            obj.actStore = [act1,assignZero,assignJuncStop,assignAhead,assignBehind,assignJuncStop1,assignStop];
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
                futureMinStopGap = calc_safe_gap(obj.a,obj.b,obj.juncExitVelocity,v0,obj.timeGap,obj.minimumGap,obj.delta,obj.a_min,1)+obj.minimumGap;
                
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
                
                
                obj.cond1.condArray = (any(oppositeDistToJunc > 0) == 0);
                obj.cond2.condArray = (selfDistToJunc >= minStopDistGapToJunc);
                obj.cond3.condArray = (isFrontCarPassedJunction == 0);
                obj.cond4.condArray = (selfDistToJunc > comfortableStopGap);
                obj.cond5.condArray = (isFrontCarPassedJunction == 1);
                obj.cond6.condArray = (any(oppositeDistToJunc > 0) == 1);
                obj.cond7.condArray = (futureGap<futureMinStopGap);
                obj.cond8.condArray = (selfDistToJunc >= minStopDistGapToJunc);
                obj.cond9.condArray = (isEnoughGapBehind == 1);
                obj.cond10.condArray = (isEnoughGapAhead == 1);
                obj.cond11.condArray = (futureGap>=futureMinStopGap);
                obj.cond12.condArray = (obj.bb.isDeadlock == 1);
                obj.cond13.condArray = (obj.bb.backOffTime >= t);
            end
            
            
            %% Update cruising acceleration
            obj.bb.Afollow = obj.idmAcceleration;            
            
            %% update BT
            output = tick(obj.full_select,1);
            
            obj.bbStore = [obj.bbStore;[obj.actStore(:).output]];
            
            
            %% draw behaviour tree
            if obj.BT_plot_flag
                if isempty(obj.Fig)
                    obj.Fig = figure();
                end
                obj.full_select.plot_tree(0);
                obj.full_select.plot_bt(obj.Fig);
            end
            [obj.actStore(:).output]=deal(-1);
            
            
            %% assign bt output to acceleration
            obj.acceleration = obj.bb.A;
            
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
                s = obj.Prev.pose(1) - obj.pose(1)-obj.dimension(2);
                dV = (obj.velocity - obj.Prev.velocity);
            else
                s = 1e5;
                dV = 1e-5;
            end
            
            intelligentBreaking = obj.velocity*obj.timeGap + (obj.velocity*dV)/(2*sqrt(obj.a_max*obj.b));
            if stop_flag || junc_flag
                s_star = 0.1 + max(0,intelligentBreaking);
            else
                s_star = obj.minimumGap + max(0,intelligentBreaking);
            end
            
            velDif = obj.velocity/obj.targetVelocity;
            if isnan(velDif)
                velDif = 1;
            end
            
            obj.juncAccel = obj.a_max*(1 - (velDif)^obj.delta - (s_star/s)^2);
            
            
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

