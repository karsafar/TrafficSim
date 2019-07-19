clc
clear
close all

%%

s0 = 2;
v0 = 13;
s1 = 0;
T = 1.6;
b = 1.5;
delta = 4;
l = 4.4;

%% get numerical values of density range, velocity and gap
n = 100;
vel = linspace(0,v0,n);
s = gappoints(vel,s0,l,v0,T,delta);
k = densitypoints(vel,s0,l,v0,T,delta);

instabVec = [];
i = 0.1:0.025:1.1;
% i = [0.2 0.6 1 1.5 3.5 ];
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
%     plot(k,temp, 'LineWidth',2)
    hold on
    grid on
%     plot(k,temp1,'g', 'LineWidth',2)
%     plot(k,zeros(1,n),'k--')
%     xlabel('\rho, veh/m','FontSize',16)
%     ylabel('\lambda_2','FontSize',16)
%     
    
    P = InterX([k;temp],[k;zeros(1,n)]);
    idxZero = (P(1,:)+P(2,:) ~= 0);
    P(:,(idxZero == 0)) = []
    
    % plot(P(1,:),P(2,:),'b*');
    % axis([0 max(k) min(temp) max(0.1,max(temp))]);
    % axis equal
    
    if isempty(P)
        instabVec = [instabVec;NaN];
    else
        instabVec = [instabVec; P(1,1)];
    end
end
dispname = []
% for a = i
%     dispname = [dispname {sprintf('a_{IDM} = %s m/s^2',num2str(a))}];
% end
% lgd = legend(dispname,'0');
% lgd.FontSize = 14
plot(i,instabVec, 'LineWidth',2)
xlabel('a, m/s^2','FontSize',16)
ylabel('\rho, veh/m','FontSize',16)

axis auto
xlim([0.1 3.5])
xticks(0.1:0.1:3.5)
ylim([0.02 0.144])
yticks(0.02:0.005:0.144)
return































%%
load('test-19.mat')


%% East Arm
ss = NaN(nCars(1),nIterations);
dvv = NaN(nCars(1),nIterations);
vv = NaN(nCars(1),nIterations);
for iCar = 1:nCars(1)
    for j = 1:nIterations
        ss(iCar,j) = sim.horizArm.allCars(iCar).Prev.History(2,j) - sim.horizArm.allCars(iCar).History(2,j);
        if ss(iCar,j) < 0
            ss(iCar,j) = road.Length(1) + ss(iCar,j);
        end
    end
    dvv(iCar,:) = sim.horizArm.allCars(iCar).Prev.History(3,:) - sim.horizArm.allCars(iCar).History(3,:);
    vv(iCar,:) = sim.horizArm.allCars(iCar).History(3,:);
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