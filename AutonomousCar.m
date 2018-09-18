classdef AutonomousCar < IdmCar
    
    properties (SetAccess = public)
        acc_min_ahead
        acc_max_behind
        T_safe = 0.1
%         tol = 1e-6
    end
    methods
        function obj = AutonomousCar(varargin)
            if nargin == 4
                orientation = varargin{1};
                startPoint = varargin{2};
                Width = varargin{3};
                dt = varargin{4};
            end
            obj = obj@IdmCar(orientation, startPoint, Width,dt);
        end
        function calc_a_min_ahead(obj,t,dt,competingCar)
            %%
            a_max = obj.maximumAcceleration;
            v = obj.velocity;
            v_max = obj.maximumVelocity;
            s = obj.pose(1);
            s_in = obj.s_in;
            s_out = obj.s_out;
            T_safe = obj.T_safe;
            tol = obj.tol;
            s_comp = competingCar.pose(1);
            v_comp = competingCar.velocity;
            a_comp = competingCar.acceleration;
            
            if s_comp <= s_in && tol < v_comp
                if tol < a_comp
                    t_in = (-v_comp+sqrt((v_comp)^2+2*a_comp*(s_in-s_comp)))/a_comp+t-T_safe;
                else
                    t_in = (s_in - s_comp)/v_comp+t-T_safe;
                end
                if t < t_in && s >= s_out-v_max*(t_in-t)
                    
                    aheadWithPositive_A = (s_out - 0.5*a_max(1)*(t_in-(t+dt))^2 - v*(t_in-t) - s)/ (dt*(t_in-(t+dt/2)));
                    juncExitVel  = (v + aheadWithPositive_A*dt) + a_max(1)*(t_in-(t+dt));

                    aheadWithMaxVel = (-sqrt((v_max-v+0.5*a_max(1)*dt)^2-2*a_max(1)*(s_out-v_max*(t_in-(t+dt))-s-v*dt)-v_max^2+2*v*v_max-v^2)+v_max-v+0.5*a_max(1)*dt)/dt;
                    
                    if juncExitVel > v_max %|| aheadWithMaxVel < aheadWithPositive_A
                        obj.acc_min_ahead = aheadWithMaxVel;
                    elseif aheadWithMaxVel >= aheadWithPositive_A
                        obj.acc_min_ahead = aheadWithPositive_A;
                    else
                        obj.acc_min_ahead = 1e3;
                    end
                else
                    obj.acc_min_ahead = 1e3;
                end
            else
                obj.acc_min_ahead = 1e3;
            end
      
        end
        function calc_a_max_behind(obj,t,dt,A_min_ahead_next,competingCar)
            %%
            a_max = obj.maximumAcceleration;
            v = obj.velocity;
            s = obj.pose(1);
            s_in = obj.s_in;
            s_out = obj.s_out;
            T_safe = obj.T_safe; %#ok<*PROPLC>
            tol = obj.tol;
            s_comp = competingCar.pose(1);
            v_comp = competingCar.velocity;
            a_comp = competingCar.acceleration;
            if s_comp <= s_out && tol < v_comp
                if tol < a_comp
                    t_out = (-v_comp+sqrt((v_comp)^2+2*a_comp*(s_out-s_comp)))/a_comp+t-T_safe;
                else
                    t_out = (s_out - s_comp)/v_comp+t-T_safe;
                end
                
                if  s <= s_in
                    behindWithNegative_A = (s_in - 0.5*a_max(2)*(t_out-(t+dt))^2 -v*(t_out-t) - s)/ (dt*(t_out-(t+dt/2)));
                    junctionExitVelocity = (v + behindWithNegative_A*dt) + a_max(2)*(t_out-(t+dt));
                    
                    behindWithZeroVel = ((dt*a_max(2)-2*v) + sqrt(((dt*a_max(2)-2*v)^2 -4*(2*a_max(2)*(s_in-s-v*dt)+v^2))))/(2*dt);
                    
                    if junctionExitVelocity < 0 || A_min_ahead_next > -50
                        obj.acc_max_behind = behindWithZeroVel;
                    elseif  junctionExitVelocity > 0 && A_min_ahead_next <= 50
                        obj.acc_max_behind =  behindWithNegative_A;
                    else
                        obj.acc_max_behind = -1e3;
                    end
                    
                else
                    obj.acc_max_behind = -1e3;
                end
            else
                obj.acc_max_behind = -1e3;
            end
        end
    end
end

