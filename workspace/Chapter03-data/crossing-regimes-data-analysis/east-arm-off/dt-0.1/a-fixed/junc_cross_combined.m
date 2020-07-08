clc
clear
close all

%%
% load data in the loop
d = dir('sim-*.mat');
Number_mat = length(d);
numCars = [];
a_val = [0.2 1 1.5 3.5];
for i = 1:Number_mat
    
    fnm = sprintf('sim-%s',num2str(i));
    load(fullfile(fnm))   
    for j = 1:numel(data)
        numCrosses(i,j) = numel(data(j).crossCountNorth);
    end
end 



ax = axes;
[k,q, v] = fundamentaldiagram();
plot(ax,q*3600,k*500,'k-','LineWidth',2)
lgd = legend(ax,'analytical curve');
xlabel('nCrosses/hour','FontSize',14)
ylabel('nCars/arm','FontSize',14)
ylim([10 72])
yticks(10:2:72)
grid on
hold on
colArray = {'r-','g-','b-','c-'};
for i = 1:Number_mat
    dispname = sprintf('a_{IDM} = %s m/s^2',num2str(a_val(i)));
    plot(ax,numCrosses(i,:),numCars(1,:),colArray{i},'LineWidth',2,'DisplayName',dispname)
end
lgd.FontSize = 14;

title(ax,'North Arm. max a_{junc} = a_{max}','FontSize',16)