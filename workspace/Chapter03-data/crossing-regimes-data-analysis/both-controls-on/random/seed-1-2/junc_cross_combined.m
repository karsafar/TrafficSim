clc
clear
close all

%%
% load data in the loop
d = dir('sim-*.mat');
Number_mat = length(d);
numCars = [];
a_val = [0.2 0.6 1 1.5 3.5];
for i = 1:Number_mat
    
    fnm = sprintf('sim-%s',num2str(i));
    load(fullfile(fnm))   
    for j = 1:numel(data)
        numCrosses(i,j) = numel(data(j).crossCount);
    end
end 

f = figure();
f.Renderer='Painters';
ax = axes;
[k,q, v] = fundamentaldiagram();
y_assimptote = 0:0.01:3000;
x_assimptote = ones(1,300001)*0.0595;
plot(ax,x_assimptote,y_assimptote,'k--','LineWidth',2)
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

y_assimptote = 0:0.01:3000;
x_assimptote = ones(1,300001)*0.062;
plot(ax,x_assimptote,y_assimptote,'g--','LineWidth',2,'DisplayName','Instability point for a = 1 m/s^2')

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
y_assimptote = 0:0.01:3000;
x_assimptote = ones(1,300001)*0.0302;
plot(ax,x_assimptote,y_assimptote,'r--','LineWidth',2,'DisplayName','Instability point for a = 0.2 m/s^2')

y_assimptote = 0:0.01:3000;
x_assimptote = ones(1,300001)*0.0448;
plot(ax,x_assimptote,y_assimptote,'m--','LineWidth',2,'DisplayName','Instability point for a = 0.6 m/s^2')
