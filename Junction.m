classdef Junction < handle
    properties (SetAccess = public)
%         allCarsImageHandle = []
        junctionPlotHandle = []
%         horizCarsImageHandle = []
%         vertCarsImageHandle = []
        collidingCarsIdx = NaN(1,2)
        collisionFlag = 0
        crossOrder = []
    end
    
    methods
        function obj = Junction(roadDimensions,plotFlag)
            if plotFlag
                obj.plot_outline(roadDimensions);
            end
        end
        function plot_outline(obj,roadDimensions)
            allAxesInFigure = findall(0,'type','axes');
            if ~isempty(allAxesInFigure)
                obj.junctionPlotHandle = allAxesInFigure(1);
            else
                figure('units', 'normalized', 'position', [0.4, 0, 0.6, 1]);
                obj.junctionPlotHandle = axes;
            end
            axis(obj.junctionPlotHandle,'equal',[roadDimensions.Start(1) roadDimensions.End(1)...
                roadDimensions.Start(2) roadDimensions.End(2)], 'off')
            hold(obj.junctionPlotHandle,'on')
            for i = 1:2
                if i == 1
                    xLimit = [roadDimensions.Start(1) roadDimensions.End(1)];
                    yLimit = [-roadDimensions.Width(1)/2 roadDimensions.Width(1)/2];
                else
                    xLimit = [-roadDimensions.Width(2)/2 roadDimensions.Width(2)/2];
                    yLimit = [roadDimensions.Start(2) roadDimensions.End(2)];
                end
                xBox = xLimit([1 1 2 2 1]);
                yBox = yLimit([1 2 2 1 1]);
                
                fill(obj.junctionPlotHandle,xBox,yBox,[0.5 0.5 0.5])
            end
            
            if isempty(allAxesInFigure)
                iDimension = [2.16 4.4 2.75];
                carRectangle = [ 0 0; iDimension(2) 0; iDimension(2) iDimension(1); 0 iDimension(1)]-...
                    [(iDimension(2) - iDimension(3))/2*ones(4,1) iDimension(1)/2*ones(4,1) ];
            end
        end
        function draw_all_cars(obj,horizontalArm,vericalArm)
            if numel(obj.junctionPlotHandle.Children) == 2
                flag = 0;
            else
                flag = 1;
            end
            if horizontalArm.numCars > 0
                obj.draw_car(horizontalArm,flag);
            end
            if vericalArm.numCars > 0
                obj.draw_car(vericalArm,flag)
            end
        end
        
        function collision_check(obj,allCarsHoriz,allCarsVert,nCars,mCars,plotFlag,t)
            hCar = 0;
            x1 = allCarsHoriz(1).s_in;
            x2 = allCarsHoriz(1).s_out;
            for iCar = 1:nCars
                x = allCarsHoriz(iCar).pose(1);
                alpha = (x-x1)/(x2-x1);
                if alpha >= 0 && alpha <= 1
                    hCar = iCar;
                    break;
                end
            end
            for jCar = 1:mCars
                vCar = 0;
                x = allCarsVert(jCar).pose(1);
                alpha = (x-x1)/(x2-x1);
                if alpha >= 0 && alpha <= 1
                    vCar = jCar;
                    break;
                end
            end
            if nCars > 0 && mCars > 0
                if hCar ==  obj.collidingCarsIdx(1) && vCar ==  obj.collidingCarsIdx(2)
                    obj.collisionFlag = 0;
                elseif hCar > 0 && vCar > 0
                    obj.collidingCarsIdx = [hCar; vCar];
                    obj.collisionFlag = 1;
                    % count crossing orders
                elseif hCar > 0 && hCar ~=  obj.collidingCarsIdx(1)
                    obj.crossOrder = [obj.crossOrder 0];
                    obj.collidingCarsIdx(1) = hCar;
                elseif vCar > 0 && vCar ~=  obj.collidingCarsIdx(2)
                    obj.crossOrder = [obj.crossOrder 1];
%                     obj.collidingCarsIdx(1) = 0;
                    obj.collidingCarsIdx(2) = vCar;
                end
            end
            if obj.collisionFlag
                msg = sprintf('Collision occured at time t = %f. collided cars = [%d %d] %i',t,hCar,vCar);
                save(['coll_t-' num2str(t) '.mat'],'allCarsHoriz','allCarsVert');
                disp(msg);
                
                if plotFlag
                    junctionAxesHandle = text(obj.junctionPlotHandle,3,-7,msg,'Color','red');
                    delete(junctionAxesHandle);
                else
                end
                
                %                 beep;
                %                 pause();
            end
        end
        
        function draw_car(obj,Arm,flag)
            plotVectorX = NaN(1,5);
            plotVectorY = NaN(1,5);
                        
            for iCar = 1:Arm.numCars
                iDimension = Arm.allCars(iCar).dimension;
                iPosition = Arm.allCars(iCar).pose;
                
                %the origin is placed on the middle of the rear wheels
                carRectangle = [ 0 0; iDimension(2) 0; iDimension(2) iDimension(1); 0 iDimension(1)]-...
                    [(iDimension(2) - iDimension(3))/2*ones(4,1) iDimension(1)/2*ones(4,1) ];
                front = [(iDimension(2) + iDimension(3))/2 0];
                
                % rotation counter-clockwise about the origin
                if iPosition(2) == 0
                    transformation = real([cosd(iPosition(2)) -sind(iPosition(2)) iPosition(1);...
                        sind(iPosition(2)) cosd(iPosition(2)) 0; 0 0 1]*[carRectangle' front'; ones(1,5)]);
                else
                    transformation = real([cosd(iPosition(2)) -sind(iPosition(2)) 0;...
                        sind(iPosition(2)) cosd(iPosition(2)) iPosition(1); 0 0 1]*[carRectangle' front'; ones(1,5)]);
                end
                
                plotVectorX(:) = [transformation(1,1:end-1) transformation(1,1)];
                plotVectorY(:) = [transformation(2,1:end-1) transformation(2,1)];
                
                % update plots of all cars' positions along each road
                
                update_car_plots(obj,Arm,flag,iCar,plotVectorX,plotVectorY);
            end
        end
        function update_car_plots(obj,arm,flag,iCar,plotVectorX,plotVectorY)
            if arm.numCars < numel(arm.CarsImageHandle)
                delete(arm.CarsImageHandle(1));
                arm.CarsImageHandle(1)= [];
            end
            if flag == 0 || iCar > numel(arm.CarsImageHandle)
                switch class(arm.allCars(iCar))
                    case 'carTypeA'
                        carColour = 'g';
                    case 'carTypeB'
                        carColour = 'r';
                    case 'carTypeC'
                        carColour = 'b';
                    case 'HesitantCar'
                        carColour = 'y';
                    case 'HdmModel'
                        carColour = 'm';
                    otherwise
                        carColour = 'k';
                end
                arm.CarsImageHandle = [arm.CarsImageHandle; fill(obj.junctionPlotHandle,plotVectorX',plotVectorY',carColour)];
            else
                set(arm.CarsImageHandle(iCar),'XData',plotVectorX','YData',plotVectorY');
            end
        end
    end
end


