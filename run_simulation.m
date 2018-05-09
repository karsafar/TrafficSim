function  [sim] = run_simulation(...
    roadTypes,...
    carTypes,...
    subRoadArgs,...
    t_rng,...
    plotFlag,...
    priority,...
    roadDims,...
    nIterations,...
    dt)

% construct two arms of the junction objects
HorizontalArm = roadTypes{1}([{carTypes},0,roadDims,priority],subRoadArgs.Horizontal);
VerticalArm = roadTypes{2}([{carTypes},90,roadDims,priority],subRoadArgs.Vertical);

% plot the junction
junc = Junction(roadDims, plotFlag);

for iIteration = 1:nIterations
    % update time
    t = t_rng(iIteration);
    
    HorizontalArm.move_all_cars(t,dt,iIteration,nIterations)
    VerticalArm.move_all_cars(t,dt,iIteration,nIterations)
   
    % draw cars
    if plotFlag
        junc.draw_all_cars(HorizontalArm,VerticalArm)
    end
    
%     % check for collision
%     junc.collision_check(...
%         allCarsHoriz,...
%         allCarsVert,...
%         horizontalArm.numCars,...
%         verticalArm.numCars,...
%         plotFlag);
    
    % calculate IDM acceleration
    for iCar = 1:HorizontalArm.numCars
        calculate_idm_accel(HorizontalArm.allCars(iCar),roadDims.Length(1));
    end
    for jCar = 1:VerticalArm.numCars
        calculate_idm_accel(VerticalArm.allCars(jCar),roadDims.Length(2));
    end
    
    % Itersection Collision Avoidance (ICA)
    for iCar = 1:HorizontalArm.numCars
        HorizontalArm.allCars(iCar).decide_acceleration(VerticalArm,t,dt);
    end
    for jCar = 1:VerticalArm.numCars
        VerticalArm.allCars(jCar).decide_acceleration(HorizontalArm,t,dt);
    end

    if plotFlag
        pause(0.01)
        junc.delete_car_images();
    end
end
sim.horizArm.numCars = HorizontalArm.numCars;
sim.horizArm.nCarHistory = HorizontalArm.nCarHistory;
sim.horizArm.numCarsHistory = HorizontalArm.numCarsHistory;
for iCar = 1:sim.horizArm.nCarHistory
    temp1 = HorizontalArm.carHistory{1,iCar}(1,:);
    temp2 = HorizontalArm.carHistory{1,iCar}(2,:);
    temp3 = HorizontalArm.carHistory{1,iCar}(3,:);
    temp4 = HorizontalArm.carHistory{1,iCar}(4,:);
    sim.horizArm.car(iCar).times = temp1(~isnan(temp1));
    sim.horizArm.car(iCar).positions = temp2(~isnan(temp2));
    sim.horizArm.car(iCar).velocities = temp3(~isnan(temp3));
    sim.horizArm.car(iCar).accelerations = temp4(~isnan(temp4));    
end
sim.horizArm.averageVelocityHistory = HorizontalArm.averageVelocityHistory;

% sim.vertArm.numCars =  VerticalArm.numCars;
% sim.vertArm.nCarHistory = VerticalArm.nCarHistory;
% sim.vertArm.numCarsHistory = VerticalArm.numCarsHistory;
% for iCar = 1:sim.vertArm.nCarHistory
%     sim.vertArm.car(iCar).times = VerticalArm.carHistory{1,iCar}(1,:);
%     sim.vertArm.car(iCar).positions = VerticalArm.carHistory{1,iCar}(2,:);
%     sim.vertArm.car(iCar).velocities = VerticalArm.carHistory{1,iCar}(3,:);
%     sim.vertArm.car(iCar).accelerations = VerticalArm.carHistory{1,iCar}(4,:);
% end
% sim.vertArm.averageVelocityHistory = VerticalArm.averageVelocityHistory;
end