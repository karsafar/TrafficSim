% choose cars to compare
close all


load('maxVelToZero.mat')
% copy the road to a faster accessible memory 
singleRoad = sim.horizArm;


load('zeroVelToZero.mat')
singleRoad.allCars(3) = sim.horizArm.allCars(2);


figure
t = tiledlayout(3,1);
xlabel(t,'Time (s)', 'FontSize',20,'Interpreter','latex')


%% plot accelerations
% Tile 1
nexttile(t)
plot(t_rng, singleRoad.allCars(2).History(3,:),'r-',...
     t_rng, singleRoad.allCars(3).History(3,:),'g-',...
     t_rng, singleRoad.allCars(1).History(3,:),'b-','LineWidth',2)
% xlabel('Time (s)', 'FontSize',20,'Interpreter','latex')
ylabel('Acceleration ($\mathrm{m/s^2}$)', 'FontSize', 20,'Interpreter','latex')
xlim([0 20])
ylim([-4 2])
hold on
plot(t_rng,1*ones(1,nIterations),'g--',...
    t_rng,-1.5*ones(1,nIterations),'r--','LineWidth',1)
% legend('Vehicle 1 with $v(0) = 0$','Vehicle 1 with $v(0) = \overline{v}$',...
%     'Vehicle 2','Comfortable acceleration $a = 1\,\mathrm{m/s^2}$',...
%     'Comfortable deceleration $b = -1.5\,\mathrm{m/s^2}$',...
%     'Location','southeast','Interpreter','latex', 'FontSize', 20)
%% plot velocities
% Tile 2
nexttile(t)
plot(t_rng, singleRoad.allCars(2).History(2,:),'r-',...
     t_rng, singleRoad.allCars(3).History(2,:),'g-',...
     t_rng, singleRoad.allCars(1).History(2,:),'b-','LineWidth',2)
% xlabel('Time (s)', 'FontSize',20,'Interpreter','latex')
ylabel('Velocity ($\mathrm{m/s}$)', 'FontSize', 20,'Interpreter','latex')
hold on
plot(t_rng,13*ones(1,nIterations),'k--','LineWidth',1)
% legend('Vehicle 1 with $v(0) = 0$','Vehicle 1 with $v(0) = \overline{v}$',...
%     'Vehicle 2','Maximum velocity $\overline{v} = 13\,\mathrm{m/s}$',...
%     'Location','southeast','Interpreter','latex', 'FontSize', 20)
xlim([0 20])
ylim([0 14])

%% plot displacements
% Tile 3
nexttile(t)
plot(t_rng, -4.4-singleRoad.allCars(2).History(1,:),'r-',...
     t_rng, -4.4-singleRoad.allCars(3).History(1,:),'g-',...
     t_rng, -singleRoad.allCars(1).History(1,:),'b-','LineWidth',2)
% xlabel('Time (s)', 'FontSize',20,'Interpreter','latex')
ylabel('Space Gap ($\mathrm{m}$)', 'FontSize', 20,'Interpreter','latex')
hold on
% x = [0 nIterations nIterations 0];
% y = [2 2 6.3 6.3];
% h1 = patch(x,y,[0.92 0.92 0.92]);
% h1.EdgeColor = 'none';
plot(t_rng,2*ones(1,nIterations),'k--','LineWidth',1)
% legend('Vehicle 1 with $v(0) = 0$','Vehicle 1 with $v(0) = \overline{v}$',...
%     'Vehicle 2','Minimum space gap $s_0 = 2\,\mathrm{m}$',...
%     'Location','northeast','Interpreter','latex', 'FontSize', 20)
xlim([0 20])
% ylim([0 10])

%% plot gaps

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
print(fig,'/Users/robot/cross_sim/workspace/Chapter02-data/test-simulations-type-A/n_cars_vs_road_length_prescription/no_junction/IDM_verification/Accel_emerg_stop','-dpdf','-r0','-bestfit')