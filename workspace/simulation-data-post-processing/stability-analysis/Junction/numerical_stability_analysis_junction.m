clc
clear
close all

%% 
% load data in the loop
d = dir('random/a_idm_*.mat');
Number_mat = length(d);
numCars = [];
a_val = {'0_5','0_75','1','1_5'};
for i = 1:Number_mat
    fnm = sprintf('a_idm_%s',a_val{i});
    setUp = sprintf('a_idm_%s_phased_vs_rand',a_val{i});
    
    %% random 
    load(fullfile('random',fnm))   
    for j = 1:numel(data)
        numCrosses_rand(i,j) = numel(data(j).crossCount);
    end
    
    % Plot Fundamental Diagram
    xlabel('Density $\rho\,(\mathrm{veh/m})$')
    ylabel('Flow $Q\,(\mathrm{veh/hr})$')
    hold on
    grid on
    box on
    [k,q,v] = fundamentaldiagram();
    plot(k,2*q*3600,'k-','LineWidth',2,'DisplayName','2x Fundamental diagram')
    plot(k,q*3600,'-','Color',[0.5 0.5 0.5 ],'LineWidth',2,'DisplayName','Fundamental diagram')
    lgd = legend;
%     lgd.Location = 'northoutside';
    lgd.NumColumns = 2;
    lgd.FontSize = 24;
    
    %% physical limiting density
    x_val = [0.05952 0.05952];
    y_val = [0 max(ylim)];
    plot(x_val,y_val,'r--','LineWidth',1,'DisplayName','Physical Limiting Density')
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
    %% no junction
    fnm = sprintf('a_idm_%s',a_val{i});
    setUp = sprintf('a_idm_%s_junction_no_junction',a_val{i});
    load(fullfile('/Users/robot/cross_sim/workspace/simulation-data-post-processing/stability-analysis/JunctionVsNoJunction/noJunciton',fnm)) 
    eastArm.density = round(eastArm.density,3);
    plot(eastArm.density,eastArm.flow*3600,'g-o','LineWidth',1,'DisplayName','Single Road Flow')
     %% Instability border lines (sim vs analyt)
    % plot the crossings
    density = round(density,3);
    plot(density(1,:),numCrosses_rand(i,:),'r-*','LineWidth',1,'DisplayName','Random Set-up')
    
    %% phased
    load(fullfile('phased',fnm))   
    for j = 1:numel(data)
        numCrosses_phased(i,j) = numel(data(j).crossCount);
    end
    %% Instability border lines (sim vs analyt)
    % plot the crossings
    density = round(density,3);
    plot(density(1,:),numCrosses_phased(i,:),' b-o','LineWidth',1,'DisplayName','Phased Set-up')
    
    

    xlim([0 0.14])
    %% save plots
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
    plot(ax,numCars(1,:)/500,numCrosses_rand(i,:),colArray{i},'LineWidth',2,'DisplayName',dispname)
end
lgd.FontSize = 10;

title(ax,' ','FontSize',16)
return

%%
a_val = 1;

dispname = sprintf('a_{IDM} = %s m/s^2',num2str(a_val));
plot(ax,numCars(1,:)/500,numCrosses_rand(3,:),'g-','LineWidth',2,'DisplayName',dispname)
lgd.FontSize = 10;

title(ax,' ','FontSize',16)

Yasymptote = 0:0.01:3000;
Xassimptote = ones(1,300001)*0.062;
plot(ax,Xassimptote,Yasymptote,'g--','LineWidth',2,'DisplayName','Instability point for a = 1 m/s^2')

%%

colArray = {'b-','c-'};
for i = 4:5
    dispname = sprintf('a_{IDM} = %s m/s^2',num2str(a_val(i)));
    plot(ax,numCars(1,:)/500,numCrosses_rand(i,:),colArray{i-3},'LineWidth',2,'DisplayName',dispname)
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
