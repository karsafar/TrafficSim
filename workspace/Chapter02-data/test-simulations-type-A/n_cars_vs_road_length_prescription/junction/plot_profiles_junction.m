% choose cars to compare
close all

% copy the road to a faster accessible memory 
east = sim.horizArm;
north = sim.vertArm;
 
% choose cars
n = 1; % east arm
m = 1; % north arm


%% plot decisions
% convert into ordered values, i.e [-1,1; 1 -1] into [2; 1] 
actArray_n = act_mat2array(east,n);
actArray_m = act_mat2array(north,m);
ax = axes;
plot(ax,east.allCars(n).History(1,:),actArray_n,'bo-',...
     north.allCars(m).History(1,:),actArray_m,'r*-','LineWidth',2);
 
yticks(1:5)
ylim([0.5 5])
yticklabels({'Follow','Back-off','Ahead','Behind','eStop'})
xlabel('Time (s)', 'FontSize', 16)
% xlim([14 24])
legend('East-bound Arm Vehicle','North-bound Arm Vehicle')
% ax.FontSize = 16;
%% plot accelerations

plot(east.allCars(n).History(1,:), east.allCars(n).History(4,:),'bo-',...
     north.allCars(m).History(1,:), north.allCars(m).History(4,:),'r*-','LineWidth',2)
xlabel('Time (s)', 'FontSize', 16)
ylabel('Accel (m/s^2)', 'FontSize', 16)
legend('East-bound Arm Vehicle','North-bound Arm Vehicle')
% xlim([14 24])

%% plot velocities

plot(east.allCars(n).History(1,:), east.allCars(n).History(3,:),'bo-',...
     north.allCars(m).History(1,:), north.allCars(m).History(3,:),'r*-','LineWidth',2)
xlabel('Time (s)', 'FontSize', 16)
ylabel('Velocity (m/s)', 'FontSize', 16)
legend('East-bound Arm Vehicle','North-bound Arm Vehicle')
% xlim([14 24])
%% plot displacements
x1 = 0;
x2 = t_rng(nIterations);
y1 = east.allCars(1).s_in;
y2 = east.allCars(1).s_out;
x = [x1, x2, x2, x1, x1];
y = [y1, y1, y2, y2, y1];
patch(x,y,[0.5 0.5 0.5],'EdgeColor','None');
hold on
plot(east.allCars(n).History(1,:), east.allCars(n).History(2,:),'bo-',...
     north.allCars(m).History(1,:), north.allCars(m).History(2,:),'r*-','LineWidth',2)
xlabel('Time (s)', 'FontSize', 16)
ylabel('Displacement (m)', 'FontSize', 16)
legend('Junction','East-bound Arm Vehicle','North-bound Arm Vehicle')

% xlim([14 24])
%% Junction crossing trajectory for two competing cars
x1 = 0;
x2 = t_rng(nIterations);
x1 = arm_2.allCars(1).s_in;
x2 = arm_2.allCars(1).s_out;
x = [x1, x2, x2, x1, x1];
y = [y1, y1, y2, y2, y1];
patch(x,y,[0.5 0.5 0.5],'EdgeColor','None');
hold on
x_axis_disp = north.allCars(m).History(2,:);
y_axis_disp = east.allCars(m).History(2,:);
x_axis_label = sprintf('North-bound Car Position (m)');
y_axis_label= sprintf('East-bound Car Position (m)');
plot(x_axis_disp, y_axis_disp,'ro-','LineWidth',1)
hold on
plot(y_axis_disp, x_axis_disp,'b*-','LineWidth',1)
xlabel(x_axis_label, 'FontSize', 16)
ylabel(y_axis_label, 'FontSize', 16)
legend('Junction','East-bound Arm Vehicle Ahead','North-bound Arm Vehicle Ahead')
axis equal
xlim([-15 5])
ylim([-15 5])

%% plot gaps

gap = east.allCars(1).History(2,:) - east.allCars(2).History(2,:) - east.allCars(1).dimension(2);
plot(east.allCars(1).History(1,:), gap,'r-',...
     east.allCars(2).History(1,:), 2*ones(1,nIterations),'b--','LineWidth',2)
xlabel('Time (s)', 'FontSize', 16)
ylabel('Space Gap (m)', 'FontSize', 16)
legend('Actual Gap','Minimum Gap')
%% save

fig = gcf;
fig.PaperPositionMode = 'auto';
fig.PaperPosition;
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(fig,'/Users/robot/cross_sim/workspace/Chapter02-data/test-simulations-type-A/n_cars_vs_road_length_prescription/junction/Unit-tests/back_off','-dpdf','-r0','-bestfit')


%% create an array of actions taken every time step by each car
function actArray = act_mat2array(arm,n)
    actMatrix = arm.allCars(n).bbStore;
    actMatrix(actMatrix<1) = 0;
    actMatrix(:,2) = actMatrix(:,2).*2;
    actMatrix(:,3) = actMatrix(:,3).*3;
    if size(actMatrix,2) == 5
        actMatrix(:,4) = actMatrix(:,4).*4;
        actMatrix(:,5) = actMatrix(:,5).*5;
        actArray = actMatrix(:,1)+actMatrix(:,2)+actMatrix(:,3)+actMatrix(:,4)+actMatrix(:,5);
    else
        actMatrix(:,1) = actMatrix(:,1)+actMatrix(:,4);
        actMatrix(:,5) = actMatrix(:,5).*4;
        actMatrix(:,6) = actMatrix(:,6).*5;
        actArray = actMatrix(:,1)+actMatrix(:,2)+actMatrix(:,3)+actMatrix(:,5)+actMatrix(:,6);
    end
end
