clc
clear
close all

%%
a = 1.5;
s0 = 2;
v0 = 13;
s1 = 0;
T = 1.6;
b = 1.5;
delta = 4;
l = 4.4;

% syms a s0 v0 T b delta s dv v l
syms f(s,dv,v) f_s f_dv f_v

f(s,dv,v) = a*(1 - (v/v0)^delta - ((s0  +...
    T*v-(v*dv)/(2*sqrt(a*b)))/(s-l))^2 );


f_s = diff(f,s);

f_dv = diff(f,dv);

f_v = diff(f,v);

% a = 1.2;
% s0 = 2;
% v0 = 13;
% s1 = 0;
% T = 1.6;
% b = 1.5;
% delta = 4;
% l = 4.4;

lambda_2 = (f_s/(f_v)^3)*((f_v^2)/2 - f_dv*f_v - f_s);


eqn = -((f_v^2)/2 - f_dv*f_v - f_s);



% theta = [eps:pi];

%
v = linspace(0,v0,10000);

s = gappoints(v,s0,s1,v0,T,delta);
k = densitypoints(v,s0,s1,v0,T,delta);

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
fs = double(f_s(ss(i,ind(i).Cars(n):ind(i).Cars(m)),dvv(i,ind(i).Cars(n):ind(i).Cars(m)),vv(i,ind(i).Cars(n):ind(i).Cars(m))));
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