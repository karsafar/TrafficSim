classdef carTypeA < IdmModel
    properties(SetAccess = public)
        bb
        bbValues = []
        bbStore = []
        cond1
        cond2
        cond3
        cond4
        cond8
        cond9
        cond10
        cond11
        cond12
        cond13
      
        actStore = ConditionNode.empty
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
            obj.bb.add_item('backOffTime',-1);
            obj.bb.add_item('t',0);
            obj.bb.add_item('isDeadlock',false);
            obj.bb.add_item('Zero',0);
            obj.bb.add_item('frontCarPassedJunction',false);
            
            obj.bbValues.A                      = [];
            obj.bbValues.Afollow                = [];
            obj.bbValues.AemergStop             = [];
            obj.bbValues.AjuncStop              = [];
            obj.bbValues.Aahead                 = [];
            obj.bbValues.canPassAhead           = [];
            obj.bbValues.canPassBehind          = [];
            obj.bbValues.distToJunc             = [];
            obj.bbValues.comfDistToJunc         = [];
            obj.bbValues.minStopDistToJunc      = [];
            obj.bbValues.futureMinGap           = [];
            obj.bbValues.futureGap              = [];
            obj.bbValues.CarsOpposite           = [];
            obj.bbValues.backOffTime            = [];
            obj.bbValues.t                      = [];
            obj.bbValues.isDeadlock             = [];
            obj.bbValues.frontCarPassedJunction = [];
            
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
            %             assignJuncStop = ActionNode('A','AjuncStop',obj.bb);
            %             obj.cond5 = ConditionNode(obj.bb.frontCarPassedJunction == 1,'frontCarPassedJunction == 1');
            %             obj.cond6 = ConditionNode(obj.bb.CarsOpposite == 1,'CarsOpposite == 1');
            %             obj.cond7 = ConditionNode(obj.bb.futureGap < obj.bb.futureMinGap,'futureGap < futureMinGap');
            %
            %             keepJunctionClear = SequenceNode([obj.cond5, obj.cond6,obj.cond7, assignJuncStop],obj.bb);
            %
            assignJuncStop = ActionNode('A','AjuncStop',obj.bb);
            obj.cond8 = ConditionNode(obj.bb.distToJunc >= obj.bb.minStopDistToJunc,'distToJunc >= minStopDistToJunc');
            stopBeforeJunction = SequenceNode([obj.cond8, assignJuncStop],obj.bb);
            
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
            %             obj.full_select = SelectorNode([DoCruise,backOff,keepJunctionClear,doAheadOrBehind,assignStop],obj.bb);
            obj.full_select = SelectorNode([DoCruise,backOff,doAheadOrBehind,assignStop],obj.bb);
            
            
            %             obj.actStore = [act1,assignZero,assignJuncStop,assignAhead,assignBehind,assignJuncStop1,assignStop];
            obj.actStore = [act1,assignZero,assignAhead,assignBehind,assignJuncStop,assignStop];
            
%             obj.bbStore = NaN(nIterations,numel(obj.actStore),'int8');
%             obj.bbStore = [obj.bbStore;[obj.actStore(:).output]]*NaN;
        end
        function decide_acceleration(obj,oppositeRoad,roadLength,t,dt,iIteration)
            
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
                
                %% assign junction acceleration
                pass_ahead_accel = obj.idmAcceleration;
                
                %% Future space gap
                obj.juncExitVelocity = min(obj.maximumVelocity,sqrt(max(0,v^2+2*pass_ahead_accel*selfDistOutOfJunc)));
                futureMinStopGap = calc_safe_gap(obj.a,obj.b,obj.juncExitVelocity,v0,obj.timeGap,obj.minimumGap,obj.delta,obj.a_min,1);
                
                % self t_in and t_out
                [obj.t_in_self, obj.t_out_self] = calculate_t_in_and_out(obj,pass_ahead_accel,v,s,t,roadLength);
                
                if s < s_out  && ~isnan(obj.t_out_self) && obj.Prev.pose(1) ~= s
                    sPrev = obj.Prev.pose(1);
                    vPrev = obj.Prev.velocity;
                    if sPrev > s %sPrev > s_in
                        futureGap = (sPrev + max(0,vPrev*(obj.t_out_self-(t+dt)))) - s_out;
                    elseif sPrev < s_in && sPrev < s
                        futureGap = (sPrev + roadLength + max(0,vPrev*(obj.t_out_self-(t+dt)))) - s_out;
                    else
                        futureGap = 0;
                    end
                else
                    futureGap = 1e5;
                end
                
                %% Comf stop gap
                if s <= s_out && s >= s_in
                    comfortableStopGap = 1e5;
                else
                    % 8 inputs. find out if this is the best way
                    comfortableStopGap = calc_safe_gap(obj.a,obj.b,v,v0,obj.timeGap,0,obj.delta,-obj.b)+10;
                end
                
                %% Min stop gap
                % 8 inputs. find out if this is the best way
                minStopDistGapToJunc = calc_safe_gap(obj.a,obj.b,v,v0,obj.timeGap,0,obj.delta,obj.a_min);
                
                %% longic for junc stop
                calculate_junc_accel(obj,roadLength,2)
                juncStop = obj.juncAccel;
                
                %% logic for emergency stop
                if s < s_in
                    calculate_junc_accel(obj,roadLength,1)
                else
                    calculate_junc_accel(obj,roadLength,3)
                end
                emergStop = obj.juncAccel;
                
                % get all opposite arm cars' positions
                s_op = oppositeRoad.allCarsStates(1,:);
                
                
                % convert positions to distances to junction
                oppositeDistToJunc = s_out - s_op;
                
                % inf - passed junction
                oppositeDistToJunc(oppositeDistToJunc<0) = inf;
                [~, ind] = min(oppositeDistToJunc);
                
                % competing car t_in and t_out
                tol_op = 0;
                s_comp = oppositeRoad.allCarsStates(1,ind);
                v_comp = oppositeRoad.allCarsStates(2,ind);
                a_comp = oppositeRoad.allCarsStates(3,ind);
                
%                 randVal = rand();
%                 noiseRate = 0.05;
%                 posNoiseRate = 2*s_comp*noiseRate*randVal - s_comp*noiseRate;
%                 velNoiseRate = 2*v_comp*noiseRate*randVal - v_comp*noiseRate;
%                 accelNoiseRate = 2*a_comp*noiseRate*randVal - a_comp*noiseRate;
%                 [t_in_op, t_out_op] = calculate_t_in_and_out(obj,a_comp,v_comp+velNoiseRate,s_comp,t,oppositeRoad.Length,tol_op);
                [t_in_op, t_out_op] = calculate_t_in_and_out(obj,a_comp,v_comp,s_comp,t,oppositeRoad.Length,tol_op);

                % next car after competing car t_in and t_out
                s_comp_next = oppositeCars(ind).Next.pose(1);
                v_comp_next = oppositeCars(ind).Next.velocity;
                a_comp_next = oppositeCars(ind).Next.History(3,round(t/dt+1));
                [t_in_next, ~] = calculate_t_in_and_out(obj,a_comp_next,v_comp_next,s_comp_next,t,oppositeRoad.Length,tol_op);
                t_in_next(t_in_next == t_in_op && oppositeRoad.numCars == 1) = 1e5;
                
                % 1 - enough gap to go ahead of competing car
                t_min = 0; % 2 seconds gap acceptance rule
                if s > s_in && s < s_out
                    isEnoughGapAhead = 1;
                else
                    isEnoughGapAhead = (t_in_op-t_min > obj.t_out_self);
                end
                
                % 1 - enough gap between current leaving and next car entering junction
                isEnoughGapBehind = (obj.t_in_self > t_out_op) && (t_in_next-t_min > obj.t_out_self);

                %% %%%%%%%%
%                 aheadGap = (t_in_op -2 - obj.t_out_self);

%                 sprintf('cross ahead gap is %f',aheadGap)
                %% %%%%%%%%
                % 1 - passed, 0 - not passed
                isFrontCarPassedJunction = (obj.Prev.pose(1) == s || obj.Prev.pose(1) > obj.Prev.ownDistfromRearToBack  || obj.Prev.pose(1) < s);
                 
                %% Update values of the Blackboard
                
                
                blackBorad = obj.bb;
                blackBorad.AemergStop = emergStop;
                blackBorad.AjuncStop = juncStop;
                blackBorad.Aahead = pass_ahead_accel;
                blackBorad.canPassAhead = isEnoughGapAhead;
                blackBorad.canPassBehind = isEnoughGapBehind;
                blackBorad.distToJunc = selfDistToJunc;
                blackBorad.comfDistToJunc = comfortableStopGap;
                blackBorad.minStopDistToJunc = minStopDistGapToJunc;
                blackBorad.futureMinGap = futureMinStopGap;
                blackBorad.futureGap = futureGap;
                blackBorad.CarsOpposite = any(oppositeDistToJunc > 0);
                timeDiff = blackBorad.backOffTime - t;
                % 1 - if both cars stopped; 0 - if either or both move
                if timeDiff < -1e-5
                    if (abs(v) < 1e-10 && abs(selfDistToJunc) < 0.1001 &&...
                            abs(oppositeCars(ind).velocity) < 1e-10 && abs(s_op(ind)-obj.s_in) < 0.1001)
                        blackBorad.isDeadlock = true;
                        blackBorad.backOffTime = t + (randi(51)-1)/(1/dt);
                        
                    end
                elseif (abs(timeDiff) < 5e-2) || (abs(oppositeCars(ind).velocity) > 0.5 && blackBorad.isDeadlock)
                    blackBorad.isDeadlock = false;
                    blackBorad.backOffTime = -1;
                end
                blackBorad.t = t;
                blackBorad.frontCarPassedJunction = isFrontCarPassedJunction;
                
                
                obj.cond1.condArray = (~any(oppositeDistToJunc > 0));
                obj.cond2.condArray = (selfDistToJunc >= minStopDistGapToJunc);
                obj.cond3.condArray = (isFrontCarPassedJunction == 0);
                obj.cond4.condArray = (selfDistToJunc > comfortableStopGap);
                obj.cond8.condArray = (selfDistToJunc >= minStopDistGapToJunc);
                obj.cond9.condArray = (isEnoughGapBehind == 1);
                obj.cond10.condArray = (isEnoughGapAhead == 1);
                obj.cond11.condArray = (futureGap>=futureMinStopGap);
                obj.cond12.condArray = (blackBorad.isDeadlock == 1);
                obj.cond13.condArray = (blackBorad.backOffTime >= t);
            end
            
            
            %% Update cruising acceleration
            blackBorad.Afollow = obj.idmAcceleration;
            
            
            
            if mod(t,obj.UpdateRate) == 0 || t < 2*dt
                
                % reset all action vaules to -1 for the next iteration
%                 [obj.actStore(:).output]=deal(-1);
                temp = int8((-1)*ones(1,numel(obj.actStore)));
                temp1 = num2cell(temp);
                [obj.actStore.output]= temp1{:};
                %% update BT
                tick(obj.full_select,int8(1));
                
%                 obj.bbStore = [obj.bbStore;[obj.actStore(:).output]];
                 obj.bbStore(:,iIteration) = [obj.actStore(:).output];
                 
                %% draw behaviour tree
                if obj.BT_plot_flag
                    if isempty(obj.Fig)
                        obj.Fig = figure();
                    end
                    obj.full_select.plot_tree(0);
                    obj.full_select.plot_bt(obj.Fig);
                end
                
            else
                obj.bbStore(:,iIteration) = [obj.actStore(:).output];
                tempActOutput = [obj.actStore(:).output];
                tempAccelVals = [blackBorad.Afollow, 0, blackBorad.Aahead, blackBorad.Afollow, blackBorad.AjuncStop,blackBorad.AemergStop];
                blackBorad.A = tempAccelVals(tempActOutput == 1);
            end
            
            
            %% assign BT output to acceleration
            randVal = rand();
            noiseRate = 0;
            if oppositeRoad.numCars > 0
                bbAccel = blackBorad.A;
                bbAccel = bbAccel + 2*bbAccel*noiseRate*randVal - bbAccel*noiseRate;
                obj.acceleration = bbAccel;
            else
                obj.acceleration = obj.idmAcceleration;
            end
            
            obj.bbValues.A(end+1)                      = obj.bb.A;
            obj.bbValues.Afollow(end+1)                = obj.bb.Afollow;
            obj.bbValues.AemergStop(end+1)             = obj.bb.AemergStop;
            obj.bbValues.AjuncStop(end+1)              = obj.bb.AjuncStop;
            obj.bbValues.Aahead(end+1)                 = obj.bb.Aahead;
            obj.bbValues.canPassAhead(end+1)           = obj.bb.canPassAhead;
            obj.bbValues.canPassBehind(end+1)          = obj.bb.canPassBehind;
            obj.bbValues.distToJunc(end+1)             = obj.bb.distToJunc;
            obj.bbValues.comfDistToJunc(end+1)         = obj.bb.comfDistToJunc;
            obj.bbValues.minStopDistToJunc(end+1)      = obj.bb.minStopDistToJunc;
            obj.bbValues.futureMinGap(end+1)           = obj.bb.futureMinGap;
            obj.bbValues.futureGap(end+1)              = obj.bb.futureGap;
            obj.bbValues.CarsOpposite(end+1)           = obj.bb.CarsOpposite;
            obj.bbValues.backOffTime(end+1)            = obj.bb.backOffTime;
            obj.bbValues.t(end+1)                      = obj.bb.t;
            obj.bbValues.isDeadlock(end+1)             = obj.bb.isDeadlock;
            obj.bbValues.frontCarPassedJunction(end+1) = obj.bb.frontCarPassedJunction;
            
            
            %%
            check_for_negative_velocity(obj,dt);
        end
        function [t_in, t_out] = calculate_t_in_and_out(obj,a,v,s,t,roadLength,varargin)
            
            crossingBegin = obj.s_in;
            crossingEnd = obj.s_out;
            
            if s <= crossingBegin
                d_in = crossingBegin - s;
                d_out = crossingEnd - s;
            elseif s >= crossingEnd
                d_in = crossingBegin - (s - roadLength);
                d_out = crossingEnd - (s - roadLength);
            elseif s > crossingBegin && s < crossingEnd
                d_in = 0;
                d_out = crossingEnd - s;
            end
            
            if  nargin == 7 % includes error tolerance for comp vehice 
                % opposite car time gap
                t_in = d_in/v + t;
                t_out = d_out/v + t;
            else
                % self time gap
                if abs(v) < 0.3 % 2 time steps vehicle uses accel to enter junction  
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
        function calculate_junc_accel(obj,varargin)
            if varargin{2} == 1     % emergency stop at junction
                stop_flag = 1;
                junc_flag = 0;
                emerg_flag = 0;
            elseif varargin{2} == 2 % normal junction stop
                stop_flag = 0;
                junc_flag = 1;
                emerg_flag = 0;
            else                    % emergency stop if not in junction
                stop_flag = 0;
                junc_flag = 0;
                emerg_flag = 1;
            end
            
            if stop_flag || junc_flag 
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
            

            if stop_flag % emergency stop at junction
                s_star = 0.1 + max(0,intelligentBreaking);
            elseif junc_flag % normal stop at junction
                s_star = 0.1 + max(0,intelligentBreaking);
            else % emergency stop if not in junction
                s_star = obj.minimumGap + max(0,intelligentBreaking);
            end
            
            velDif = obj.velocity/obj.targetVelocity;
            if isnan(velDif)
                velDif = 1;
            end
            
            obj.juncAccel = obj.a*(1 - (velDif)^obj.delta - (s_star/s)^2);
            
            % use lennard-jones if exceeded a_feas_min = 9 m/s^2
            if obj.juncAccel < obj.a_feas_min
                if (emerg_flag || stop_flag)
                    obj.juncAccel = -Lennard_Jones(s ,obj.a_feas_min);
                else
                    % BT logic excludes this from happening
                    % !! Test if ever get here !!
                    obj.juncAccel =  obj.a_feas_min;
                end
            end

        end
    end
end

