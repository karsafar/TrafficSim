clc
clear
% close all


d = dir('test-*.mat');
Number_mat = length(d);
numCars = [];
for i = 1:Number_mat
    %% load simualation
    fnm = sprintf('test-%s',num2str(i));
    load(fullfile(fnm),'sim')
    

    % East Arm
    diff_in_out_E = [];
    r_E = [];
    arm_E = sim.horizArm;
    
    for iCar = 1:arm_E.numCars
        timeCar = arm_E.allCars(iCar).History(1,:);
        diff_in_out_E(iCar).time = diff(timeCar(arm_E.allCars(iCar).History(2,:)>=arm_E.endPoint));
        r_E = [r_E, diff_in_out_E(iCar).time];
    end
    
    
    % North Arm
    diff_in_out_N = [];
    r_N = [];
    arm_N = sim.vertArm;

    for iCar = 1:arm_N.numCars
        timeCar = arm_N.allCars(iCar).History(1,:);
        diff_in_out_N(iCar).time = diff(timeCar(arm_N.allCars(iCar).History(2,:)>=arm_N.endPoint));
        r_N = [r_N, diff_in_out_N(iCar).time];
    end
    
    
    %% Mean
    m_E = mean(r_E);
    std_E(i) = std(r_E);
    
    m_N = mean(r_N);
    std_N(i) = std(r_N);
    
    %% Fairness Metric
    nCrosses = numel(r_E) + numel(r_N);
    R_E = numel(r_E)/nCrosses;
    R_N = numel(r_N)/nCrosses;
    
    % Global utility of the juncton
    F(i) = min(m_E*R_E,m_N*R_N)/max(m_E*R_E,m_N*R_N)
    
    
    
    i
end


