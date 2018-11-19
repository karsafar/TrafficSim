classdef HdmModel < IdmModel
    properties (Constant)
        Tr = 0.6 % sec, reation time
        n_a = 5     % num of anticipated cars
        Vs = 0.1     % percent, variation coefficient of gap estimation
        sigma_r = 0.01 % 1/sec, estimation error for the inverse TTC
        sigma_a = 0.1  % m/s^2, magnitude of acceleration noise
        tau_tilda = 20 % sec, persistence time of the estimation errors
        tau_tilda_a = 1 % sec, persistence time of the acceleration noise
    end
    properties
        k1 = 0
        k2 = 0
        k11 = 0
        k12 = 0
        w_s
        w_l
        w_a
        pd_s
        pd_l
        pd_a
        stepsDelay
        t_Minus_Tr = 0
    end
    methods
        function obj = HdmModel(varargin)
            if nargin == 4
                orientation = varargin{1};
                startPoint = varargin{2};
                Width = varargin{3};
                dt = varargin{4};
            end
            obj = obj@IdmModel(orientation, startPoint, Width,dt);
            obj.k1 = exp(-obj.dt/obj.tau_tilda);
            obj.k2 = sqrt((2*obj.dt)/obj.tau_tilda);
            obj.k11 = exp(-obj.dt/obj.tau_tilda_a);
            obj.k12 = sqrt((2*obj.dt)/obj.tau_tilda_a);
            obj.pd_s = makedist('normal',0,1);
            obj.pd_l = makedist('normal',0,1);
            obj.pd_a = makedist('normal',0,1);
            obj.w_s = random(obj.pd_s);
            obj.w_l = random(obj.pd_l);
            obj.w_a = random(obj.pd_a);
            %% initialize the number of time-steps to look back. 
            % based on Tr - reaction time
            obj.stepsDelay = round(obj.Tr/obj.dt);

        end
        function calculate_idm_accel(obj,varargin)
            roadLength = varargin{1};
            %% all those flags are for different use cases (such as generating an emergency break decelerations)
            % not important for getting steady state. they are all set to zero for the car-following mode 
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
            
            %% noise is set to zero
%             obj.w_s = obj.k1*obj.w_s  + obj.k2*random(obj.pd_s);
%             obj.w_l = obj.k1*obj.w_l  + obj.k2*random(obj.pd_l);
%             obj.w_a = obj.k11*obj.w_a + obj.k12*random(obj.pd_a);
%            
            obj.w_s = 0;
            obj.w_l = 0;
            obj.w_a = 0;
            
            %% free flow acceleration
            a_idm_free  = obj.a*(1 - (obj.velocity/obj.targetVelocity)^obj.delta);
            
            a_int = 0;
            count = 1;
            
            %% temporal anticipation 
            % using values of position, velocity and acceleration at time (t-Tr)
            obj.t_Minus_Tr = obj.historyIndex - obj.stepsDelay;
            if  obj.t_Minus_Tr <= 0
                currentCarPose_t_Minus_Tr = obj.pose(1);
                currentCarVel_t_Minus_Tr = obj.velocity;
                currentCarAccel_t_Minus_Tr = obj.acceleration;
            else
                currentCarPose_t_Minus_Tr = obj.locationHistory(obj.t_Minus_Tr);
                currentCarVel_t_Minus_Tr = obj.velocityHistory(obj.t_Minus_Tr);
                currentCarAccel_t_Minus_Tr = obj.accelerationHistory(obj.t_Minus_Tr);
            end
            
            %% Multi-vehicle anticipation
            if ~isempty(obj.Prev) && ~junc_flag
                leadingCar = obj.Prev;
                nCarLength = 0;
                while count <= obj.n_a && leadingCar.pose(1) ~= obj.pose(1) && ~junc_flag
                    %% temporal anticipation for the current leading car
                    leadingCar.t_Minus_Tr = leadingCar.historyIndex - leadingCar.stepsDelay;
                    if leadingCar.t_Minus_Tr <= 0
                        leadingCarPose_t_Minus_Tr = leadingCar.pose(1);
                        leadingCarVel_t_Minus_Tr = leadingCar.velocity;
                    else
                        leadingCarPose_t_Minus_Tr = leadingCar.locationHistory(leadingCar.t_Minus_Tr);
                        leadingCarVel_t_Minus_Tr = leadingCar.velocityHistory(leadingCar.t_Minus_Tr);
                    end
                    % subtract the lengths of all cars between current and
                    % leading car
                    if leadingCarPose_t_Minus_Tr > currentCarPose_t_Minus_Tr
                        s_ab = leadingCarPose_t_Minus_Tr - currentCarPose_t_Minus_Tr - nCarLength;
                    else
                        s_ab = leadingCarPose_t_Minus_Tr - currentCarPose_t_Minus_Tr + roadLength - nCarLength;
                    end
                    %% all noise set to zero
                    dV = currentCarVel_t_Minus_Tr - leadingCarVel_t_Minus_Tr;
                    dV_est = dV + s_ab*obj.sigma_r*obj.w_l;
                    s_ab_prog = s_ab*exp(obj.Vs*obj.w_s) - obj.Tr*dV_est;
                    v_prog = currentCarVel_t_Minus_Tr + obj.Tr*currentCarAccel_t_Minus_Tr;
                    v_l_prog = leadingCarVel_t_Minus_Tr - s_ab*obj.sigma_r*obj.w_l;
                    
                    intelligentBreaking = v_prog*obj.timeGap + (v_prog*(v_prog-v_l_prog))/(2*sqrt(obj.a*obj.b));
                    
                    s_star = obj.minimumGap + max(0,intelligentBreaking);
                    %% interaction acceleration 
                    % sum of all interaction accelerations 
                    a_int = a_int - obj.a*(s_star/s_ab_prog)^2;
                    
                    % select next leader car. 
                    leadingCar = leadingCar.Prev;
                    count = count + 1;
                    % add one car length to subtract the sum of all cars
                    % between current car and next leading car
                    nCarLength = nCarLength + obj.dimension(2);
                end
            end
            %% speed independent reduction factor
            C_idm = min(1,(sum(1./((1:(count-1)).^2)))^-1);
            
            %%
            if obj.velocity == 0 && obj.targetVelocity == 0
                obj.idmAcceleration = a_int;
            elseif stop_flag || junc_flag
                obj.s = obj.s_in - obj.pose(1);
                dV = obj.velocity-0.01;
                intelligentBreaking = obj.velocity*obj.timeGap + (obj.velocity*dV)/(2*sqrt(obj.a*obj.b));
                s_star = 0.3 + max(0,intelligentBreaking);
                
                obj.idmAcceleration = obj.a*(1 - (obj.velocity/obj.targetVelocity)^obj.delta - (s_star/obj.s)^2);
            else
                %% car-following HDM acceleration
                obj.idmAcceleration = a_idm_free + C_idm*a_int + obj.sigma_a*obj.w_a;
            end
            
            
            %% check for breaking the acceleration bounds
            if obj.idmAcceleration > obj.a_max
                obj.idmAcceleration = obj.a_max;
            elseif obj.idmAcceleration < obj.a_min
                if (emerg_flag || stop_flag) && obj.idmAcceleration < obj.a_feas_min
                    obj.idmAcceleration =  obj.a_feas_min;
                else
                    obj.idmAcceleration =  obj.a_min;
                end
            end
        end
    end
end

