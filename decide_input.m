function [Arm] = decide_input(manualFlag,carTypes,roadDims,subRoadArgs,dt)

for i = 1:2
    if manualFlag(i)
        if i == 1
            msg = ('Horizontal arm input');
        else
            msg = ('Vertical arm input');
        end
        title = msg;
        prompt = {'Number of vehicles','Positions','Velocites','Accelerations',' Control types'};
        dims = [1 50; 1 50; 1 50; 1 50; 1 50];
        definput = {'2', '20 -20', '5 7', '1 1','3 3'};
        answer = inputdlg(prompt,title,dims,definput);
        
        sz = [str2num(answer{1}) 4];
        varTypes = {'double','double','double','function_handle'};
        varNames = {'position','velocity','acceleration','carType'};
        
        T = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
        T.position = [str2num(answer{2})'];
        T.velocity = [str2num(answer{3})'];
        T.acceleration = [str2num(answer{4})'];
        T.carType = {carTypes{str2num(answer{5})'}}';
        
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

