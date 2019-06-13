function  [sim] = run_simulation(...
                        roadTypes,...
                        carTypes,...
                        ArmH,...
                        ArmV,...
                        t_rng,...
                        plotFlag,...
                        priority,...
                        roadDims,...
                        nIterations,...
                        transientCutOffLength,...
                        swapRate,...
                        dt)

% construct two arms of the junction objects
HorizontalArm = roadTypes{1}([{carTypes},0,roadDims,priority],ArmH);
VerticalArm = roadTypes{2}([{carTypes},90,roadDims,priority],ArmV);

% plot the junction
junc = Junction(roadDims, plotFlag);

% define the length of storage data for all cars
for iCar = 1:HorizontalArm.numCars
    HorizontalArm.allCars(iCar).History = single(NaN(4,nIterations));
end
for jCar = 1:VerticalArm.numCars
    VerticalArm.allCars(jCar).History = single(NaN(4,nIterations));
end

% define transient length
HorizontalArm.transientCutOffLength = transientCutOffLength;
VerticalArm.transientCutOffLength = transientCutOffLength;

% define swap rate
if isa(HorizontalArm,'LoopRoad')
    HorizontalArm.swapRate = swapRate;
end
if isa(VerticalArm,'LoopRoad')
    VerticalArm.swapRate = swapRate;
end

for iIteration = 1:nIterations
    % update time
    t = t_rng(iIteration);
    
    % define the length of storage data for all cars
    for iCar = 1:HorizontalArm.numCars
        HorizontalArm.allCarsStates(1,iCar) = HorizontalArm.allCars(iCar).pose(1);
        HorizontalArm.allCarsStates(2,iCar) = HorizontalArm.allCars(iCar).velocity;
        HorizontalArm.allCarsStates(3,iCar) = HorizontalArm.allCars(iCar).acceleration;
        HorizontalArm.allCars(iCar).store_state_data(t,HorizontalArm.allCarsStates(:,iCar));
    end
    for jCar = 1:VerticalArm.numCars
        VerticalArm.allCarsStates(1,jCar) = VerticalArm.allCars(jCar).pose(1);
        VerticalArm.allCarsStates(2,jCar) = VerticalArm.allCars(jCar).velocity;
        VerticalArm.allCarsStates(3,jCar) = VerticalArm.allCars(jCar).acceleration;
        VerticalArm.allCars(jCar).store_state_data(t,VerticalArm.allCarsStates(:,jCar));
    end
    % draw cars
    if plotFlag
        junc.draw_all_cars(HorizontalArm,VerticalArm,iIteration,transientCutOffLength)
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
    
    % save whole simulation data if collision
%     if junc.collisionFlag
%         save(['coll_iter-' num2str(iIteration) '.mat']);
%         fprintf('Collision occured at time t = %f. collided cars = [%d %d] %i',t,junc.collidingCarsIdx(1),junc.collidingCarsIdx(2));
%     end
    
    % calculate IDM acceleration
    for iCar = 1:HorizontalArm.numCars
        calculate_idm_accel(HorizontalArm.allCars(iCar),roadDims.Length(1));
    end
    for jCar = 1:VerticalArm.numCars
        calculate_idm_accel(VerticalArm.allCars(jCar),roadDims.Length(2));
    end
    
    % Itersection Collision Avoidance (ICA)
    for iCar = 1:HorizontalArm.numCars
        if t > transientCutOffLength*0.8
            HorizontalArm.allCars(iCar).decide_acceleration(VerticalArm,roadDims.Length(1),t,dt);
        else
            HorizontalArm.allCars(iCar).acceleration = HorizontalArm.allCars(iCar).idmAcceleration;
            check_for_negative_velocity( HorizontalArm.allCars(iCar),dt);
        end        
    end
    for jCar = 1:VerticalArm.numCars
        if t > transientCutOffLength*0.8
            VerticalArm.allCars(jCar).decide_acceleration(HorizontalArm,roadDims.Length(2),t,dt);
        else
            VerticalArm.allCars(jCar).acceleration = VerticalArm.allCars(jCar).idmAcceleration;
            check_for_negative_velocity( VerticalArm.allCars(jCar),dt);
        end
    end
    
    % Move all the cars along the road
%     count_emegrency_breaks(HorizontalArm);
%     count_emegrency_breaks(VerticalArm);
    
    % Move all the cars along the road
    HorizontalArm.move_all_cars(t,dt,iIteration,nIterations)
    VerticalArm.move_all_cars(t,dt,iIteration,nIterations)
end
sim.horizArm = HorizontalArm;
sim.vertArm = VerticalArm;
sim.crossOrder = junc.crossOrder;
sim.crossCount = junc.crossCount;
sim.crossCarTypeCount = junc.crossCarTypeCount;
sim.crossCarTypeOrder = junc.crossCarTypeOrder;
end


