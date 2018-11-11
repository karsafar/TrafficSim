function  [sim] = run_simulation(...
                        roadTypes,...
                        carTypes,...
                        Arm,...
                        t_rng,...
                        plotFlag,...
                        priority,...
                        roadDims,...
                        nIterations,...
                        dt)

% construct two arms of the junction objects
HorizontalArm = roadTypes{1}([{carTypes},0,roadDims,priority],Arm.H);
VerticalArm = roadTypes{2}([{carTypes},90,roadDims,priority],Arm.V);

% plot the junction
junc = Junction(roadDims, plotFlag);

for iIteration = 1:nIterations
    % update time
    t = t_rng(iIteration);
    
    % draw cars
    if plotFlag
        junc.draw_all_cars(HorizontalArm,VerticalArm)
        if getappdata(0,'drawRAte')
            drawnow limitrate
        else
            drawnow
        end
    end

    % check for collision
    junc.collision_check(...
        HorizontalArm.allCars,...
        VerticalArm.allCars,...
        HorizontalArm.numCars,...
        VerticalArm.numCars,...
        plotFlag,t);
    
    % calculate IDM acceleration
    for iCar = 1:HorizontalArm.numCars
        calculate_idm_accel(HorizontalArm.allCars(iCar),roadDims.Length(1));
    end
    for jCar = 1:VerticalArm.numCars
        calculate_idm_accel(VerticalArm.allCars(jCar),roadDims.Length(2));
    end
    
    % Itersection Collision Avoidance (ICA)
    for iCar = 1:HorizontalArm.numCars
        HorizontalArm.allCars(iCar).decide_acceleration(VerticalArm,roadDims.Length(1),t,dt);
    end
    for jCar = 1:VerticalArm.numCars
        VerticalArm.allCars(jCar).decide_acceleration(HorizontalArm,roadDims.Length(2),t,dt);
    end
    
    % Move all the cars along the road
    count_emegrency_breaks(HorizontalArm);
    count_emegrency_breaks(VerticalArm);
    
    % Move all the cars along the road
    HorizontalArm.move_all_cars(t,dt,iIteration,nIterations)
    VerticalArm.move_all_cars(t,dt,iIteration,nIterations)
    
    if plotFlag == 0 && mod(iIteration,36) == 0
        % Update waitbar and message
        f = findall(0,'type','figure','tag','TMWWaitbar');
        if getappdata(0,'simType') == 0
            waitbar(iIteration/nIterations,f,sprintf('%d percent out of %d iterations',round(iIteration*100/nIterations),nIterations))
        end
        if getappdata(f,'canceling')
            sim.horizArm = cast_output(HorizontalArm);
            sim.vertArm = cast_output(VerticalArm);
            return
        end
    end
end
sim.horizArm = cast_output(HorizontalArm);
sim.vertArm = cast_output(VerticalArm);
end

function tempArm = cast_output(arm)
tempArm.nCarHistory = arm.nCarHistory;
tempArm.numEmergBreaks = arm.numEmergBreaks;
if strcmpi(class(arm),'FiniteRoad')
    tempArm.prescription = 1;
    tempArm.numCarsHistory = arm.numCarsHistory(~isnan(arm.numCarsHistory));
else
    tempArm.Density = arm.numCars/arm.Length;
end
for iCar = 1:tempArm.nCarHistory
    temp1 = arm.carHistory{1,iCar}(1,:);
    temp2 = arm.carHistory{1,iCar}(2,:);
    temp3 = arm.carHistory{1,iCar}(3,:);
    temp4 = arm.carHistory{1,iCar}(4,:);
    tempArm.car(iCar).times = temp1(~isnan(temp1));
    tempArm.car(iCar).positions = temp2(~isnan(temp2));
    tempArm.car(iCar).velocities = temp3(~isnan(temp3));
    tempArm.car(iCar).accelerations = temp4(~isnan(temp4));
end
tempArm.averageVelocityHistory = arm.averageVelocityHistory(~isnan(arm.averageVelocityHistory));
end


