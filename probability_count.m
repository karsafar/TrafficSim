clc
clear
close all

%%

% load data in the loop
d = dir('/Users/robot/OneDrive - University of Bristol/PhD/bulk simulations/density-range/swappings/*.mat');
Number_mat = length(d);
numCars = [];
for i = 1:Number_mat
    
    fnm = sprintf('test-%s',num2str(i));
    load(fullfile('/Users/robot/OneDrive - University of Bristol/PhD/bulk simulations/density-range/swappings',fnm))
    data(i).crossOrder = sim.crossOrder;
    numCars = [numCars, nCars];
    clear sim
end

save('/Users/robot/OneDrive - University of Bristol/PhD/bulk simulations/density-range/swappings/CrossOrders','data','numCars');

%%

load('/Users/robot/OneDrive - University of Bristol/PhD/bulk simulations/density-range/swappings/CrossOrders.mat');

%% junction crossing graph

idx = 10;

figure(6)
plot(data(idx).crossOrder,'-b','LineWidth',1.5)
axis([0 numel(data(idx).crossOrder) 0 3])
grid on
xlabel('Number of Junction Crosses','FontSize',16)
text(numel(data(idx).crossOrder)/2,-0.1,'\uparrow East Arm Crosses','FontSize',16)
text(numel(data(idx).crossOrder)/2,1.1,'\downarrow North Arm Crosses','FontSize',16)
ylim([-0.5,1.5])

%% conditional probabilities

m = length(data);

n = 200; % max bit size
p_E = zeros(m,n);
p_N = zeros(m,n);
bitSize = zeros(n,1);
for i = 1:m
    for j = 1:n
        bitSize(j) = j+1;
        
        counts = get_kernel_counts(bitSize(j),data(i).crossOrder);
        
        [p_E(i,j), p_N(i,j)] = calc_cond_probability(counts,j);
    end
end

%%

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


%% 

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

%%









%%

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
idx = 8;

selectedTestData = data(idx).crossOrder;
freq_counter = zeros(1,length(selectedTestData));
count = 1;
for i = 1:length(selectedTestData)-1
    if selectedTestData(i) == selectedTestData(i+1)
        count = count + 1;
    else
        freq_counter(count) = freq_counter(count) + 1;
        count = 1;        
    end
    if i+1 == length(selectedTestData)
        freq_counter(count) = freq_counter(count) + 1;
    end
end
[row,col] = find(freq_counter);
figure
bar(freq_counter)
xlim([0 max(col)])
grid on
xlabel('Size of the Platoon, veh','FontSize',14)
ylabel('Frequency','FontSize',14)



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
