function time_velocity_plot(iCar,iSim,sim,Arm)
if strcmpi(Arm,'horizontal')
    times = sim(iSim).horizArm.car(iCar).times;
    velocities = sim(iSim).horizArm.car(iCar).velocities;
else
    times = sim(iSim).vertArm.car(iCar).times;
    velocities = sim(iSim).vertArm.car(iCar).velocities;
end
ha1 = axes;
title(ha1,'Velocity profile','FontSize',20)
ylabel(ha1,' Velocity V, m/s','FontSize',18)
xlabel(ha1,' Time, s','FontSize',18)
hold on
grid on
plot(ha1,times,velocities,'b-','LineWidth',1)
axis(ha1,[min(times) max(times) 0 10])
end