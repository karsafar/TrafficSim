clc
clear

%%
% load data in the loop
Number_mat = [0.2 0.6 1 1.5 3.5];
for i = Number_mat
    fnm = sprintf('a-%s/seed-1-2/',num2str(i));
    load(fullfile([fnm,'aggregatedCrossingData.mat']))
    plot_junc_crosses(data,density,numCars,fnm)
end
%%


function plot_junc_crosses(data,density,numCars,fnm)

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
    orderedPlatoons(idx,1:length(temp)) = temp;
    [~,platoonSizes] = find(freq_counter);

    platoonNums = freq_counter((freq_counter) > eps);
    platoons(idx,1:numel(platoonSizes)) = (platoonNums.*platoonSizes);
end
  
f2 = figure('visible', 'off');
ax3 = axes;
xlim(ax3,[0.015 0.15])
ylim(ax3,[0 3000])
xticks(ax3,0.02:0.01:0.144)
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
% %     % for number of cars prescription
% %     h = line(ax3,[numCars(1,ii)*ones(1,numel(temp))./500; numCars(1,ii)*ones(1,numel(temp))./500],temp1,'LineWidth',8);
% %      plot(ax3,[numCars(1,ii)*ones(1,numel(temp)); numCars(1,ii)*ones(1,numel(temp))],temp1,'LineWidth',20)


    % for road length prescription
    h = plot(ax3,[density(1,ii)*ones(1,numel(temp)); density(1,ii)*ones(1,numel(temp))],temp1,'LineWidth',4);
    set(h,{'Color'},num2cell([colourArray(ii).density(:,1),colourArray(ii).density(:,2),colourArray(ii).density(:,3)],2));
    hold on
    if ii == 1
        h_tem = h;
    end
end

ylabel('Junction Capacity Q (veh/hour)','FontSize',14)
xlabel('Density \rho (veh/m)','FontSize',14)
lgd = legend([h_tem],{'North Arm Crossing','East Arm Crossing'},'location','northeast');

[k,q, ~] = fundamentaldiagram();
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
saveas(f2,fullfile([fnm,'b-random.eps']),'epsc');
close(f2)
end