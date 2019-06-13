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
for i = 1:11
    iCar = nCars(i);
    [a,idx] = ismember((iCar/road.Length(1)),round(k,5));
    normData(:,i) = turnTakinglengths(i,:)/maxCrosses(idx);
end

%%

xRange = [10:2:30];
boxplot(normData,xRange)
axis([0 11 0 1])
ylabel('Normalized Longest Turn-Taking','FontSize',14)
xlabel('Num cars per arm','FontSize',14)
%% 
xRange = [10:2:30];
boxplot(turnTakinglengths',xRange)
ylabel('Longest Turn-Taking','FontSize',14)
xlabel('Num cars per arm','FontSize',14)
