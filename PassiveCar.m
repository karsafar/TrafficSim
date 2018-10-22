classdef PassiveCar < AutonomousCar
    
    properties (SetAccess = private)
        bb
        it_accel
        it_pose
        it_CarsOpposite
        it_a_stop_idm
        it_future_emerg_gap
        it_future_gap
        it_dist_to_junc
        it_comf_dist_to_junc
        it_emerg_dist_to_junc
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
        function obj = PassiveCar(varargin)
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
            obj.it_future_emerg_gap = obj.bb.add_item('futureEmergGap',0);
            obj.it_future_gap = obj.bb.add_item('futureGap',1e5);
            obj.it_dist_to_junc = obj.bb.add_item('distToJunc',abs(obj.pose(1)-obj.s_in));
            obj.it_comf_dist_to_junc = obj.bb.add_item('comfDistToJunc',0);
            obj.it_emerg_dist_to_junc = obj.bb.add_item('emergDistToJunc',0);
            
            if isempty(obj.Prev) || obj.Prev.pose(1) > obj.s_out
                obj.it_frontCarPassedJunction = obj.bb.add_item('frontCarPassedJunction',true);
            else
                obj.it_frontCarPassedJunction = obj.bb.add_item('frontCarPassedJunction',false);
                
            end
            
            % Ahead logic
            assignAhead = BtAssign(obj.it_accel,obj.it_A_min_ahead);
            aheadCar = BtSequence(...
                obj.it_A_min_ahead>=0,...
                obj.it_A_min_ahead<=obj.it_a_max_accel,...
                assignAhead);
            aheadWithIdm = BtSequence(obj.it_future_gap > obj.it_future_emerg_gap,obj.it_A_min_ahead<0, BtAssign(obj.it_accel,obj.it_a_idm));

            % Behind logic
            assignBehind = BtAssign(obj.it_accel,obj.it_A_max_behind);
            behindWithIdm = BtSequence(obj.it_future_gap > obj.it_future_emerg_gap,obj.it_A_max_behind>obj.it_a_idm, BtAssign(obj.it_accel,obj.it_a_idm));

            behindOrIdm = BtSelector(obj.it_A_max_behind<=0,obj.it_A_max_behind<=obj.it_a_idm);
            behindCar = BtSequence(obj.it_A_max_behind>=obj.it_a_max_decel,obj.it_A_min_ahead>=obj.it_a_max_decel,behindOrIdm,assignBehind);
            
            % Emergency stop before the junction
            assignEmergencyStop = BtAssign(obj.it_accel,obj.it_a_stop_idm);
            doEmergencyStop = BtSequence(obj.it_dist_to_junc >= obj.it_emerg_dist_to_junc,assignEmergencyStop);
            
            % normal IDM leading car following acceleration
            assignIdm = BtAssign(obj.it_accel,obj.it_a_idm);
            IsEmergStopAvailable = BtSequence(obj.it_frontCarPassedJunction==0,...
                obj.it_dist_to_junc >= obj.it_emerg_dist_to_junc);
            
            cruise = BtSelector(obj.it_dist_to_junc > obj.it_comf_dist_to_junc ,...
                obj.it_pose > obj.s_out,...
                obj.it_CarsOpposite == 0, ...
                IsEmergStopAvailable);
            doCruiseIdm = BtSequence(cruise,assignIdm);
            
            % Ahead or Behind logic
            Crossing = BtSelector(behindWithIdm,behindCar,aheadWithIdm,aheadCar);
            doJunctionAvoid = BtSequence(obj.it_future_gap > obj.it_future_emerg_gap, Crossing);
            
            obj.full_tree = BtSelector(doCruiseIdm, doJunctionAvoid,doEmergencyStop);
        end
        %%
        function decide_acceleration(obj,oppositeRoad,roadLength,t,dt)
            if oppositeRoad.numCars == 0
                % if no cars on competing arm
                obj.acceleration = obj.idmAcceleration;
            else
                oppositeCars = oppositeRoad.allCars;
                crossingBegin = obj.s_in;
                crossingEnd = obj.s_out;
                tol = 1e-2;
                
                % impatience parameter
                if obj.historyIndex >= 50 && obj.pose(1) <= crossingBegin && tol > abs(obj.velocity) && tol > abs(obj.acceleration) && obj.maximumAcceleration(1) < 7 &&...
                        (isempty(obj.Prev) || obj.Prev.pose(1) < obj.pose(1) ||  obj.Prev.pose(1)> crossingEnd )
                    obj.maximumAcceleration(1) = obj.maximumAcceleration(1) + 0.05;
                elseif obj.maximumAcceleration(1) ~= 3.5 && obj.pose(1) > crossingEnd
                    obj.maximumAcceleration(1) = 3.5;
                end
                
                %% 
                oppositeDistToJunc = NaN(oppositeRoad.numCars,1);
                for jCar = 1:oppositeRoad.numCars
                    oppositeDistToJunc(jCar) = crossingEnd - oppositeCars(jCar).pose(1);
                end
                % 0 - all competing cars passed junction 1 - not all passed
                notAllCarsPassedJunction = any(oppositeDistToJunc > 0);
                
                % inf - passed junction
                oppositeDistToJunc(oppositeDistToJunc<0) = inf;
                [~, ind] = min(oppositeDistToJunc);
                
                if ~isempty(obj.Prev) && (obj.Prev.pose(1) > obj.s_in) && (obj.Prev.pose(1) < obj.s_out)
                    calculate_idm_accel(obj,roadLength,1)
                end
                
                if ~isempty(oppositeCars(ind).Next)
                    calc_a_min_ahead(obj,t,dt,oppositeCars(ind).Next);
                else
                    obj.acc_min_ahead = -1e3;
                end
                
                calc_a_max_behind(obj,t,dt,obj.acc_min_ahead,oppositeCars(ind));
                
                calc_a_min_ahead(obj,t,dt,oppositeCars(ind));
                
                
                %-----------------Update the Blackboard------------------%
                obj.it_A_min_ahead.set_value(obj.acc_min_ahead);
                obj.it_A_max_behind.set_value(obj.acc_max_behind);
                obj.it_a_idm.set_value(obj.idmAcceleration);
                obj.it_a_max_accel.set_value(obj.maximumAcceleration(1)+tol);
                obj.it_a_max_decel.set_value(obj.maximumAcceleration(2)-tol);
                obj.it_dist_to_junc.set_value(abs(min(0,obj.pose(1)-obj.s_in)));
                comfortableStopGap = calc_safe_gap(obj.a,obj.b,obj.velocity,obj.targetVelocity,obj.timeGap,0.1,obj.delta,-obj.b)+10;
                obj.it_comf_dist_to_junc.set_value(comfortableStopGap);
                
                emergencyStopGap = calc_safe_gap(obj.a,obj.b,obj.velocity,obj.targetVelocity,obj.timeGap,0,obj.delta,obj.maximumAcceleration(2),1);
                obj.it_emerg_dist_to_junc.set_value(emergencyStopGap);
                
                obj.it_pose.set_value(obj.pose(1));
                obj.it_CarsOpposite.set_value(notAllCarsPassedJunction);
                
                futureEmergencyStopGap = calc_safe_gap(obj.a,obj.b,obj.juncExitVelocity,obj.targetVelocity,obj.timeGap,obj.minimumGap,obj.delta,obj.maximumAcceleration(2),1);
                obj.it_future_emerg_gap.set_value(futureEmergencyStopGap);
                                
                if obj.pose(1) < obj.s_out && ~isempty(obj.Prev) && ~isnan(obj.t_in)
                    if obj.Prev.pose(1) > 0
                        futureGap = obj.Prev.pose(1) + obj.Prev.velocity*(obj.t_in-(t+dt)) + 0.5*obj.Prev.acceleration*(obj.t_in-(t+dt))^2 - obj.s_out;
                    elseif obj.Prev.pose(1) < 0
                        futureGap = obj.Prev.pose(1) + roadLength + obj.Prev.velocity*(obj.t_in-(t+dt)) + 0.5*obj.Prev.acceleration*(obj.t_in-(t+dt))^2 - obj.s_out;
                    end
                    elseif ~isempty(obj.Prev)
                    futureGap = obj.Prev.pose(1) + obj.Prev.velocity*dt + 0.5*obj.Prev.acceleration*dt^2 - obj.s_out;
                else
                    futureGap = 1e5;
                end
                obj.it_future_gap.set_value(futureGap)
                
                if isempty(obj.Prev) || obj.Prev.pose(1) > crossingEnd || obj.Prev.pose(1) < obj.pose(1)
                    obj.it_frontCarPassedJunction.set_value(true);
                else
                    obj.it_frontCarPassedJunction.set_value(false);
                end
                
                calculate_idm_accel(obj,roadLength,1)
                obj.it_a_stop_idm.set_value(obj.idmAcceleration);
                
                % update BT
                obj.full_tree.tick;
                obj.acceleration =  obj.it_accel.get_value;
                
%                 if obj.pose(1) > -8 && obj.pose(1) < obj.s_in
%                     obj.BT_plot_flag = 1;
%                 else
%                     obj.BT_plot_flag = 0;
%                 end
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
                         obj.juncExitVelocity,comfortableStopGap,emergencyStopGap,futureEmergencyStopGap)
                end
            end
            % check for negative velocities
            check_for_negative_velocity(obj,dt);
        end
    end
end

