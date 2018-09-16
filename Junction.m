classdef Junction < handle
    properties (SetAccess = public)
        allCarsImageHandle = []
        junctionPlotHandle = []
        horizCarsImageHandle = []
        vertCarsImageHandle = []
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
                %                 rad = 30;
                %                 x1=-rad;
                %                 x2=rad;
                %                 y1=-rad;
                %                 y2=rad;
                %                 x = [x1, x2, x2, x1, x1];
                %                 y = [y1, y1, y2, y2, y1];
                %                 plot(obj.junctionPlotHandle,x, y, 'k--', 'LineWidth', 1);
                %
                iDimension = [2.16 4.4 2.75];
                carRectangle = [ 0 0; iDimension(2) 0; iDimension(2) iDimension(1); 0 iDimension(1)]-...
                    [(iDimension(2) - iDimension(3))/2*ones(4,1) iDimension(1)/2*ones(4,1) ];
                
                x = roadDimensions.End(2)-20;
                x1 = x-5;
                y = (roadDimensions.End(2)-5):-5:(roadDimensions.End(2)-30);
                fill(obj.junctionPlotHandle,x1+[carRectangle(:,1); carRectangle(1,1)],y(1)+[carRectangle(:,2); carRectangle(1,2)],'g');
                text(obj.junctionPlotHandle,x, y(1)+0.5, '- ManualCar');
                
                fill(obj.junctionPlotHandle,x1+[carRectangle(:,1); carRectangle(1,1)],y(2)+[carRectangle(:,2); carRectangle(1,2)],'r');
                text(obj.junctionPlotHandle,x, y(2)+0.5, '- AggressiveCar');
                
                fill(obj.junctionPlotHandle,x1+[carRectangle(:,1); carRectangle(1,1)],y(3)+[carRectangle(:,2); carRectangle(1,2)],'b');
                text(obj.junctionPlotHandle,x, y(3)+0.5, '- PassiveCar');
                
                fill(obj.junctionPlotHandle,x1+[carRectangle(:,1); carRectangle(1,1)],y(4)+[carRectangle(:,2); carRectangle(1,2)],'y');
                text(obj.junctionPlotHandle,x, y(4)+0.5, '- HesitantCar');
                
                fill(obj.junctionPlotHandle,x1+[carRectangle(:,1); carRectangle(1,1)],y(5)+[carRectangle(:,2); carRectangle(1,2)],'m');
                text(obj.junctionPlotHandle,x, y(5)+0.5, '- HdmCar');
                
                fill(obj.junctionPlotHandle,x1+[carRectangle(:,1); carRectangle(1,1)],y(6)+[carRectangle(:,2); carRectangle(1,2)],'k');
                text(obj.junctionPlotHandle,x, y(6)+0.5, '- IdmCar');
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

        function collision_check(obj,allCarsHoriz,allCarsVert,nCars,mCars,plotFlag)
            bothCarsAtCrossing(1:2)  = false;
            for iCar = 1:nCars
                if allCarsHoriz(iCar).pose(1) > allCarsHoriz(iCar).s_in &&...
                        allCarsHoriz(iCar).pose(1) < allCarsHoriz(iCar).s_out
                    bothCarsAtCrossing(1) = true;
                    break;
                end
            end
            for jCar = 1:mCars
                if allCarsVert(jCar).pose(1) > allCarsVert(jCar).s_in &&...
                        allCarsVert(jCar).pose(1) < allCarsVert(jCar).s_out
                    bothCarsAtCrossing(2) = true;
                    break;
                end
            end
            if all(bothCarsAtCrossing)
                msg = 'Collision occured';
                disp(msg);
                if plotFlag
                    junctionAxesHandle = text(obj.junctionPlotHandle,3,-7,msg,'Color','red');
                    %                     pause()
                    delete(junctionAxesHandle);
                    beep;
                else
                    %pause();
                    beep;
                end
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
                
                if strcmpi(Arm.orientation,'horizontal')
                    if Arm.numCars < numel(obj.horizCarsImageHandle)
                        delete(obj.horizCarsImageHandle(1));
                        obj.horizCarsImageHandle(1)= [];
                    end
                    if flag == 0 || iCar > numel(obj.horizCarsImageHandle)
                        if strcmpi(class(Arm.allCars(iCar)),'ManualCar')
                            carColour = 'g';
                        elseif strcmpi(class(Arm.allCars(iCar)),'AggressiveCar')
                            carColour = 'r';
                        elseif strcmpi(class(Arm.allCars(iCar)),'PassiveCar')
                            carColour = 'b';
                        elseif strcmpi(class(Arm.allCars(iCar)),'HesitantCar')
                            carColour = 'y';
                        elseif strcmpi(class(Arm.allCars(iCar)),'HdmCar')
                            carColour = 'm';
                        else
                            carColour = 'k';
                        end
                        obj.horizCarsImageHandle = [obj.horizCarsImageHandle; fill(obj.junctionPlotHandle,plotVectorX',plotVectorY',carColour)];
                    else
                        set(obj.horizCarsImageHandle(iCar),'XData',plotVectorX','YData',plotVectorY');
                    end
                else
                    if Arm.numCars < numel(obj.vertCarsImageHandle)
                        delete(obj.vertCarsImageHandle(1));
                        obj.vertCarsImageHandle(1)= [];
                    end
                    if flag == 0 || iCar > numel(obj.vertCarsImageHandle)
                        if strcmpi(class(Arm.allCars(iCar)),'ManualCar')
                            carColour = 'g';
                        elseif strcmpi(class(Arm.allCars(iCar)),'AggressiveCar')
                            carColour = 'r';
                        elseif strcmpi(class(Arm.allCars(iCar)),'PassiveCar')
                            carColour = 'b';
                        elseif strcmpi(class(Arm.allCars(iCar)),'HesitantCar')
                            carColour = 'y';
                        elseif strcmpi(class(Arm.allCars(iCar)),'HdmCar')
                            carColour = 'm';
                        else
                            carColour = 'k';
                        end
                        obj.vertCarsImageHandle = [obj.vertCarsImageHandle; fill(obj.junctionPlotHandle,plotVectorX',plotVectorY',carColour)];
                    else
                        set(obj.vertCarsImageHandle(iCar),'XData',plotVectorX','YData',plotVectorY');
                    end
                    drawnow limitrate
%                     drawnow
                end
            end
        end
        
    end
end

