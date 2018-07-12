classdef AggressiveCar < IdmCar
    
    properties (SetAccess = private)
        bb
        it_accel
        it_pose
        it_CarsOpposite
        it_a_stop_idm
        it_dist_gap
        it_front_car_vel
        it_a_max_accel
        it_a_max_decel
        it_A_min_ahead
        it_A_max_behind
        it_a_idm
        it_frontCarPassedJunction
        full_tree
    end
    methods
        function obj = AggressiveCar(varargin)
            if nargin == 4
                orientation = varargin{1};
                startPoint = varargin{2};
                Width = varargin{3};
                dt = varargin{4};
            end
            obj = obj@IdmCar(orientation, startPoint, Width,dt);
            
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
            obj.it_dist_gap = obj.bb.add_item('distGap',obj.s);
            obj.it_front_car_vel = obj.bb.add_item('frontCarVel',0);
            
            if isempty(obj.Prev) || obj.Prev.pose(1) > obj.s_out
                obj.it_frontCarPassedJunction = obj.bb.add_item('frontCarPassedJunction',true);
            else
                obj.it_frontCarPassedJunction = obj.bb.add_item('frontCarPassedJunction',false);
                
            end
            
            %-------------------intersection collision avoidance-------------------
            assignAhead = BtAssign(obj.it_accel,obj.it_A_min_ahead);
            aheadCar = BtSequence(...
                obj.it_A_min_ahead>=0,...
                obj.it_A_min_ahead<=(obj.it_a_max_accel),...
                assignAhead);
            assignZero = BtAssign(obj.it_accel,obj.it_A_max_behind);
            stopCar = BtSequence(...
                obj.it_A_max_behind>=0,...
                obj.it_A_max_behind<obj.it_a_idm, assignZero);
            
            assignBehind = BtAssign(obj.it_accel,obj.it_A_max_behind);
            
            behindCar = BtSequence(...
                obj.it_A_max_behind<0,...
                obj.it_A_min_ahead>=obj.it_a_max_decel,...
                obj.it_A_max_behind>=obj.it_a_max_decel,...
                obj.it_A_max_behind<obj.it_a_idm, assignBehind);
            
            goCar = BtSequence(obj.it_A_min_ahead<0, BtAssign(obj.it_accel,obj.it_a_idm));
            
            Crossing = BtSelector(aheadCar,stopCar,behindCar,goCar);
            
            cruise_idm = BtAssign(obj.it_accel,obj.it_a_idm);
            
            cruise = BtSelector(obj.it_pose < -50,...
                obj.it_pose > obj.s_out,...
                obj.it_CarsOpposite == 0, ...
                obj.it_frontCarPassedJunction==0);
            
            doCruiseIdm = BtSequence(cruise,cruise_idm);
            
            enoughAfterJuncSpace = BtSelector(obj.it_front_car_vel > 2, obj.it_dist_gap > 15);
            
            doJunctionAvoid = BtSequence(enoughAfterJuncSpace, Crossing);
            
            
            assignEmergencyStop = BtAssign(obj.it_accel,obj.it_a_stop_idm);
            EmergencyStop = BtSequence(obj.it_pose < obj.s_in,assignEmergencyStop);
            emergencyStopOrCrossing = BtSelector(doJunctionAvoid,EmergencyStop);
            
            obj.full_tree = BtSelector(doCruiseIdm, emergencyStopOrCrossing);
            
        end
        %%
        function decide_acceleration(obj,oppositeRoad,t,dt)
            oppositeCars = oppositeRoad.allCars;
            crossingBegin = obj.s_in;
            crossingEnd = obj.s_out;
            oppositeDistToJunc = NaN(oppositeRoad.numCars,1);
            tol = 1e-3;
            
            % unpatiance parameter
            if obj.historyIndex >= 50 && obj.pose(1) <= crossingBegin && tol > abs(obj.velocity) && tol > abs(obj.acceleration) && obj.maximumAcceleration(1) < 8 &&...
                    (isempty(obj.Prev) || obj.Prev.pose(1) < obj.pose(1) ||  obj.Prev.pose(1)> crossingEnd )
               obj.maximumAcceleration(1) = obj.maximumAcceleration(1) + 0.05;
            elseif obj.maximumAcceleration(1) ~= 3.5 && obj.pose(1) > crossingEnd
                obj.maximumAcceleration(1) = 3.5;
            end
            %% seperate function find opposite car
            for jCar = 1:oppositeRoad.numCars
                oppositeDistToJunc(jCar) = crossingEnd - oppositeCars(jCar).pose(1);
            end
            if  all(oppositeDistToJunc <= 0)
                allPassedJunction = 1;
            else
                allPassedJunction = 0;
            end
            oppositeDistToJunc(oppositeDistToJunc<0) = inf;
            [m, ind] = min(oppositeDistToJunc);
            oppositeCarPose = oppositeCars(ind).pose(1);
            if strcmpi(obj.parentRoad,'horizontal') || t == 0
                oppositeCarAcceleration = oppositeCars(ind).acceleration;
                if ~isempty(oppositeCars(ind).Next)
                    oppositeNextCarAcceleration = oppositeCars(ind).Next.acceleration;
                end
            else
                oppositeCarAcceleration = oppositeCars(ind).accelerationHistory(oppositeCars(ind).historyIndex-1);
                if ~isempty(oppositeCars(ind).Next)
                    oppositeNextCarAcceleration = oppositeCars(ind).Next.accelerationHistory(oppositeCars(ind).Next.historyIndex-1);
                end
            end
            %%
            %%
            if tol > (oppositeCars(ind).velocity - 0) && tol > abs(obj.velocity) &&...
                    t > 0 && (isempty(obj.Prev) || obj.Prev.pose(1) < obj.pose(1) ||  obj.Prev.pose(1)>crossingBegin )
                %%  %-----------------Both cars stopped at junction------------------%
                if oppositeRoad.priority == false
                    if  isempty(obj.Prev)
                        obj.acceleration = obj.maximumAcceleration(1);
                    else
                        calculate_idm_accel(obj,oppositeRoad.Length)
                        obj.acceleration = obj.idmAcceleration;
                    end
                else
                    obj.acceleration = 0;
                end
                
            else
                %% %-----------------Collision Avoidance BT------------------%
                T_safe = 0.1;
                tol = 1e-6;
                if tol < abs(oppositeCarAcceleration) && ((oppositeCars(ind).velocity)^2+2*oppositeCarAcceleration*(crossingBegin-oppositeCarPose)) > 0
                    t_in = (-oppositeCars(ind).velocity+sqrt((oppositeCars(ind).velocity)^2+2*oppositeCarAcceleration...
                        *(crossingBegin-oppositeCarPose)))/oppositeCarAcceleration+t-3*T_safe;
                    
                    t_out = (-oppositeCars(ind).velocity+sqrt((oppositeCars(ind).velocity)^2+2*oppositeCarAcceleration...
                        *(crossingEnd-oppositeCarPose)))/oppositeCarAcceleration+t+3*T_safe*0;
                elseif tol > abs(oppositeCarAcceleration) && tol > oppositeCars(ind).velocity || ((oppositeCars(ind).velocity)^2+2*oppositeCarAcceleration*(crossingBegin-oppositeCarPose)) > 0
                    t_in = 99999;
                    t_out = 99999;
                else
                    t_in = (crossingBegin - oppositeCarPose)/oppositeCars(ind).velocity+t-3*T_safe;
                    t_out = (crossingEnd - oppositeCarPose)/oppositeCars(ind).velocity+t+3*T_safe*0;
                end
                
                if ~isempty(oppositeCars(ind).Next) && oppositeCars(ind).Next.pose(1) <= obj.s_in && ((oppositeCars(ind).Next.velocity)^2+2*oppositeNextCarAcceleration*(crossingBegin-oppositeCars(ind).Next.pose(1))) > 0
                    if tol < abs(oppositeNextCarAcceleration)
                        t_in_next = (-oppositeCars(ind).Next.velocity+sqrt((oppositeCars(ind).Next.velocity)^2+2*oppositeNextCarAcceleration...
                            *(crossingBegin-oppositeCars(ind).Next.pose(1))))/oppositeNextCarAcceleration+t-3*T_safe;
                    elseif tol > abs(oppositeNextCarAcceleration) && tol > oppositeCars(ind).Next.velocity || ((oppositeCars(ind).Next.velocity)^2+2*oppositeNextCarAcceleration*(crossingBegin-oppositeCars(ind).Next.pose(1))) > 0
                        t_in_next = 99999;
                    else
                        t_in_next = (crossingBegin - oppositeCars(ind).Next.pose(1))/oppositeCars(ind).Next.velocity+t+3*T_safe*0;
                    end
                    
                    A_min_ahead_next = obj.calc_a_min_ahead(...
                        t,...
                        dt,...
                        obj.maximumAcceleration,...
                        obj.velocity,...
                        obj.maximumVelocity,...
                        t_in_next,...
                        crossingEnd,...
                        obj.pose(1));
                else
                    A_min_ahead_next = -9999;
                end
                
                if isinf(t_in) || isnan(t_in)
                    A_min_ahead = -9999;
                    A_max_behind = 9999;
                else
                    
                    A_max_behind = obj.calc_a_max_behind(...
                        t,...
                        dt,...
                        obj.maximumAcceleration,...
                        obj.velocity,...
                        t_out,...
                        crossingBegin,...
                        obj.pose(1),...
                        A_min_ahead_next);
                    
                    A_min_ahead = obj.calc_a_min_ahead(...
                        t,...
                        dt,...
                        obj.maximumAcceleration,...
                        obj.velocity,...
                        obj.maximumVelocity,...
                        t_in,...
                        crossingEnd,...
                        obj.pose(1));
                end
                
                %-----------------Update the Blackboard------------------%
                obj.it_A_min_ahead.set_value(A_min_ahead);
                obj.it_A_max_behind.set_value(A_max_behind);
                obj.it_a_idm.set_value(obj.idmAcceleration);
                obj.it_a_max_accel.set_value(obj.maximumAcceleration(1)+0.1);
                obj.it_a_max_decel.set_value(obj.maximumAcceleration(2)-0.1);
                obj.it_pose.set_value(obj.pose(1));
                obj.it_CarsOpposite.set_value(~isempty(oppositeCars) && allPassedJunction==0);
                obj.it_dist_gap.set_value(obj.s);
                
                if isempty(obj.Prev)
                    obj.it_front_car_vel.set_value(obj.targetVelocity);
                else
                    obj.it_front_car_vel.set_value(obj.Prev.velocity);
                end
                
                if isempty(obj.Prev) || obj.Prev.pose(1) > crossingEnd || obj.Prev.pose(1) < obj.pose(1)
                    obj.it_frontCarPassedJunction.set_value(true);
                else
                    obj.it_frontCarPassedJunction.set_value(false);
                end
                
                obj.modifyIdm(1);
                calculate_idm_accel(obj,oppositeRoad.Length,1)
                obj.it_a_stop_idm.set_value(obj.idmAcceleration);
                obj.modifyIdm(0);
                
                obj.full_tree.tick;
                obj.acceleration =  obj.it_accel.get_value;
                %                             break
                %                                                     h5 = figure(5);
                %                             set(h5,'units', 'normalized', 'outerposition',[0 0 1 1])
                %                                                     plot(obj.full_tree,0);
                %                             pause()
                %                             cla(obj.full_tree.ha);
                %                             delete(obj.full_tree.ha)
                %                             close(h5);
            end
        end
    end
    methods (Static)
        function accelerationToPassAhead = calc_a_min_ahead(t,dt,a_max,v,v_max,t_in,s_out,s)
            if (t+dt) <= t_in && s >= s_out-v_max*(t_in-(t+dt))
                
                minimumAccelerationToPassAhead = (s_out - 0.5*a_max(1)*(t_in-(t+dt))^2 - v*(t_in-t) - s)/ (dt*(t_in-(t+dt/2)));
                junctionExitVelocity  = (v + minimumAccelerationToPassAhead*dt) + a_max(1)*(t_in-(t+dt));
                
                minimumAccelerationToReachMaxVel = (-sqrt((v_max-v+0.5*a_max(1)*dt)^2-2*a_max(1)*(s_out-...
                    v_max*(t_in-(t+dt))-s-v*dt)-v_max^2+2*v*v_max-v^2)+v_max-v+0.5*a_max(1)*dt)/dt;
                
                if junctionExitVelocity > v_max || minimumAccelerationToReachMaxVel < minimumAccelerationToPassAhead
                    accelerationToPassAhead = minimumAccelerationToReachMaxVel;
                elseif minimumAccelerationToReachMaxVel >= minimumAccelerationToPassAhead
                    accelerationToPassAhead = minimumAccelerationToPassAhead;
                else
                    accelerationToPassAhead = 9999;
                end
            else
                accelerationToPassAhead = 9999;
            end
        end
        function accelerationToPassBehind = calc_a_max_behind(t,dt,a_max,v,t_out,s_in,s,A_min_ahead_next)
            
            if  s <= s_in
                maximumAccelerationToPassBehind = (s_in - 0.5*a_max(2)*(t_out-(t+dt))^2 -...
                    v*(t_out-t) - s)/ (dt*(t_out-(t+dt/2)));
                junctionExitVelocity = (v + maximumAccelerationToPassBehind*dt) + a_max(2)*(t_out-(t+dt));
                
                maximumAccelerationToStop = ((dt*a_max(2)-2*v) + sqrt(((dt*a_max(2)-2*v)^2 -...
                    4*(2*a_max(2)*(s_in-s-v*dt)+v^2))))/(2*dt);
                
                if junctionExitVelocity < 0 || A_min_ahead_next > -50
                    accelerationToPassBehind = maximumAccelerationToStop;
                elseif  junctionExitVelocity > 0 && A_min_ahead_next <= 50
                    accelerationToPassBehind =  maximumAccelerationToPassBehind;
                else
                    accelerationToPassBehind = -9999;
                end
                
            else
                accelerationToPassBehind = -9999;
            end
        end
    end
end

