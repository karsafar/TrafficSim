clc
clear
close all

%% 
% load data in the loop
d = dir('a_idm_*.mat');
Number_mat = length(d);
numCars = [];
a_val = {'0_5','0_75','1','1_5'};
for i = 1:Number_mat
    fnm = sprintf('a_idm_%s',a_val{i});
    setUp = sprintf('a_idm_%s_junction',a_val{i});
    load(fullfile(fnm))   
    for j = 1:numel(data)
        numCrosses(i,j) = numel(data(j).crossCount);
    end
    
    %% Plot Fundamental Diagram
    xlabel('Density $\rho\,(\mathrm{veh/m})$')
    ylabel('Flow Q  $(\mathrm{veh/hr})$')
    hold on
    grid on
    box on
    [k,q,v] = fundamentaldiagram();
    plot(k,2*q*3600,'k-','LineWidth',2,'DisplayName','2x Fundamental diagram')
    plot(k,q*3600,'-','Color',[0.5 0.5 0.5 ],'LineWidth',2,'DisplayName','Fundamental diagram')
    lgd = legend;
    lgd.Location = 'northoutside';
    lgd.NumColumns = 2;
    %% Instability border lines (sim vs analyt)
    % plot the crossings
    plot(density(1,:),numCrosses(i,:),'r*','LineWidth',1,'DisplayName','Random Set-up')
    % plot assymptote
    Yasymptote = 0:max(ylim);
    if i < 4
        if i == 1
            Xassimptote = ones(1,numel(Yasymptote))*0.0416; % for a_idm = 0.5
        elseif i == 2
            Xassimptote = ones(1,numel(Yasymptote))*0.04971; % for a_idm = 0.5
        elseif i == 3
            Xassimptote = ones(1,numel(Yasymptote))*0.0620; % for a_idm = 1
        end
        plot(Xassimptote,Yasymptote,'k--','LineWidth',1,'DisplayName','Instability point')
    end
    fig = gcf;
    fig.PaperPositionMode = 'auto';
    fig.PaperPosition;
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
    print(fig,fullfile(setUp),'-dpdf','-r0','-bestfit')
    close all
    clear data
end 



%% 
f = figure();
f.Renderer='Painters';
ax = axes;
[k,q, v] = fundamentaldiagram();
Yasymptote = 0:0.01:3000;
Xassimptote = ones(1,300001)*0.0595;
plot(ax,Xassimptote,Yasymptote,'k--','LineWidth',2)
hold on
plot(ax,k,2*q*3600,'k-','LineWidth',2)
lgd = legend(ax,'Critical Density','Fundamental Diagram of Junction');
plot(ax,k,q*3600,'-','Color',[0.5 0.5 0.5 ],'LineWidth',2,'DisplayName','Findamental Diagram of Single Arm')
ylabel('Junction Capacity Q (veh/hr)','FontSize',16)
xlabel('Density \rho (veh/m)','FontSize',16)
xlim([0.02 0.144])
xticks(0.02:0.01:0.144)
% ylim([10 72])
% yticks(10:2:72)
grid on
hold on
%%
colArray = {'r-','m','g-','b-','c-'};
for i = 1:2
    dispname = sprintf('a_{IDM} = %s m/s^2',num2str(a_val(i)));
    plot(ax,numCars(1,:)/500,numCrosses(i,:),colArray{i},'LineWidth',2,'DisplayName',dispname)
end
lgd.FontSize = 10;

title(ax,' ','FontSize',16)
return

%%
a_val = 1;

dispname = sprintf('a_{IDM} = %s m/s^2',num2str(a_val));
plot(ax,numCars(1,:)/500,numCrosses(3,:),'g-','LineWidth',2,'DisplayName',dispname)
lgd.FontSize = 10;

title(ax,' ','FontSize',16)

Yasymptote = 0:0.01:3000;
Xassimptote = ones(1,300001)*0.062;
plot(ax,Xassimptote,Yasymptote,'g--','LineWidth',2,'DisplayName','Instability point for a = 1 m/s^2')

%%

colArray = {'b-','c-'};
for i = 4:5
    dispname = sprintf('a_{IDM} = %s m/s^2',num2str(a_val(i)));
    plot(ax,numCars(1,:)/500,numCrosses(i,:),colArray{i-3},'LineWidth',2,'DisplayName',dispname)
end
lgd.FontSize = 10;

title(ax,' ','FontSize',16)
return 
%%
Yasymptote = 0:0.01:3000;
Xassimptote = ones(1,300001)*0.0302;
plot(ax,Xassimptote,Yasymptote,'r--','LineWidth',2,'DisplayName','Instability point for a = 0.2 m/s^2')

Yasymptote = 0:0.01:3000;
Xassimptote = ones(1,300001)*0.0448;
plot(ax,Xassimptote,Yasymptote,'m--','LineWidth',2,'DisplayName','Instability point for a = 0.6 m/s^2')
