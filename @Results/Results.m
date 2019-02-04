function varargout = Results(varargin)
% RESULTS MATLAB code for Results.fig
%      RESULTS, by itself, creates a new RESULTS or raises the existing
%      singleton*.
%
%      H = RESULTS returns the handle to a new RESULTS or the handle to
%      the existing singleton*.
%
%      RESULTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RESULTS.M with the given input arguments.
%
%      RESULTS('Property','Value',...) creates a new RESULTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Results_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Results_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Results

% Last Modified by GUIDE v2.5 21-Aug-2018 03:00:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Results_OpeningFcn, ...
                   'gui_OutputFcn',  @Results_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Results is made visible.
function Results_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Results (see VARARGIN)

% Choose default command line output for Results
handles.output = hObject;

if get(handles.checkbox_micro,'Value') == 0
    set(findall(handles.uipanel_micro, '-property', 'enable'), 'enable', 'off')
end
if get(handles.checkbox_macro,'Value') == 0
    set(findall(handles.uipanel_macro, '-property', 'enable'), 'enable', 'off')
end
handles.HorizontalArm = getappdata(0,'horiz');
handles.VerticalArm = getappdata(0,'vert');
handles.iIteration = getappdata(0,'iter');
% handles.junc = getappdata(0,'junc');
handles.t_rng = getappdata(0,'t_rng');
handles.TempCarHighlight = [];
handles.density.H = getappdata(0,'density_H');
handles.density.V = getappdata(0,'density_V');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Results wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Results_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_plot.
function pushbutton_plot_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.radiobutton_horiz,'Value')
    cars = handles.HorizontalArm.allCars;
    road =  handles.HorizontalArm;
    density = ones(handles.iIteration,1)*handles.density.H;
else
    cars = handles.VerticalArm.allCars;
    road =  handles.VerticalArm;    
    density = ones(handles.iIteration,1)*handles.density.V;
end


if get(handles.checkbox_micro,'Value')
    if get(handles.checkbox_time_disp,'Value')
        cla(findall(handles.axes_time_disp,'type','axes'),'reset');
        title(handles.axes_time_disp,'Trajectories','FontSize',12)
        xlabel(handles.axes_time_disp,'Time, s','FontSize',12)
        ylabel(handles.axes_time_disp,'Horizontal Position, m','FontSize',12)
        hold(handles.axes_time_disp,'on');
        grid(handles.axes_time_disp,'on');
        x1 = 0;
        x2 = handles.t_rng(handles.iIteration);
        y1 = cars(1).s_in;
        y2 = -cars(1).s_in;
        x = [x1, x2, x2, x1, x1];
        y = [y1, y1, y2, y2, y1];
        axis(handles.axes_time_disp,[0 handles.t_rng(handles.iIteration) handles.HorizontalArm.startPoint handles.HorizontalArm.endPoint] )
        yyaxis(handles.axes_time_disp,'left')
        patch(handles.axes_time_disp,x,y,[0.5 0.5 0.5],'EdgeColor','None');
        for iCar = 1:handles.HorizontalArm.nCarHistory
%             plot(handles.axes_time_disp,handles.HorizontalArm.carHistory{iCar}(1,1:end),handles.HorizontalArm.carHistory{iCar}(2,1:end),'b-','LineWidth',1);
            plot(handles.axes_time_disp,handles.HorizontalArm.carHistory(iCar).timeHistory,handles.HorizontalArm.carHistory(iCar).locationHistory,'b-','LineWidth',1);
        end
        yyaxis(handles.axes_time_disp,'right')
        for jCar = 1:handles.VerticalArm.nCarHistory
%             plot(handles.axes_time_disp,handles.VerticalArm.carHistory{jCar}(1,1:end),handles.VerticalArm.carHistory{jCar}(2,1:end),'r-','LineWidth',1);
            plot(handles.axes_time_disp,handles.VerticalArm.carHistory(jCar).timeHistory,handles.VerticalArm.carHistory(jCar).locationHistory,'r-','LineWidth',1);
        end
        ylabel(handles.axes_time_disp,'Vertical Position, m','FontSize',12)
        set(handles.axes_time_disp, 'Ydir', 'reverse')
                
        axis(handles.axes_time_disp,[0 handles.t_rng(handles.iIteration) handles.VerticalArm.startPoint handles.VerticalArm.endPoint] )
    end

    if get(handles.checkbox_spat,'Value')
        cla(findall(handles.axes_heatmap,'type','axes'),'reset');
        title(handles.axes_heatmap,'Spatiotemporal Velocity Profiles','FontSize',12)
        xlabel(handles.axes_heatmap,'Time, s','FontSize',12)
        ylabel(handles.axes_heatmap,'Horizontal Position, s','FontSize',12)
        hold(handles.axes_heatmap,'on');
        grid(handles.axes_heatmap,'on');
        axis(handles.axes_heatmap,[0 handles.t_rng(handles.iIteration) road.startPoint road.endPoint] )
        sz = 5;
        for iCar = 1:road.nCarHistory
%             scatter(handles.axes_heatmap,road.carHistory{iCar}(1,1:end),road.carHistory{iCar}(2,1:end),sz,road.carHistory{iCar}(3,1:end),'filled');
            scatter(handles.axes_heatmap,road.carHistory(iCar).timeHistory,road.carHistory(iCar).locationHistory,sz,road.carHistory(iCar).velocityHistory,'filled');
        end
        axes(handles.axes_heatmap)
        c = colorbar;
        c.Label.String = 'Velocity, m/s';
        c.Label.FontSize = 12;
        caxis([0 13])
        colormap(flipud(jet));
    end
end

if get(handles.checkbox_macro,'Value')
    if get(handles.checkbox_time_av_vel,'Value')
       % cla(findall(handles.axes_time_av_vel,'type','axes'));
        title(handles.axes_time_av_vel,'Velocity Average Across All Cars','FontSize',12)
        xlabel(handles.axes_time_av_vel,'Time, s','FontSize',12)
        ylabel(handles.axes_time_av_vel,' Velocity \langleV\rangle, m/s','FontSize',12)
        hold(handles.axes_time_av_vel,'on');
        grid(handles.axes_time_av_vel,'on');
        plot(handles.axes_time_av_vel,handles.t_rng(1:handles.iIteration),road.averageVelocityHistory(1:handles.iIteration),'LineWidth',1)
        axis(handles.axes_time_av_vel,[0 handles.t_rng(handles.iIteration) 0 (max(road.averageVelocityHistory(1:handles.iIteration))+2)])
    end
    
%     if get(handles.checkbox_time_ag_vel,'Value')
%         %cla(findall(handles.axes_time_ag_vel,'type','axes'));
%         
% %         for i = 1:handles.iIteration
% %             cumulativeAverage(i) = nanmean(road.averageVelocityHistory(1:i)); %#ok<*AGROW>
% %         end
% 
%         title(handles.axes_time_ag_vel,'Cumulative Velocity Average','FontSize',12)
%         xlabel(handles.axes_time_ag_vel,'Time, s','FontSize',12)
%         ylabel(handles.axes_time_ag_vel,' Velocity \langleV\rangle, m/s','FontSize',12)
%         hold(handles.axes_time_ag_vel,'on');
%         grid(handles.axes_time_ag_vel,'on');
%         plot(handles.axes_time_ag_vel,handles.t_rng(1:handles.iIteration),cumulativeAverage,'LineWidth',1)
%         axis(handles.axes_time_ag_vel,[0 handles.t_rng(handles.iIteration) 0 (max(cumulativeAverage)+2)])
%     end
    if get(handles.checkbox_var,'Value')
        %cla(findall(handles.axes_speed_var,'type','axes'));
        title(handles.axes_speed_var,'Speed Variance','FontSize',12)
        xlabel(handles.axes_speed_var,'Time, s','FontSize',12)
        ylabel(handles.axes_speed_var,' \sigma^{2}, m^{2}/s^{2}','FontSize',12)
        hold(handles.axes_speed_var,'on');
        grid(handles.axes_speed_var,'on');
        plot(handles.axes_speed_var,handles.t_rng(1:handles.iIteration),road.variance(1:handles.iIteration),'LineWidth',1)
        axis(handles.axes_speed_var,[0 handles.t_rng(handles.iIteration) 0 max(road.variance)])
    end
    if get(handles.checkbox_flow,'Value')
        tf = isa(road,'LoopRoad');
        for i = 1:handles.iIteration
            cumulativeAverage(i) = nanmean(road.averageVelocityHistory(1:i)); %#ok<*AGROW>
        end
        if tf == 0
            density = road.numCarsHistory/road.Length;
        end
        flow = density'.*cumulativeAverage;
        
        %cla(findall(handles.axes_flow,'type','axes'));
        title(handles.axes_flow,'Demand','FontSize',12)
        xlabel(handles.axes_flow,'Time, s','FontSize',12)
        ylabel(handles.axes_flow,'Flow, veh/s','FontSize',12)
        hold(handles.axes_flow,'on');
        grid(handles.axes_flow,'on');
        plot(handles.axes_flow,handles.t_rng(1:handles.iIteration),flow(1:handles.iIteration),'LineWidth',1)
        axis(handles.axes_flow,[0 handles.t_rng(handles.iIteration) 0 max(flow)])
    end
    if get(handles.checkbox_occupancy,'Value')
        
        O_in = -10-cars(1).ownDistfromRearToFront;
        O_out = -10+cars(1).ownDistfromRearToBack;
        occupancy = zeros(length(handles.t_rng(1:handles.iIteration)),1);
        for iCar = 1:road.nCarHistory
            iCar_pos = road.carHistory(iCar).locationHistory;
            iCar_times = road.carHistory(iCar).timeHistory;
            iCar_times = iCar_times(iCar_pos>=O_in & iCar_pos<=O_out);
            iCar_pos = iCar_pos(iCar_pos>=O_in & iCar_pos<=O_out);
            [tf,loc]=ismember(iCar_times,handles.t_rng);
            if ~isempty(iCar_pos)
                for i = loc(1):loc(end)
                occupancy(i:end) = occupancy(i)+(handles.t_rng(2)-handles.t_rng(1));
                end
            end
        end
        for i = 1:length(occupancy)
            occupancy(i) = (occupancy(i)/handles.t_rng(i))* 100;
        end
        %cla(findall(handles.axes_occupancy,'type','axes'));
        title(handles.axes_occupancy,'Occupancy','FontSize',12)
        xlabel(handles.axes_occupancy,'Time, s','FontSize',12)
        ylabel(handles.axes_occupancy,' Occupancy, per cent','FontSize',12)
        hold(handles.axes_occupancy,'on');
        grid(handles.axes_occupancy,'on');
        plot(handles.axes_occupancy,handles.t_rng(1:handles.iIteration),occupancy,'LineWidth',1)
        axis(handles.axes_occupancy,[0 handles.t_rng(handles.iIteration) 0 100])
    end
    if get(handles.checkbox_density,'Value')
        tf = isa(road,'LoopRoad');
        if tf == 0
            density = road.numCarsHistory/road.Length;
        end
        %cla(findall(handles.axes_density,'type','axes'));
        title(handles.axes_density,'Density','FontSize',12)
        xlabel(handles.axes_density,'Time, s','FontSize',12)
        ylabel(handles.axes_density,'Density, veh/m','FontSize',12)
        hold(handles.axes_density,'on');
        grid(handles.axes_density,'on');
        plot(handles.axes_density,handles.t_rng(1:handles.iIteration),density(1:handles.iIteration),'LineWidth',1)
        axis(handles.axes_density,[0 handles.t_rng(handles.iIteration) 0 max(density)])
    end
end


% --- Executes on button press in pushbutton_clear.
function pushbutton_clear_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla(findall(handles.axes_time_disp,'type','axes'),'reset');
cla(findall(handles.axes_heatmap,'type','axes'),'reset');
cla(findall(handles.axes_time_vel,'type','axes'),'reset');
cla(findall(handles.axes_time_av_vel,'type','axes'),'reset');
cla(findall(handles.axes_time_ag_vel,'type','axes'),'reset');
cla(findall(handles.axes_speed_var,'type','axes'),'reset');
cla(findall(handles.axes_density,'type','axes'),'reset');
cla(findall(handles.axes_flow,'type','axes'),'reset');
cla(findall(handles.axes_occupancy,'type','axes'),'reset');

guidata(hObject,handles);

% --- Executes on button press in checkbox_time_ag_vel.
function checkbox_time_ag_vel_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_time_ag_vel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_time_ag_vel


% --- Executes on button press in checkbox_time_av_vel.
function checkbox_time_av_vel_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_time_av_vel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_time_av_vel


% --- Executes on button press in checkbox_time_disp.
function checkbox_time_disp_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_time_disp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_time_disp


% --- Executes on button press in checkbox_time_vel.
function checkbox_time_vel_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_time_vel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_time_vel


% --- Executes on selection change in listbox_select_car.
function handles = listbox_select_car_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_select_car (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_select_car contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_select_car
delete(handles.TempCarHighlight);
if get(handles.checkbox_micro, 'Value')
    if get(handles.radiobutton_horiz, 'Value')
        if numel(handles.HorizontalArm.allCars) == 0
            numList = 0;
            set(hObject,'Value',1);
            set(hObject,'string',{numList});
        else
            numList = (1:numel(handles.HorizontalArm.allCars))';
            
            idx = get(hObject,'Value');
            if numel(handles.HorizontalArm.allCars) < idx
                idx = 1;
                set(hObject,'Value',idx);
            end
            set(hObject,'string',{numList});
            allAxesInFigure = findall(0,'type','axes');
            handles.TempCarHighlight = plotCarEdge(handles.HorizontalArm.allCars(idx),allAxesInFigure(1));
        end
    elseif get(handles.radiobutton_vert, 'Value')
        if numel(handles.VerticalArm.allCars) == 0
            numList = 0;
            set(hObject,'Value',1);
            set(hObject,'string',{numList});
        else
            numList = (1:numel(handles.VerticalArm.allCars))';
            
            idx = get(hObject,'Value');
            if numel(handles.VerticalArm.allCars) < idx
                idx = 1;
                set(hObject,'Value',idx);
            end
            set(hObject,'string',{numList});
            allAxesInFigure = findall(0,'type','axes');
            handles.TempCarHighlight = plotCarEdge(handles.VerticalArm.allCars(idx),allAxesInFigure(1));
        end
    end
end

if get(handles.radiobutton_horiz,'Value')
    cars = handles.HorizontalArm.allCars;
else
    cars = handles.VerticalArm.allCars;
end
if get(handles.checkbox_time_vel,'Value') && ~isempty(cars)
    cla(findall(handles.axes_time_vel,'type','axes'));
    title(handles.axes_time_vel,'Velocity Profile','FontSize',12)
    xlabel(handles.axes_time_vel,'Time, s','FontSize',12)
    ylabel(handles.axes_time_vel,' Velocity V, m/s','FontSize',12)
    hold(handles.axes_time_vel,'on');
    grid(handles.axes_time_vel,'on');
    axis(handles.axes_time_vel,[min(cars(idx).timeHistory) max(cars(idx).timeHistory) 0 cars(1).maximumVelocity])
    plot(handles.axes_time_vel,cars(idx).timeHistory,cars(idx).velocityHistory,'b-','LineWidth',1)
    
    
    
    cla(findall(handles.axes_time_ag_vel,'type','axes'));
    title(handles.axes_time_ag_vel,'Acceleration Profile','FontSize',12)
    xlabel(handles.axes_time_ag_vel,'Time, s','FontSize',12)
    ylabel(handles.axes_time_ag_vel,' Acceleration V, m/s^2','FontSize',12)
    hold(handles.axes_time_ag_vel,'on');
    grid(handles.axes_time_ag_vel,'on');
    axis(handles.axes_time_ag_vel,[min(cars(idx).timeHistory) max(cars(idx).timeHistory) min(cars(idx).a_feas_min,min(cars(idx).accelerationHistory)) max(cars(idx).a_max,max(cars(idx).accelerationHistory))])
    plot(handles.axes_time_ag_vel,cars(idx).timeHistory,cars(idx).accelerationHistory,'b-','LineWidth',1)
end
guidata(hObject, handles);

function CarsImageHandle = plotCarEdge(obj,junctionAxesHandle)
plotVectorX = NaN(1,5);
plotVectorY = NaN(1,5);
iDimension = obj.dimension;
iPosition = [obj.locationHistory(obj.historyIndex-1), obj.pose(2)];

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

CarsImageHandle = plot(junctionAxesHandle,plotVectorX',plotVectorY','w-','LineWidth',2);


% --- Executes during object creation, after setting all properties.
function listbox_select_car_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_select_car (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_micro.
function checkbox_micro_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_micro (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_micro
if get(hObject,'Value')
    set(findall(handles.uipanel_micro, '-property', 'enable'), 'enable', 'on');
    handles = listbox_select_car_Callback(handles.listbox_select_car,eventdata,handles);
elseif get(hObject,'Value') == 0
    set(findall(handles.uipanel_micro, '-property', 'enable'), 'enable', 'off');
end
guidata(hObject, handles);

% --- Executes on button press in checkbox_macro.
function checkbox_macro_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_macro (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_macro
if get(hObject,'Value')
    set(findall(handles.uipanel_macro, '-property', 'enable'), 'enable', 'on');
elseif get(hObject,'Value') == 0
    set(findall(handles.uipanel_macro, '-property', 'enable'), 'enable', 'off');
end

% --- Executes on button press in radiobutton_horiz.
function radiobutton_horiz_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_horiz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_horiz
if get(handles.checkbox_micro,'Value')
%     set(handles.listbox_select_car,'Value',0);
    handles = listbox_select_car_Callback(handles.listbox_select_car,eventdata,handles);
end
guidata(hObject, handles);


% --- Executes on button press in radiobutton_vert.
function radiobutton_vert_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_vert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_vert
if get(handles.checkbox_micro,'Value')
%     set(handles.listbox_select_car,'Value',1);
    handles = listbox_select_car_Callback(handles.listbox_select_car,eventdata,handles);
end
guidata(hObject, handles);


% --- Executes on button press in checkbox_var.
function checkbox_var_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_var (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_var


% --- Executes on button press in checkbox_spat.
function checkbox_spat_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_spat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_spat


% --- Executes on button press in checkbox_flow.
function checkbox_flow_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_flow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_flow


% --- Executes on button press in checkbox_density.
function checkbox_density_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_density (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_density


% --- Executes on button press in checkbox_occupancy.
function checkbox_occupancy_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_occupancy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_occupancy
