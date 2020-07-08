% daily progress (24/10/19-30/04/2020) excluding sundays and Christmas
% holidays
% make x value as a time stamp
daily_progress = [7163,7507,7674,7893,8226,8226,8333,8316,8619,8755,8840,9522,9600 9900 10206 10206 10306 10500];
trend = linspace(7163,60000,190);

startDate = datenum('10-24-2019');
endDate = datenum('04-30-2020');
xData = linspace(startDate,endDate,190);


ax = gca;

% desired curve
plot(ax,xData,trend,'r-')
hold on

% convert x axis into dd/mm format
datetick('x',19,'keeplimits')

% current progress
plot(ax,xData(1:numel(daily_progress)),daily_progress, 'bo-','LineWidth',2)

% prediction
c = polyfit(xData(1:numel(daily_progress)),daily_progress,1);
y_est = polyval(c,xData);
plot(ax,xData,y_est, 'g.-','LineWidth',2)


legend(ax,{'desired progress','current progress','prediction'})
xlabel(ax,'Day and Month')
ylabel(ax, 'Thesis Word Count')
