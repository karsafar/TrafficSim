%{
clc
clear
close all

%%
% load data in the loop
d = dir('CrossOrders-*.mat');
Number_mat = length(d);
numCars = [];
for i = 1:Number_mat
    
    fnm = sprintf('CrossOrders-%s',num2str(i));
    load(fullfile(fnm))
    data(i).crossOrder = crossOrder;
    numCars = [numCars, nCars'];
    
    filename = sprintf('test-%s.mat',num2str(i));
    load(fullfile(filename),'sim')
    data(i).crossCount = sim.crossCount;
    data(i).crossCarTypeCount = sim.crossCarTypeCount;
    data(i).crossCarTypeOrder = sim.crossCarTypeOrder;
    averageVelocity(i).east = nanmean(sim.horizArm.averageVelocityHistory);
    averageVelocity(i).north = nanmean(sim.vertArm.averageVelocityHistory);
    i
end

save('aggregatedCrossingData.mat','data','numCars','averageVelocity');
%}
%% conditional probabilities

m = length(data);

n = 200; % max bit size
p_E = zeros(m,n);
p_N = zeros(m,n);
bitSize = zeros(n,1);
for i = 1:m
    for j = 1:n
        bitSize(j) = j+1;
        
        counts = get_kernel_counts(bitSize(j),data(i).crossCount);
        
        [p_E(i,j), p_N(i,j)] = calc_cond_probability(counts,j);
    end
end

f1 = figure('visible', 'off','units','normalized','outerposition',[0 0 1 1]);
Z = p_E;
X = repmat(bitSize',length(numCars(1,:)),1) ;
Y = repmat(numCars(1,:)',1,length(bitSize)) ;

sz = 30;
for i = 1:numel(numCars(1,:))
    scatter(X(i,:)',Y(i,:)',sz,Z(i,:)','filled');
    hold on
end

% Define colormap
c1=[0 1 0]; %G
c2=[1 1 0]; %Y
c3=[1 0 0]; %R
n1=20;
n2=20;
cmap=[linspace(c1(1),c2(1),n1);linspace(c1(2),c2(2),n1);linspace(c1(3),c2(3),n1)];
cmap(:,end+1:end+n2) = [linspace(c2(1),c3(1),n2);linspace(c2(2),c3(2),n2);linspace(c2(3),c3(3),n2)];
colormap(cmap')

c = colorbar;
c.Label.String = 'p(E|nE)';
c.Label.FontSize = 16;
caxis([0 1])
xlabel(' "Word" Length','FontSize',14)
zlabel('p(E|nE)','FontSize',14)
ylabel('Numer of cars per arm','FontSize',14)
axis equal

saveas(f1,'Porbabilities.png')
close(f1)



%% Platoon sizes and frequencies

platoons = NaN(length(data),50);
orderedPlatoons = NaN(length(data),1000);
for idx = 1:length(data)
    temp = [];
%     selectedTestData = data(idx).crossOrder;
    selectedTestData = data(idx).crossCount;
    freq_counter = zeros(1,length(selectedTestData));
    count = 1;
    for i = 1:length(selectedTestData)-1
        if selectedTestData(i) == selectedTestData(i+1)
            count = count + 1;
        else
            freq_counter(count) = freq_counter(count) + 1;
            temp = [temp count];
            count = 1;
        end
        if i+1 == length(selectedTestData)
            freq_counter(count) = freq_counter(count) + 1;
            temp = [temp count];
        end
    end
%     orderedPlatoons(idx,1:length(temp)) = sort(temp,'ascend');
    orderedPlatoons(idx,1:length(temp)) = temp;
    [row,platoonSizes] = find(freq_counter);

    platoonNums = freq_counter((freq_counter) > eps);
    numCars(1,idx);
    [platoonSizes;platoonNums];
    c = categorical(platoonSizes);
    platoons(idx,1:numel(platoonSizes)) = (platoonNums.*platoonSizes);
% platoons(idx,1:numel(platoonSizes)) = platoonSizes;
    maxPlatoons(idx) = max(platoonSizes);    
end


f2 = figure('visible', 'off','units','normalized','outerposition',[0 0 1 1]);
ax3 = axes;
for ii = 1:size(orderedPlatoons,1)
    temp = orderedPlatoons(ii,:);
    temp(isnan(temp)) = [];
    temp1 = NaN(2,numel(temp));
    temp1(:,1) = [0; temp(1)];
    if numel(temp) >= 2
        for i = 2:numel(temp)
            temp1(:,i) = [temp1(2,i-1); temp1(2,i-1)+temp(i)];
        end
    end
    line(ax3,[numCars(1,ii)*ones(1,numel(temp)); numCars(1,ii)*ones(1,numel(temp))],temp1,'LineWidth',20)
%     plot(ax3,[numCars(1,ii)*ones(1,numel(temp)); numCars(1,ii)*ones(1,numel(temp))],temp1,'LineWidth',20)
    hold on
end

for i = 1:numel(data)
    dataNums(1,i) = numel(data(i).crossCount(:));
end
hold(ax3,'on');
text(ax3,numCars(1,:)',dataNums,num2str(dataNums'),'vert','middle','horiz','left','FontSize',14);
ylabel('Crossing Platoon Sizes','FontSize',14)
xlabel('Numer of cars per arm','FontSize',14)

xticks(numCars(1,1):2:numCars(1,end))
xlim([numCars(1,1)-2 numCars(1,end)+2])
view([90 -90])
saveas(f2,'Platoon-sizes.png')
close(f2)



%%
f3 = figure('visible', 'off','units','normalized','outerposition',[0 0 1 1]);
plot(numCars(1,:),maxPlatoons)
ylabel('Largest platoon','FontSize',14)
xlabel('Density, veh/m','FontSize',14)
grid on 
hold on
legend('road length 500 m')
saveas(f3,'Max-platoons.png')
close(f3)

disp('done');
beep
clear

%%
function [p_E, p_N] = calc_cond_probability(counts,x)
E_counts = counts(1)+counts(end);
N_counts = counts(2)+counts(end-1);

p_E = max(E_counts/(E_counts+N_counts),0);
p_N = max(N_counts/(E_counts+N_counts),0);
end
%%
function counts = get_kernel_counts(bits, data)
counts = zeros(4,1);
no = length(data);
for i = 1:no-bits+1
    bin_i = data(i:i+bits-1);
    
    A = sum(bin_i);
    B = sum(bin_i(1:(end-1)));
    
    if A == 0
        counts(1) = counts(1) + 1;
    elseif B == 0
        counts(2) = counts(2) + 1;
    elseif A == bits
        counts(4) = counts(4) + 1;
    elseif B == (bits-1)
        counts(3) = counts(3) + 1;
    end
end
end
