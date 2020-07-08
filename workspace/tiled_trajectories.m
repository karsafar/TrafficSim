% choose cars to compare
close all
n = 2;
m = 1;

% select the arm
flag = 0;
switch flag
    case 1 % East arm only
        arm_1 = sim.horizArm;
        arm_2 = arm_1;
        n_idx = sprintf('East Car %i',n);
        m_idx = sprintf('East Car %i',m);
    case 2 % North arm only
        arm_1 = sim.vertArm;
        arm_2 = arm_1;
        n_idx = sprintf('North Car %i',n);
        m_idx = sprintf('North Car %i',m);
    otherwise % Both arms
        arm_1 = sim.horizArm;
        arm_2 = sim.vertArm;
        n_idx = sprintf('East  Car %i',n);
        m_idx = sprintf('North Car %i',m);
end


% Create a tile figure
% t = tiledlayout('flow');
figure
t = tiledlayout(4,1);
xlabel(t,'Time (s)', 'FontSize', 16)

% Tile 1
nexttile(t)
actArray_n = act_mat2array(arm_1,n);
plot(arm_1.allCars(n).History(1,:),actArray_n,'bo-','LineWidth',2)
hold on
actArray_m = act_mat2array(arm_2,m);
plot(arm_2.allCars(m).History(1,:),actArray_m,'r*-','LineWidth',2)
yticks(1:5)
ylim([0.5 5.5])
yticklabels({'Follow','Back-off','Ahead','Behind','eStop'})

% xlabel('Time (s)', 'FontSize', 16)
ylabel('Actions', 'FontSize', 16)
legend({n_idx,m_idx}, 'FontSize', 16,'Location','northeastoutside')
% xlim([0 50])
%}


% Tile 2
nexttile(t)
plot(arm_1.allCars(n).History(1,:), arm_1.allCars(n).History(4,:),'bo-','LineWidth',2)
hold on
plot(arm_2.allCars(m).History(1,:), arm_2.allCars(m).History(4,:),'r*-','LineWidth',2)
% xlabel('Time (s)', 'FontSize', 16)
ylabel('Accel (m/s^2)', 'FontSize', 16)
legend({n_idx,m_idx}, 'FontSize', 16,'Location','northeastoutside')
% xlim([0 50])
% Tile 3
nexttile(t)
plot(arm_1.allCars(n).History(1,:), arm_1.allCars(n).History(3,:),'bo-','LineWidth',2)
hold on
plot(arm_2.allCars(m).History(1,:), arm_2.allCars(m).History(3,:),'r*-','LineWidth',2)
% xlabel('Time (s)', 'FontSize', 16)
ylabel('Velocity (m/s)', 'FontSize', 16)
legend({n_idx,m_idx}, 'FontSize', 16,'Location','northeastoutside')
ylim([-0.5 13])
% xlim([0 50])

% Tile 4
nexttile(t)
x1 = 0;
x2 = t_rng(nIterations);
% x1 = arm_2.allCars(1).s_in;
% x2 = arm_2.allCars(1).s_out;
y1 = arm_1.allCars(1).s_in;
y2 = arm_1.allCars(1).s_out;
x = [x1, x2, x2, x1, x1];
y = [y1, y1, y2, y2, y1];
patch(x,y,[0.5 0.5 0.5],'EdgeColor','None');
JNC = 'Junction';
hold on
plot(arm_1.allCars(n).History(1,:), arm_1.allCars(n).History(2,:),'bo-','LineWidth',2)
hold on
plot(arm_2.allCars(m).History(1,:), arm_2.allCars(m).History(2,:),'r*-','LineWidth',2)
% xlabel('Time (s)', 'FontSize', 16)
ylabel('Displacement (m)', 'FontSize', 16)
lgd = legend({JNC,n_idx,m_idx}, 'FontSize', 16,'Location','northeastoutside');
% xlim([0 50])


% create an array of actions taken every time step by each car
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