t = 0:0.01:10;

%% PDF
y1 = exppdf(t,1);

y_rng = [];
i = 1;
while y1(i) >= y1((t==1))
    y_rng = [y_rng y1(i)];
    i = i+1;
end


figure
h1 = fill([0 t(1:(i-1)) 1],[0 y_rng 0],[0.9 0.9 0.9],'EdgeColor','none','DisplayName','none');
set(get(get(h1,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
hold on
plot(t,y1,'LineWidth',2)
xlabel('Arrival Time t (s)','FontSize',22)
ylabel('Probability Density p(t)','FontSize',22)
% hold on

y = exppdf(t,2);
plot(t,y,'LineWidth',2)

y = exppdf(t,4);
plot(t,y,'LineWidth',2)

lgd = legend('Mean arrival time \mu = 1 s','Mean arrival time \mu = 2 s','Mean arrival time \mu = 4 s');
lgd.FontSize = 22;

%% CDF
pd_1 = makedist('Exponential','mu',1);
pd_2 = makedist('Exponential','mu',2);
pd_3 = makedist('Exponential','mu',4);
y_1 = cdf(pd_1,t,1,1);
figure

plot(t,y_1,'LineWidth',2)
xlabel('Arrival Time t (s)','FontSize',22)
ylabel('Cumulative Frequency P(T \leq t)','FontSize',22)
hold on

y_2 = cdf(pd_2,t,2,1);
plot(t,y_2,'LineWidth',2)

y_3 = cdf(pd_3,t,4,1);
plot(t,y_3,'LineWidth',2)

lgd = legend('Mean arrival time \mu = 1 s','Mean arrival time \mu = 2 s','Mean arrival time \mu = 4 s','Location','southeast');
lgd.FontSize = 22;

h2=plot([0 1],[y_1(t==1) y_1(t==1)],'k--',1,y_1(t==1),'k*');
h3=plot([0 1],[y_2(t==1) y_2(t==1)],'k--',1,y_2(t==1),'k*');
h4=plot([0 1],[y_3(t==1) y_3(t==1)],'k--',1,y_3(t==1),'k*');
h5=plot([1 1],[0 y_1(t==1)],'k--');
set(get(get(h2(1),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
set(get(get(h2(2),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
set(get(get(h3(1),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
set(get(get(h3(2),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
set(get(get(h4(1),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
set(get(get(h4(2),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
set(get(get(h5,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
