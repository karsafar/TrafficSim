classdef Junction < handle
    properties (SetAccess = public)
        allCarsImageHandle = []
        junctionPlotHandle = []
    end
    
    methods
        function obj = Junction(roadDimensions,plotFlag)
            if plotFlag
                obj.plot_outline(roadDimensions);
            end
        end
        function plot_outline(obj,roadDimensions)
            %figure('units', 'normalized', 'position', [0.4, 0, 0.6, 1]);
            obj.junctionPlotHandle = axes;
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
            rad = 30;
            x1=-rad;
            x2=rad;
            y1=-rad;
            y2=rad;
            x = [x1, x2, x2, x1, x1];
            y = [y1, y1, y2, y2, y1];
            plot(obj.junctionPlotHandle,x, y, 'k--', 'LineWidth', 1);
            
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
        function draw_all_cars(obj,horizontalArm,vericalArm)
            if horizontalArm.numCars > 0
                obj.allCarsImageHandle = [obj.allCarsImageHandle obj.draw_car(horizontalArm,obj.junctionPlotHandle)];
            end
            if vericalArm.numCars > 0
                obj.allCarsImageHandle = [obj.allCarsImageHandle obj.draw_car(vericalArm,obj.junctionPlotHandle)];
            end
        end
        function delete_car_images(obj)
            delete(obj.allCarsImageHandle);
            obj.allCarsImageHandle = [];
        end
        % possibly for collecting history data (position, velocity and acceleration)
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
    end
    methods (Static)
        function CarsImageHandle =  draw_car(obj,junctionAxesHandle)
            plotVectorX = NaN(1,5);
            plotVectorY = NaN(1,5);
            CarsImageHandle = NaN(1,obj.numCars);
            for iCar = 1:obj.numCars
                iDimension = obj.allCars(iCar).dimension;
                iPosition = obj.allCars(iCar).pose;
                
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
                %                 if obj.allCars(iCar).acceleration > 0
                %                     carColour = 'g';
                %                 elseif obj.allCars(iCar).acceleration == 0
                %                     carColour = 'k';
                %                 else
                %                     carColour = 'r';
                %                 end
                if strcmpi(class(obj.allCars(iCar)),'ManualCar')
                    carColour = 'g';
                elseif strcmpi(class(obj.allCars(iCar)),'AggressiveCar')
                    carColour = 'r';
                elseif strcmpi(class(obj.allCars(iCar)),'PassiveCar')
                    carColour = 'b';
                elseif strcmpi(class(obj.allCars(iCar)),'HesitantCar')
                    carColour = 'y';
                elseif strcmpi(class(obj.allCars(iCar)),'HdmCar')
                    carColour = 'm';
                else
                    carColour = 'k';
                end
                CarsImageHandle(iCar) = fill(junctionAxesHandle,plotVectorX',plotVectorY',carColour);
            end
            
            %             allCarsImageHandle = fill(ha1,plotVectorX',plotVectorY','k');
        end
        
    end
end

