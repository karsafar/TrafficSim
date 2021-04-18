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

clear ArmH ArmV
% plot the junction
junc = Junction(roadDims, plotFlag,nIterations);

% define the length of storage data for all cars
for iCar = 1:HorizontalArm.numCars
    HorizontalArm.allCars(iCar).History = NaN(3,nIterations,'single');
    HorizontalArm.allCars(iCar).bbStore = zeros(numel(HorizontalArm.allCars(iCar).actStore),nIterations,'int8');
end
for jCar = 1:VerticalArm.numCars
    VerticalArm.allCars(jCar).History = NaN(3,nIterations,'single');
    VerticalArm.allCars(jCar).bbStore = zeros(numel(VerticalArm.allCars(jCar).actStore),nIterations,'int8');
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
% create our clean up object
cleanupObj = onCleanup(@cleanMeUp);

if plotFlag
    drawRate = getappdata(0,'drawRAte');
end
t_off = getappdata(0,'t_off');

% minimum gap acceptance
minTimeGap = getappdata(0,'time_gap_dist'); 

% maximum deceleration
a_feas_min = getappdata(0,'MinFeasibleDecel');

% maximum crossing acceleration
a_ahead = getappdata(0,'MaxCrossAccel');

% set min gap and max decel
for iCar = 1:HorizontalArm.numCars
    HorizontalArm.allCars(iCar).minTimeGap = minTimeGap(iCar);
    HorizontalArm.allCars(iCar).a_feas_min = a_feas_min(iCar);
    HorizontalArm.allCars(iCar).a_ahead = a_ahead(iCar);
end
for jCar = 1:VerticalArm.numCars
    VerticalArm.allCars(jCar).minTimeGap = minTimeGap(iCar+jCar);
    VerticalArm.allCars(jCar).a_feas_min = a_feas_min(iCar+jCar);
    VerticalArm.allCars(jCar).a_ahead = a_ahead(iCar+jCar);
end

for iIteration = 1:nIterations
    % update time
    t = t_rng(iIteration);
    
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
    if plotFlag && t >= transientCutOffLength && t >= t_off
        junc.draw_all_cars(HorizontalArm,VerticalArm,iIteration,transientCutOffLength)
        if drawRate
            drawnow limitrate
        else
            drawnow
        end
    end
    
    % check for collision
    if t >= transientCutOffLength
        junc.collision_check(...
            HorizontalArm.allCars,...
            VerticalArm.allCars,...
            HorizontalArm.numCars,...
            VerticalArm.numCars,...
            plotFlag,t,iIteration);
    end
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
        if t >= transientCutOffLength
            HorizontalArm.allCars(iCar).decide_acceleration(VerticalArm,roadDims.Length(1),t,dt,iIteration);
        else
            HorizontalArm.allCars(iCar).acceleration = HorizontalArm.allCars(iCar).idmAcceleration;
            check_for_negative_velocity(HorizontalArm.allCars(iCar),dt);
        end
    end
    for jCar = 1:VerticalArm.numCars
        if t >= transientCutOffLength
            VerticalArm.allCars(jCar).decide_acceleration(HorizontalArm,roadDims.Length(2),t,dt,iIteration);
        else
            VerticalArm.allCars(jCar).acceleration = VerticalArm.allCars(jCar).idmAcceleration;
            check_for_negative_velocity( VerticalArm.allCars(jCar),dt);
        end
    end

    % Move all the cars along the road
    count_emegrency_breaks(HorizontalArm);
    count_emegrency_breaks(VerticalArm);
    
    % Move all the cars along the road
    HorizontalArm.move_all_cars(t,dt,iIteration,nIterations,VerticalArm,roadDims.Length(1))
    VerticalArm.move_all_cars(t,dt,iIteration,nIterations,HorizontalArm,roadDims.Length(2))
    
    
    if plotFlag == 0 && mod(iIteration,36) == 0 || t < t_off
        % Update waitbar and message
        f = findall(0,'type','figure','tag','TMWWaitbar');
        if getappdata(0,'simType') == 0
            waitbar(iIteration/nIterations,f,sprintf('%d percent out of %d iterations',round(iIteration*100/nIterations),nIterations))
        end
        if getappdata(f,'canceling')
            sim.horizArm = HorizontalArm;
            sim.vertArm = VerticalArm;
            sim.crossOrder = junc.crossOrder;
            return
        end
    end
end
%% store data before exiting run loop
sim.horizArm = HorizontalArm;
sim.vertArm = VerticalArm;
sim.crossOrder = junc.crossOrder;
sim.crossCount = junc.crossCount;
sim.crossCarTypeCount = junc.crossCarTypeCount;
sim.crossCarTypeOrder = junc.crossCarTypeOrder;
end

% fires when main function terminates
function cleanMeUp()
% close waitbar
f = findall(0,'type','figure','tag','TMWWaitbar');
delete(f)
end



