classdef carTypeB < AutonomousCar
    properties(SetAccess = public)
        bb
        bbStore = []
        cond1
        cond2
        cond3
        cond4
        cond5
        cond6
        cond7
        cond8
        cond9
        cond10
        cond11
        cond12
        
        actStore = ConditionNode.empty
        full_select
        Fig = []
    end
    
    properties (SetAccess = public)
        BT_plot_flag = 0
        juncAccel = 0
    end
    methods
        function obj = carTypeB(varargin)
            if nargin == 4
                orientation = varargin{1};
                startPoint = varargin{2};
                Width = varargin{3};
                dt = varargin{4};
            end
            obj = obj@AutonomousCar(orientation, startPoint, Width,dt);
            obj.priority = 1;
            
            %% -----------------Initialize Blackboard------------------
            obj.bb = BlackBoard;
            obj.bb.add_item('A',obj.acceleration);
            obj.bb.add_item('Afollow',obj.idmAcceleration);
            obj.bb.add_item('AemergStop',obj.idmAcceleration);
%             obj.bb.add_item('AjuncStop',obj.idmAcceleration);
            
            obj.bb.add_item('AminAhead',0);
            obj.bb.add_item('AmaxBehind',0);
            obj.bb.add_item('Amax',obj.a_max);
            obj.bb.add_item('Amin',obj.a_min);

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
            
            
            assignFollow = ActionNode('A','Afollow',obj.bb);
            DoCruise = SequenceNode([CruisePreOrAfterJunction, assignFollow],obj.bb);
            
            %% 'Junction' Tree
            % 'Cross Behind' Tree

            obj.cond5 = ConditionNode(obj.bb.AmaxBehind > obj.bb.Amin,'AmaxBehind > Amin');  
            assignBehind = ActionNode('A','AmaxBehind',obj.bb);
            behindCar = SequenceNode([obj.cond5,assignBehind],obj.bb);
            
            
            % 'Cross Following Front car' Tree
            
            obj.cond6 = ConditionNode(obj.bb.AmaxBehind > obj.bb.Afollow,'AmaxBehind > Afollow');
%             behindWithIdm = SequenceNode([obj.cond6, ActionNode('A','Afollow',obj.bb)],obj.bb);
%             aheadWithIdm = SequenceNode([obj.cond7, ActionNode('A','Afollow',obj.bb)],obj.bb);
            obj.cond7 = ConditionNode(obj.bb.AminAhead <= obj.bb.Afollow,'AminAhead <= Afollow');
            aheadOrBehindIDM = SelectorNode([obj.cond7,obj.cond6],obj.bb);
            crossFollowingFrontCar = SequenceNode([aheadOrBehindIDM, assignFollow],obj.bb);
            
            % 'Cross Ahead' Tree
            obj.cond8 = ConditionNode(obj.bb.AminAhead > obj.bb.Afollow,'AminAhead > Afollow');
            obj.cond9 = ConditionNode(obj.bb.AminAhead <= obj.bb.Amax,'AminAhead <= Amax');
            assignAhead = ActionNode('A','AminAhead',obj.bb);
            aheadCar = SequenceNode([obj.cond8,obj.cond9,assignAhead ],obj.bb);
            
            selectAheadOrBehind = SelectorNode([aheadCar, crossFollowingFrontCar, behindCar],obj.bb);
%             selectAheadOrBehind = SelectorNode([ crossFollowingFrontCar,aheadCar, behindCar],obj.bb);

%{
            assignJuncStop = ActionNode('A','AjuncStop',obj.bb);
            obj.cond5 = ConditionNode(obj.bb.distToJunc >= obj.bb.minStopDistToJunc,'distToJunc >= minStopDistToJunc');
            stopBeforeJunction = SequenceNode([obj.cond5, assignJuncStop],obj.bb);
            
            % 'Cross Behind' Tree
            assignBehind =  ActionNode('A','Afollow',obj.bb);
            obj.cond9 = ConditionNode(obj.bb.canPassBehind == 1,'canPassBehind == 1');
            passBehind = SequenceNode([obj.cond9, assignBehind],obj.bb);
            
           %  'Cross Ahead' Tree
            assignAhead =  ActionNode('A','Aahead',obj.bb);
            obj.cond10 = ConditionNode(obj.bb.canPassAhead == 1,'canPassAhead == 1');
            passAhead = SequenceNode([obj.cond10, assignAhead],obj.bb);
             
            % Choose 'Ahead or Behind' Tree
            selectAheadOrBehind = SelectorNode([passAhead,passBehind,stopBeforeJunction],obj.bb);
%}            
            obj.cond10 = ConditionNode(obj.bb.futureGap >= obj.bb.futureMinGap,'futureGap >= futureMinGap');
            doAheadOrBehind = SequenceNode([obj.cond10, selectAheadOrBehind],obj.bb);
            
            %% 'Emengency Stop' Tree
            assignStop = ActionNode('A','AemergStop',obj.bb);
            
            
            %% random back-off
            assignZero = ActionNode('A','Zero',obj.bb);
            obj.cond11 = ConditionNode(obj.bb.isDeadlock == 1,'isDeadlock == 1');
            obj.cond12 = ConditionNode(obj.bb.backOffTime >= obj.bb.t,'backOffTime >= t');
            backOff = SequenceNode([obj.cond11, obj.cond12,assignZero],obj.bb);
            
            %% Full Behaviour Tree
%             obj.full_select = SelectorNode([DoCruise,backOff,keepJunctionClear,doAheadOrBehind,assignStop],obj.bb);
            obj.full_select = SelectorNode([DoCruise,backOff,doAheadOrBehind,assignStop],obj.bb);
            
            
%             obj.actStore = [act1,assignZero,assignJuncStop,assignAhead,assignBehind,assignJuncStop1,assignStop];
            obj.actStore = [assignFollow,assignZero,assignAhead,assignBehind,assignStop];
%             obj.full_select.plot_tree(0);
%             obj.full_select.plot_bt(obj.Fig);
        end
        function decide_acceleration(obj,oppositeRoad,roadLength,t,dt,iIteration)
            
            % Update cruising acceleration
            obj.bb.Afollow = obj.idmAcceleration;
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

                %% Future Gap
                if isnan(obj.t_out)
                    accel_out = obj.idmAcceleration;
                    obj.juncExitVelocity = min(obj.maximumVelocity,sqrt(max(0,obj.velocity^2+2*accel_out*(crossingEnd-obj.pose(1)))));
                    t_out_self_ahead = (obj.juncExitVelocity - obj.velocity)/accel_out+t;
                    futureMinStopGap = calc_safe_gap(obj.a,obj.b,obj.juncExitVelocity,obj.targetVelocity,obj.timeGap,obj.minimumGap,obj.delta,obj.a_min)+obj.minimumGap;
                else
                    t_out_self_ahead = obj.t_out;
                    futureMinStopGap = calc_safe_gap(obj.a,obj.b,obj.juncExitVelocity,obj.targetVelocity,obj.timeGap,obj.minimumGap,obj.delta,obj.a_min,1)+obj.minimumGap;
                end

                if s < crossingEnd && ~isempty(obj.Prev) && obj.Prev.pose(1) ~= s
                    sPrev = obj.Prev.pose(1);
                    vPrev = obj.Prev.velocity;
                    %aPrev = obj.Prev.acceleration;
                    if sPrev > crossingBegin
                        futureGap = (sPrev + vPrev*(t_out_self_ahead-(t+dt))) - crossingEnd;
                    elseif sPrev < crossingBegin && sPrev < s
                        futureGap = (sPrev + roadLength + vPrev*(t_out_self_ahead-(t+dt))) - crossingEnd;
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

                %% Emergency stop logic
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
                
                if ~isempty(oppositeCars(ind).Next)
                    calc_a_min_ahead(obj,t,dt,oppositeCars(ind).Next,oppositeRoad.Length);
                else
                    obj.acc_min_ahead = -1e3;
                end
                calc_a_max_behind(obj,t,dt,obj.acc_min_ahead,oppositeCars(ind),oppositeRoad.Length);
                calc_a_min_ahead(obj,t,dt,oppositeCars(ind),oppositeRoad.Length);
               
                
                % 1 - passed, 0 - not passed
                isFrontCarPassedJunction = (obj.Prev.pose(1) == s || obj.Prev.pose(1) > 0.825 || obj.Prev.pose(1) < s);
                
                %% Update values of the Blackboard
                
                obj.bb.AemergStop = emergStop;
                obj.bb.AminAhead = obj.acc_min_ahead;
                obj.bb.AmaxBehind = obj.acc_max_behind;

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
                
                
                obj.cond5.condArray = (obj.bb.AmaxBehind > obj.bb.Amin);
                obj.cond6.condArray = (obj.bb.AmaxBehind > obj.bb.Afollow);
                obj.cond7.condArray = (obj.bb.AminAhead <= obj.bb.Afollow);
                
                obj.cond8.condArray = (obj.bb.AminAhead > obj.bb.Afollow);
                obj.cond9.condArray = (obj.bb.AminAhead <= obj.bb.Amax);

                obj.cond10.condArray = (futureGap>=futureMinStopGap);
                obj.cond11.condArray = (obj.bb.isDeadlock == 1);
                obj.cond12.condArray = (obj.bb.backOffTime >= t);
            end
            
            
            
            %% update BT
            tick(obj.full_select,1);
            
            obj.bbStore = [obj.bbStore;[obj.actStore(:).output]];
            
            
            % draw behaviour tree
            if obj.BT_plot_flag
                if isempty(obj.Fig)
                    obj.Fig = figure();
                end
                obj.full_select.plot_tree(0);
                obj.full_select.plot_bt(obj.Fig);
            end
            [obj.actStore(:).output]=deal(-1);
            
            
            % assign bt output to acceleration
            obj.acceleration = obj.bb.A;
            
            %
            check_for_negative_velocity(obj,dt);
        end
        function calculate_junc_accel(obj,varargin)
%             roadLength = varargin{1};
            if nargin == 2
                stop_flag = 0;
                junc_flag = 0;
                emerg_flag = 0;
            elseif varargin{2} == 1
                stop_flag = 1;
                junc_flag = 0;
                emerg_flag = 0;
            elseif varargin{2} == 2
                stop_flag = 0;
                junc_flag = 1;
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
            
            intelligentBreaking = obj.velocity*obj.timeGap + (obj.velocity*dV)/(2*sqrt(obj.a*obj.b));
            if stop_flag || junc_flag
                s_star = 0.1 + max(0,intelligentBreaking);
            else
                s_star = obj.minimumGap + max(0,intelligentBreaking);
            end
            
            velDif = obj.velocity/obj.targetVelocity;
            if isnan(velDif)
                velDif = 1;
            end
            
            obj.juncAccel = obj.a*(1 - (velDif)^obj.delta - (s_star/s)^2);
            
            if obj.juncAccel < obj.a_feas_min
                if (emerg_flag || stop_flag)
                    obj.juncAccel = -Lennard_Jones(s ,obj.a_feas_min);
                else
                    obj.juncAccel =  obj.a_feas_min;
                end
            end
        end
    end
end

