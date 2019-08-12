clc
clear
close all

%%
%  load(['test-' num2str(7) '.mat']);

load('aggregatedCrossingData.mat');
%%

% counts
idx = 14;

bitSize = 6;
data_str = data(idx).crossOrder;
counts = get_kernel_counts(bitSize, data_str);
% mytable = table('Size', [2^bitSize, 2],'VariableTypes',{'string','double'});

Alphabet = {'EN'};
for i = 1:2^bitSize
    words(i,1) = {Alphabet{1}((dec2bin(i-1, bitSize) - '0')+1)};
    freqs(i,1) = (counts(i));
end
mytable = table(freqs,'VariableNames',{'Freq'},'RowNames',words);


no = length(data_str);

%

%{

figure;
% subplot(2,2,1)

% plot
bar((1:2^bitSize)-1, counts/no)
xticks((0:(2^bitSize)-1))
xticklabels(words)
xtickangle(45)
ylim([0,1])
title('1: Full range frequency')


%% Plot in chunks

%%%% potentially useless as it jumps 300 to draw next 300

% subplot(2,2,2)

ll = 300;

for k = 1:(floor(length(sim.crossOrder)/ll)) % cuts the whole data into dividable by ll length range
    data_strip = sim.crossOrder(((k-1)*ll+1):(k*ll));
    no = length(data_strip);
    counts = get_kernel_counts(bitSize, data_strip);
    
    % plot
    bar((1:2^bitSize)-1, counts/no);
    ylim([0,1])
    xticks((0:(2^bitSize)-1))
    xticklabels(words)
    xtickangle(45)
    
    drawnow;
    pause(0.5)
    
end
title('2: range of 300 frequency')

%% Plot whilst sliding down the list

% subplot(2,2,3)

ll = 300;
for k = 1:(length(sim.crossOrder)-ll)
    data_strip = sim.crossOrder(k : k+ll);
    no = length(data_strip);
    counts = get_kernel_counts(bitSize, data_strip);
    
    % plot
    bar((1:2^bitSize)-1, counts/no);
    ylim([0,1])
    xticks((0:(2^bitSize)-1))
    xticklabels(words)
    
    xtickangle(45)
    drawnow;
    
end
title('3: range of 300 frequency')


%}


% group the bits by their patters sums
mymat = dec2bin(2^bitSize-1:-1:0)-'0';
% diff_counts = sum(abs(diff(mymat,1, 2)),2);

diff_counts = NaN(length(mymat),1);
for i = 1:length(mymat)/2
    diff_counts(i) = i;
    diff_counts(end-i+1) = i;
end

% groupTable = table('Size', [length(mymat)/2, 1],'VariableTypes',{'string'});
for i = 1:length(mymat)/2
    %     groupTable{i,1} = {sprintf('Delta n - %i',max(diff_counts)+1-i)};
    wordsComb(i,1) = {sprintf('%s/%s', Alphabet{1}((dec2bin(i-1, bitSize) - '0')+1) , Alphabet{1}((dec2bin(2^bitSize-i, bitSize) - '0')+1))};
end
groupTable = table(NaN(numel(wordsComb),1),'VariableNames',{'Freq'},'RowNames',wordsComb);

%

% subplot(2,2,4);

% idx = 1;

ll = length(data(idx).crossOrder)-1;
% ll = 100;

sum_counts = NaN(1,max(diff_counts));
for k = 1:(length(data(idx).crossOrder)-ll)
    data_strip = data(idx).crossOrder(k:k+ll);
    no = length(data_strip);
    counts = get_kernel_counts(bitSize, data_strip);
    for i = 1:max(diff_counts)
        sum_counts(i) = sum(counts(diff_counts == (i)));
    end
    
    % plot
    bar((0:(2^bitSize-1)/2), sum_counts/no);
    ylim([0,1])
    xticks((0:length(mymat)/2))
    xticklabels(wordsComb)
    xtickangle(45)
    
    drawnow limitrate;
    %     pause(0.01)
    
end
title('4: grouped range of frequencies')




%% junction crossing graph
idx = 9;

figure(6)
plot(data(idx).crossOrder,'-b','LineWidth',1.5)
axis([0 numel(data(idx).crossOrder) 0 3])
grid on
xlabel('Number of Junction Crosses','FontSize',16)
text(numel(data(idx).crossOrder)/2,-0.1,'\uparrow East Arm Crosses','FontSize',16)
text(numel(data(idx).crossOrder)/2,1.1,'\downarrow North Arm Crosses','FontSize',16)
ylim([-0.5,1.5])


%{

%% conditional probabilities
idx = 9;


data_str = data(idx);

n = 20; % max bit size
bitSize = (1:n)+1; % range from 2 to 26

p_E.E          = NaN(n,1);p_N.E          = NaN(n,1);
p_E.EE         = NaN(n,1);p_N.EE         = NaN(n,1);
p_E.EEE        = NaN(n,1);p_N.EEE        = NaN(n,1);
p_E.EEEE       = NaN(n,1);p_N.EEEE       = NaN(n,1);
p_E.EEEEE      = NaN(n,1);p_N.EEEEE      = NaN(n,1);
p_E.EEEEEE     = NaN(n,1);p_N.EEEEEE     = NaN(n,1);
p_E.EEEEEEE    = NaN(n,1);p_N.EEEEEEE    = NaN(n,1);
p_E.EEEEEEEE   = NaN(n,1);p_N.EEEEEEEE   = NaN(n,1);
p_E.EEEEEEEEE  = NaN(n,1);p_N.EEEEEEEEE  = NaN(n,1);
p_E.EEEEEEEEEE = NaN(n,1);p_N.EEEEEEEEEE = NaN(n,1);


for i = 1:n    
    counts = get_kernel_counts(bitSize(i),data_str);
    
    [p_E.E(i), p_N.E(i)] = calc_cond_probability(counts,1);
    
    if i > 1
        [p_E.EE(i), p_N.EE(i)] = calc_cond_probability(counts,2);
    end
    if i > 2
        [p_E.EEE(i), p_N.EEE(i)] = calc_cond_probability(counts,3);
    end
    if i > 3
        [p_E.EEEE(i), p_N.EEEE(i)] = calc_cond_probability(counts,4);
    end
    if i > 4
        [p_E.EEEEE(i), p_N.EEEEE(i)] = calc_cond_probability(counts,5);
    end
    if i > 5
        [p_E.EEEEEE(i), p_N.EEEEEE(i)] = calc_cond_probability(counts,6);
    end
    if i > 6
        [p_E.EEEEEEE(i), p_N.EEEEEEE(i)] = calc_cond_probability(counts,7);
    end
    if i > 7
        [p_E.EEEEEEEE(i), p_N.EEEEEEEE(i)] = calc_cond_probability(counts,8);
    end
    if i > 8
        [p_E.EEEEEEEEE(i), p_N.EEEEEEEEE(i)] = calc_cond_probability(counts,9);
    end
    if i > 9
        [p_E.EEEEEEEEEE(i), p_N.EEEEEEEEEE(i)] = calc_cond_probability(counts,10);
    end
end

%%
figure; hold on;grid on
xlabel('Bit Size','FontSize',14)
ylabel('Probability of Next Bit E','FontSize',14)
plot(bitSize,  p_E.E ,'-x')
plot(bitSize,  p_E.EE ,'-o')
plot(bitSize,  p_E.EEE ,'-^')
plot(bitSize,  p_E.EEEE ,'->')
plot(bitSize,  p_E.EEEEE ,'-*')
plot(bitSize,  p_E.EEEEEE ,'-s')
plot(bitSize,  p_E.EEEEEEE ,'-v')
plot(bitSize,  p_E.EEEEEEEE ,'-<')
plot(bitSize,  p_E.EEEEEEEEE ,'-p')
plot(bitSize,  p_E.EEEEEEEEEE ,'-h')
ylim([0.65 1])
lgd = legend({'p(E|E)','p(E|EE)','p(E|EEE)','p(E|EEEE)','p(E|EEEEE)','p(E|EEEEEE)','p(E|EEEEEEE)','p(E|EEEEEEEE)','p(E|EEEEEEEEE)','p(E|EEEEEEEEEE)'},'location','northwestoutside');
lgd.FontSize = 14;


%%


% p(E/EN)
p_E_EN = zeros(n,1);
bitSize = zeros(n,1);
for i = 1:n
    bitSize(i) = i+2;
    counts = get_kernel_counts(bitSize(i), data_str);
    p_E_EN(i) = calc_cond_probability(bitSize(i),counts,11);
end



[p_E_EE,p_E_EN]

figure; hold on;
plot(bitSize, p_E_EE ,'r-o')
plot(bitSize, p_E_EN ,'b-o')
grid on

%}

%%

function [p_E, p_N] = calc_cond_probability(counts,x)

% mymat = dec2bin(2^bits-1:-1:0)-'0';
% mymat = (2^bits-1):-1:0;
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
% groupTable = table('Size', [length(mymat)/2, 1],'VariableTypes',{'string'});
% for i = 1:length(mymat)/2
%     groupTable{i,1} = {sprintf('%s/%s', Alphabet{1}((dec2bin(i-1, bits) - '0')+1) , Alphabet{1}((dec2bin(2^bits-i, bits) - '0')+1))};
% end


% sum_counts = NaN(1,max(diff_counts));
% for i = 1:max(diff_counts)
%     sum_counts(i) = sum(counts(diff_counts == (i)));
% 
% 
% end

%sum_counts = NaN(1,length(counts)/2);
bitNum = length(counts);
% firstPart = counts(1:bitNum/2);
% secondPart = counts(end:-1:bitNum/2+1);
half = bitNum/2;
sum_counts = counts(1:half) + counts(end:-1:half+1);

p_E = sum(sum_counts(1:bitNum/2^(x+1)))/sum(sum_counts(1:bitNum/2^x));

% opposite probability
p_N = sum(sum_counts((bitNum/2^(x+1)+1):2*bitNum/2^(x+1)))/sum(sum_counts(1:bitNum/2^x));

% if x == 11
%     p = sum(sum_counts((bitNum/4+1):end-bitNum/8))/sum(sum_counts((bitNum/4+1):end));
% end
end
%%
function counts = get_kernel_counts(bits, data)
counts = zeros((2^(bits)),1);
no = length(data);
for i=1:no-bits+1
    bin_i = data(i:i+bits-1);
    dec = 0;
    for j=1:bits
        dec = dec + 2^(j-1) * bin_i(end-j+1);
    end
    counts(dec+1) = counts(dec+1) + 1;
end
end