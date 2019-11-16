classdef Junction < handle
    properties (SetAccess = public)
        %         allCarsImageHandle = []
        junctionPlotHandle = []
        %         horizCarsImageHandle = []
        %         vertCarsImageHandle = []
        collidingCarsIdx = NaN(1,2)
        collisionFlag = 0
        crossOrder = NaN
        crossCarTypeOrder = NaN
        crossCount = []
        crossCarTypeCount = []

        
        collisionMsgs = []
        
        flowHandle = []
        flowAxHandle = []
        
        crossHandle = []
        crossAxHandle = []
        crossAxHandle2 = []
        crossAxHandle3 = []
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
                h1 = gcf;
                obj.junctionPlotHandle = allAxesInFigure(1);
                axis(obj.junctionPlotHandle,'off')
            else
                h1 = figure('units', 'normalized', 'position', [0.4, 0, 0.6, 1]);
            end
%             obj.junctionPlotHandle = axes('Parent',h1,'Units','normalized','Position',[0.05 0.5 0.9 0.45]);
            obj.junctionPlotHandle = axes;
            %{
            obj.flowHandle = axes('Parent',h1,'Units','normalized','Position',[0.05 0.3 0.9 0.15]);
            hold(obj.flowHandle,'on')
            grid(obj.flowHandle,'on')
            obj.crossHandle = axes('Parent',h1,'Units','normalized','Position',[0.05 0.1 0.9 0.15]);
            hold(obj.crossHandle,'on')
            grid(obj.crossHandle,'on')
            
            obj.flowAxHandle = plot(obj.flowHandle,NaN,NaN,'b-',NaN,NaN,'r-',NaN,NaN,'g-');
            
            lgd = legend(obj.flowAxHandle,{'East Arm','North Arm','Average'},'Location','southwest');
            lgd.FontSize = 16;
            obj.crossAxHandle = plot(obj.crossHandle,NaN,NaN,'-b','LineWidth',1.5);
            obj.crossAxHandle2 = text(1/2,-0.05,'\uparrow East Arm Crosses','FontSize',16);
            obj.crossAxHandle3 = text(1/2,1.05,'\downarrow North Arm Crosses','FontSize',16);
            
            %}
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
                
                % roadPlotHanlde - handle for each individual road  
                roadPlotHanlde(i) = fill(obj.junctionPlotHandle,xBox,yBox,[0.5 0.5 0.5]);
            end
            x1=-roadDimensions.Width(1)/2;
            x2=roadDimensions.Width(1)/2;
            y1=-roadDimensions.Width(1)/2;
            y2=roadDimensions.Width(1)/2;
            x = [x1, x2, x2, x1, x1];
            y = [y1, y1, y2, y2, y1];
           
            % juncBoxhandle - handle for junction box
            juncBoxhandle = plot(obj.junctionPlotHandle,x, y,'k');

            %RoadOrJunctionFlag - flag determins if plotting junction or single road
            % True - plot just road; False - plot full junction
            RoadOrJunctionFlag = getappdata(0,'RoadOrJunctionFlag');
             
            if RoadOrJunctionFlag
                roadPlotHanlde(2).Visible = 'Off';
                juncBoxhandle.Visible = 'Off';
            end
                                
            if isempty(allAxesInFigure)
                iDimension = [2.16 4.4 2.75];
                carRectangle = [ 0 0; iDimension(2) 0; iDimension(2) iDimension(1); 0 iDimension(1)]-...
                    [(iDimension(2) - iDimension(3))/2*ones(4,1) iDimension(1)/2*ones(4,1) ];
            end
        end
        function draw_all_cars(obj,horizontalArm,vericalArm,iIteration,transientCutOffLength)
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
%{
            if transientCutOffLength*10 <= iIteration && mod(iIteration,1) == 0
                %% plot flow and crossings
                set(obj.flowAxHandle(1),'XData',1:iIteration,'YData',horizontalArm.flow(1:iIteration));
                set(obj.flowAxHandle(2),'XData',1:iIteration,'YData',vericalArm.flow(1:iIteration));
                set(obj.flowAxHandle(3),'XData',1:iIteration,'YData',mean([horizontalArm.flow(1:iIteration)';vericalArm.flow(1:iIteration)']));
                
                set(obj.crossAxHandle,'XData',1:iIteration,'YData',obj.crossOrder);
                
                if (iIteration-1000 <= 0)
                    startSpot = 1;
                    set(obj.crossAxHandle2,'Position',[iIteration/2,-0.05,0]);
                    set(obj.crossAxHandle3,'Position',[iIteration/2,1.05,0]);
                else
                    startSpot = iIteration-1000;
                    set(obj.crossAxHandle2,'Position',[(iIteration+startSpot)/2,-0.05,0]);
                    set(obj.crossAxHandle3,'Position',[(iIteration+startSpot)/2,1.05,0]);
                end
                axis(obj.flowHandle,[startSpot, (iIteration+50) 0, 0.35]);
                axis(obj.crossHandle,[startSpot, (iIteration+50), -0.1, 1.1]);
                
            end
%}
        end
        function draw_car(obj,Arm,flag)
            plotVectorX = NaN(1,5);
            plotVectorY = NaN(1,5);
            delete(Arm.CarsNumberHandle);
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
%                 msg = sprintf('%i', iCar);
%                 arm.CarsNumberHandle = [arm.CarsNumberHandle; text(mean(plotVectorX),mean(plotVectorY),msg,'Color','black')];
            else
                set(arm.CarsImageHandle(iCar),'XData',plotVectorX','YData',plotVectorY');
%                 set(arm.CarsNumberHandle(iCar),'XData',mean(plotVectorX),'YData',mean(plotVectorY));
            end
            msg = sprintf('%i', iCar);
            arm.CarsNumberHandle = [arm.CarsNumberHandle; text(mean(plotVectorX),mean(plotVectorY),msg,'Color','black')];
            
            
        end
        function collision_check(obj,allCarsHoriz,allCarsVert,nCars,mCars,plotFlag,t)
            hCar = 0;
            if isempty(allCarsHoriz) && isempty(allCarsVert)
                return
            elseif isempty(allCarsHoriz)
                x1 = allCarsVert(1).s_in;
                x2 = allCarsVert(1).s_out;
            else
                x1 = allCarsHoriz(1).s_in;
                x2 = allCarsHoriz(1).s_out;
                vCar = 0;
            end
            if  ~isempty(allCarsHoriz)
                for iCar = 1:nCars
                    x = allCarsHoriz(iCar).pose(1);
                    alpha = (x-x1)/(x2-x1);
                    if alpha >= 0 && alpha <= 1
                        hCar = iCar;
                        break;
                    end
                end
            end
            if ~isempty(allCarsVert)
                for jCar = 1:mCars
                    vCar = 0;
                    x = allCarsVert(jCar).pose(1);
                    alpha = (x-x1)/(x2-x1);
                    if alpha >= 0 && alpha <= 1
                        vCar = jCar;
                        break;
                    end
                end
            end
            if nCars > 0 && mCars > 0
                if hCar ==  obj.collidingCarsIdx(1) && vCar ==  obj.collidingCarsIdx(2)
                    obj.collisionFlag = 0;
                    if isempty(obj.crossOrder)
                        obj.crossOrder = NaN;
                        obj.crossCarTypeOrder = NaN;
                    else
                        obj.crossOrder = [obj.crossOrder obj.crossOrder(end)];
                        obj.crossCarTypeOrder = [obj.crossCarTypeOrder obj.crossCarTypeOrder(end)];
                    end
                elseif hCar > 0 && vCar > 0
                    obj.crossCount = [obj.crossCount NaN];
                    obj.collidingCarsIdx = [hCar; vCar];
                    obj.collisionFlag = 1;
                    if isempty(obj.crossOrder)
                        obj.crossOrder = NaN;
                        obj.crossCarTypeOrder = NaN;
                    else
                        obj.crossOrder = [obj.crossOrder obj.crossOrder(end)];
                        obj.crossCarTypeOrder = [obj.crossCarTypeOrder obj.crossCarTypeOrder(end)];
                    end
                    % count crossing orders
                elseif hCar > 0 && hCar ~=  obj.collidingCarsIdx(1)
                    
                    obj.crossOrder = [obj.crossOrder 0];
                    obj.crossCount = [obj.crossCount 0];
                    
                    obj.collidingCarsIdx(1) = hCar;
                    switch class(allCarsHoriz(hCar))
                        case 'carTypeA'
                            obj.crossCarTypeCount = [obj.crossCarTypeCount 1];
                            obj.crossCarTypeOrder = [obj.crossCarTypeOrder 1];

                        case 'carTypeB'
                            obj.crossCarTypeCount = [obj.crossCarTypeCount 2];
                            obj.crossCarTypeOrder = [obj.crossCarTypeOrder 2];

                        case 'carTypeC'
                            obj.crossCarTypeCount = [obj.crossCarTypeCount 3];
                            obj.crossCarTypeOrder = [obj.crossCarTypeOrder 3];

                        otherwise
                            obj.crossCarTypeCount = [obj.crossCarTypeCount NaN];
                            obj.crossCarTypeOrder = [obj.crossCarTypeOrder NaN];
                    end
                elseif vCar > 0 && vCar ~=  obj.collidingCarsIdx(2)
                    
                    obj.crossOrder = [obj.crossOrder 1];
                    obj.crossCount = [obj.crossCount 1];
                    
                    %                     obj.collidingCarsIdx(1) = 0;
                    obj.collidingCarsIdx(2) = vCar;
                    switch class(allCarsVert(vCar))
                        case 'carTypeA'
                            obj.crossCarTypeCount = [obj.crossCarTypeCount 1];
                            obj.crossCarTypeOrder = [obj.crossCarTypeOrder 1];

                        case 'carTypeB'
                            obj.crossCarTypeCount = [obj.crossCarTypeCount 2];
                            obj.crossCarTypeOrder = [obj.crossCarTypeOrder 2];

                        case 'carTypeC'
                            obj.crossCarTypeCount = [obj.crossCarTypeCount 3];
                            obj.crossCarTypeOrder = [obj.crossCarTypeOrder 3];

                        otherwise
                            obj.crossCarTypeCount = [obj.crossCarTypeCount NaN];
                            obj.crossCarTypeOrder = [obj.crossCarTypeOrder NaN];
                    end
                else
                    if isempty(obj.crossOrder)
                        obj.crossOrder = NaN;
                        obj.crossCarTypeOrder = NaN;
                    else
                        obj.crossOrder = [obj.crossOrder obj.crossOrder(end)];
                        obj.crossCarTypeOrder = [obj.crossCarTypeOrder obj.crossCarTypeOrder(end)];
                    end
                end
            else
                obj.crossOrder = [obj.crossOrder obj.crossOrder(end)];
                obj.crossCarTypeOrder = [obj.crossCarTypeOrder obj.crossCarTypeOrder(end)];
            end
%             %{
            if obj.collisionFlag
                msg = sprintf('Collision occured at time t = %f.2 collided cars = [%d %d]',t,hCar,vCar);
                obj.collisionMsgs = [obj.collisionMsgs; size(msg)];
                %save(['coll_t-' num2str(t) '.mat'],'allCarsHoriz','allCarsVert');
                disp(msg);

                if plotFlag
                    junctionAxesHandle = text(obj.junctionPlotHandle,3,-7,msg,'Color','red');
                    delete(junctionAxesHandle);
                else
                end
                obj.collisionFlag = 0;
            end
            %}
        end
        
    end
end


