classdef AutonomousCar < IdmModel
    properties (SetAccess = public)
        acc_min_ahead
        acc_max_behind
        T_safe = 0.0
        juncExitVelocity = NaN
        t_in = NaN
        t_out = NaN
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
            if competingCar.pose(1) > s_out
                s_comp = competingCar.pose(1)-OppositeLength;
            else
                s_comp = competingCar.pose(1);
            end
            phi =  0.75 + rand()*0.5; % phi in [0.75, 1.25] ie +- 25%
            phi = 1;
            v_comp = competingCar.velocity*phi;
            %             a_comp = competingCar.History(4,competingCar.historyIndex-1);
            if s_comp <= s_in && obj.tol < v_comp
                obj.t_in = (s_in - s_comp)/v_comp+t;
                if t < obj.t_in && s >= (s_out-v_max*(obj.t_in-t))
                    
                    A_ahead = (s_out - 0.5*obj.a_max*(obj.t_in-(t+dt))^2 - v*(obj.t_in-t) - s)/ (dt*(obj.t_in-(t+dt/2)));
                    juncExitVel  = (v + A_ahead*dt) + obj.a_max*(obj.t_in-(t+dt));

                    aheadWithMaxVel = (-sqrt((v_max-v+0.5*obj.a_max*dt)^2-2*obj.a_max*(s_out-v_max*(obj.t_in-(t+dt))-s-v*dt)-v_max^2+2*v*v_max-v^2)+v_max-v+0.5*obj.a_max*dt)/dt;
                    
                    if juncExitVel > v_max 
                        obj.acc_min_ahead = aheadWithMaxVel;
                        if aheadWithMaxVel <= obj.a_max && aheadWithMaxVel >= obj.a_min
                            obj.juncExitVelocity = v_max;
                        else
                            obj.juncExitVelocity = sqrt(v^2+2*obj.a_max*(s_out-s));
                        end
                    elseif aheadWithMaxVel >= A_ahead
                        obj.acc_min_ahead = A_ahead;
                        obj.juncExitVelocity = juncExitVel;
                    else
                        obj.acc_min_ahead = 1e3;
                        obj.juncExitVelocity = sqrt(v^2+2*obj.a_max*(s_out-s));
                    end
                else
                    obj.acc_min_ahead = 1e3;
                    obj.juncExitVelocity = sqrt(v^2+2*obj.a_max*(s_out-s));
                end
            elseif obj.tol > v_comp && s_comp <= s_in
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
            s_in = obj.s_in; 
            s_out = obj.s_out;

            if competingCar.pose(1) > s_out
                s_comp = competingCar.pose(1)-OppositeLength;
            else
                s_comp = competingCar.pose(1);
            end
            phi =  0.75 + rand()*0.5; % phi in [0.75, 1.25] ie +- 25%
            phi = 1;
            v_comp = competingCar.velocity*phi;
            a_comp = competingCar.History(4,competingCar.historyIndex-1);
            if s_comp <= s_out && obj.tol < v_comp
                exit_vel_sqr = (v_comp)^2+2*a_comp*(s_out-s_comp);
                if  abs(a_comp) > obj.tol
                    if exit_vel_sqr > 0
                        obj.t_out = (-v_comp+sqrt(exit_vel_sqr))/a_comp+t;
                    else
                        obj.t_out = t;
                    end
                else
                    obj.t_out = (s_out - s_comp)/v_comp+t;
                end

                if  s <= obj.s_in && obj.t_out > (t + dt)
                    A_nonZero = (s_in - 0.5*obj.a_min*(obj.t_out-(t+dt))^2 -v*(obj.t_out-t) - s)/ (dt*(obj.t_out-(t+dt/2)));
                    ExitVel = (v + A_nonZero*dt) + obj.a_min*(obj.t_out-(t+dt));
                    
%                     behindWithZeroVel = ((dt*obj.a_min-2*v) + sqrt(((dt*obj.a_min-2*v)^2 -4*(2*obj.a_min*(s_in-s-v*dt)+v^2))))/(2*dt);

                    % why is 50? fixed numbers need explanations
%                     if  ExitVel > 0 && A_min_ahead_next <= 50
                    if  ExitVel > 0 && A_min_ahead_next <= obj.a_max
                        obj.acc_max_behind =  A_nonZero;
                    else
                        obj.acc_max_behind = -1e3;
                    end
                else
                    if A_min_ahead_next <= obj.a_max
                        obj.acc_max_behind =  A_min_ahead_next;
                    else
                        obj.acc_max_behind = -1e3;
                    end
%                     obj.acc_max_behind = 1e3;
                end
            elseif obj.tol > v_comp && s_comp <= s_in
                obj.acc_max_behind = obj.idmAcceleration;
            else
                obj.acc_max_behind = -1e3;
            end
        end
    end
end

