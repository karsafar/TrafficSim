function  [sim] = driverscript_flow(...
    carTypeRatios,...
    runTime,...
    plotFlag,...
    priority,...
    roadDimensions,...
    distributionMean,...
    timeStep)

dt = timeStep;
nIterations = runTime/timeStep;
nDigits = numel(num2str(dt))-2;
t_rng = round(linspace(0,runTime,nIterations),nDigits);
t = t_rng(1);

% road start and end
startPoint = roadDimensions(1);
endPoint = roadDimensions(2);
roadLength = endPoint - startPoint;
roadWidth = roadDimensions(3);

% construct two arms of the junction objects
horizontalArm = FiniteRoad([startPoint,endPoint,roadWidth,0,priority,carTypeRatios(1)],distributionMean(1),nIterations);
verticalArm = FiniteRoad([startPoint,endPoint,roadWidth,90,priority,carTypeRatios(2)],distributionMean(2),nIterations);

% create a junction object
junc = Junction(startPoint,endPoint,roadWidth, plotFlag);

for iIteration = 1:nIterations
    
    % spawn cars if appropriate
    horizontalArm.spawn_car(t)
    verticalArm.spawn_car(t)
    
    % draw cars
    if plotFlag
        junc.draw_all_cars(horizontalArm,verticalArm)
    end
    
    % acceleration options
    allCarsHoriz = horizontalArm.allCars;
    allCarsVert = verticalArm.allCars;
    
    % calculate IDM acceleration
    for iCar = 1:horizontalArm.numCars
        calculate_idm_accel(allCarsHoriz(iCar),roadLength);
    end
    for jCar = 1:verticalArm.numCars
        calculate_idm_accel(allCarsVert(jCar),roadLength);
    end
    
    % Itersection Collision Avoidance (ICA)
    for iCar = 1:horizontalArm.numCars
        allCarsHoriz(iCar).decide_acceleration(verticalArm,t,dt);
    end
    for jCar = 1:verticalArm.numCars
        allCarsVert(jCar).decide_acceleration(horizontalArm,t,dt);
    end
    
    % move all cars
    horizontalArm.move_all_cars(t,dt,iIteration,nIterations)
    verticalArm.move_all_cars(t,dt,iIteration,nIterations)
    
    % check for collision
%     junc.collision_check(...
%         allCarsHoriz,...
%         allCarsVert,...
%         horizontalArm.numCars,...
%         verticalArm.numCars,...
%         plotFlag);

    horizontalArm.store_num_cars(iIteration)
    verticalArm.store_num_cars(iIteration)
    
    % delete images of cars from junction
    if plotFlag
        pause(1/1200)
        junc.delete_car_images();
    end
    
    % update time
    t = t_rng(iIteration);
end
sim.horizArm.numCars =  horizontalArm.numCars;
sim.horizArm.nCarHistory = horizontalArm.nCarHistory;
for iCar = 1:sim.horizArm.nCarHistory
    sim.horizArm.car(iCar).times = horizontalArm.carHistory{1,iCar}(1,:);
    sim.horizArm.car(iCar).positions = horizontalArm.carHistory{1,iCar}(2,:);
    sim.horizArm.car(iCar).velocities = horizontalArm.carHistory{1,iCar}(3,:);
    sim.horizArm.car(iCar).accelerations = horizontalArm.carHistory{1,iCar}(4,:);
end
sim.horizArm.averageVelocityHistory = horizontalArm.averageVelocityHistory;

sim.vertArm.numCars =  verticalArm.numCars;
sim.vertArm.nCarHistory = verticalArm.nCarHistory;
for iCar = 1:sim.vertArm.nCarHistory
    sim.vertArm.car(iCar).times = verticalArm.carHistory{1,iCar}(1,:);
    sim.vertArm.car(iCar).positions = verticalArm.carHistory{1,iCar}(2,:);
    sim.vertArm.car(iCar).velocities = verticalArm.carHistory{1,iCar}(3,:);
    sim.vertArm.car(iCar).accelerations = verticalArm.carHistory{1,iCar}(4,:);
end
sim.vertArm.averageVelocityHistory = verticalArm.averageVelocityHistory;
end
