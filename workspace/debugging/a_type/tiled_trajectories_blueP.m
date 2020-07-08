
set(0,'defaultAxesTickLabelInterpreter','latex'); 
set(0,'defaultLegendInterpreter','latex');
set(0,'defaultLegendFontName','Times New Roman');
set(0,'defaultTextInterpreter','latex');
set(0,'defaultTextboxshapeInterpreter','latex');
set(0,'defaultAxesFontSize',22);
set(0,'defaultAxesFontName','Times New Roman');
%% 
% choose cars to compare
% close all
n = 22;
m = 6;

xA = 0; xB = 200;
% xA = 0; xB = t_rng(end);
yA = road.Start(1); yB = road.End(1);
% yA = -6.3; yB = -5;

% select the arm
flag = 0;
switch flag
    case 1 % East arm only
        arm_1 = sim.horizArm;
        arm_2 = arm_1;
        n_idx = sprintf('Eastbound vehicle %i',n);
        m_idx = sprintf('Eastbound vehicle %i',m);
    case 2 % North arm only
        arm_1 = sim.vertArm;
        arm_2 = arm_1;
        n_idx = sprintf('Northbound vehicle %i',n);
        m_idx = sprintf('Northbound vehicle %i',m);
    otherwise % Both arms
        arm_1 = sim.horizArm;
        arm_2 = sim.vertArm;
%         n_idx = sprintf('Eastbound vehicle %i',n);
%         m_idx = sprintf('Northbound vehicle %i',m);
        n_idx = sprintf('Eastbound vehicle trajectory');
        m_idx = sprintf('Northbound vehicle trajectory');
end


% Create a tile figure
% t = tiledlayout('flow');
figure(10)
t = tiledlayout(4,1);
xlabel(t,'Time (s)','Interpreter','latex','FontSize',22)

% Tile 1: displacements
nexttile(t)

plot(t_rng, arm_1.allCars(n).History(1,:),'ro-','LineWidth',1.5)
hold on
plot(t_rng, arm_2.allCars(m).History(1,:),'b*-','LineWidth',1.5)
% xlabel('Time (s)', 'FontSize', 16)
ylabel('Displacement (m)')

x1 = 0;
x2 = t_rng(nIterations);
% x1 = arm_2.allCars(1).s_in;
% x2 = arm_2.allCars(1).s_out;
y1 = arm_1.allCars(1).s_in;
y2 = arm_1.allCars(1).s_out;
x = [x1, x2, x2, x1, x1];
y = [y1, y1, y2, y2, y1];
p1 = patch(x,y,[0.5 0.5 0.5],'EdgeColor','None');
p1.FaceAlpha = 0.5;
JNC = 'Junction';

lgd = legend({n_idx,m_idx,JNC},'Location','northoutside','Orientation','horizontal');
xlim([xA xB])
ylim([yA yB])


% Tile 2: velocities
nexttile(t)
plot(t_rng, arm_1.allCars(n).History(2,:),'ro-','LineWidth',1.5)
hold on
plot(t_rng, arm_2.allCars(m).History(2,:),'b*-','LineWidth',1.5)
plot(t_rng,13*ones(1,nIterations),'k--')
t3 = text(1,14.2,'Maximum velocity $\overline{v} = 13\,\mathrm{m/s}$');
t3.FontSize = 22;
% xlabel('Time (s)', 'FontSize', 16)
ylabel('Velocity (m/s)')
% legend({n_idx,m_idx}, 'FontSize', 16,'Location','northeastoutside')
ylim([-0.5 16])
xlim([xA xB])


% Tile 3: accelerations
nexttile(t)
plot(t_rng, arm_1.allCars(n).History(3,:),'ro-','LineWidth',1.5)
hold on
plot(t_rng, arm_2.allCars(m).History(3,:),'b*-','LineWidth',1.5)
plot(t_rng,arm_1.allCars(n).a*ones(1,nIterations),'k--')
t1 = text(1,arm_1.allCars(n).a+1,strjoin({'Maximum acceleration $\overline{a} = $',sprintf('%0.1f',arm_1.allCars(n).a),'$\mathrm{m/s^2}$'}));
t1.FontSize = 22;
plot(t_rng,arm_1.allCars(n).a_feas_min*ones(1,nIterations),'k--')
t2 = text(1,arm_1.allCars(n).a_feas_min-3,strjoin({'Maximum deceleration $a_{\textrm{feas}}^{\textrm{max}} = $',sprintf('%0.1f',arm_1.allCars(n).a_feas_min),'$\mathrm{m/s^2}$'}));
t2.FontSize = 22;
% xlabel('Time (s)', 'FontSize', 16)
ylabel('Accel ($\mathrm{m/s^2}$)')
% legend({n_idx,m_idx}, 'FontSize', 16,'Location','northeastoutside')
xlim([xA xB])
ylim([arm_1.allCars(n).a_feas_min-6 arm_1.allCars(n).a+3.5])

% Tile 4: Actions
nexttile(t)
actArray_n = act_mat2array(arm_1,n);
plot(t_rng,actArray_n,'ro-','LineWidth',1.5)
hold on
actArray_m = act_mat2array(arm_2,m);
plot(t_rng,actArray_m,'b*-','LineWidth',1.5)
yticks(1:5)
ylim([0.5 5.5])
yticklabels({'Follow','Back-off','Ahead','Behind','eStop'})

% xlabel('Time (s)', 'FontSize', 16)
% ylabel('Actions')
% legend({n_idx,m_idx}, 'FontSize', 16,'Location','northeastoutside')
xlim([xA xB])
%}






%% saving figure as a PDF
fig = gcf;
fig.PaperPositionMode = 'auto';
fig.PaperPosition;
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(fig,'East1North2','-dpdf','-r0','-bestfit')
% print(fig,'TiledBehindAheadTest','-dpdf','-r0','-bestfit')

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