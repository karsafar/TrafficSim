function [Arm] = decide_input(manualFlag,carTypes,roadDims,subRoadArgs,dt)
for i = 1:2
    if manualFlag(i)
        sz = [2 4];
        varTypes = {'double','double','double','function_handle'};
        varNames = {'position','velocity','acceleration','carType'};

        T = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
        T.position = [20;-20];
        T.velocity = [5;7];
        T.acceleration = [1;1];
        T.carType = {carTypes{3};carTypes{3}};
        
        if i == 1
            Arm.H = SpawnCars(T,'horizontal',roadDims.Start(1),roadDims.End(1),roadDims.Width(1),dt);
        else
            Arm.V = SpawnCars(T,'vertical',roadDims.Start(2),roadDims.End(2),roadDims.Width(2),dt);
        end
    else
        if i == 1
            Arm.H = SpawnCars([subRoadArgs(1).Horizontal,{carTypes}],'horizontal',roadDims.Start(1),roadDims.End(1),roadDims.Width(1),dt);
        else
            Arm.V = SpawnCars([subRoadArgs(1).Vertical,{carTypes}],'vertical',roadDims.Start(2),roadDims.End(2),roadDims.Width(1),dt);
        end
    end
end
end

