% choose cars to compare
close all


load('maxVelToZero.mat')
% copy the road to a faster accessible memory 
singleRoad = sim.horizArm;


load('zeroVelToZero.mat')
singleRoad.allCars(3) = sim.horizArm.allCars(2);

%%
figure(1)
singleRoad = sim.horizArm;

t = tiledlayout(4,1);
xlabel(t,'Time (s)','Interpreter','latex','FontSize',22)

xA = 0; xB = t_rng(end);
yA = road.Start(1); yB = 10;

% plot displacements
% Tile 3
nexttile(t)
plot(t_rng, singleRoad.allCars(1).History(1,:),'r-*',...
     t_rng, singleRoad.allCars(2).History(1,:),'g-^',...
     t_rng, singleRoad.allCars(3).History(1,:),'b-o','LineWidth',1)
% xlabel('Time (s)', 'FontSize',20,'Interpreter','latex')
ylabel('Displacement ($\mathrm{m}$)')
hold on
% x = [0 nIterations nIterations 0];
% y = [2 2 6.3 6.3];
% h1 = patch(x,y,[0.92 0.92 0.92]);
% h1.EdgeColor = 'none';
% plot(t_rng,2*ones(1,nIterations),'k--','LineWidth',1)
% legend('Vehicle 1 with $v(0) = 0$','Vehicle 1 with $v(0) = \overline{v}$',...
%     'Vehicle 2','Minimum space gap $s_0 = 2\,\mathrm{m}$',...
%     'Location','northeast','Interpreter','latex', 'FontSize', 20)
xlim([xA xB])
ylim([yA yB])

lgd = legend('Vehicle 1','Vehicle 2','Vehicle 3','Location','northoutside','Orientation','horizontal');



% plot velocities
% Tile 2
nexttile(t)
plot(t_rng, singleRoad.allCars(1).History(2,:),'r-*',...
     t_rng, singleRoad.allCars(2).History(2,:),'g-^',...
     t_rng, singleRoad.allCars(3).History(2,:),'b-o','LineWidth',1)
% xlabel('Time (s)', 'FontSize',20,'Interpreter','latex')
ylabel('Velocity ($\mathrm{m/s}$)')
hold on
plot(t_rng,13*ones(1,nIterations),'k--')
t3 = text(1,14.2,'Maximum velocity $\overline{v} = 13\,\mathrm{m/s}$');
t3.FontSize = 22;
% legend('Vehicle 1 with $v(0) = 0$','Vehicle 1 with $v(0) = \overline{v}$',...
%     'Vehicle 2','Maximum velocity $\overline{v} = 13\,\mathrm{m/s}$',...
%     'Location','southeast','Interpreter','latex', 'FontSize', 20)
ylim([-0.5 16])
xlim([xA xB])



% plot accelerations
% Tile 1
nexttile(t)
plot(t_rng, singleRoad.allCars(1).History(3,:),'r-*',...
     t_rng, singleRoad.allCars(2).History(3,:),'g-^',...
     t_rng, singleRoad.allCars(3).History(3,:),'b-o','LineWidth',1)

% xlabel('Time (s)', 'FontSize',20,'Interpreter','latex')
ylabel('Acceleration ($\mathrm{m/s^2}$)')
xlim([xA xB])
ylim([-13 3.5])
hold on
plot(t_rng,1*ones(1,nIterations),'k--')
t1 = text(1,2,'Maximum acceleration $\overline{a} = 1\,\mathrm{m/s^2}$');
t1.FontSize = 22;
plot(t_rng,-9*ones(1,nIterations),'k--')
t2 = text(1,-11,'Maximum deceleration $a_{\textrm{feas}}^{\textrm{max}} = -9\,\mathrm{m/s^2}$');
t2.FontSize = 22;
% legend('Vehicle 1 with $v(0) = 0$','Vehicle 1 with $v(0) = \overline{v}$',...
%     'Vehicle 2','Comfortable acceleration $a = 1\,\mathrm{m/s^2}$',...
%     'Comfortable deceleration $b = -1.5\,\mathrm{m/s^2}$',...
%     'Location','southeast','Interpreter','latex', 'FontSize', 20)


%% Tile 4: Actions
nexttile(t)
n = 3;
actArray = [];
for i = 1:n
    actArray = [actArray act_mat2array(singleRoad,i)];
end
plot(t_rng,actArray(:,1),'r-*',...
     t_rng,actArray(:,2),'g-^',...
     t_rng,actArray(:,3),'b-o','LineWidth',1)
yticklabels({'Follow','Back-off','Ahead','Behind','eStop'})

% xlabel('Time (s)', 'FontSize', 16)
% ylabel('Actions')
% legend({n_idx,m_idx}, 'FontSize', 16,'Location','northeastoutside')


%% plot gaps
% Tile 1
nexttile(t)
gap = singleRoad.allCars(1).History(2,:) - singleRoad.allCars(2).History(2,:) - singleRoad.allCars(1).dimension(2);
plot(singleRoad.allCars(1).History(1,:), gap,'b-',...
     singleRoad.allCars(2).History(1,:), 2*ones(1,nIterations),'k--','LineWidth',2)
xlabel('Time (s)', 'FontSize', 16)
ylabel('Space Gap (m)', 'FontSize', 16)
legend('Actual Gap','Minimum Gap')
% xlim([0 10])
% ylim([0 10])
%% save

fig = gcf;
fig.PaperPositionMode = 'auto';
fig.PaperPosition;
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
% print(fig,'/Users/robot/cross_sim/workspace/Chapter02-data/test-simulations-type-A/n_cars_vs_road_length_prescription/no_junction/IDM_verification/Accel_emerg_stop','-dpdf','-r0','-bestfit')
print(fig,'3CarsStop','-dpdf','-r0','-bestfit')

%% create an array of actions taken every time step by each car
function actArray = act_mat2array(arm,n)
    actMatrix = arm.allCars(n).bbStore';
    actMatrix(actMatrix<1) = 0;
    actMatrix(:,2) = actMatrix(:,2).*2;
    actMatrix(:,3) = actMatrix(:,3).*3;
    if size(actMatrix,2) == 5
        actMatrix(:,4) = actMatrix(:,4).*4;
        actMatrix(:,5) = actMatrix(:,5).*5;
        actArray = actMatrix(:,1)+actMatrix(:,2)+actMatrix(:,3)+actMatrix(:,4)+actMatrix(:,5);
    else
%         actMatrix(:,1) = actMatrix(:,1)+actMatrix(:,4);
%         actMatrix(:,5) = actMatrix(:,5).*4;
%         actMatrix(:,6) = actMatrix(:,6).*5;
%         actArray = actMatrix(:,1)+actMatrix(:,2)+actMatrix(:,3)+actMatrix(:,5)+actMatrix(:,6);
        actMatrix(:,1) = actMatrix(:,1);
        actMatrix(:,5) = (actMatrix(:,5)+actMatrix(:,4)).*4;
        actMatrix(:,6) = actMatrix(:,6).*5;
        actArray = actMatrix(:,1)+actMatrix(:,2)+actMatrix(:,3)+actMatrix(:,5)+actMatrix(:,6);
    end
end


