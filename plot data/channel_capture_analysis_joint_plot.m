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

return
%%

load('aggregatedCrossingData.mat');

%% junction crossing graph

idx = 26;

figure('units', 'normalized', 'position', [0.4, 0, 0.6, 1]);
for idx = 1:numel(data)
    numCars(1,idx)
    ax1 = subplot(2,1,1);
    plot(ax1,data(idx).crossOrder,'-b','LineWidth',1.5)
    axis(ax1,[0 numel(data(idx).crossOrder) 0 3])
%     axis(ax1,'off')
%     grid(ax1,'on');
    xlabel(ax1,'Iteration Number','FontSize',16)
    text(ax1,numel(data(idx).crossOrder)/2,-0.1,'\uparrow East Arm Crosses','FontSize',16)
    text(ax1,numel(data(idx).crossOrder)/2,1.1,'\downarrow North Arm Crosses','FontSize',16)
    ylim(ax1,[-0.5,1.5])
    
    ax2 = subplot(2,1,2);
    plot(ax2,data(idx).crossCount,'-b','LineWidth',1.5)
    axis(ax2,[0 numel(data(idx).crossCount) 0 3])
%     axis(ax2,'off')
%     grid(ax2,'on');
    xlabel(ax2,'Number of Junction Crosses','FontSize',16)
    text(ax2,numel(data(idx).crossCount)/2,-0.1,'\uparrow East Arm Crosses','FontSize',16)
    text(ax2,numel(data(idx).crossCount)/2,1.1,'\downarrow North Arm Crosses','FontSize',16)
    ylim(ax2,[-0.5,1.5])
    pause(1)
end
%}
%% junction crossing with car types info
figure('units', 'normalized', 'position', [0.4, 0, 0.6, 1]);
for idx = 1:numel(data)
    numCars(1,idx)
    sz = 25;
    ax1 = subplot(2,1,1);
    x = 1:numel(data(idx).crossOrder);
    y = data(idx).crossOrder;
    c = NaN(length(x),3);
    idx1 = find(data(idx).crossCarTypeOrder == 1);
    idx2 = find(data(idx).crossCarTypeOrder == 2);
    
    c(idx1,:) = ones(numel(idx1),3).*[0 1 0];
    c(idx2,:) = ones(numel(idx2),3).*[1 0 0];
    line(ax1,x,y,'Color','black');
    hold(ax1,'on');
    scatter(ax1,x,y,sz,c,'filled')
%     hold(ax1,'off');
    xlabel(ax1,'Iteration Number','FontSize',16)
    text(ax1,numel(data(idx).crossOrder)/2,-0.1,'\uparrow East Arm Crosses','FontSize',16)
    text(ax1,numel(data(idx).crossOrder)/2,1.1,'\downarrow North Arm Crosses','FontSize',16)
    ylim(ax1,[-0.5,1.5])
    ax2 = subplot(2,1,2);
%     cla(ax2)
    x = 1:numel(data(idx).crossCount);
    y = data(idx).crossCount;
    c = NaN(length(x),3);
    idx1 = find(data(idx).crossCarTypeCount == 1);
    idx2 = find(data(idx).crossCarTypeCount == 2);
    
    c(idx1,:) = ones(numel(idx1),3).*[0 1 0];
    c(idx2,:) = ones(numel(idx2),3).*[1 0 0];
    line(ax2,x,y,'Color','black');
    hold(ax2,'on');
    scatter(ax2,x,y,sz,c,'filled')
%     hold(ax2,'off');
    xlabel(ax2,'Number of Junction Crosses','FontSize',16)
    text(ax2,numel(data(idx).crossCount)/2,-0.1,'\uparrow East Arm Crosses','FontSize',16)
    text(ax2,numel(data(idx).crossCount)/2,1.1,'\downarrow North Arm Crosses','FontSize',16)
    ylim(ax2,[-0.5,1.5])
%     pause(1)
    cla(ax1)
    cla(ax2)

end


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

%%  old line plots
%{
figure; hold on;grid on
ylabel(' "Word" Length','FontSize',14)
zlabel('p(E|nE)','FontSize',14)
xlabel('Numer of cars per arm','FontSize',14)

% plot(bitSize,p_E,'-*')
for i = 1:m
    plot3(ones(1,n)*numCars(1,i),bitSize,p_E(i,:),'-')
end
%plot(bitSize,p_N,'-ob')

yticks(bitSize)
xticks(numCars(1,:))
for i = 1:m
    x_tickLabel{i} = sprintf('%d',numCars(1,i));
end
xticklabels(x_tickLabel)
% xtickanxgle(45)

zlim([0 1])
ylim([2 n+1])
yticks(2:n+1)
for i = 1:n
    tickLabel{i} = sprintf('%dE',i);
end
yticklabels(tickLabel)
ytickangle(45)
%}

%%
figure;
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
% yticks(1:2:n)


%% 
clear figure
figure;
Z = p_E;
X = repmat(bitSize',length(numCars(1,:)),1) ;
Y = repmat(numCars(1,:)',1,length(bitSize)) ;
surf(X,Y,Z);
% shading interp
 view(2);

 
c = colorbar;
c.Label.String = 'p(E|nE)';
c.Label.FontSize = 16;
caxis([0 1])
xlabel(' "Word" Length','FontSize',14)
zlabel('p(E|nE)','FontSize',14)
ylabel('Numer of cars per arm','FontSize',14)



xlim([2 n+1])
xticks(2:n+1)
% for i = 1:n
%     tickLabel{i} = sprintf('%dE',i);
% end
% xticklabels(tickLabel)
xtickangle(45)


%%
% %{
p_E_given_N  = p_E(1);

counts = get_kernel_counts(bitSize(2), data(1).crossOrder);

bitNum = length(counts);
half = bitNum/2;
sum_counts = counts(1:half) + counts(end:-1:half+1);
p_E_given_EN = sum(sum_counts((bitNum/4+1):end-bitNum/8))/sum(sum_counts((bitNum/4+1):end));



figure; hold on;
xlabel('"Word" Length','FontSize',14)
ylabel('Probability of Next Bit E','FontSize',14)
plot(bitSize(1:2),  [p_E_given_N, p_E_given_EN] ,'-x')
grid on
ylim([0 1])
% lgd = legend({'p(E|N)','p(E|EN)'},'location','northwestoutside');
% lgd.FontSize = 14;
xticks([2 3])
xticklabels({'N','EN'})



%% Platoon sizes and frequencies

% idx = 17;

platoons = NaN(length(data),50);
orderedPlatoons = NaN(length(data),900);
for idx = 1:length(data)
%     figure(6)
%     plot(data(idx).crossOrder,'-b','LineWidth',1.5)
%     axis([0 numel(data(idx).crossOrder) 0 3])
%     grid on
%     xlabel('Number of Junction Crosses','FontSize',16)
%     text(numel(data(idx).crossOrder)/2,-0.1,'\uparrow East Arm Crosses','FontSize',16)
%     text(numel(data(idx).crossOrder)/2,1.1,'\downarrow North Arm Crosses','FontSize',16)
%     ylim([-0.5,1.5])
%     pause(1)
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
    % figure
    % bar(freq_counter)
    % xlim([0 max(col)])
    % grid on
    % xlabel('Size of the Platoon, veh','FontSize',14)
    % ylabel('Frequency','FontSize',14)
    
    %
%     figure
%     bp1 = [];
%     for i = 1:length(col)
%         temp = col(i)*ones(1,freq_counter(col(i)));
%         bp1 = [bp1, temp];
%     end
    platoonNums = freq_counter((freq_counter) > eps);
    numCars(1,idx);
    [platoonSizes;platoonNums];
    c = categorical(platoonSizes);
    platoons(idx,1:numel(platoonSizes)) = (platoonNums.*platoonSizes);%/length(freq_counter);
% platoons(idx,1:numel(platoonSizes)) = platoonSizes;
    maxPlatoons(idx) = max(platoonSizes);
%     bar(prices','stacked')
    
end
%}
%}
%%
figure
ax3 = axes;
% orderedPlatoons(:,253:end)=[];


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
% c = colorbar;
% c.Label.String = 'Platoon Size';
% c.Label.FontSize = 12;
% caxis(ax3,[1 max(max(orderedPlatoons))])

% h = bar(ax3,orderedPlatoons,'stacked');


% h(49).FaceColor
% h(49).CData= orderedPlatoons;

% caxis(ax3,[1 max(max(orderedPlatoons))])

% set(bar_child,'CData',max(max(orderedPlatoons)));
% colormap(flipud(jet));

% c = colorbar;
% c.Label.String = 'Platoon Size';
% c.Label.FontSize = 12;
% caxis(ax3,[1 max(max(orderedPlatoons))])

for i = 1:numel(data)
    dataNums(1,i) = numel(data(i).crossCount(:));
end
hold(ax3,'on');
text(ax3,numCars(1,:)',dataNums,num2str(dataNums'),'vert','middle','horiz','left','FontSize',14);
ylabel('Crossing Platoon Sizes','FontSize',14)
xlabel('Numer of cars per arm','FontSize',14)
% xlim([0 1])
% ylim([2 n+1])
% axis(ax3,'off')
xticks(numCars(1,1):2:numCars(1,end))
xlim([numCars(1,1)-2 numCars(1,end)+2])
view([90 -90])

% c = colorbar;
% c.Label.String = 'Platoon Size';
% c.Label.FontSize = 12;
% caxis(ax3,[1 max(max(orderedPlatoons))])
%
% A loop that does num2str conversion only if value is >0
% for i=1:size(platoons,1)
%     for j=1:size(platoons,2)
%         if platoons(i,j)>0
%         labels_stacked=num2str(platoons(i,j))
%         hText = text(ax,i, sum(platoons(i,1:j),2), labels_stacked)
%         i, sum(platoons(i,1:j),2)
%         set(hText,'HorizontalAlignment', 'center','FontSize',20, 'Color','k');
%         break
%         end
%     end
%     break
% end
%%
figure
plot(numCars(1,:),maxPlatoons)
ylabel('Largest platoon','FontSize',14)
xlabel('Density, veh/m','FontSize',14)
grid on 
hold on
legend('road length 1000 m','road length 500 m')
%%
function [p_E, p_N] = calc_cond_probability(counts,x)

% mymat = dec2bin(2^bits-1:-1:0)-'0';
% bitNum = length(counts);
% mymat = (2^(x+1)-1):-1:0;
% bits = x+1;
% 
% diff_counts = NaN(length(mymat),1);
% 
% for i = 1:length(mymat)/2
%     diff_counts(i) = i;
%     diff_counts(end-i+1) = i;
% end
% 
% Alphabet = {'EN'};
% 
% groupTable = table('Size', [bitNum, 1],'VariableTypes',{'string'});
% for i = 1:bitNum
%     groupTable{i,1} = {sprintf('%s/%s', Alphabet{1}((dec2bin(i-1, bits) - '0')+1) , Alphabet{1}((dec2bin(2^bits-i, bits) - '0')+1))};
% end


% sum_counts = NaN(1,max(diff_counts));
% for i = 1:max(diff_counts)
%     sum_counts(i) = sum(counts(diff_counts == (i)));
% 
% 
% end

% half = bitNum/2;
% a = reshape(counts,half,2);
% sum_counts = a(:,1) + flipud(a(:,2));
% 
% p_E = sum(sum_counts(1:bitNum/2^(x+1)))/sum(sum_counts(1:bitNum/2^x));
% p_N = sum(sum_counts((bitNum/2^(x+1)+1):2*bitNum/2^(x+1)))/sum(sum_counts(1:bitNum/2^x));

E_counts = counts(1)+counts(end);
N_counts = counts(2)+counts(end-1);

p_E = max(E_counts/(E_counts+N_counts),0);
p_N = max(N_counts/(E_counts+N_counts),0);


end
%%
function counts = get_kernel_counts(bits, data)
counts = zeros(4,1);
% counts_temp = zeros((2^(bits)),1);
no = length(data);
for i = 1:no-bits+1
    bin_i = data(i:i+bits-1);
%     decNum = 0;
%     for j=1:bits
%         decNum = decNum + 2^(j-1) * bin_i(end-j+1);
%     end
%     decNumTemp = 0;
%     decNumTemp = bin2dec(char('0' + bin_i));
    %decNumTemp = bin2dec(num2str(bin_i))+1;
%     switch (decNum+1)
%         case 1
%           counts(1) = counts(1) + 1;
%         case 2
%             counts(2) = counts(2) + 1;
%         case (arrayLength-1)
%             counts(3) = counts(3) + 1;
%         case arrayLength
%             counts(4) = counts(4) + 1;
%         otherwise
%     end
    
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
%     counts_temp(decNum) = counts_temp(decNum)+1;
end
end
