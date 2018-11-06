classdef AutonomousCar < IdmModel
    
    properties (SetAccess = public)
        acc_min_ahead
        acc_max_behind
        T_safe = 0.0
        juncExitVelocity = NaN
        t_in = NaN
        t_out = NaN
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
            obj = obj@IdmModel(orientation, startPoint, Width,dt);
        end
        function calc_a_min_ahead(obj,t,dt,competingCar,OppositeLength)
            %%
            v = obj.velocity;
            v_max = obj.maximumVelocity;
            s = obj.pose(1);
            s_in = obj.s_in;
            s_out = obj.s_out;
            T_safe = obj.T_safe;
            tol = obj.tol;
            if competingCar.pose(1) > obj.s_out
                s_comp = competingCar.pose(1)-OppositeLength;
            else
                s_comp = competingCar.pose(1);
            end
            v_comp = competingCar.velocity;
            a_comp = competingCar.acceleration;
            
            if s_comp <= s_in && tol < v_comp
                if tol < a_comp
                    obj.t_in = (-v_comp+sqrt((v_comp)^2+2*a_comp*(s_in-s_comp)))/a_comp+t-T_safe;
                else
                    obj.t_in = (s_in - s_comp)/v_comp+t-T_safe;
                end
                if t < (obj.t_in+0.1) && (s+0.01) >= (s_out-v_max*(obj.t_in-t))
                    
                    aheadWithPositive_A = (s_out - 0.5*obj.a_max*(obj.t_in-(t+dt))^2 - v*(obj.t_in-t) - s)/ (dt*(obj.t_in-(t+dt/2)));
                    juncExitVel  = (v + aheadWithPositive_A*dt) + obj.a_max*(obj.t_in-(t+dt));

                    aheadWithMaxVel = (-sqrt((v_max-v+0.5*obj.a_max*dt)^2-2*obj.a_max*(s_out-v_max*(obj.t_in-(t+dt))-s-v*dt)-v_max^2+2*v*v_max-v^2)+v_max-v+0.5*obj.a_max*dt)/dt;
                    
                    if juncExitVel > v_max 
                        obj.acc_min_ahead = aheadWithMaxVel;
                        if aheadWithMaxVel <= obj.a_max && aheadWithMaxVel >= obj.a_min
                            obj.juncExitVelocity = v_max;
                        else
                            obj.juncExitVelocity = sqrt(v^2+2*obj.a_max*(s_out-s));
                        end
                    elseif aheadWithMaxVel >= aheadWithPositive_A
                        obj.acc_min_ahead = aheadWithPositive_A;
                        obj.juncExitVelocity = juncExitVel;
                    else
                        obj.acc_min_ahead = 1e3;
                        obj.juncExitVelocity = sqrt(v^2+2*obj.a_max*(s_out-s));
                    end
                else
                    obj.acc_min_ahead = 1e3;
                    obj.juncExitVelocity = sqrt(v^2+2*obj.a_max*(s_out-s));
                end
            elseif tol > v_comp && s_comp <= s_in
                obj.acc_min_ahead = obj.idmAcceleration;
                obj.juncExitVelocity = sqrt(v^2+2*obj.a_max*(s_out-s));
            else
                obj.acc_min_ahead = 1e3;
                obj.juncExitVelocity = sqrt(v^2+2*obj.a_max*(s_out-s));
            end
      
        end
        function calc_a_max_behind(obj,t,dt,A_min_ahead_next,competingCar,OppositeLength)
            %%
            v = obj.velocity;
            s = obj.pose(1);
            s_in = obj.s_in-0.2;
            s_out = obj.s_out;
            T_safe = obj.T_safe; %#ok<*PROPLC>
            tol = obj.tol;
            if competingCar.pose(1) > obj.s_out
                s_comp = competingCar.pose(1)-OppositeLength;
            else
                s_comp = competingCar.pose(1);
            end
            v_comp = competingCar.velocity;
            a_comp = competingCar.acceleration;
            if s_comp <= s_out && tol < v_comp
                if tol < a_comp
                    obj.t_out = (-v_comp+sqrt((v_comp)^2+2*a_comp*(s_out-s_comp)))/a_comp+t+T_safe;
                else
                    obj.t_out = (s_out - s_comp)/v_comp+t+T_safe;
                end
                
                if  s <= obj.s_in
                    behindWithNegative_A = (s_in - 0.5*obj.a_min*(obj.t_out-(t+dt))^2 -v*(obj.t_out-t) - s)/ (dt*(obj.t_out-(t+dt/2)));
                    junctionExitVelocity = (v + behindWithNegative_A*dt) + obj.a_min*(obj.t_out-(t+dt));
                    
                    behindWithZeroVel = ((dt*obj.a_min-2*v) + sqrt(((dt*obj.a_min-2*v)^2 -4*(2*obj.a_min*(s_in-s-v*dt)+v^2))))/(2*dt);
                    
%                     if junctionExitVelocity < 0 || A_min_ahead_next > -50
%                         obj.acc_max_behind = behindWithZeroVel;
%                     else
                    if  junctionExitVelocity > 0 && A_min_ahead_next <= 50
                        obj.acc_max_behind =  behindWithNegative_A;
                    else
                        obj.acc_max_behind = -1e3;
                    end
                    
                else
                    obj.acc_max_behind = -1e3;
                end
            elseif tol > v_comp && s_comp <= s_in
                obj.acc_max_behind = obj.idmAcceleration;
            else
                obj.acc_max_behind = -1e3;
            end
        end
    end
end

