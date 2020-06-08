set(0,'defaultAxesTickLabelInterpreter','latex'); 
set(0,'defaultLegendInterpreter','latex');
set(0,'defaultLegendFontName','Times New Roman');
set(0,'defaultTextInterpreter','latex');
set(0,'defaultTextboxshapeInterpreter','latex');
set(0,'defaultAxesFontSize',22);
set(0,'defaultAxesFontName','Times New Roman');
%%

ax1 = axes;
set(ax1,'FontSize',14)
ylabel(ax1,'Acceleration (m/s^2)')
xlabel(ax1,'Distance to Junction (m)')
hold(ax1,'on');
grid(ax1,'on');
R = linspace(0.05,4,1000);
set(ax1, 'YScale', 'log')

%%
f = @(r) 1*((0.3./r).^6 - (0.25./r).^6);
% f = @(r) 2*((1./r).^20 - (0.25./r).^20);

plot(ax1,R,f(R),'LineWidth',2)
grid on

f(0.2)
%%

f = @(r) 10*((2.5./r).^6 - (0.25./r).^6);
hold on
temp = f(R);
plot(ax1,R,temp,'LineWidth',2)

f(0.1)

return

%%
f = @(r) 10*((0.2./r).^12 - (0.25./r).^6);

R = linspace(0,4,1000);
plot(ax1,R,f(R),'LineWidth',2)
grid on

% f(2)
% syms r
% a = 10*((1.5/r)^12-(.25/r)^6)
%% 
ax1 = axes;
ylabel(ax1,'Acceleration ($\mathrm{m/s^2}$)')
xlabel(ax1,'Distance to Junction $d_J^i$ (m)')
hold(ax1,'on');
grid(ax1,'on');
R = linspace(0,5,1000);
set(ax1, 'YScale', 'log')

f = @(r) 10*((2.25./r).^6);
hold on
temp = f(R);
plot(ax1,R,-temp,'k-','LineWidth',1)

plot(ax1,R,-9*ones(1,numel(temp)),'r-')

plot(ax1,R,-temp-9,'b-','LineWidth',2)

plot(ax1,1.3*ones(1,numel(temp)),-temp,'k--')

xlim([0 5])
ylim([-1000000 0])

legend(ax1,'$a_{\mathrm{LJ}}$','$a_{\mathrm{comf}}^{\mathrm{max}}$','$a_{\mathrm{stop}}^{i}$','$d_{\mathrm{critical}}$')

%% saving figure as a PDF
% xlim([1000 1500])
fig = gcf;
fig.PaperPositionMode = 'auto';
fig.PaperPosition;
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
% print(fig,'/Users/robot/cross_sim/workspace/Chapter03-data/jcunction-flow-change-sym-1-vel-0-no-warm-up-002','-dpdf','-r0','-bestfit')
% print(fig,'/Users/robot/cross_sim/workspace/Chapter02-data/test-simulations-type-A/n_cars_vs_road_length_prescription/junction/junc_30_cars_1500_m_0_02_zoomed','-dpdf','-r0','-bestfit')
print(fig,'/Users/robot/cross_sim/workspace/LennardJonesKoefficient','-dpdf','-r0','-bestfit')
