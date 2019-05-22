classdef carTypeB < AutonomousCar
    
    properties (SetAccess = public)
        bb
        it_accel
        it_CarsOpposite
        it_a_emerg_stop
        it_a_junc_stop
        it_future_min_stop_gap
        it_future_gap
        it_dist_to_junc
        it_comf_dist_to_junc
        it_min_stop_dist_to_junc
        it_a_max_accel
        it_a_max_decel
        it_A_min_ahead
        it_A_max_behind
        it_a_follow
        it_frontCarPassedJunction
        it_backOffTime
        it_currentTime
        full_tree
        juncAccel
    end
    properties (SetAccess = public)
        BT_plot_flag = 0
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
            %-----------------Initialize Blackboard------------------
            obj.bb = BtBlackboard;
            obj.it_accel = obj.bb.add_item('A',obj.acceleration);
            obj.it_A_min_ahead = obj.bb.add_item('AminAhead',0);
            obj.it_A_max_behind = obj.bb.add_item('AmaxBehind',0);
            obj.it_a_follow = obj.bb.add_item('Afollow',obj.idmAcceleration);
            obj.it_a_max_accel = obj.bb.add_item('Amax',obj.a_max);
            obj.it_a_max_decel = obj.bb.add_item('Amin',obj.a_min);
            obj.it_CarsOpposite = obj.bb.add_item('CarsOpposite',true);
            obj.it_a_emerg_stop = obj.bb.add_item('AemergStop',obj.idmAcceleration);
            obj.it_a_junc_stop = obj.bb.add_item('AjuncStop',obj.idmAcceleration);
            obj.it_future_min_stop_gap = obj.bb.add_item('futureMinGap',0);
            obj.it_future_gap = obj.bb.add_item('futureGap',1e5);
            obj.it_dist_to_junc = obj.bb.add_item('distToJunc',abs(obj.pose(1)-obj.s_in));
            obj.it_comf_dist_to_junc = obj.bb.add_item('comfDistToJunc',0);
            obj.it_min_stop_dist_to_junc = obj.bb.add_item('minStopDistToJunc',0);
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
            % 'Cross Behind' Tree
            assignBehind = BtAssign(obj.it_accel,obj.it_A_max_behind);
            behindWithIdm = BtSequence(...
                obj.it_A_max_behind > obj.it_a_follow,...
                BtAssign(obj.it_accel,obj.it_a_follow));
            
            behindOrIdm = BtSelector(obj.it_A_max_behind<=0,obj.it_A_max_behind<=obj.it_a_follow);
            behindCar = BtSequence(obj.it_A_max_behind>=obj.it_a_max_decel,behindOrIdm,assignBehind);
            % 'Cross Ahead' Tree
            assignAhead = BtAssign(obj.it_accel,obj.it_A_min_ahead);
            aheadCar = BtSequence(...
                obj.it_A_min_ahead > 0,...
                obj.it_A_min_ahead <= obj.it_a_max_accel,...
                assignAhead);
            aheadWithIdm = BtSequence(...
                obj.it_A_min_ahead <= 0,...
                BtAssign(obj.it_accel,obj.it_a_follow));
            % Choose 'Ahead or Behind' Tree
            Crossing = BtSelector(aheadWithIdm,aheadCar,behindWithIdm,behindCar);
            doJunction = BtSequence(obj.it_future_gap > obj.it_future_min_stop_gap, Crossing);
            
            %% 'Emengency Stop' Tree
            assignStop = BtAssign(obj.it_accel, obj.it_a_emerg_stop);
            
            %% random back-off
            assignZero = BtAssign(obj.it_accel, 0);
            backOff = BtSequence(obj.it_backOffTime > obj.it_currentTime,assignZero);
            %% Full Behaviour Tree
            obj.full_tree = BtSelector(DoCruise,keepJunctionClear,backOff,doJunction,assignStop);
%             obj.full_tree = BtSelector(DoCruise,backOff,Crossing,assignStop);
% 
%             Crossing_lazy = BtSelector(aheadWithIdm,behindWithIdm,aheadCar,behindCar);
%             doLazyJunction = BtSequence(obj.it_future_gap > obj.it_future_min_stop_gap, Crossing_lazy);
%             obj.full_tree = BtSelector(DoCruise,keepJunctionClear,backOff,doLazyJunction,assignStop);


%             figure(5)
%             tempGraph = gca;
%             plot(obj.full_tree,tempGraph)
        end
        %%
        function decide_acceleration(obj,oppositeRoad,roadLength,t,dt)
            oppositeCars = oppositeRoad.allCars;
            crossingBegin = obj.s_in;
            crossingEnd = obj.s_out;
%             tol = 5e-6;
               tol = 0; 
            
%             % impatience parameter
%             if obj.historyIndex >= 50 && obj.pose(1) <= crossingBegin && tol > abs(obj.velocity) && tol > abs(obj.acceleration) && obj.a_max < 5 &&...
%                     (isempty(obj.Prev) || obj.Prev.pose(1) < obj.pose(1) ||  obj.Prev.pose(1)> crossingEnd) && oppositeRoad.numCars > 0
%                 obj.a_max = obj.a_max + 0.05;
%             elseif obj.a_max ~= 3.5 && obj.pose(1) > crossingEnd
%                 obj.a_max = 3.5;
%             end
            
            if oppositeRoad.numCars == 0
                % if no cars on competing arm
                notAllCarsPassedJunction = false;
            else

                s_op = oppositeRoad.allCarsStates(1,:);
                
                oppositeDistToJunc = crossingEnd - s_op;
                % 0 - all competing cars passed junction 1 - not all passed
                notAllCarsPassedJunction = any(oppositeDistToJunc > 0);
                
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
                
                obj.it_A_min_ahead.set_value(obj.acc_min_ahead);
                obj.it_A_max_behind.set_value(obj.acc_max_behind);
            end
            
            obj.it_a_follow.set_value(obj.idmAcceleration);
            obj.it_a_max_accel.set_value(obj.a_max+tol);
            obj.it_a_max_decel.set_value(obj.a_min-tol);

            if obj.pose(1) > crossingBegin
                selfDistToJunc = crossingBegin-obj.pose(1)+roadLength;
            else
                selfDistToJunc = crossingBegin-obj.pose(1);
           end
           obj.it_dist_to_junc.set_value(selfDistToJunc);
            
            %%
            if obj.pose(1) <= crossingEnd && obj.pose(1) >= crossingBegin
                comfortableStopGap = 9999;
            else
                comfortableStopGap = calc_safe_gap(obj.a,obj.b,obj.velocity,obj.targetVelocity,obj.timeGap,0.1,obj.delta,-obj.b)+10;
            end
            obj.it_comf_dist_to_junc.set_value(comfortableStopGap);
            
            if obj.pose(1) >  crossingBegin && obj.pose(1) < crossingEnd
                minStopDistGapToJunc = -1e5;
            else  
                minStopDistGapToJunc = calc_safe_gap(obj.a,obj.b,obj.velocity,obj.targetVelocity,obj.timeGap,0,obj.delta,obj.a_feas_min,1);
            end
            obj.it_min_stop_dist_to_junc.set_value(minStopDistGapToJunc);
            
            obj.it_CarsOpposite.set_value(notAllCarsPassedJunction);
           
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
            
            if obj.pose(1) < crossingEnd && ~isempty(obj.Prev)
                sPrev = obj.Prev.pose(1);
                vPrev = obj.Prev.velocity;
                %aPrev = obj.Prev.acceleration;
                if sPrev > crossingBegin
                    futureGap = (sPrev + vPrev*(t_out_self_ahead-(t+dt))) - crossingEnd;
                elseif sPrev < crossingBegin && sPrev < obj.pose(1)
                    futureGap = (sPrev + roadLength + vPrev*(t_out_self_ahead-(t+dt))) - crossingEnd;
                else
                    futureGap = 0;
                end
            else
                futureGap = 1e5;
            end
            obj.it_future_min_stop_gap.set_value(futureMinStopGap);
            obj.it_future_gap.set_value(futureGap)
            
            %% is frot car passed junction?
            obj.it_frontCarPassedJunction = obj.bb.add_item('frontCarPassedJunction',...
                (isempty(obj.Prev) || obj.Prev.pose(1) > 0.825 || obj.Prev.pose(1) < obj.pose(1)));
   
            %% stop at junction
            calculate_junc_accel(obj,roadLength,2)
            obj.it_a_junc_stop.set_value(obj.juncAccel);
           
            %% Change this logic for emergency stop
            if obj.pose(1) < crossingBegin
                calculate_junc_accel(obj,roadLength,1)
            else
                calculate_junc_accel(obj,roadLength,3)
            end
            obj.it_a_emerg_stop.set_value(obj.juncAccel);
            
            %%  Random Back-off
            obj.it_currentTime.set_value(t);
            if abs(obj.velocity)< 0.001 && abs(selfDistToJunc) < 0.1 ...
                    && abs(oppositeCars(ind).velocity)< 0.001 &&...
                    abs(s_op(ind)-obj.s_in) < 0.1 && obj.it_backOffTime.get_value < t-dt
                obj.it_backOffTime.set_value(t + (randi(21)-1)/10);
            end
            
            %% update BT
            obj.full_tree.tick;
            obj.acceleration =  obj.it_accel.get_value;
            
            %% draw BT
            if obj.BT_plot_flag
                tempGraph = gca;
                if isempty(tempGraph.Parent.Number) || tempGraph.Parent.Number ~= 5
                    figure(5)
                else
                    clf(tempGraph.Parent)
                end
                plot(obj.full_tree,tempGraph)
                obj.bb
                sprintf("Junction Exit Velocity = %.4f\n Comfortable Stop Gap = %.4f\n Emergency Stop Gap = %.4f \n Future Emergency Stop Gap = %.4f",...
                    obj.juncExitVelocity,comfortableStopGap,minStopDistGapToJunc,futureMinStopGap)
            end
            %% check for negative velocities
            check_for_negative_velocity(obj,dt);
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

