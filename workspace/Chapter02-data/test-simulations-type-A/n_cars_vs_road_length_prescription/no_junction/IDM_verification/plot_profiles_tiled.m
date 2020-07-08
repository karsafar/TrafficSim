% choose cars to compare
close all

% copy the road to a faster accessible memory 
% arm = sim.horizArm;
arm = sim.vertArm;

%% Create a tile figure
figure
t = tiledlayout(3,1);
xlabel(t,'Time (s)', 'FontSize', 16)

%% Tile 1
nexttile(t)
actArray_n = act_mat2array(arm,n);
plot(t_rng,actArray_n,'bo-','LineWidth',2)
hold on
yticks(1:5)
ylim([0.5 5.5])
yticklabels({'Follow','Back-off','Ahead','Behind','eStop'})

% xlabel('Time (s)', 'FontSize', 16)
ylabel('Actions', 'FontSize', 16)
% legend({n_idx,m_idx}, 'FontSize', 16,'Location','northeastoutside')
% xlim([0 50])

%% Tile 2
nexttile(t)
plot(t_rng, arm.allCars(n).History(3,:),'-','LineWidth',2)
hold on
% xlabel('Time (s)', 'FontSize', 16)
ylabel('Accel (m/s^2)', 'FontSize', 16)
% legend({n_idx,m_idx}, 'FontSize', 16,'Location','northeastoutside')
% ylim([-2 1.5])


%% Tile 3
nexttile(t)
plot(t_rng, arm.allCars(n).History(2,:),'-','LineWidth',2)
hold on
% xlabel('Time (s)', 'FontSize', 16)
ylabel('Velocity (m/s)', 'FontSize', 16)
% legend({n_idx,m_idx}, 'FontSize', 16,'Location','northeastoutside')
ylim([-0.5 13])
% xlim([0 20])

%% Tile 4
nexttile(t)
plot(t_rng, arm.allCars(n).History(1,:),'-','LineWidth',2)
hold on
ylabel('Displacement (m)', 'FontSize', 16)
% legend({n_idx,m_idx}, 'FontSize', 16,'Location','northeastoutside')
% ylim([0 60])

%% save
fig = gcf;
fig.PaperPositionMode = 'auto';
fig.PaperPosition;
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(fig,'/Users/robot/cross_sim/workspace/Chapter02-data/test-simulations-type-A/n_cars_vs_road_length_prescription/no_junction/IDM_verification/three_cars_profiles','-dpdf','-r0','-bestfit')

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