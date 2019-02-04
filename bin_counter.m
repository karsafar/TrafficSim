clc
clear
close all

%% 
load(['test-' num2str(7) '.mat']);

%%

sim.carTypeOrders(:,1) = convert_types_to_nums(sim.horizArm.allCars);
sim.carTypeOrders(:,2) = convert_types_to_nums(sim.vertArm.allCars);

%%

horizBinCount = frequency_count(sim.carTypeOrders(:,1),nCars);
vertBinCount  = frequency_count(sim.carTypeOrders(:,2),nCars);

[ro1,col1] = find(horizBinCount);
[row2,col2] = find(vertBinCount);
maxCol = max([col1',col2']);
horizBinCount = horizBinCount(:,1:maxCol);
vertBinCount = vertBinCount(:,1:maxCol);

mytable = table('Size', [maxCol, 1],'VariableTypes',{'string'});
for i = 1:maxCol
    mytable{i,1} = {sprintf('Group of %i',i)};
end

%%

ax1 = subplot(2,1,1);
h1 = bar(ax1,horizBinCount');
title(ax1,'East Arm','FontSize',16)
lgd = legend(h1,'A','B','C');
lgd.FontSize = 16;
xticks(ax1,(1:length(horizBinCount)))
xticklabels(ax1,table2array(mytable(:,1)))
xtickangle(ax1,45)
grid on

ax2 = subplot(2,1,2);
h2 = bar(ax2,vertBinCount');
title(ax2,'North Arm','FontSize',16)
lgd = legend(h2,'A','B','C');
lgd.FontSize = 16;
xticks(ax2,(1:length(horizBinCount)))
xticklabels(ax2,table2array(mytable(:,1)))
xtickangle(ax2,45)
grid on



%%

%%%%%%%%%%%%%%%%%% FUNCTION convert_types_to_nums %%%%%%%%%%%%%%%%%%%%%
function orderNums = convert_types_to_nums(allCars)

orderNums = NaN(1,numel(allCars));
for i = 1:numel(allCars)
    switch class(allCars(i))
        case 'carTypeA'
            orderNums(i) = 1;
        case 'carTypeB'
            orderNums(i) = 2;
        otherwise
            orderNums(i) = 3;
    end
end

end

%%

%%%%%%%%%%%%%%%%%% FUNCTION frequency_count %%%%%%%%%%%%%%%%%%%%%%%%%%%
function binCount = frequency_count(carsOrder,nCars)

binCount = zeros(max(carsOrder),floor(nCars(1)/2));
for carIdx = 1:max(carsOrder)
    for i = 1:length(binCount)
        endFlag = 0;
        j = 1;
        firstIdxMatch = 0;
        while j <= nCars(1)
            if carsOrder(j) == carIdx
                if j == 1
                   firstIdxMatch = 1;
                end
                count = 1;
                noMatchFlag = [0 0];
                for ii = 1:i
                    if j+ii > nCars(1) && noMatchFlag(1) == 0
                        endFlag = 1;
                        if carsOrder(j+ii-end) == carIdx && firstIdxMatch == 0
                            count = count + 1;
                        elseif firstIdxMatch == 1
                            count = 0;
                            noMatchFlag(1) = 1;
                            noMatchFlag(2) = 1;
                        end
                    elseif noMatchFlag(1) == 0 && carsOrder(j+ii) == carIdx
                        count = count + 1;
                    else
                        noMatchFlag(1) = 1;
                    end
                    
                    
                    if noMatchFlag(2) == 0
                        if (j-ii < 1 && carsOrder(end+(j-ii)) == carIdx) || (j-ii >= 1 && carsOrder(j-ii) == carIdx)
                            count = count + 1;
                        else
                            noMatchFlag(2) = 1;
                        end
                    end
                    if sum(noMatchFlag) == 2 || endFlag == 1
                        break;
                    end
                end
                if count == i
                    binCount(carIdx,i) = binCount(carIdx,i) + 1;
                    j = j+i-1;
                end
            end
            j = j+1;
        end
    end
end

end

