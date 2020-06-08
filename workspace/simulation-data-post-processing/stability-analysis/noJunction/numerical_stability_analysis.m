clc
clear
close all

%%
% load data in the loop
d = dir('a_idm_*.mat');
Number_mat = length(d);
numCars = [];
a_val = {'0_5','0_5','1_5','2'};
for i = 1:Number_mat
    fnm = sprintf('a_idm_%s',a_val{i});
    load(fullfile(fnm))   
    for j = 1:numel(data)
        numCrosses(i,j) = numel(data(j).crossCount);
    end
end 

%% plot density-flow diagrams

plot_density_flow(eastArm.flow,eastArm.density, northArm.flow,northArm.density,junction.flow,junction.density);

%% Instability border lines (sim vs analyt) 
y_assimptote = 0:max(ylim);
% x_assimptote = ones(1,numel(y_assimptote))*0.0416; % for a_idm = 0.5
% x_assimptote = ones(1,numel(y_assimptote))*0.0620; % for a_idm = 1
plot(x_assimptote,y_assimptote,'k--','LineWidth',1,'DisplayName','Instability point')


%% saving figure as a PDF
fig = gcf;
fig.PaperPositionMode = 'auto';
fig.PaperPosition;
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(fig,'a_idm_2','-dpdf','-r0','-bestfit')


%%
function plot_density_flow(flow1,density1,flow2,density2,flow3,density3)
% figure;
% ha10 = subplot(2,2,3);
ha10 = axes;
% title(ha10,'Flow-Density Diagram','FontSize',20)
xlabel(ha10,' Density $\rho\,(\mathrm{veh/m})$')
ylabel(ha10,' Flow Q  $(\mathrm{veh/hr})$')
hold on
grid on
[k,q,v] = fundamentaldiagram();
plot(ha10,k,q*3600,'k','LineWidth',2)
plot(ha10,density1,flow1*3600,'r^','MarkerFaceColor','r','LineWidth',1);
% plot(ha10,density2,flow2,'-r');
% plot(ha10,density3,flow1+flow2,'--g');
legend(ha10,{'Fundamental diagram','Numerical simulations'})
% legend(ha10,{'Analytical curve','East Arm','North Arm','Average'},'FontSize',16)
% xlim([0 0.131])
% xticks(0:0.01:0.13)
end
