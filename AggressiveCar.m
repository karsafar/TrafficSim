classdef AggressiveCar < AutonomousCar
    
    properties (SetAccess = private)
        bb
        it_accel
        it_pose
        it_CarsOpposite
        it_a_stop_idm
        it_future_min_stop_gap
        it_future_gap
        it_dist_to_junc
        it_comf_dist_to_junc
        it_min_stop_dist_to_junc
        it_a_max_accel
        it_a_max_decel
        it_A_min_ahead
        it_A_max_behind
        it_a_idm
        it_frontCarPassedJunction
        full_tree
    end
    properties (SetAccess = public)
        BT_plot_flag = 0
    end
    methods
        function obj = AggressiveCar(varargin)
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
            obj.it_a_idm = obj.bb.add_item('idmAccel',obj.idmAcceleration);
            obj.it_a_max_accel = obj.bb.add_item('Amax',obj.maximumAcceleration(1));
            obj.it_a_max_decel = obj.bb.add_item('Amin',obj.maximumAcceleration(2));
            obj.it_pose = obj.bb.add_item('pose',obj.pose(1));
            obj.it_CarsOpposite = obj.bb.add_item('CarsOpposite',true);
            obj.it_a_stop_idm = obj.bb.add_item('Astop',obj.idmAcceleration);
            obj.it_future_min_stop_gap = obj.bb.add_item('futureMinGap',0);
            obj.it_future_gap = obj.bb.add_item('futureGap',1e5);
            obj.it_dist_to_junc = obj.bb.add_item('distToJunc',abs(obj.pose(1)-obj.s_in));
            obj.it_comf_dist_to_junc = obj.bb.add_item('comfDistToJunc',0);
            obj.it_min_stop_dist_to_junc = obj.bb.add_item('minStopDistToJunc',0);
            
            if isempty(obj.Prev) || obj.Prev.pose(1) > -1.125
                obj.it_frontCarPassedJunction = obj.bb.add_item('frontCarPassedJunction',true);
            else
                obj.it_frontCarPassedJunction = obj.bb.add_item('frontCarPassedJunction',false);
            end
            
            % Ahead logic
            assignAhead = BtAssign(obj.it_accel,obj.it_A_min_ahead);
            aheadCar = BtSequence(...
                obj.it_A_min_ahead > 0,...
                obj.it_A_min_ahead <= obj.it_a_max_accel,...
                assignAhead);
            aheadWithIdm = BtSequence(...
                obj.it_future_gap > obj.it_future_min_stop_gap,...
                obj.it_A_min_ahead <= 0,...
                BtAssign(obj.it_accel,obj.it_a_idm));
            
            % Behind logic
            assignBehind = BtAssign(obj.it_accel,obj.it_A_max_behind);
            behindWithIdm = BtSequence(...
                obj.it_future_gap > obj.it_future_min_stop_gap,...
                obj.it_A_max_behind > obj.it_a_idm,...
                BtAssign(obj.it_accel,obj.it_a_idm));
            
            behindOrIdm = BtSelector(obj.it_A_max_behind<=0,obj.it_A_max_behind<=obj.it_a_idm);
            behindCar = BtSequence(obj.it_A_max_behind>=obj.it_a_max_decel,behindOrIdm,assignBehind);
            
            % Emergency stop before the junction
            assignStop = BtAssign(obj.it_accel, obj.it_a_stop_idm);
            doEmergencyStop = BtSequence(obj.it_dist_to_junc >= obj.it_min_stop_dist_to_junc,assignStop);
            
            % normal IDM leading car following acceleration
            assignIdm = BtAssign(obj.it_accel,obj.it_a_idm);
            
            cruiseOutsideJunction = BtSequence(...
                obj.it_dist_to_junc > obj.it_comf_dist_to_junc,...
                obj.it_pose > obj.s_out,...
                assignIdm);
            stopBeforeJunction = BtSequence(...
                obj.it_frontCarPassedJunction == 1,...
                obj.it_future_gap < obj.it_future_min_stop_gap,...
                assignStop);
            followFrontCar = BtSelector(obj.it_CarsOpposite == 0,obj.it_dist_to_junc >= obj.it_min_stop_dist_to_junc);
            doIdm = BtSequence(obj.it_frontCarPassedJunction == 0,followFrontCar,assignIdm);

            doCruiseIdm = BtSelector(cruiseOutsideJunction,stopBeforeJunction,doIdm);
                        
            % Ahead or Behind logic
            Crossing = BtSelector(aheadWithIdm,aheadCar,behindWithIdm,behindCar);
            doJunctionAvoid = BtSequence(obj.it_future_gap > obj.it_future_min_stop_gap, Crossing);
            
            obj.full_tree = BtSelector(doCruiseIdm, doJunctionAvoid,doEmergencyStop);
        end
        %%
        function decide_acceleration(obj,oppositeRoad,roadLength,t,dt)
            oppositeCars = oppositeRoad.allCars;
            crossingBegin = obj.s_in;
            crossingEnd = obj.s_out;
            tol = 5e-2;
            
            % impatience parameter
            if obj.historyIndex >= 50 && obj.pose(1) <= crossingBegin && tol > abs(obj.velocity) && tol > abs(obj.acceleration) && obj.maximumAcceleration(1) < 5 &&...
                    (isempty(obj.Prev) || obj.Prev.pose(1) < obj.pose(1) ||  obj.Prev.pose(1)> crossingEnd) && oppositeRoad.numCars > 0
                obj.maximumAcceleration(1) = obj.maximumAcceleration(1) + 0.05;
            elseif obj.maximumAcceleration(1) ~= 3.5 && obj.pose(1) > crossingEnd
                obj.maximumAcceleration(1) = 3.5;
            end
            
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
                
                %% what is that for??????????????
                if ~isempty(obj.Prev) && (obj.Prev.pose(1) > -1.125) && (obj.Prev.pose(1) < crossingEnd)
                    calculate_idm_accel(obj,roadLength,1)
                end
                
                if ~isempty(oppositeCars(ind).Next)
                    calc_a_min_ahead(obj,t,dt,oppositeCars(ind).Next);
                else
                    obj.acc_min_ahead = -1e3;
                end
                
                calc_a_max_behind(obj,t,dt,obj.acc_min_ahead,oppositeCars(ind));
                
                calc_a_min_ahead(obj,t,dt,oppositeCars(ind));
                
                obj.it_A_min_ahead.set_value(obj.acc_min_ahead);
                obj.it_A_max_behind.set_value(obj.acc_max_behind);
            end
            
            obj.it_a_idm.set_value(obj.idmAcceleration);
            obj.it_a_max_accel.set_value(obj.maximumAcceleration(1)+tol);
            obj.it_a_max_decel.set_value(obj.maximumAcceleration(2)-tol);
            if obj.pose(1) > crossingBegin
                obj.it_dist_to_junc.set_value(abs(min(0,obj.pose(1)-crossingBegin-roadLength)));
            else
                obj.it_dist_to_junc.set_value(abs(min(0,obj.pose(1)-crossingBegin)));
            end
            comfortableStopGap = calc_safe_gap(obj.a,obj.b,obj.velocity,obj.targetVelocity,obj.timeGap,0.1,obj.delta,-obj.b)+10;
            obj.it_comf_dist_to_junc.set_value(comfortableStopGap);
            
            minStopDistGapToJunc = calc_safe_gap(obj.a,obj.b,obj.velocity,obj.targetVelocity,obj.timeGap,0,obj.delta,obj.maximumAcceleration(2),1);
            obj.it_min_stop_dist_to_junc.set_value(minStopDistGapToJunc);
            
            obj.it_pose.set_value(obj.pose(1));
            obj.it_CarsOpposite.set_value(notAllCarsPassedJunction);
            
            if isnan(obj.t_in)
                accel_out = obj.idmAcceleration;
                obj.juncExitVelocity = min(obj.maximumVelocity,sqrt(max(0,obj.velocity^2+2*accel_out*(crossingEnd-obj.pose(1)))));
                t_out_self_ahead = (obj.juncExitVelocity - obj.velocity)/accel_out+t;
                futureMinStopGap = calc_safe_gap(obj.a,obj.b,obj.juncExitVelocity,obj.targetVelocity,obj.timeGap,obj.minimumGap,obj.delta,obj.maximumAcceleration(2));
            else
                t_out_self_ahead = obj.t_in;
                futureMinStopGap = calc_safe_gap(obj.a,obj.b,obj.juncExitVelocity,obj.targetVelocity,obj.timeGap,obj.minimumGap,obj.delta,obj.maximumAcceleration(2),1);
            end
            
            if obj.pose(1) < crossingEnd && ~isempty(obj.Prev)

                sPrev = obj.Prev.pose(1);
                vPrev = obj.Prev.velocity;
                aPrev = obj.Prev.acceleration;
                if sPrev > crossingEnd
                    futureGap = (sPrev + vPrev*(t_out_self_ahead-(t+dt)) + 0.5*aPrev*(t_out_self_ahead-(t+dt))^2) - crossingEnd;
                elseif sPrev < crossingBegin && sPrev < obj.pose(1)
                    futureGap = (sPrev + roadLength + vPrev*(t_out_self_ahead-(t+dt)) + 0.5*aPrev*(t_out_self_ahead-(t+dt))^2) - crossingEnd;
                else
                    futureGap = 0;
                end
            else
                futureGap = 1e5;
            end
            obj.it_future_min_stop_gap.set_value(futureMinStopGap);
            obj.it_future_gap.set_value(futureGap)
            
            if isempty(obj.Prev) || obj.Prev.pose(1) > -1.125 || obj.Prev.pose(1) < obj.pose(1)
                obj.it_frontCarPassedJunction.set_value(true);
            else
                obj.it_frontCarPassedJunction.set_value(false);
            end
            
            calculate_idm_accel(obj,roadLength,1)
            obj.it_a_stop_idm.set_value(obj.idmAcceleration);
            
            % update BT
            obj.full_tree.tick;
            obj.acceleration =  obj.it_accel.get_value;

%             if obj.pose(1) > -6.5 && obj.pose(1) < crossingBegin
%                 obj.BT_plot_flag = 1;
%             else
%                 obj.BT_plot_flag = 0;
%             end

            % draw BT
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
            % check for negative velocities
            check_for_negative_velocity(obj,dt);
        end
    end
end

