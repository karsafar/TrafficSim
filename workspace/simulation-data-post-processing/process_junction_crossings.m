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
% %}
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

%}

%% Platoon sizes and frequencies

platoons = NaN(length(data),50);
orderedPlatoons = NaN(length(data),3000);
colourArray = [];
for idx = 1:length(data)
    temp = [];
%     selectedTestData = data(idx).crossOrder;
    selectedTestData = data(idx).crossCount;
    selectedTestData = selectedTestData(isnan(selectedTestData)==0) ;
    freq_counter = zeros(1,length(selectedTestData));
    count = 1;
    colourArray(idx).density = [];
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
        if selectedTestData(i) == 1 && (i == 1 || selectedTestData(i) ~= selectedTestData(i-1))
            colourArray(idx).density = [colourArray(idx).density;[1 0 0]];
        elseif selectedTestData(i) == 0 && (i == 1 ||selectedTestData(i) ~= selectedTestData(i-1))
            colourArray(idx).density = [colourArray(idx).density;[0 1 0]];
        elseif isnan(selectedTestData(i)) && (i == 1 || selectedTestData(i) ~= selectedTestData(i-1))
           colourArray(idx).density = [colourArray(idx).density;[0.5 0.5 0.5]]; 
        end
    end
    if selectedTestData(i+1) == 1 && selectedTestData(i+1) ~= selectedTestData(i)
        colourArray(idx).density = [colourArray(idx).density;[1 0 0]];
    elseif selectedTestData(i+1) == 0 && selectedTestData(i+1) ~= selectedTestData(i) 
        colourArray(idx).density = [colourArray(idx).density;[0 1 0]];
    elseif isnan(selectedTestData(i)) && selectedTestData(i) ~= selectedTestData(i-1)
        colourArray(idx).density = [colourArray(idx).density;[0.5 0.5 0.5]];
    end
%     orderedPlatoons(idx,1:length(temp)) = sort(temp,'ascend');
    orderedPlatoons(idx,1:length(temp)) = temp;
    [row,platoonSizes] = find(freq_counter);

    platoonNums = freq_counter((freq_counter) > eps);
%     numCars(1,idx);
    [platoonSizes;platoonNums];
    c = categorical(platoonSizes);
    platoons(idx,1:numel(platoonSizes)) = (platoonNums.*platoonSizes);
% platoons(idx,1:numel(platoonSizes)) = platoonSizes;
    maxPlatoons(idx) = max(platoonSizes);    
end

% tic  
f2 = figure('visible', 'off');
ax3 = axes;
xlim(ax3,[0.015 0.15])
ylim(ax3,[0 3000])
xticks(ax3,0.02:0.01:0.144)
% platoonY = NaN(size(orderedPlatoons));
% platoonX = repmat(density(1,:),size(orderedPlatoons,2),1)';
for ii = 1:size(orderedPlatoons,1)
    temp = orderedPlatoons(ii,:);
    temp(isnan(temp)) = [];
    temp1 = NaN(2,numel(temp));
    temp1(:,1) = [0; temp(1)];
%     platoonY(ii,1) = 0;
    if numel(temp) >= 2
        for i = 2:numel(temp)
            temp1(:,i) = [temp1(2,i-1); temp1(2,i-1)+temp(i)];
%             platoonY(ii,i) = platoonY(ii,i-1)+temp(i);
        end
    end
% %     h = line(ax3,[numCars(1,ii)*ones(1,numel(temp))./500; numCars(1,ii)*ones(1,numel(temp))./500],temp1,'LineWidth',8);

    h = plot(ax3,[density(1,ii)*ones(1,numel(temp)); density(1,ii)*ones(1,numel(temp))],temp1,'LineWidth',4);
    set(h,{'Color'},num2cell([colourArray(ii).density(:,1),colourArray(ii).density(:,2),colourArray(ii).density(:,3)],2));

% %      plot(ax3,[numCars(1,ii)*ones(1,numel(temp)); numCars(1,ii)*ones(1,numel(temp))],temp1,'LineWidth',20)

    hold on
    if ii == 1
        h_tem = h;
    end
end
% h = plot(ax3,platoonX,platoonY,'.','LineWidth',4);
% toc
% f2.Visible = 'on';
ylabel('Junction Capacity Q (veh/hour)','FontSize',14)
xlabel('Density \rho (veh/m)','FontSize',14)
lgd = legend([h_tem],{'North Arm Crossing','East Arm Crossing'},'location','northeast');


% for i = 1:numel(data)
%     dataNums(1,i) = sum(~isnan(data(i).crossCount(:)));
% end
% hold(ax3,'on');
%  text(ax3,numCars(1,:)'./500,dataNums,num2str(dataNums'),'vert','middle','horiz','left','FontSize',10);
% text(ax3,density(1,:)',dataNums,num2str(dataNums'),'vert','middle','horiz','left','FontSize',5);

% ylabel('Crossing Platoon Sizes','FontSize',14)
% xlabel('Number of cars per arm','FontSize',14)


% xticks(numCars(1,1):2:numCars(1,end))
% xlim([numCars(1,1)-2 numCars(1,end)+2])
% view([90 -90])



[k,q, v] = fundamentaldiagram();
y_assimptote = 0:0.01:3000;
x_assimptote = ones(1,300001)*0.0595;
plot(ax3,x_assimptote,y_assimptote,'k--','LineWidth',1,'DisplayName','Critical Density','LineWidth',3)
hold on
plot(ax3,k,2*q*3600,'k','LineWidth',2,'DisplayName','Fundamental Diagram of Junction')
plot(ax3,k,q*3600,'-','Color',[0.5 0.5 0.5 ],'LineWidth',2,'DisplayName','Findamental Diagram of Single Arm')
lgd.FontSize = 10;
grid on
xlim(ax3,[0.015 0.15])
ylim(ax3,[0 3000])
xticks(ax3,0.02:0.01:0.144)

f2.Renderer='Painters';
saveas(f2,'b-random-35-sym-capacity.eps','epsc');
close(f2)
return

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
