clc
clear


%

load(['test-' num2str(27) '.mat']);


%%
% East Arm
in_out = [];
diff_in_out = [];
r_E = [];
arm = sim.vertArm;
        
figure
clf;
ax = axes;
ylabel(ax,'Number of Cars')
xlabel(ax,'Time to get from Start to End (s)')
hold on
grid on
for iCar = 1:arm.numCars
    dispCar = arm.allCars(iCar).History(2,:);
    timeCar = arm.allCars(iCar).History(1,:);
    in_out(iCar).time =  timeCar(dispCar>=arm.endPoint);
    diff_in_out(iCar).time = diff(in_out(iCar).time);
    %    plot(ax,diff_in_out(iCar).time,'b+')
    r_E = [r_E, diff_in_out(iCar).time];
end


histfit(r_E)
fitdist(r_E','Normal')




% North Arm
in_out = [];
diff_in_out = [];
r_N = [];
figure
clf;
arm1 = sim.vertArm;
ax1 = axes;
ylabel(ax1,'Number of Cars')
xlabel(ax1,'Time to get from Start to End (s)')
hold on
grid on

for iCar = 1:arm1.numCars
    dispCar = arm1.allCars(iCar).History(2,:);
    timeCar = arm1.allCars(iCar).History(1,:);
    in_out(iCar).time =  timeCar(dispCar>=arm1.endPoint);
    diff_in_out(iCar).time = diff(in_out(iCar).time);
    %    plot(ax,diff_in_out(iCar).time,'ro')
    r_N = [r_N, diff_in_out(iCar).time];
end



histfit(r_N)
fitdist(r_N','Normal')

figure
x = [r_E,r_N]';
g1 = repmat({'East Arm'},numel(r_E),1);
g2 = repmat({'North Arm'},numel(r_N),1);
g = [g1;g2];
boxplot(x,g)
grid on

%% 
% Statistical data for the East Arm
[m_E,sigma_E,median_E,Q_E,SID_E,Noutliers_E,Qk_E] = quartile(r_E);

% Statistical data for the North Arm
[m_N,sigma_N,median_N,Q_N,SID_N,Noutliers_N,Qk_N] = quartile(r_N);

%% Fairness Metric
nCrosses = numel(r_E) + numel(r_N);
p_E = numel(r_E)/nCrosses;
p_N = numel(r_N)/nCrosses;

% Global utility of the juncton
F = min(m_E*p_E,m_N*p_N)/max(m_E*p_E,m_N*p_N);



plot(F)