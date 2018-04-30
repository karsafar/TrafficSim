classdef BtCar < IdmCar
    
    properties (SetAccess = private)
        bb
        it_accel
        it_t_out
        it_pose
        it_A_min_ahead
        it_A_max_behind
        it_idmAccel
        it_t
        it_frontCarPassedJunction
        full_tree
    end
    methods
        function obj = BtCar(orientation, prescription, startPoint, Width)
            obj = obj@IdmCar(orientation, prescription, startPoint, Width);
            
            %-----------------Initialize Blackboard------------------
            obj.bb = BtBlackboard;
            obj.it_accel = obj.bb.add_item('A',obj.acceleration);
            obj.it_A_min_ahead = obj.bb.add_item('AminAhead',0);
            obj.it_A_max_behind = obj.bb.add_item('AmaxBehind',0);
            obj.it_idmAccel = obj.bb.add_item('idmAccel',obj.idmAcceleration);
            
            if ~isempty(obj.Prev)
                if obj.Prev.pose(1) > obj.s_out
                    obj.it_frontCarPassedJunction = obj.bb.add_item('frontCarPassedJunction',true);
                else
                    obj.it_frontCarPassedJunction = obj.bb.add_item('frontCarPassedJunction',false);
                    
                end
            else
                obj.it_frontCarPassedJunction = obj.bb.add_item('frontCarPassedJunction',true);
            end
            
            %-------------------intersection collision avoidance-------------------
            A6 = BtAssign(obj.it_accel,obj.it_A_min_ahead);
            aheadCar = BtSequence(...
                obj.it_A_min_ahead>=0,...
                obj.it_A_min_ahead<=obj.it_idmAccel,...
                A6);
            
            p71 = BtSequence(...
                obj.it_A_min_ahead<obj.maximumAcceleration(2),...
                obj.it_A_max_behind>obj.maximumAcceleration(1));
            p7 = BtSelector(...
                p71,...
                obj.it_A_min_ahead<=0,...
                obj.it_A_max_behind>=obj.it_idmAccel);
            A7 = BtAssign(obj.it_accel,obj.it_idmAccel);
            idmCar = BtSequence(p7, A7);
            
            A71 = BtAssign(obj.it_accel,obj.it_A_max_behind);
            stopCar = BtSequence(...
                obj.it_A_min_ahead>obj.it_idmAccel,...
                obj.it_A_max_behind>=0,...
                obj.it_A_max_behind<obj.it_idmAccel, A71);
            
            A8 = BtAssign(obj.it_accel,obj.it_idmAccel);
            behindCarIdm = BtSequence(obj.it_A_max_behind>=obj.it_idmAccel, A8);
            
            A9 = BtAssign(obj.it_accel,obj.it_A_max_behind);
            behindCarMax = BtSequence(obj.it_A_max_behind<obj.it_idmAccel, A9);
            selectIdmVsMax = BtSelector(behindCarIdm,behindCarMax);
            
            BehindCar = BtSequence(...
                obj.it_A_max_behind<=0,...
                obj.it_A_max_behind>=(obj.maximumAcceleration(2)-0.000001),...
                selectIdmVsMax);
            
            Crossing = BtSelector(aheadCar,idmCar,stopCar,BehindCar);
            
            % front car not passed junction
            idmAfterjunction = BtAssign(obj.it_accel,obj.it_idmAccel);
            
            frontCarPassedJunc = BtSequence(obj.it_frontCarPassedJunction==1,Crossing);
            obj.full_tree = BtSelector(frontCarPassedJunc, idmAfterjunction);
            
        end
        function decide_acceleration(obj,oppositeRoad,t,dt)
            oppositeCars = oppositeRoad.allCars;
            crossingBegin = obj.s_in;
            crossingEnd = obj.s_out;
            oppositeDistToJunc = NaN(oppositeRoad.numCars,1);
            if   obj.pose(1) > crossingEnd
                obj.acceleration = obj.idmAcceleration;
            elseif obj.pose(1) > crossingBegin
                obj.acceleration = obj.maximumAcceleration(1);
            else
                for jCar = 1:oppositeRoad.numCars
                    oppositeDistToJunc(jCar) = crossingEnd - oppositeCars(jCar).pose(1);
                end
                oppositeDistToJunc(oppositeDistToJunc<0) = inf;
                [m, ind] = min(oppositeDistToJunc);
                oppositeCarPose = oppositeCars(ind).pose(1);
                if eps > (oppositeCars(ind).velocity - 0) && eps > (obj.velocity - 0)&&...
                        numel(obj.accelerationHistory)>1 && (isempty(obj.Prev) ||...
                        obj.Prev.pose(1) < obj.pose(1) ||  obj.Prev.pose(1)>crossingBegin )
                    if oppositeRoad.priority == false
                        if  isempty(obj.Prev)
                            obj.acceleration = obj.maximumAcceleration(1);
                        else
                            obj.acceleration = obj.idmAcceleration;
                        end
                    else
                        obj.acceleration = 0;
                    end
                else
                    t_in = (crossingBegin - oppositeCarPose)/oppositeCars(ind).velocity+t - 0.1;%obj.timeGap;
                    t_out = (crossingEnd - oppositeCarPose)/oppositeCars(ind).velocity+t + 0.1;% obj.timeGap;
                    
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
                            obj.pose(1));
                        
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
                    obj.it_idmAccel.set_value(obj.idmAcceleration);
                    
                    if ~isempty(obj.Prev)
                        if obj.Prev.pose(1) > crossingEnd || obj.Prev.pose(1) < obj.pose(1)
                            obj.it_frontCarPassedJunction.set_value(true);
                        else
                            obj.it_frontCarPassedJunction.set_value(false);
                        end
                    else
                        obj.it_frontCarPassedJunction.set_value(true);
                    end
                    
                    obj.full_tree.tick;
                    obj.acceleration =  obj.it_accel.get_value;
                    %                             break
                    %                             h5 = figure(5);
                    %                             set(h5,'units', 'normalized', 'outerposition',[0 0 1 1])
                    %                             plot(obj.full_tree,0);
                    %                             pause()
                    %                             cla(obj.full_tree.ha);
                    %                             delete(obj.full_tree.ha)
                    %                             close(h5);
                end
                %                     end
                %                 end
            end
        end
    end
    methods (Static)
        function accelerationToPassAhead = calc_a_min_ahead(t,dt,a_max,v,v_max,t_in,s_out,s)
            if (t+dt) <= t_in
                
                minimumAccelerationToPassAhead = (s_out - 0.5*a_max(1)*(t_in-(t+dt))^2 - v*(t_in-t) - s)/ (dt*(t_in-(t+dt/2)));
                junctionExitVelocity  = (v + minimumAccelerationToPassAhead*dt) + a_max(1)*(t_in-(t+dt));
                
                minimumAccelerationToReachMaxVel = (-sqrt(((v_max-v+0.5*a_max(1)*dt)^2-2*a_max(1)*(s_out-...
                    v_max*(t_in-(t+dt))-s-v*dt)-v_max^2+2*v*v_max-v^2))+v_max-v+0.5*a_max(1)*dt)/dt;
                
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
        function accelerationToPassBehind = calc_a_max_behind(t,dt,a_max,v,t_out,s_in,s)
            
            if  s <= s_in
                maximumAccelerationToPassBehind = (s_in - 0.5*a_max(2)*(t_out-(t+dt))^2 -...
                    v*(t_out-t) - s)/ (dt*(t_out-(t+dt/2)));
                junctionExitVelocity = (v + maximumAccelerationToPassBehind*dt) + a_max(2)*(t_out-(t+dt));
                
                maximumAccelerationToStop = ((dt*a_max(2)-2*v) + sqrt(((dt*a_max(2)-2*v)^2 -...
                    4*(2*a_max(2)*(s_in-s-v*dt)+v^2))))/(2*dt);
                
                if junctionExitVelocity < 0 || maximumAccelerationToStop >= maximumAccelerationToPassBehind
                    accelerationToPassBehind = maximumAccelerationToStop;
                elseif maximumAccelerationToStop < maximumAccelerationToPassBehind
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

