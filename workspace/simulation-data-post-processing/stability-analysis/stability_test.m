clc
clear
close all

set(0,'defaultAxesTickLabelInterpreter','latex'); 
set(0,'defaultLegendInterpreter','latex');
set(0,'defaultLegendFontName','Times New Roman');
set(0,'defaultTextInterpreter','latex');
set(0,'defaultTextboxshapeInterpreter','latex');
set(0,'defaultAxesFontSize',22);
set(0,'defaultAxesFontName','Times New Roman');

%%

s0 = 2;
v0 = 13;
s1 = 0;
T = 1.6;
b = 1.5;
delta = 4;
l = 4.4;

%% plot stability curves for selected values of parameter "a"
% get numerical values of density range, velocity and gap
n = 100;
vel = linspace(0,v0,n);
s = gappoints(vel,s0,l,v0,T,delta);
k = densitypoints(vel,s0,l,v0,T,delta);
instabVec = [];

i = [0.5 0.75 1.0 1.5];
colArray = {'m','b','g','c'};
dotArray = {'-s','-^','-o','-*'};
idx = 0;
% plot(k,zeros(1,n),'k--' ,'LineWidth',2)
% hold on
% xlim([0.015 0.15])
% ylim([-1 3.5])
% xticks(0.02:0.01:0.144)
% colArray = {'g'};
% i = 0.75;
for a = i
%     % syms a s0 v0 T b delta s dv v l
    syms f(h,dv,v)
    
    f(h,dv,v) = a*(1 - (v/v0)^delta - ((s0+T*v-(v*dv)/(2*sqrt(a*b)))/(h-l))^2);
    
    
    f_h = diff(f,h);
    
    f_dv = diff(f,dv);
    
    f_v = diff(f,v);
    
    
    lambda_2 = (f_h/(f_v)^3)*((f_v^2)/2 - f_dv*f_v - f_h);
    
    %
    % lambdaSign = -((f_v^2)/2 - f_dv*f_v - f_h);
    
    % lambdaSign = 1/2 - f_dv/f_v - f_h/(f_v.^2);
    % lambdaSign = f_v^2 - 2*f_h - 2*f_dv*f_v;
    
    % f_h(h,0,v)
    % f_v(h,0,v)
    % f_dv(h,0,v)
    % lambda_2(h,0,v)
    % lambdaSign(s,0,v)
    

    
    %% calculate numerically eigenvalue lambda_2
    % algebraic equations of Taylor expansions f_h,f_v and f_dv as well as the
    % eigenvalue lambda_2 at equilibrium state
    
    dv = zeros(1,n);
    h = s+l;
    temp = double(lambda_2(h,dv,vel));
    % temp1 = double(lambdaSign(h,dv,v));
    idx = idx+1;
    %%
    plot(k,temp,dotArray{idx},'Color',colArray{idx}, 'LineWidth',1)
    hold on
    grid off
%     plot(k,temp1,'g', 'LineWidth',2)
    xlabel('Density $\rho\,\mathrm{(veh/m)}$')
    ylabel(' $\lambda_2$')
    xlim([0 max(k)])    
%% 

    P = InterX([k;temp],[k;zeros(1,n)]);
    idxZero = (P(1,:)+P(2,:) ~= 0);
    P(:,(idxZero == 0)) = []
%     
%     plot(P(1,1),P(2,1),'*','Color','k','LineWidth',2);

%     axis([0 max(k) min(temp) max(0.1,max(temp))]);
%     axis equal
    
    if isempty(P)
        instabVec = [instabVec;NaN];
    else
        instabVec = [instabVec; P(1,1)];
    end
end
plot(k,zeros(1,n),'--','Color',[0.5 0.5 0.5 ],'LineWidth',1)
% plot(P(1,1),P(2,1),'*','Color','r','LineWidth',4);
% lgd = legend({'$\lambda_2\,\mathrm{solutions}$','$\lambda_2 = 0$','Instability threshold~$\rho = 0.062\,\mathrm{veh/m}$'});
%
lgd = legend({strjoin({'$a = $',sprintf('%0.2f',i(1)),'$\mathrm{m/s^2}$'}),...
    strjoin({'$a = $',sprintf('%0.2f',i(2)),'$\mathrm{m/s^2}$'}),...
    strjoin({'$a = $',sprintf('%0.2f',i(3)),'$\mathrm{m/s^2}$'}),...
    strjoin({'$a = $',sprintf('%0.2f',i(4)),'$\mathrm{m/s^2}$'}),'$\lambda_2 = 0$'});


%% Plot the stability edge line
% get numerical values of density range, velocity and gap
n = 100;
vel = linspace(0,v0,n);
s = gappoints(vel,s0,l,v0,T,delta);
k = densitypoints(vel,s0,l,v0,T,delta);

instabVec = [];
i = 0:0.01:1.1;

% loop through every value of "a"
for a = i
    % syms a s0 v0 T b delta s dv v l
    syms f(h,dv,v)
    
    f(h,dv,v) = a*(1 - (v/v0)^delta - ((s0+T*v-(v*dv)/(2*sqrt(a*b)))/(h-l))^2);
    
    
    f_h = diff(f,h);
    
    f_dv = diff(f,dv);
    
    f_v = diff(f,v);
    
    
    lambda_2 = (f_h/(f_v)^3)*((f_v^2)/2 - f_dv*f_v - f_h);
    
    %
    % lambdaSign = -((f_v^2)/2 - f_dv*f_v - f_h);
    
    % lambdaSign = 1/2 - f_dv/f_v - f_h/(f_v.^2);
    % lambdaSign = f_v^2 - 2*f_h - 2*f_dv*f_v;
    
    % f_h(h,0,v)
    % f_v(h,0,v)
    % f_dv(h,0,v)
    % lambda_2(h,0,v)
    % lambdaSign(s,0,v)
    

    
    %% calculate numerically eigenvalue lambda_2
    % algebraic equations of Taylor expansions f_h,f_v and f_dv as well as the
    % eigenvalue lambda_2 at equilibrium state
    
    dv = zeros(1,n);
    h = s+l;
    temp = double(lambda_2(h,dv,vel));
    % temp1 = double(lambdaSign(h,dv,v));
%     idx = idx+1;
    %%
%     plot(k,temp,dotArray{idx},'Color',colArray{idx}, 'LineWidth',1)
%     hold on
%     grid off
%     plot(k,temp1,'g', 'LineWidth',2)
%     xlabel('Density $\rho \mathrm{(veh/m)}$')
%     ylabel('Solution $\lambda_2$')
%     xlim([0 max(k)])    
%% 

    P = InterX([k;temp],[k;zeros(1,n)]);
    idxZero = (P(1,:)+P(2,:) ~= 0);
    P(:,(idxZero == 0)) = []
    
%     plot(P(1,1),P(2,1),'*','Color','k','LineWidth',2);

%     axis([0 max(k) min(temp) max(0.1,max(temp))]);
%     axis equal
    
    if isempty(P)
        instabVec = [instabVec;NaN];
    else
        instabVec = [instabVec; P(1,1)];
    end
end


% dispname = [dispname {sprintf('$a_{\mathrm{IDM}} = 1 m/s^2$')}];
% lgd = legend(dispname);
% lgd = legend('$\lambda_2 = 0$','$a_{\mathrm{IDM}} = 1 m/s^2$');
%%
instabVec = instabVec(~isnan(instabVec));
plot(instabVec,i(1:numel(instabVec)),'b-','LineWidth',1)
ylabel('Acceleration parameter $a\,\mathrm{(m/s^2)}$')
xlabel('Density $\rho$ (veh/m)')
text(0.04,0.3,'Unstable region','FontSize',30,'Color','r')
text(0.02,1.1,'Stable region','FontSize',30,'Color','g')
legend('Stability threshold')
xlim([min(instabVec) max(instabVec)+0.001])
% xlim([min(instabVec) 0.16])
ylim([0 2])


% xticks(0.1:0.1:3.5)
% yticks(0.02:0.005:0.144)
return































%%
load('test-19.mat')


%% East Arm
ss = NaN(nCars(1),nIterations);
dvv = NaN(nCars(1),nIterations);
vv = NaN(nCars(1),nIterations);
for iCar = 1:nCars(1)
    for j = 1:nIterations
        ss(iCar,j) = sim.horizArm.allCars(iCar).Prev.History(1,j) - sim.horizArm.allCars(iCar).History(1,j);
        if ss(iCar,j) < 0
            ss(iCar,j) = road.Length(1) + ss(iCar,j);
        end
    end
    dvv(iCar,:) = sim.horizArm.allCars(iCar).Prev.History(2,:) - sim.horizArm.allCars(iCar).History(2,:);
    vv(iCar,:) = sim.horizArm.allCars(iCar).History(2,:);
end



%%
% temp = double(lambda_2(ss,dvv,vv));
ind = [];
for i = 1:nCars(1)
    ind(i).Cars = [sim.horizArm.allCars(i).downStreamEndTime];
end

%%
i = 1;
n = 1;
m = 5+1;
% for i = 1:numel(ind)
temp1 = double(lambda_2(ss(i,ind(i).Cars(n):ind(i).Cars(m)),dvv(i,ind(i).Cars(n):ind(i).Cars(m)),vv(i,ind(i).Cars(n):ind(i).Cars(m))));
%     plot(temp1+(28-i))
plot([ind(i).Cars(n):ind(i).Cars(m)],temp1)
hold on
%     xlim([ind(i).Cars(n) ind(i).Cars(m)])
%     pause(0.1)
% end
plot([1:ind(i).Cars(m)],zeros(1,ind(i).Cars(m)),'k--')
ylabel('Lambda_2','FontSize',14)
xlabel('Interation','FontSize',14)

%%
syms lambda_plat fs fv fdv

%%
eqn = lambda_plat^2 + (fdv-fv)*lambda_plat + fs == 0;

solx = solve(eqn, lambda_plat);

syms f(fs,fdv,fv)

ff(fs,fdv,fv) = solx(1);
ff1(fs,fdv,fv) = solx(2);
%%
i = 1;
n = 1;
m = 5+1;
fs = double(f_h(ss(i,ind(i).Cars(n):ind(i).Cars(m)),dvv(i,ind(i).Cars(n):ind(i).Cars(m)),vv(i,ind(i).Cars(n):ind(i).Cars(m))));
fv = double(f_v(ss(i,ind(i).Cars(n):ind(i).Cars(m)),dvv(i,ind(i).Cars(n):ind(i).Cars(m)),vv(i,ind(i).Cars(n):ind(i).Cars(m))));
fdv = double(f_dv(ss(i,ind(i).Cars(n):ind(i).Cars(m)),dvv(i,ind(i).Cars(n):ind(i).Cars(m)),vv(i,ind(i).Cars(n):ind(i).Cars(m))));

sols_1 = double(ff(fs,fdv,fv))';

sols_2 = double(ff1(fs,fdv,fv))';

figure(1)
plot(real(sols_1))
ylabel('Lambda-plat_1','FontSize',14)
xlabel('Interation','FontSize',14)
figure(2)
plot(real(sols_2))
ylabel('Lambda-plat_2','FontSize',14)
xlabel('Interation','FontSize',14)