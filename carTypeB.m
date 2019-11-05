classdef carTypeB < AutonomousCar
    properties(SetAccess = public)
        bb
        bbValues = []
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
        cond13 % inJunction Flag
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
            obj.bb.add_item('noCarsOpposite',false);
            obj.bb.add_item('backOffTime',0);
            obj.bb.add_item('t',0);
            obj.bb.add_item('isDeadlock',0);
            obj.bb.add_item('Zero',0);
            obj.bb.add_item('frontCarPassedJunction',0);
            obj.bb.add_item('isSelfInJunction',0)
            
            obj.bbValues.A                      = obj.bb.A;
            obj.bbValues.Afollow                = obj.bb.Afollow;
            obj.bbValues.AemergStop             = obj.bb.AemergStop;
            obj.bbValues.AminAhead              = obj.bb.AminAhead;
            obj.bbValues.AmaxBehind             = obj.bb.AmaxBehind;
            obj.bbValues.distToJunc             = obj.bb.distToJunc;
            obj.bbValues.comfDistToJunc         = obj.bb.comfDistToJunc;
            obj.bbValues.minStopDistToJunc      = obj.bb.minStopDistToJunc;
            obj.bbValues.futureMinGap           = obj.bb.futureMinGap;
            obj.bbValues.futureGap              = obj.bb.futureGap;
            obj.bbValues.noCarsOpposite         = obj.bb.noCarsOpposite;
            obj.bbValues.backOffTime            = obj.bb.backOffTime;
            obj.bbValues.t                      = obj.bb.t;
            obj.bbValues.isDeadlock             = obj.bb.isDeadlock;
            obj.bbValues.frontCarPassedJunction = obj.bb.frontCarPassedJunction;
            obj.bbValues.isSelfInJunction       = obj.bb.isSelfInJunction; 
            
            %% 'Follow Front Car' Tree
            obj.cond13 = ConditionNode(obj.bb.isSelfInJunction == 0,'isSelfInJunction == 0');
            obj.cond1 = ConditionNode(obj.bb.noCarsOpposite == 1,'noCarsOpposite == 1');
            obj.cond2 = ConditionNode(obj.bb.distToJunc >= obj.bb.minStopDistToJunc,'distToJunc >= minStopDistToJunc');
            followFrontCar = SelectorNode([obj.cond1,obj.cond2],obj.bb);
            
            obj.cond3 = ConditionNode(obj.bb.frontCarPassedJunction == 0,'frontCarPassedJunction == 0');
            clearedJunction = SequenceNode([obj.cond3,followFrontCar],obj.bb);
            
            obj.cond4 = ConditionNode(obj.bb.distToJunc > obj.bb.comfDistToJunc,'distToJunc > comfDistToJunc');
            CruisePreOrAfterJunction = SelectorNode([obj.cond4,clearedJunction],obj.bb);
            
            
            assignFollow = ActionNode('A','Afollow',obj.bb);
            DoCruise = SequenceNode([obj.cond13,CruisePreOrAfterJunction, assignFollow],obj.bb);
            
            %% 'Junction' Tree
            % 'Cross Behind' Tree
            obj.cond5 = ConditionNode(obj.bb.AmaxBehind > obj.bb.Amin,'AmaxBehind > Amin');  
            assignBehind = ActionNode('A','AmaxBehind',obj.bb);
            behindCar = SequenceNode([obj.cond5,assignBehind],obj.bb);
            
            % 'Cross Following Front car' Tree
            obj.cond6 = ConditionNode(obj.bb.AmaxBehind > obj.bb.Afollow,'AmaxBehind > Afollow');
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
            obj.full_select = SelectorNode([DoCruise,backOff,doAheadOrBehind,assignStop],obj.bb);
            
            
%             obj.actStore = [act1,assignZero,assignJuncStop,assignAhead,assignBehind,assignJuncStop1,assignStop];
            obj.actStore = [assignFollow,assignZero,assignAhead,assignBehind,assignStop];
%             obj.full_select.plot_tree(0);
%             obj.full_select.plot_bt(obj.Fig);
            obj.bbStore = [obj.bbStore;[obj.actStore(:).output]];   
        end
        function decide_acceleration(obj,oppositeRoad,roadLength,t,dt,iIteration)
            
            % Update cruising acceleration
            obj.bb.Afollow = obj.idmAcceleration;
            %% if no cars opposite
            if oppositeRoad.numCars > 0
                oppositeCars = oppositeRoad.allCars;
                s_in = obj.s_in;
                s_out = obj.s_out;
                s = obj.pose(1);
                v = obj.velocity;
                v0 = obj.targetVelocity;
              
                %% calc and assign self distance to junction
                selfDistToJunc = s_in - s + (s>s_in)*roadLength;
                selfDistOutOfJunc = s_out - s + (s>s_out)*roadLength;
                
                %% Future Gap
                accel_out = obj.a_max;
                obj.juncExitVelocity = min(v0,sqrt(max(0,v^2+2*accel_out*selfDistOutOfJunc)));
                
                % [self t_in and t_out] use this one as it is identical
                % to type A one (i.e. for consistency purposes)
                [~, t_out_self_ahead] = calculate_t_in_and_out(obj,0,v,s,t,roadLength);
                futureMinStopGap =  -(obj.juncExitVelocity^2)/(2*obj.a_feas_min);
                
                
%                 if s < s_out && ~isempty(obj.Prev) && obj.Prev.pose(1) ~= s && ~isinf(t_out_self_ahead) 
%                     sPrev = obj.Prev.pose(1);
%                     vPrev = obj.Prev.velocity;
%                     %aPrev = obj.Prev.acceleration;
%                     if sPrev > s_out
%                         futureGap = (sPrev + vPrev*(t_out_self_ahead-t)) - s_out;
%                     elseif sPrev < s_out && sPrev < s
%                         futureGap = (sPrev + roadLength + vPrev*(t_out_self_ahead-t)) - s_out;
%                     else
%                         futureGap = 0;
%                     end
%                 else
%                     futureGap = 1e5;
%                 end



                if s < s_out && ~isempty(obj.Prev) && obj.Prev.pose(1) > s_out 
                    sPrev = obj.Prev.pose(1);
                    vPrev = obj.Prev.velocity;
                    futureGap = (sPrev + vPrev*(t_out_self_ahead-t)) - s_out;
                    % Avoid NaN Future Gap
                    futureGap(isinf(t_out_self_ahead) & vPrev == 0) = 1e5;
                else
                    futureGap = 1e5;
                end
                
                
                
                
                
                
%                 if futureGap>1e5
%                     futureGap
%                 end
%                 if isnan(futureGap)
%                     futureGap
%                 end
                    
                %% Comf stop gap
                isSelfInJunction = (s <= s_out && s >= s_in);
                if isSelfInJunction
                    comfortableStopGap = 1e5;
                else
                    % +10 is for BT to stay in junction crossing and not
                    % oscillate at low speed
                    comfortableStopGap = calc_safe_gap(obj.a,obj.b,v,v0,obj.timeGap,0,obj.delta,-obj.b,1)+10;
                end
                
                %% Min stop gap
                % +5 is for BT to stay in junction crossing and not
                % oscillate at low speed
                minStopDistGapToJunc = calc_safe_gap(obj.a,obj.b,v,v0,obj.timeGap,0,obj.delta,obj.a_min,1)+5;

                %% Emergency stop logic
                if s < s_in
                    calculate_junc_accel(obj,roadLength,1)
                else
                    calculate_junc_accel(obj,roadLength,3)
                end
                emergStop = obj.juncAccel;
                
                % get all opposite arm cars' positions
                s_op = oppositeRoad.allCarsStates(1,:);
                
                % convert positions to distances to junction
                oppositeDistToJunc = s_op-s_out;
                
                % NaN - passed junction
                oppositeDistToJunc(oppositeDistToJunc>0) = NaN;
                [~, ind] = max(oppositeDistToJunc);
                
                if ~isempty(oppositeCars(ind).Next)
                    calc_a_min_ahead(obj,t,dt,oppositeCars(ind).Next,oppositeRoad.Length);
                else
                    obj.acc_min_ahead = -1e3;
                end
                calc_a_max_behind(obj,t,dt,obj.acc_min_ahead,oppositeCars(ind),oppositeRoad.Length);
                calc_a_min_ahead(obj,t,dt,oppositeCars(ind),oppositeRoad.Length);
               
                
                % 1 - passed, 0 - not passed
                isFrontCarPassedJunction = (obj.Prev.pose(1) == s || obj.Prev.pose(1) > obj.Prev.ownDistfromRearToBack || obj.Prev.pose(1) < s);
                
                %% Update values of the Blackboard
                obj.bb.isSelfInJunction = isSelfInJunction;
                obj.bb.AemergStop = emergStop;
                obj.bb.AminAhead = obj.acc_min_ahead;
                obj.bb.AmaxBehind = obj.acc_max_behind;

%                 obj.bb.distToJunc = selfDistToJunc;
                obj.bb.distToJunc = selfDistOutOfJunc;
                obj.bb.comfDistToJunc = comfortableStopGap;
                obj.bb.minStopDistToJunc = minStopDistGapToJunc;
                obj.bb.futureMinGap = futureMinStopGap;
                obj.bb.futureGap = futureGap;
                obj.bb.noCarsOpposite = ~any(oppositeDistToJunc < 0);
                timeDiff = obj.bb.backOffTime - t;
                % 1 - if both cars stopped; 0 - if either or both move
                if timeDiff < 0
                    if (abs(v) < 0.001 && abs(selfDistToJunc) < 0.6 &&...
                            abs(oppositeCars(ind).velocity) < 0.001 && abs(s_op(ind)-obj.s_in) < 0.6)
                        obj.bb.isDeadlock = 1;
                        obj.bb.backOffTime = t + (randi(21)-1)/(1/dt);
                        
                    end
                elseif timeDiff == 0
                    obj.bb.isDeadlock = 0;
                end
                obj.bb.t = t;
                obj.bb.frontCarPassedJunction = isFrontCarPassedJunction;
                
                
                obj.cond1.condArray = (obj.bb.noCarsOpposite==1);
                obj.cond2.condArray = (selfDistToJunc >= minStopDistGapToJunc);
                obj.cond3.condArray = (isFrontCarPassedJunction == 0);
                obj.cond4.condArray = (selfDistToJunc > comfortableStopGap);
%                 obj.cond4.condArray = (selfDistToJunc > minStopDistGapToJunc);

                
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
                    clf(obj.Fig) = figure(2);
                else
                    gcf = figure(2);
                end
                obj.full_select.plot_tree(0);
                obj.full_select.plot_bt(obj.Fig);
                cla(obj.Fig)
            end
            [obj.actStore(:).output]=deal(-1);
            
            
            % assign bt output to acceleration
            obj.acceleration = obj.bb.A;
            
            obj.bbValues.A(end+1)                      = obj.bb.A;
            obj.bbValues.Afollow(end+1)                = obj.bb.Afollow;
            obj.bbValues.AemergStop(end+1)             = obj.bb.AemergStop;
            obj.bbValues.AminAhead(end+1)              = obj.bb.AminAhead;
            obj.bbValues.AmaxBehind(end+1)             = obj.bb.AmaxBehind;
            obj.bbValues.distToJunc(end+1)             = obj.bb.distToJunc;
            obj.bbValues.comfDistToJunc(end+1)         = obj.bb.comfDistToJunc;
            obj.bbValues.minStopDistToJunc(end+1)      = obj.bb.minStopDistToJunc;
            obj.bbValues.futureMinGap(end+1)           = obj.bb.futureMinGap;
            obj.bbValues.futureGap(end+1)              = obj.bb.futureGap;
            obj.bbValues.noCarsOpposite(end+1)         = obj.bb.noCarsOpposite;
            obj.bbValues.backOffTime(end+1)            = obj.bb.backOffTime;
            obj.bbValues.t(end+1)                      = obj.bb.t;
            obj.bbValues.isDeadlock(end+1)             = obj.bb.isDeadlock;
            obj.bbValues.frontCarPassedJunction(end+1) = obj.bb.frontCarPassedJunction;
            obj.bbValues.isSelfInJunction(end+1)       = obj.bb.isSelfInJunction; 
            %
            check_for_negative_velocity(obj,dt);
        end
        function calculate_junc_accel(obj,varargin)
            if varargin{2} == 1
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
            if varargin{2} == 1
                s_star = 0.1 + max(0,intelligentBreaking);
            else
                s_star = obj.minimumGap + max(0,intelligentBreaking);
            end
            
            velDif = obj.velocity/obj.targetVelocity;
            if isnan(velDif)
                velDif = 1;
            end
            
            obj.juncAccel = obj.a*(1 - (velDif)^obj.delta - (s_star/s)^2);
            
            % 'r' is gap 's'
            lennardJones = 10*((0.8/s)^6-(.25/s)^6);
            if obj.juncAccel < obj.a_feas_min
                obj.juncAccel = obj.a_feas_min-lennardJones;
            end
        end
         function [t_in, t_out] = calculate_t_in_and_out(obj,a,v,s,t,roadLength,varargin)
            
            s_in = obj.s_in;
            s_out = obj.s_out;
            
            if s <= s_in
                d_in = s_in - s;
                d_out = s_out - s;
            elseif s >= s_out
                d_in = s_in - s - roadLength;
                d_out = s_out - s - roadLength;
            elseif s > s_in && s < s_out
                d_in = 0;
                d_out = s_out - s;
            end
            
            if  nargin == 7
                % opposite car time gap
                t_in = d_in/v + t;
                t_out = d_out/v + t;
            else
                 % self time gap
                if obj.tol < abs(a)
                    v_f_in = min(obj.maximumVelocity,sqrt(max(0,v^2 + 2*a*d_in)));
                    v_f_out = min(obj.maximumVelocity,sqrt(max(0,v^2 + 2*a*d_out)));
                    
                    t_in = (-v + v_f_in)/a + t;
                    t_out = (-v + v_f_out)/a + t;
                else
                    t_in = d_in/v + t;
                    t_out = d_out/v + t;
                end
            end
        end
    end
end

