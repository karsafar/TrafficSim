classdef HdmModel < IdmModel
    properties (Constant)
        Tr = 0.3  % sec, reation time
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
        J
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
            obj.J = round(obj.Tr/obj.dt);
        end
        function calculate_idm_accel(obj,varargin)
            roadLength = varargin{1};
            if nargin == 2
                junc_flag = 0;
            else
                junc_flag = varargin{2};
            end
            obj.w_s = obj.k1*obj.w_s  + obj.k2*random(obj.pd_s);
            obj.w_l = obj.k1*obj.w_l  + obj.k2*random(obj.pd_l);
            obj.w_a = obj.k11*obj.w_a + obj.k12*random(obj.pd_a);
            
            %             jj = 1:obj.n_a;
            %             C_idm = (sum(1./(jj.^2)))^-1;
            a_idm_free  = obj.a*(1 - (obj.velocity/obj.targetVelocity)^obj.delta);
            
            a_int = 0;
            count = 1;
            
            if obj.historyIndex <= obj.J
                currentCarPoseJ = obj.pose(1);
                currentCarVelJ = obj.velocity;
                currentCarAccelJ = obj.acceleration;
            else
                currentCarPoseJ = obj.locationHistory(obj.historyIndex-obj.J);
                currentCarVelJ = obj.velocityHistory(obj.historyIndex-obj.J);
                currentCarAccelJ = obj.accelerationHistory(obj.historyIndex-obj.J);
            end
            
            if ~isempty(obj.Prev) && ~junc_flag
                leaderCar = obj.Prev;
                nCarLength = 0;
                while count <= obj.n_a && leaderCar.pose(1) ~= obj.pose(1) && ~junc_flag
                    if leaderCar.historyIndex <= obj.J
                        leaderCarPoseJ = leaderCar.pose(1);
                        leaderCarVelJ = leaderCar.velocity;
                    else
                        leaderCarPoseJ = leaderCar.locationHistory(leaderCar.historyIndex-obj.J);
                        leaderCarVelJ = leaderCar.velocityHistory(leaderCar.historyIndex-obj.J);
                    end
                    
                    if leaderCarPoseJ > currentCarPoseJ
                        s_ab = leaderCarPoseJ - currentCarPoseJ - nCarLength;
                    else
                        s_ab = leaderCarPoseJ - currentCarPoseJ + roadLength - nCarLength;
                    end
                    dV = currentCarVelJ - leaderCarVelJ;
                    dV_est = dV + s_ab*obj.sigma_r*obj.w_l;
                    s_ab_prog = s_ab*exp(obj.Vs*obj.w_s) - obj.Tr*dV_est;
                    v_prog = currentCarVelJ + obj.Tr*currentCarAccelJ;
                    v_l_prog = leaderCarVelJ - s_ab*obj.sigma_r*obj.w_l;
                    
                    intelligentBreaking = v_prog*obj.timeGap + (v_prog*(v_prog-v_l_prog))/(2*sqrt(obj.a*obj.b));
                    
                    s_star = obj.minimumGap + max(0,intelligentBreaking);
                    
                    a_int = a_int - obj.a*(s_star/s_ab_prog)^2;
                    
                    leaderCar = leaderCar.Prev;
                    count = count + 1;
                    nCarLength = nCarLength + obj.dimension(2);
                end
            end
            C_idm = max(1,(sum(1./((count-1).^2))))^-1;
            
            
            if obj.velocity == 0 && obj.targetVelocity == 0
                obj.idmAcceleration = a_int;
            elseif junc_flag
                obj.s = obj.s_in - obj.pose(1);
                dV = obj.velocity-0.01;
                intelligentBreaking = obj.velocity*obj.timeGap + (obj.velocity*dV)/(2*sqrt(obj.a*obj.b));
                s_star = 0.3 + max(0,intelligentBreaking);
                
                obj.idmAcceleration = obj.a*(1 - (obj.velocity/obj.targetVelocity)^obj.delta - (s_star/obj.s)^2);
            else
                obj.idmAcceleration = a_idm_free + C_idm*a_int + obj.sigma_a*obj.w_a;
            end
            
            if obj.idmAcceleration > obj.maximumAcceleration(1)
                obj.idmAcceleration = obj.maximumAcceleration(1);
            elseif obj.idmAcceleration < obj.maximumAcceleration(2)
                obj.idmAcceleration =  obj.maximumAcceleration(2);
            end
        end
    end
end

