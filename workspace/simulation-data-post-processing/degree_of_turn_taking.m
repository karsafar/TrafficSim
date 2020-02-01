clear
close all
clc

for i = 1:11
    folderName = sprintf('density-%s',num2str(i));
    cum_count = [];
    for j = 1:1
        fileName = sprintf('test-%s.mat',num2str(j));
        load(fullfile(folderName,fileName))
        %     load(['test-' num2str(j) '.mat']);
        count = abs(diff(sim.crossCount));
        cum_count(j,1) = count(1);
        for k = 2:numel(count)
            cum_count(j,k) = (cum_count(j,k-1)+count(k))*count(k);
        end
    end
    i
    turnTakinglengths(i,:) = max(cum_count,[],2);
end



turnTakinglengths = max(cum_count,[],2);
%%
[k,q, v] = fundamentaldiagram();
maxCrosses = 2*q*t_rng(end);
nCars = 10:2:30;
for i = 1:21
    iCar = nCars(i);
    [a,idx] = ismember(round(dens(1,i),5),round(k,5));
    normData(i,:) = turnTakinglengths(i,:)./maxCrosses(idx);
end

%%

xRange = [0.02:0.002:0.06];
boxplot(normData,xRange)
% axis([0 11 0 1])
ylabel('Normalized Longest Turn-Taking','FontSize',14)
xlabel('Num cars per arm','FontSize',14)
%% 
% xRange = [10:2:30];
ax3 = axes;

%
[k,q, v] = fundamentaldiagram();
k_new = k*500-9;
xticks('auto')
xticklabels({'0.022','0.026','0.030','0.034','0.038','0.042','0.046','0.050','0.054','0.058'})
plot(ax3,k_new,2*q*3600,'k-','LineWidth',2,'DisplayName','Fundamental Diagram of Junction')
hold on
plot(ax3,k_new,q*3600,'-','Color',[0.5 0.5 0.5 ],'LineWidth',2,'DisplayName','Findamental Diagram of Single Arm')
% view([90 -90])


xRange = dens(1,:);
boxplot(ax3,turnTakinglengths',xRange)
ylabel('Capacity Q (veh/hr)','FontSize',14)
xlabel('Density \rho (veh/m)','FontSize',14)
xticks('auto')
xticklabels({'0.022','0.026','0.030','0.034','0.038','0.042','0.046','0.050','0.054','0.058'})

% % xticks(1:1:20)
% xticklabels(string([0.02:0.01:0.06]))
grid on
hold on
ylim([0 3000])

