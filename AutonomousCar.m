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
            % self car states
            v = obj.velocity;
            v_max = obj.maximumVelocity;
            s = obj.pose(1);
            
            % competing car states
            s_in = competingCar.s_in;
            s_out = competingCar.s_out;
            s_comp = competingCar.pose(1)-OppositeLength*(competingCar.pose(1)>s_out);
            v_comp = competingCar.velocity;
            
            % calculate t_in of competing car without taking its acceleration into account
            obj.t_in = (s_in - s_comp)/v_comp+t;
            
            if s_comp <= s_in && obj.tol < v_comp && s < s_out && s >= (s_out-v_max*(obj.t_in-(t+dt)))
                % competing car has not entered the junction yet,
                % competing car velocity is not zero,
                % self car has not left the junction yet
                % self car is above the line that defines the edge of
                % collision inevitable state space
                
                A_ahead = (s_out - 0.5*obj.a_max*(obj.t_in-(t+dt))^2 - v*(obj.t_in-t) - s)/ (dt*(obj.t_in-(t+dt/2)));
                juncExitVel  = (v + A_ahead*dt) + obj.a_max*(obj.t_in-(t+dt));
                
                if juncExitVel < v_max
                    obj.acc_min_ahead = A_ahead;
                else
                    aheadWithMaxVel = (-sqrt((v_max-v+0.5*obj.a_max*dt)^2-2*obj.a_max*(s_out-v_max*(obj.t_in-(t+dt))-s-v*dt)-v_max^2+2*v*v_max-v^2)+v_max-v+0.5*obj.a_max*dt)/dt;
                    obj.acc_min_ahead = aheadWithMaxVel;
                end
            elseif obj.tol > v_comp && s_comp <= s_in
                obj.acc_min_ahead = -1e3;
            else
                obj.acc_min_ahead = 1e3;
            end
        end
        function calc_a_max_behind(obj,t,dt,A_min_ahead_next,competingCar,OppositeLength)
            %%
            % self car states
            v = obj.velocity;
            s = obj.pose(1);
            
            % competing car states
            s_in = competingCar.s_in;
            s_out = competingCar.s_out;
            s_comp = competingCar.pose(1)-OppositeLength*(competingCar.pose(1)>s_out);
            v_comp = competingCar.velocity;
%             a_comp = competingCar.History(4,competingCar.historyIndex-1);
            
            % time when competing car leaves junction
            obj.t_out = (s_out - s_comp)/v_comp+t;
            
            if s_comp <= s_out && obj.tol < v_comp && s <= obj.s_in
                % competing car has not left junction yet
                % competing car velocity is not zero
                % self car has not entered junction yet                
                
                if obj.t_out > t && obj.t_out <t+dt
                    % when t_out is smaller than t+dt it gives a complex output
                    % due to negative (t_out - (t+dt)) < 0
                    obj.t_out = obj.t_out + dt;
                end
                
                A_nonZero = ((s_in-0.02) - 0.5*obj.a_min*(obj.t_out-(t+dt))^2 -v*(obj.t_out-t) - s)/(dt*(obj.t_out-(t+dt/2)));
                ExitVel = (v + A_nonZero*dt) + obj.a_min*(obj.t_out-(t+dt));
                if A_min_ahead_next <= obj.a_max &&  ExitVel > 0
                    obj.acc_max_behind =  A_nonZero;
                else
                    behindWithZeroVel = ((dt*obj.a_min-2*v) + sqrt(((dt*obj.a_min-2*v)^2 -4*(2*obj.a_min*((s_in-0.02)-s-v*dt)+v^2))))/(2*dt);
                    obj.acc_max_behind = behindWithZeroVel;
                end
            elseif obj.tol > v_comp && s_comp < s_in
                % when competing car stopped just set a_max_behind to a very
                % large number
                obj.acc_max_behind =  1e3;
            else
                obj.acc_max_behind = -1e3;
            end
        end
    end
end

