function varargout = microSim(varargin)
%UI MATLAB code file for UI.fig
%      UI, by itself, creates a new UI or raises the existing
%      singleton*.
%
%      H = UI returns the handle to a new UI or the handle to
%      the existing singleton*.
%
%      UI('Property','Value',...) creates a new UI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to UI_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      UI('CALLBACK') and UI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in UI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help UI

% Last Modified by GUIDE v2.5 18-Sep-2018 22:30:52

% Begin initialization code - DO NOT EDIT

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @UI_OpeningFcn, ...
    'gui_OutputFcn',  @UI_OutputFcn, ...
    'gui_LayoutFcn',  [], ...
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


% --- Executes just before UI is made visible.
function UI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for UI
handles.carTypes = {@IdmCar, @HdmCar, @AggressiveCar, @PassiveCar, @HesitantCar, @ManualCar};
handles.roadTypes = {@LoopRoad @FiniteRoad};

% handles.hPlot7 = plot(handles.axes7, NaN, NaN)


handles = text18_Callback(handles.text18,eventdata,handles);
handles = edit23_Callback(handles.edit23,eventdata,handles);
handles = edit27_Callback(handles.edit27,eventdata,handles);

handles.noSpawnAreaLength = 24.4;   % length of no spawn area around the junction + length of a car for safe respawn
handles.max_density = 1/6.4;        % number of cars per metre (0.1562)

handles.allCarsNumArray_H = zeros(1,numel(handles.carTypes));
handles.allCarsNumArray_V = zeros(1,numel(handles.carTypes));
handles.t_rng = [];
handles.iIteration = 1;
handles.TempCarHighlight = [];
handles.loadFlag = 0;
handles.pauseLength = 0.05;

% Update handles structure
handles.output = hObject;
guidata(hObject, handles);


% UIWAIT makes UI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = UI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function handles = edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double

init_density = str2double(get(hObject,'String'));

roadLength = str2double(get(handles.text18,'String'));

numCars = round(init_density * roadLength);
numCars_max = round(handles.max_density * (roadLength - handles.noSpawnAreaLength));
if numCars_max < numCars
    numCars = numCars_max;
end
density = numCars/roadLength;
set(hObject, 'String', round(density,4));
assert(density <= handles.max_density,'wrong max limit of densities. Have to be 0.1562 max');
assert(density >= 0,'wrong min limit of densities. have to be positive');

carTypeRatios = str2num(get(handles.edit28,'String'));

for j = 1:numel(handles.carTypes)
    if j == numel(handles.carTypes)
        handles.allCarsNumArray_H(j) = numCars - sum(handles.allCarsNumArray_H(1:j-1));
    else
        handles.allCarsNumArray_H(j) = round(numCars*carTypeRatios(j));
    end
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function uibuttongroup5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uibuttongroup5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object deletion, before destroying properties.
function uibuttongroup5_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to uibuttongroup5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function radiobutton14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radiobutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes on button press in radiobutton14.
function radiobutton14_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
p = get(handles.radiobutton11,'Value');
if p == 0
    set([ handles.edit3,handles.text4],'Enable','off');
    set([ handles.edit2,handles.text3],'Enable','on');
elseif p == 1
    set(findall(handles.uipanel3, '-property', 'enable'), 'enable', 'on')
    set(findall(handles.uipanel4, '-property', 'enable'), 'enable', 'off')
    %     set([ handles.edit4,handles.edit5,handles.edit6,handles.edit7,handles.edit8],'Enable','on')
    %     set([ handles.edit2,handles.edit3,handles.edit28,handles.checkbox2],'Enable','off');
end

% Hint: get(hObject,'Value') returns toggle state of radiobutton14


% --- Executes during object creation, after setting all properties.
function radiobutton15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radiobutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in radiobutton15.
function radiobutton15_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
p = get(handles.radiobutton11,'Value');
if p == 0
    set([ handles.edit3,handles.text4],'Enable','on');
    set([ handles.edit2,handles.text3],'Enable','off');
    %     set([ handles.edit2],'Enable','off');
    %     set([ handles.edit3],'Enable','on');
elseif p == 1
    set(findall(handles.uipanel3, '-property', 'enable'), 'enable', 'on')
    set(findall(handles.uipanel4, '-property', 'enable'), 'enable', 'off')
    %     set([ handles.edit4,handles.edit5,handles.edit6,handles.edit7,handles.edit8],'Enable','on')
    %     set([ handles.edit2,handles.edit3,handles.edit28,handles.checkbox2],'Enable','off');
end

% Hint: get(hObject,'Value') returns toggle state of radiobutton15


% --- Executes on button press in radiobutton10.
function radiobutton10_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
p = get(handles.radiobutton14,'Value');
set(findall(handles.uipanel3, '-property', 'enable'), 'enable', 'off')
set(findall(handles.uipanel4, '-property', 'enable'), 'enable', 'on')
if p == 0
    %     set([ handles.edit2],'Enable','off');
    %     set([ handles.edit3],'Enable','on');
    set([ handles.edit3,handles.text4],'Enable','on');
    set([ handles.edit2,handles.text3],'Enable','off');
else
    set([ handles.edit3,handles.text4],'Enable','off');
    set([ handles.edit2,handles.text3],'Enable','on');
    %     set([ handles.edit2],'Enable','on');
    %     set([ handles.edit3],'Enable','off');
end
% set([ handles.edit4,handles.edit5,handles.edit6,handles.edit7,handles.edit8],'Enable','off')

% set([ handles.edit28,handles.checkbox2],'Enable','on');
% Hint: get(hObject,'Value') returns toggle state of radiobutton10


% --- Executes during object creation, after setting all properties.
function radiobutton10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radiobutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in radiobutton11.
function radiobutton11_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% set([ handles.edit4,handles.edit5,handles.edit6,handles.edit7,handles.edit8],'Enable','on')
% set([ handles.edit2,handles.edit3,handles.edit28,handles.checkbox2],'Enable','off');
set(findall(handles.uipanel3, '-property', 'enable'), 'enable', 'on')
set(findall(handles.uipanel4, '-property', 'enable'), 'enable', 'off')
% Hint: get(hObject,'Value') returns toggle state of radiobutton11


% --- Executes during object creation, after setting all properties.
function radiobutton11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radiobutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function uibuttongroup3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uibuttongroup3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function uipanel3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbutton2.
function handles = pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.loadFlag == 0
    handles = uibuttongroup2_ButtonDownFcn(handles.uibuttongroup2, eventdata, handles);
    handles = uibuttongroup6_ButtonDownFcn(handles.uibuttongroup6, eventdata, handles);
end
handles = edit23_Callback(handles.edit23,eventdata,handles);

if get(handles.radiobutton14,'Value') && get(handles.radiobutton15,'Value') == 0
    roadType.H = 1;
else
    roadType.H = 2;
end
if get(handles.radiobutton17,'Value') && get(handles.radiobutton16,'Value') == 0
    roadType.V = 1;
else
    roadType.V = 2;
end

roadDims.Start = [str2num(get(handles.edit18,'String')); str2num(get(handles.edit24,'String'))];
roadDims.End = [str2num(get(handles.edit19,'String')); str2num(get(handles.edit25,'String'))];
roadDims.Width = [str2num(get(handles.edit20,'String')); str2num(get(handles.edit26,'String'))];
roadDims.Length = roadDims.End - roadDims.Start;

if get(handles.checkbox_animate,'Value')
    % open and run car plotting figure
    run('plotCars');
end

plotFlag = get(handles.checkbox_animate,'Value');
nIterations = str2num(get(handles.edit23,'String'));
dt = str2num(get(handles.edit17,'String'));

% handles.sim = run_simulation({handles.roadTypes{roadType.H},...
%     handles.roadTypes{roadType.V}},...
%     handles.carTypes,...
%     handles.Arm,...
%     handles.t_rng,...
%     plotFlag,...
%     priority,...
%     roadDims,...
%     nIterations,...
%     dt);
   
guidata(hObject,handles);

% construct two arms of the junction objects
if get(handles.pushbutton7,'Value') == 0
    handles.iIteration = 1;
    HorizontalArm = handles.roadTypes{roadType.H}([{handles.carTypes},0,roadDims],handles.Arm.H);
    VerticalArm = handles.roadTypes{roadType.V}([{handles.carTypes},90,roadDims],handles.Arm.V);
else
    HorizontalArm = handles.HorizontalArm;
    VerticalArm = handles.VerticalArm;
end
% plot the junction
junc = Junction(roadDims, plotFlag);

if plotFlag == 0
    f = waitbar(0,'','Name','Running simulation',...
        'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
    
    setappdata(f,'canceling',0);
end
% controlled break of the simulation
% finishup = onCleanup(@() myCleanupFun(HorizontalArm, VerticalArm));
set(handles.pushbutton3,'userdata',0);
for iIteration = handles.iIteration:nIterations
    % update time
    t = handles.t_rng(iIteration);
    
    % draw cars
    if plotFlag
        junc.draw_all_cars(HorizontalArm,VerticalArm)
        if get(handles.fastRate,'Value')
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
        plotFlag);

%     if iIteration == 1300
%         HorizontalArm.allCars(3).BT_plot_flag = 1;
%         plotFlag = 1;
%         junc = Junction(roadDims, plotFlag);
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
        HorizontalArm.allCars(iCar).decide_acceleration(VerticalArm,t,dt);
    end
    for jCar = 1:VerticalArm.numCars
        VerticalArm.allCars(jCar).decide_acceleration(HorizontalArm,t,dt);
    end
    
    % Move all the cars along the road
    HorizontalArm.move_all_cars(t,dt,iIteration,nIterations)
    VerticalArm.move_all_cars(t,dt,iIteration,nIterations)
    
    if get(handles.pushbutton3,'userdata') % stop condition
        for iCar = 1:HorizontalArm.numCars
            HorizontalArm.collect_car_history(HorizontalArm.allCars(iCar));
        end
        for jCar = 1:VerticalArm.numCars
            VerticalArm.collect_car_history(VerticalArm.allCars(jCar));
        end
        break;
    end
    
    if mod(iIteration,36) == 0 && plotFlag == 0
        if getappdata(f,'canceling')
            set(handles.pushbutton3,'userdata',1);
            set(handles.pushbutton7, 'enable', 'on')
            set(handles.pushbutton_plot_resutls, 'enable', 'on')
        end
        % Update waitbar and message
        waitbar(iIteration/nIterations,f,sprintf('%d percent progress',round(iIteration*100/nIterations)))
    end
end
if plotFlag == 0
    f = findall(0,'type','figure','tag','TMWWaitbar');
    delete(f)
end
set(handles.pushbutton_plot_resutls, 'enable', 'on')

handles.HorizontalArm = HorizontalArm;
handles.VerticalArm = VerticalArm;
handles.iIteration = iIteration;
handles.junc = junc;


guidata(hObject,handles);


setappdata(0,'horiz',HorizontalArm);
setappdata(0,'vert',VerticalArm);
setappdata(0,'iter',iIteration);
setappdata(0,'junc',junc);
setappdata(0,'t_rng',handles.t_rng);
setappdata(0,'density_H',str2double(get(handles.edit2,'String')));
setappdata(0,'density_V',str2double(get(handles.edit10,'String')));

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.pushbutton7, 'enable', 'on')
set(handles.pushbutton_plot_resutls, 'enable', 'on')
set(hObject,'userdata',1);


function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function handles = edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double
init_density = str2double(get(hObject,'String'));

roadLength = str2double(get(handles.edit27,'String'));

numCars = round(init_density * roadLength);
numCars_max = round(handles.max_density * (roadLength - handles.noSpawnAreaLength));
if numCars_max < numCars
    numCars = numCars_max;
end
density = numCars/roadLength;
set(hObject, 'String', round(density,4));
assert(density <= handles.max_density,'wrong max limit of densities. Have to be 0.1562 max');
assert(density >= 0,'wrong min limit of densities. have to be positive');

carTypeRatios = str2num(get(handles.edit29,'String'));
% handles.allCarsNumArray_V = zeros(1,numel(handles.carTypes));
for j = 1:numel(handles.carTypes)
    if j == numel(handles.carTypes)
        handles.allCarsNumArray_V(j) = numCars - sum(handles.allCarsNumArray_V(1:j-1));
    else
        handles.allCarsNumArray_V(j) = round(numCars*carTypeRatios(j));
    end
end
guidata(hObject,handles)






% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double


% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double


% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton19.
function radiobutton19_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
p = get(handles.radiobutton17,'Value');
set(findall(handles.uipanel5, '-property', 'enable'), 'enable', 'off')
set(findall(handles.uipanel6, '-property', 'enable'), 'enable', 'on')
if p == 0
    set([ handles.edit10,handles.text11],'Enable','off');
    set([ handles.edit9,handles.text10],'Enable','on');
else
    set([ handles.edit10,handles.text11],'Enable','on');
    set([ handles.edit9,handles.text10],'Enable','off');
end
% set([ handles.edit11,handles.edit12,handles.edit13,handles.edit14,handles.edit15],'Enable','off')
% set([ handles.edit29,handles.checkbox3],'Enable','on');

% Hint: get(hObject,'Value') returns toggle state of radiobutton19


% --- Executes on button press in radiobutton18.
function radiobutton18_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(findall(handles.uipanel5, '-property', 'enable'), 'enable', 'on')
set(findall(handles.uipanel6, '-property', 'enable'), 'enable', 'off')
% set([ handles.edit11,handles.edit12,handles.edit13,handles.edit14,handles.edit15],'Enable','on')
% set([ handles.edit9,handles.edit10,handles.edit29,handles.checkbox3],'Enable','off');
% Hint: get(hObject,'Value') returns toggle state of radiobutton18


% --- Executes on button press in radiobutton17.
function radiobutton17_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
p = get(handles.radiobutton18,'Value');
if p == 0
    set([ handles.edit10,handles.text11],'Enable','on');
    set([ handles.edit9,handles.text10],'Enable','off');
    %     set([ handles.edit9],'Enable','off');
    %     set([ handles.edit10],'Enable','on');
elseif p == 1
    set(findall(handles.uipanel5, '-property', 'enable'), 'enable', 'on')
    set(findall(handles.uipanel6, '-property', 'enable'), 'enable', 'off')
    %     set([ handles.edit11,handles.edit12,handles.edit13,handles.edit14,handles.edit15],'Enable','on')
    %     set([ handles.edit9,handles.edit10,handles.edit29,handles.checkbox3],'Enable','off');
end
% Hint: get(hObject,'Value') returns toggle state of radiobutton17


% --- Executes on button press in radiobutton16.
function radiobutton16_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
p = get(handles.radiobutton18,'Value');
if p == 0
    set([ handles.edit10,handles.text11],'Enable','off');
    set([ handles.edit9,handles.text10],'Enable','on');
    %     set([ handles.edit10],'Enable','off');
    %     set([ handles.edit9],'Enable','on');
elseif p == 1
    set(findall(handles.uipanel5, '-property', 'enable'), 'enable', 'on')
    set(findall(handles.uipanel6, '-property', 'enable'), 'enable', 'off')
    %     set([ handles.edit11,handles.edit12,handles.edit13,handles.edit14,handles.edit15],'Enable','on')
    %     set([ handles.edit9,handles.edit10,handles.edit29,handles.checkbox3],'Enable','off');
end
% Hint: get(hObject,'Value') returns toggle state of radiobutton16


% --- Executes on button press in checkbox_animate.
function checkbox_animate_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_animate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

allAxesInFigure = findall(0,'type','axes');
if ~isempty(allAxesInFigure) && strcmpi(allAxesInFigure.Tag,'axes1') 
    close(plotCars);
end

if get(hObject,'Value')
     set(findall(handles.updateRateGroup, '-property', 'enable'), 'enable', 'on');
 else
     set(findall(handles.updateRateGroup, '-property', 'enable'), 'enable', 'off');
 end


function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = edit23_Callback(handles.edit23,eventdata,handles);

guidata(hObject,handles)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double


% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit17_Callback(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = edit23_Callback(handles.edit23,eventdata,handles);
guidata(hObject,handles)

% Hints: get(hObject,'String') returns contents of edit17 as text
%        str2double(get(hObject,'String')) returns contents of edit17 as a double


% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit21_Callback(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit21 as text
%        str2double(get(hObject,'String')) returns contents of edit21 as a double


% --- Executes during object creation, after setting all properties.
function edit21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function handles = edit23_Callback(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

runTime = str2double(get(handles.edit16,'String'));
dt = str2double(get(handles.edit17,'String'));
nIterations = (runTime/dt)+1;
set(hObject,'String',nIterations);
% nDigits = numel(num2str(dt))-2;
handles.t_rng = 0:dt:runTime;
% handles.t_rng = round(linspace(0,runTime,nIterations),nDigits);

guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of edit23 as text
%        str2double(get(hObject,'String')) returns contents of edit23 as a double


% --- Executes during object creation, after setting all properties.
function edit23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit18_Callback(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = text18_Callback(handles.text18,eventdata,handles);

guidata(hObject,handles)
% Hints: get(hObject,'String') returns contents of edit18 as text
%        str2double(get(hObject,'String')) returns contents of edit18 as a double


% --- Executes during object creation, after setting all properties.
function edit18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit19_Callback(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = text18_Callback(handles.text18,eventdata,handles);

guidata(hObject,handles)
% Hints: get(hObject,'String') returns contents of edit19 as text
%        str2double(get(hObject,'String')) returns contents of edit19 as a double


% --- Executes during object creation, after setting all properties.
function edit19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit20_Callback(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit20 as text
%        str2double(get(hObject,'String')) returns contents of edit20 as a double


% --- Executes during object creation, after setting all properties.
function edit20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit28_Callback(hObject, eventdata, handles)
% hObject    handle to edit28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

assert(sum(str2num(get(hObject,'String'))) == 1,'Wrong distribution of horizontal arm rations');
% Hints: get(hObject,'String') returns contents of edit28 as text
%        str2double(get(hObject,'String')) returns contents of edit28 as a double


% --- Executes during object creation, after setting all properties.
function edit28_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2



function handles = edit27_Callback(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
p1 = str2double(get(handles.edit25,'String'));
p2 = str2double(get(handles.edit24,'String'));
p3 = p1 - p2;
set(hObject, 'String', p3);
% Hints: get(hObject,'String') returns contents of edit27 as text
%        str2double(get(hObject,'String')) returns contents of edit27 as a double


% --- Executes during object creation, after setting all properties.
function edit27_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% p1 = str2double(get(handles.edit25,'String'));
% p2 = str2double(get(handles.edit24,'String'));
% p3 = p1 - p2;
% set(hObject, 'String', p3);
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit26_Callback(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit26 as text
%        str2double(get(hObject,'String')) returns contents of edit26 as a double


% --- Executes during object creation, after setting all properties.
function edit26_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit25_Callback(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = edit27_Callback(handles.edit27,eventdata,handles);

guidata(hObject,handles)
% Hints: get(hObject,'String') returns contents of edit25 as text
%        str2double(get(hObject,'String')) returns contents of edit25 as a double


% --- Executes during object creation, after setting all properties.
function edit25_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit24_Callback(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = edit27_Callback(handles.edit27,eventdata,handles);

guidata(hObject,handles)
% Hints: get(hObject,'String') returns contents of edit24 as text
%        str2double(get(hObject,'String')) returns contents of edit24 as a double


% --- Executes during object creation, after setting all properties.
function edit24_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit29_Callback(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

assert(sum(str2num(get(hObject,'String'))) == 1,'Wrong distribution of vertical arm rations');

% Hints: get(hObject,'String') returns contents of edit29 as text
%        str2double(get(hObject,'String')) returns contents of edit29 as a double


% --- Executes during object creation, after setting all properties.
function edit29_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3



function handles = text18_Callback(hObject, eventdata, handles)
% hObject    handle to text18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
p1 = str2double(get(handles.edit19,'String'));
p2 = str2double(get(handles.edit18,'String'));
p3 = p1 - p2;
set(hObject, 'String', p3);
% Hints: get(hObject,'String') returns contents of text18 as text
%        str2double(get(hObject,'String')) returns contents of text18 as a double


% --- Executes during object creation, after setting all properties.
function text18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns calle
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on text18 and none of its controls.
function text18_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to text18 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over text18.
function text18_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to text18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2

% --- Executes during object creation, after setting all properties.
function axes7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes7


% --- Executes during object creation, after setting all properties.
function handles = axes5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes5


% --- Executes during object creation, after setting all properties.
function axes2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes2


% --- Executes during object creation, after setting all properties.
function axes4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes4


% --- Executes during object creation, after setting all properties.
function axes6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes6


% --------------------------------------------------------------------
function uipanel11_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uipanel11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in radiobutton25.
function radiobutton25_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton25


% --- Executes on button press in radiobutton27.
function radiobutton27_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton27

function edit30_Callback(hObject, eventdata, handles)
% hObject    handle to edit30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit30 as text
%        str2double(get(hObject,'String')) returns contents of edit30 as a double


% --- Executes during object creation, after setting all properties.
function edit30_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit31_Callback(hObject, eventdata, handles)
% hObject    handle to edit31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit31 as text
%        str2double(get(hObject,'String')) returns contents of edit31 as a double


% --- Executes during object creation, after setting all properties.
function edit31_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% construct two arms of the junction objects
handles = pushbutton2_Callback(handles.pushbutton2, eventdata, handles);
guidata(hObject,handles);


% --------------------------------------------------------------------
function handles = uibuttongroup2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uibuttongroup2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = text18_Callback(handles.text18,eventdata,handles);
handles = edit2_Callback(handles.edit2,eventdata,handles);
handles = edit23_Callback(handles.edit23,eventdata,handles);

roadStart = str2num(get(handles.edit18,'String'));
roadEnd = str2num(get(handles.edit19,'String'));
roadWidth = str2num(get(handles.edit20,'String'));
dt = str2num(get(handles.edit17,'String'));
if get(handles.radiobutton11,'Value')
    sz = [str2num(get(handles.edit4,'String')) 7];
    varTypes = {'double','double','double','double','function_handle','double','double'};
    varNames = {'position','velocity','target_velocity','acceleration','carType','priority','max_vel'};
    
    T = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
    T.position = (str2num(get(handles.edit5,'String'))');
    T.velocity = (str2num(get(handles.edit6,'String'))');
    T.target_velocity = (str2num(get(handles.edit30,'String'))'); %#ok<*ST2NM>
    T.acceleration = (str2num(get(handles.edit7,'String'))');
    T.carType = {handles.carTypes{str2num(get(handles.edit8,'String'))'}}';
    T.priority = (str2num(get(handles.edit32,'String'))');
    T.max_vel = (str2num(get(handles.edit34,'String'))');
    
    handles.Arm.H = SpawnCars(T,'horizontal',roadStart,roadEnd,roadWidth,dt);
else
    nIterations = str2double(get(handles.edit23,'String'));
    fixedSeed = get(handles.checkbox2,'Value');
    if get(handles.radiobutton14,'Value')
        handles.Arm.H = SpawnCars([{handles.allCarsNumArray_H},fixedSeed,{handles.carTypes}],'horizontal',roadStart,roadEnd,roadWidth,dt,nIterations);
    else
        spawnRate = str2double(get(handles.edit3,'String'));
        carTypeRatios = str2num(get(handles.edit28,'String'));
        dt = str2double(get(handles.edit17,'String'));
        handles.Arm.H = [{carTypeRatios},spawnRate,fixedSeed,dt,nIterations];
    end
end
guidata(hObject,handles)


% --------------------------------------------------------------------
function handles = uibuttongroup6_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uibuttongroup6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = edit27_Callback(handles.edit27,eventdata,handles);
handles = edit10_Callback(handles.edit10,eventdata,handles);
handles = edit23_Callback(handles.edit23,eventdata,handles);

roadStart = str2num(get(handles.edit24,'String'));
roadEnd = str2num(get(handles.edit25,'String'));
roadWidth = str2num(get(handles.edit26,'String'));
dt = str2num(get(handles.edit17,'String'));
if get(handles.radiobutton18,'Value')
    sz = [str2num(get(handles.edit15,'String')) 7];
    varTypes = {'double','double','double','double','function_handle','double','double'};
    varNames = {'position','velocity','target_velocity','acceleration','carType','priority','max_vel'};
    
    T = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
    T.position = (str2num(get(handles.edit14,'String'))');
    T.velocity = (str2num(get(handles.edit13,'String'))');
    T.target_velocity = (str2num(get(handles.edit31,'String'))');
    T.acceleration = (str2num(get(handles.edit12,'String'))');
    T.carType = {handles.carTypes{str2num(get(handles.edit11,'String'))'}}';
    T.priority = (str2num(get(handles.edit33,'String'))');
    T.max_vel = (str2num(get(handles.edit35,'String'))');
    
    handles.Arm.V = SpawnCars(T,'vertical',roadStart,roadEnd,roadWidth,dt);
else
    nIterations = str2double(get(handles.edit23,'String'));
    fixedSeed = get(handles.checkbox3,'Value');
    if get(handles.radiobutton17,'Value')
        handles.Arm.V = SpawnCars([{handles.allCarsNumArray_V},fixedSeed,{handles.carTypes}],'vertical',roadStart,roadEnd,roadWidth,dt,nIterations);
    else
        spawnRate = str2double(get(handles.edit9,'String'));
        carTypeRatios = str2num(get(handles.edit29,'String'));
        dt = str2double(get(handles.edit17,'String'));
        handles.Arm.V = [{carTypeRatios},spawnRate,fixedSeed,dt,nIterations];
    end
end
guidata(hObject,handles)

% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles) %#ok<*INUSL>
% hObject    handle to pushbutton_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nIterations = str2num(get(handles.edit23,'String'));
if get(handles.pushbutton3,'userdata') || (handles.iIteration == nIterations)
    sim.HorizontalArm = handles.HorizontalArm;
    sim.VerticalArm = handles.VerticalArm;
    sim.ResumeFlag = 1;
else
    handles = uibuttongroup2_ButtonDownFcn(handles.uibuttongroup2, eventdata, handles);
    handles = uibuttongroup6_ButtonDownFcn(handles.uibuttongroup6, eventdata, handles);
    handles = edit23_Callback(handles.edit23,eventdata,handles);
    sim.ResumeFlag = 0;
end
sim.runTime = get(handles.edit16,'String');
sim.timeStepSize = get(handles.edit17,'String');
sim.t_rng = handles.t_rng;
sim.Iterations = handles.iIteration;
sim.animate = get(handles.checkbox_animate,'Value');

%% horizontal arm
sim.H.start = get(handles.edit18,'String');
sim.H.end = get(handles.edit19,'String');
sim.H.width = get(handles.edit20,'String');
sim.H.prescribeDensityFlow = get(handles.radiobutton10,'Value');
sim.H.manuallyInputCars = get(handles.radiobutton11,'Value');
sim.H.loopRoad = get(handles.radiobutton14,'Value');
sim.H.finiteRoad = get(handles.radiobutton15,'Value');

% manual Traffic assignment
sim.H.nCars = get(handles.edit4,'String');
sim.H.position = get(handles.edit5,'String');
sim.H.velocity = get(handles.edit6,'String');
sim.H.target_velocity = get(handles.edit30,'String');
sim.H.acceleration = get(handles.edit7,'String');
sim.H.carType = get(handles.edit8,'String');
sim.H.priority = get(handles.edit32,'String');
sim.H.max_vel = get(handles.edit34,'String');

% random traffic assignment
sim.H.density = get(handles.edit2,'String');
sim.H.flowrate = get(handles.edit3,'String');
sim.H.carTypeRatio = get(handles.edit28,'String');
sim.H.fixedSeed = get(handles.checkbox2,'Value');
%% vertical arm
sim.V.start = get(handles.edit24,'String');
sim.V.end = get(handles.edit25,'String');
sim.V.width = get(handles.edit26,'String');
sim.V.prescribeDensityFlow = get(handles.radiobutton19,'Value');
sim.V.manuallyInputCars = get(handles.radiobutton18,'Value');
sim.V.loopRoad = get(handles.radiobutton17,'Value');
sim.V.finiteRoad = get(handles.radiobutton16,'Value');

% manual Traffic assignment
sim.V.nCars = get(handles.edit15,'String');
sim.V.position = get(handles.edit14,'String');
sim.V.velocity = get(handles.edit13,'String');
sim.V.target_velocity = get(handles.edit31,'String');
sim.V.acceleration = get(handles.edit12,'String');
sim.V.carType = get(handles.edit11,'String');
sim.V.priority = get(handles.edit33,'String');
sim.V.max_vel = get(handles.edit35,'String');

% random traffic assignment
sim.V.density = get(handles.edit10,'String');
sim.V.flowrate = get(handles.edit9,'String');
sim.V.carTypeRatio = get(handles.edit29,'String');
sim.V.fixedSeed = get(handles.checkbox3,'Value');  %#ok<*STRNU>

sim.Arm = handles.Arm;

uisave('sim');



function edit32_Callback(hObject, eventdata, handles)
% hObject    handle to edit32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit32 as text
%        str2double(get(hObject,'String')) returns contents of edit32 as a double


% --- Executes during object creation, after setting all properties.
function edit32_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit33_Callback(hObject, eventdata, handles)
% hObject    handle to edit33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit33 as text
%        str2double(get(hObject,'String')) returns contents of edit33 as a double


% --- Executes during object creation, after setting all properties.
function edit33_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit34_Callback(hObject, eventdata, handles) %#ok<*INUSD>
% hObject    handle to edit34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit34 as text
%        str2double(get(hObject,'String')) returns contents of edit34 as a double


% --- Executes during object creation, after setting all properties.
function edit34_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit35_Callback(hObject, eventdata, handles)
% hObject    handle to edit35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit35 as text
%        str2double(get(hObject,'String')) returns contents of edit35 as a double


% --- Executes during object creation, after setting all properties.
function edit35_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_load.
function pushbutton_load_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
% hObject    handle to pushbutton_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiopen

set(handles.edit16,'String',sim.runTime);
set(handles.edit17,'String',sim.timeStepSize);
handles.iIteration = sim.Iterations;
handles.t_rng = sim.t_rng;
set(handles.checkbox_animate,'Value',sim.animate);

%% horizontal arm
set(handles.edit18,'String', sim.H.start);
set(handles.edit19,'String',sim.H.end);
set(handles.edit20,'String',sim.H.width);
set(handles.radiobutton10,'Value',sim.H.prescribeDensityFlow);
set(handles.radiobutton11,'Value',sim.H.manuallyInputCars);
set(handles.radiobutton14,'Value',sim.H.loopRoad);
set(handles.radiobutton15,'Value',sim.H.finiteRoad);

% manual Traffic assignment
set(handles.edit4,'String',sim.H.nCars);
set(handles.edit5,'String',sim.H.position);
set(handles.edit6,'String',sim.H.velocity);
set(handles.edit30,'String',sim.H.target_velocity);
set(handles.edit7,'String',sim.H.acceleration);
set(handles.edit8,'String',sim.H.carType);
set(handles.edit32,'String',sim.H.priority);
set(handles.edit34,'String',sim.H.max_vel);

% random traffic assignment
set(handles.edit2,'String',sim.H.density);
set(handles.edit3,'String',sim.H.flowrate);
set(handles.edit28,'String',sim.H.carTypeRatio);
set(handles.checkbox2,'Value',sim.H.fixedSeed);
%% vertical arm
set(handles.edit24,'String',sim.V.start);
set(handles.edit25,'String',sim.V.end);
set(handles.edit26,'String',sim.V.width);
set(handles.radiobutton19,'Value',sim.V.prescribeDensityFlow);
set(handles.radiobutton18,'Value',sim.V.manuallyInputCars);
set(handles.radiobutton17,'Value',sim.V.loopRoad);
set(handles.radiobutton16,'Value',sim.V.finiteRoad);

% manual Traffic assignment
set(handles.edit15,'String',sim.V.nCars);
set(handles.edit14,'String',sim.V.position);
set(handles.edit13,'String',sim.V.velocity);
set(handles.edit31,'String',sim.V.target_velocity);
set(handles.edit12,'String',sim.V.acceleration);
set(handles.edit11,'String',sim.V.carType);
set(handles.edit33,'String',sim.V.priority);
set(handles.edit35,'String',sim.V.max_vel);

% random traffic assignment
set(handles.edit10,'String',sim.V.density);
set(handles.edit9,'String',sim.V.flowrate);
set(handles.edit29,'String',sim.V.carTypeRatio);
set(handles.checkbox3,'Value',sim.V.fixedSeed);

handles.Arm = sim.Arm;
handles.loadFlag = 1;

if sim.ResumeFlag
    set(handles.pushbutton7, 'enable', 'on')
    set(handles.pushbutton_plot_resutls, 'enable', 'on')
    handles.HorizontalArm = sim.HorizontalArm;
    handles.VerticalArm = sim.VerticalArm;
end
set(handles.checkbox11, 'enable', 'on')
guidata(hObject,handles);

if sim.ResumeFlag
    setappdata(0,'horiz',handles.HorizontalArm);
    setappdata(0,'vert',handles.VerticalArm);
end
setappdata(0,'iter',handles.iIteration);
% setappdata(0,'junc',junc);
setappdata(0,'t_rng',handles.t_rng);
setappdata(0,'density_H',str2double(get(handles.edit2,'String')));
setappdata(0,'density_V',str2double(get(handles.edit10,'String')));

% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(microSim);
run('microSim');   


% --- Executes on button press in checkbox11.
function checkbox11_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
enableFlag = get(hObject,'Value');
if enableFlag
    handles.loadFlag = 0;
end
guidata(hObject,handles);

% Hint: get(hObject,'Value') returns toggle state of checkbox11


% --- Executes on button press in pushbutton_plot_resutls.
function pushbutton_plot_resutls_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_plot_resutls (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
run('Results');


% --- Executes on button press in fastRate.
function fastRate_Callback(hObject, eventdata, handles)
% hObject    handle to fastRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fastRate


% --- Executes on button press in slowRate.
function slowRate_Callback(hObject, eventdata, handles)
% hObject    handle to slowRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of slowRate


% --- Executes during object creation, after setting all properties.
function updateRateGroup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to updateRateGroup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(findall(hObject, '-property', 'enable'), 'enable', 'on');
