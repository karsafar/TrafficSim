clc
clear
close all

%%
load('test-12.mat')


%% East Arm
ss = NaN(nCars(1),nIterations);
dv = NaN(nCars(1),nIterations);
v = NaN(nCars(1),nIterations);
for iCar = 1:nCars(1)
    for j = 1:nIterations
        ss(iCar,j) = sim.horizArm.allCars(iCar).Prev.History(2,j) - sim.horizArm.allCars(iCar).History(2,j);
        if ss(iCar,j) < 0
            ss(iCar,j) = road.Length(1) + ss(iCar,j);
        end
    end
    dv(iCar,:) = sim.horizArm.allCars(iCar).Prev.History(3,:) - sim.horizArm.allCars(iCar).History(3,:);
    v(iCar,:) = sim.horizArm.allCars(iCar).History(3,:);
end

% ss = gapSpaceEastV;
% vv = velocityEastV;
% dvv = relativeVelocityEastV;



gapSpaceEast = (diff(ss));
relativeVelocityEast = (diff(dv));
velocityEast = (diff(v));
%% North Arm
gapSpaceNorth = NaN(nCars(2),nIterations);
relativeVelocityNorth = NaN(nCars(2),nIterations);
velocityNorth = NaN(nCars(1),nIterations);
for iCar = 1:nCars(2)
    for j = 1:nIterations
        gapSpaceNorth(iCar,j) = sim.vertArm.allCars(iCar).Prev.History(2,j) - sim.vertArm.allCars(iCar).History(2,j);
        if gapSpaceNorth(iCar,j) < 0
            gapSpaceNorth(iCar,j) = road.Length(2) + gapSpaceNorth(iCar,j);
        end
    end
    relativeVelocityNorth(iCar,:) = sim.vertArm.allCars(iCar).Prev.History(3,:) - sim.vertArm.allCars(iCar).History(3,:);
    velocityNorth(iCar,:) = sim.vertArm.allCars(iCar).History(3,:);
end



%%
theta = linspace(0,pi,nIterations);
lambda2N = gapSpaceNorth./(velocityNorth.^3).*((velocityNorth.^2)/2-relativeVelocityNorth.*velocityNorth-gapSpaceNorth);
%%
lambda1E = gapSpaceEast./velocityEast;
theta = linspace(0,pi,nIterations);
lambda2E = gapSpaceEast./(velocityEast.^3).*((velocityEast.^2)/2-relativeVelocityEast.*velocityEast-gapSpaceEast);
% wavelengthE = (2*pi)./lambda2E;

lambda3E = (1./(6.*velocityEast)).*(6.*lambda2E.*(relativeVelocityEast+...
    2.*lambda1E)+3.*relativeVelocityEast.*lambda1E-gapSpaceEast);

lambda4E = (1./(24.*velocityEast)).*(24.*(lambda2E.^2)+...
    relativeVelocityEast.*lambda2E-24.*lambda3E.*(relativeVelocityEast+...
    lambda1E)-4.*lambda1E.*(6.*lambda3E-relativeVelocityEast+(velocityEast./4)));


% lambdaE_real = lambda2E(1,:).*(theta.^2) + lambda4E(1,:).*(theta.^4);
%%
n = nCars(2);
n = 1;
% for i = 1:nCars(1)
%     plot(lambda2E(:,i))
%     pause(0.5)
% end
plot(lambda2E(:,1000))
% ylim([-10 10])
hold on
% plot(1:nIterations,zeros(1,nIterations),'k--')
xlabel('number of iterations')
ylabel(' Lambda2')
%% Animation
figure(1)
h = animatedline;
axis([1 21 -3 1.5])
for i = 1:4:nIterations
    addpoints(h,gapSpaceEast(1,i),relativeVelocityEast(1,i));
    drawnow 
end
%%
plot(gapSpaceEast(1,1:end),relativeVelocityEast(1,1:end),'k-')
hold on
plot(1:21,zeros(1,21),'k--')
title('Phase Space')
xlabel('Headway, m')
ylabel(' Relative Velocity, m/s')

%%
plot(gapSpaceEast(1,:))
%%
figure(2)
plot(velocityEast(1,:))
%%
figure(3)
plot(relativeVelocityEast(1,1:end))

%% 
plot(velocityEast(1,:),relativeVelocityEast(1,:),'k-')
xlabel('Velocity, m/s')
ylabel('Relative Velocity, m/s')

%% 
plot(gapSpaceEast(1,1:15000),lambda2E(1,1:15000))
ylim([-4 2])
xlim([8 20])
xlabel('Headway, m')
ylabel('Growth Rate')
%% 
plot(theta,-lambdaE_real)
ylim([-10 10])
xlim([0 pi])
hold on
plot(theta(1,:),zeros(1,nIterations),'k--')