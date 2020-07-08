close all

%% East Arm
split_trajectories.East = split_trajectory_profiles(sim.horizArm,nIterations);

%% North Arm
split_trajectories.North = split_trajectory_profiles(sim.vertArm,nIterations);


%% plot trajectories
figure
clf;
ax1 = subplot(3,1,1);
ax2 = subplot(3,1,2);
ax3 = subplot(3,1,3);

xlabel(ax1,'Time (s)')
ylabel(ax1,'Displacement (m)')
hold(ax1,'on')

xlabel(ax2,'Time (s)')
ylabel(ax2,'Velocity (s)')
hold(ax2,'on')

xlabel(ax3,'Time (s)')
ylabel(ax3,'Acceleration (s)')
hold(ax3,'on')

ylim(ax1,[sim.horizArm.startPoint sim.horizArm.endPoint])
ylim(ax2,[0 sim.horizArm.allCars(1).maximumVelocity])
ylim(ax3,[sim.horizArm.allCars(1).a_min sim.horizArm.allCars(1).a_max])

% plot(ax3,3.5*ones(nIterations,1),'k--')
% plot(ax3,-3.5*ones(nIterations,1),'k--')

for i = 1:min(numel(split_trajectories.East),numel(split_trajectories.North))
    cla(ax1)
    cla(ax2)
    cla(ax3)
    
    plot(ax1,split_trajectories.East(i,:).time, split_trajectories.East(i,:).displacement,'b',...
     split_trajectories.North(i,:).time, split_trajectories.North(i,:).displacement,'r')
    legend(ax1,'East Arm','North Arm')
    
    plot(ax2,split_trajectories.East(i,:).time, split_trajectories.East(i,:).velocity,'b',...
        split_trajectories.North(i,:).time, split_trajectories.North(i,:).velocity,'r')
    legend(ax2,'East Arm','North  Arm')
    
    plot(ax3,split_trajectories.East(i,:).time, split_trajectories.East(i,:).acceleration,'b',...
        split_trajectories.North(i,:).time, split_trajectories.North(i,:).acceleration,'r')
    legend(ax3,'East Arm','North Arm')
    pause()
end

function in_out = split_trajectory_profiles(arm,nIterations)
k = 1;
in_out = [];
for iCar = 1:arm.numCars
    
    t_Car  = arm.allCars(iCar).History(1,:);
    d_Car  = arm.allCars(iCar).History(2,:);
    v_Car   = arm.allCars(iCar).History(3,:);
    a_Car = arm.allCars(iCar).History(4,:);
    
    idx = find(d_Car>=arm.endPoint);
    idx = [0,idx,nIterations];
    
    for i = 1:numel(idx)-1
        in_out(k,:).time         =  t_Car(idx(i)+1:idx(i+1));
        in_out(k,:).displacement =  d_Car(idx(i)+1:idx(i+1));
        in_out(k,:).velocity     =  v_Car(idx(i)+1:idx(i+1));
        in_out(k,:).acceleration =  a_Car(idx(i)+1:idx(i+1));
        
        k = k+1;
    end
end
end
