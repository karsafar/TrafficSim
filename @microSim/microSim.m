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

% Last Modified by GUIDE v2.5 23-Jul-2018 21:18:04

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

set(findall(handles.uipanel10, '-property', 'enable'), 'enable', 'off')
handles = text18_Callback(handles.text18,eventdata,handles);
handles = edit23_Callback(handles.edit23,eventdata,handles);
handles = edit27_Callback(handles.edit27,eventdata,handles);

handles.noSpawnAreaLength = 24.4;   % length of no spawn area around the junction + length of a car for safe respawn
handles.max_density = 1/6.4;        % number of cars per metre (0.1562)

handles.allCarsNumArray_H = zeros(1,numel(handles.carTypes));
handles.allCarsNumArray_V = zeros(1,numel(handles.carTypes));
handles.t_rng = [];
% Update handles structure
handles.output = hObject;
guidata(hObject, handles);
% start the timer


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


function timerCallback(hTimer, eventdata, hFigure)
handles = guidata(hFigure);
str = handles.myCellData{handles.strIdx};
set(handles.pushbutton1,'String',str);
handles.strIdx = handles.strIdx + 1;
if handles.strIdx > length(handles.myCellData)
    handles.strIdx = 1;
end
guidata(hFigure,handles);

function handles = edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double

init_density = str2double(get(hObject,'String'));

roadLength = str2double(get(handles.text18,'String'));

numCars = round(init_density * (roadLength - handles.noSpawnAreaLength));

density = numCars/roadLength;
set(hObject, 'String', density);
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


% --- Executes on button press in pushbutton1.
function handles = pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
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
    sz = [str2num(get(handles.edit4,'String')) 5];
    varTypes = {'double','double','double','double','function_handle'};
    varNames = {'position','velocity','target_velocity','acceleration','carType'};
    
    T = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
    T.position = [str2num(get(handles.edit5,'String'))'];
    T.velocity = [str2num(get(handles.edit6,'String'))'];
    T.target_velocity = [str2num(get(handles.edit30,'String'))'];
    T.acceleration = [str2num(get(handles.edit7,'String'))'];
    T.carType = {handles.carTypes{str2num(get(handles.edit8,'String'))'}}';
    
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
        handles.Arm.H =  [{carTypeRatios},spawnRate,fixedSeed,dt,nIterations];
    end
end


guidata(hObject,handles)

% --- Executes on button press in pushbutton2.
function handles = pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = pushbutton1_Callback(handles.pushbutton1, eventdata, handles);
handles = pushbutton4_Callback(handles.pushbutton4, eventdata, handles);
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

plotFlag = get(handles.checkbox1,'Value');
priority = get(handles.edit22,'Value');
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

set(findall(handles.uipanel10, '-property', 'enable'), 'enable', 'off')
guidata(hObject,handles);

% construct two arms of the junction objects
HorizontalArm = handles.roadTypes{roadType.H}([{handles.carTypes},0,roadDims,priority],handles.Arm.H);
VerticalArm = handles.roadTypes{roadType.V}([{handles.carTypes},90,roadDims,priority],handles.Arm.V);

% plot the junction
junc = Junction(roadDims, plotFlag);

% controlled break of the simulation
% finishup = onCleanup(@() myCleanupFun(HorizontalArm, VerticalArm));
set(handles.pushbutton3,'userdata',0);
for iIteration = 1:nIterations
    % update time
    t = handles.t_rng(iIteration);
    
    % draw cars
    if plotFlag
        junc.draw_all_cars(HorizontalArm,VerticalArm)
    end
    
    % check for collision
    junc.collision_check(...
        HorizontalArm.allCars,...
        VerticalArm.allCars,...
        HorizontalArm.numCars,...
        VerticalArm.numCars,...
        plotFlag);
    
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
        break;
    end
    if plotFlag
        pause(0.01)
        junc.delete_car_images();
    end

end
set(findall(handles.uipanel10, '-property', 'enable'), 'enable', 'on')
set(findall(handles.uipanel14, '-property', 'enable'), 'enable', 'off')
set(findall(handles.uipanel15, '-property', 'enable'), 'enable', 'off')
handles.HorizontalArm = HorizontalArm;
handles.VerticalArm = VerticalArm;
handles.iIteration = iIteration;

guidata(hObject,handles);

% sim.horizArm = cast_output(HorizontalArm);
% sim.vertArm = cast_output(VerticalArm);


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject,'userdata',1);

% set(findall(handles.uipanel10, '-property', 'enable'), 'enable', 'on')



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

numCars = round(init_density * (roadLength - handles.noSpawnAreaLength));

density = numCars/roadLength;
set(hObject, 'String', density);
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


% --- Executes on button press in pushbutton4.
function handles = pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
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
    sz = [str2num(get(handles.edit15,'String')) 5];
    varTypes = {'double','double','double','double','function_handle'};
    varNames = {'position','velocity','target_velocity','acceleration','carType'};
    
    T = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
    T.position = [str2num(get(handles.edit14,'String'))'];
    T.velocity = [str2num(get(handles.edit13,'String'))'];
    T.target_velocity = [str2num(get(handles.edit31,'String'))'];
    T.acceleration = [str2num(get(handles.edit12,'String'))'];
    T.carType = {handles.carTypes{str2num(get(handles.edit11,'String'))'}}';
    
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
        handles.Arm.V =  [{carTypeRatios},spawnRate,fixedSeed,dt,nIterations];
    end
end



guidata(hObject,handles)


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1



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


% --- Executes on button press in edit22.
function edit22_Callback(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of edit22


% --- Executes during object creation, after setting all properties.
function edit22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function handles = edit23_Callback(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

runTime = str2double(get(handles.edit16,'String'));
dt = str2double(get(handles.edit17,'String'));
nIterations = (runTime/dt)+1;
set(hObject,'String',nIterations);
nDigits = numel(num2str(dt))-2;
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


% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7


% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5


% --- Executes on selection change in listbox2.
function handles = listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.checkbox8, 'Value')
    if get(handles.radiobutton21, 'Value')
        if numel(handles.HorizontalArm.allCars) == 0
            numList = 0;
        else
            numList = [1:numel(handles.HorizontalArm.allCars)]';
        end
        set(hObject,'string',{numList});
    elseif get(handles.radiobutton22, 'Value')
        if numel(handles.VerticalArm.allCars) == 0
            numList = 0;
        else
            numList = [1:numel(handles.VerticalArm.allCars)]';
        end
        set(hObject,'string',{numList});
    end
end
guidata(hObject, handles);

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox8.
function checkbox8_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    set(findall(handles.uipanel14, '-property', 'enable'), 'enable', 'on');
    handles = listbox2_Callback(handles.listbox2,eventdata,handles);
elseif get(hObject,'Value') == 0
    set(findall(handles.uipanel14, '-property', 'enable'), 'enable', 'off');
end
guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of checkbox8


% --- Executes on button press in checkbox9.
function checkbox9_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    set(findall(handles.uipanel15, '-property', 'enable'), 'enable', 'on');
elseif get(hObject,'Value') == 0
    set(findall(handles.uipanel15, '-property', 'enable'), 'enable', 'off');
end
% Hint: get(hObject,'Value') returns toggle state of checkbox9


% --- Executes on button press in radiobutton21.
function radiobutton21_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.checkbox8,'Value')
    handles = listbox2_Callback(handles.listbox2,eventdata,handles);
end 
% Hint: get(hObject,'Value') returns toggle state of radiobutton21


% --- Executes on button press in radiobutton22.
function radiobutton22_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.checkbox8,'Value')
    handles = listbox2_Callback(handles.listbox2,eventdata,handles);
end 
% Hint: get(hObject,'Value') returns toggle state of radiobutton22


% --- Executes on button press in pushbutton5.
function handles = pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.radiobutton21,'Value')
    cars = handles.HorizontalArm.allCars;
    road =  handles.HorizontalArm;
else
    cars = handles.VerticalArm.allCars;
    road =  handles.VerticalArm;
end

 
if get(handles.checkbox8,'Value')
    if get(handles.checkbox4,'Value')
        cla(findall(handles.axes5,'type','axes'),'reset');
        title(handles.axes5,'All Displacements','FontSize',12)
        xlabel(handles.axes5,'Time, s','FontSize',12)
        ylabel(handles.axes5,'Position, m','FontSize',12)
        hold(handles.axes5,'on');
        grid(handles.axes5,'on');
        axis(handles.axes5,[0 handles.t_rng(handles.iIteration) -inf inf] )
        plot(handles.axes5,handles.t_rng(1:handles.iIteration),zeros(1,handles.iIteration),'-g','LineWidth',1);
        yyaxis(handles.axes5,'left') 
        plot(handles.axes5,[handles.HorizontalArm.allCars(1:end).timeHistory],[handles.HorizontalArm.allCars(1:end).locationHistory],'b-','LineWidth',1)
        yyaxis(handles.axes5,'right')
        plot(handles.axes5,[handles.VerticalArm.allCars(1:end).timeHistory],[handles.VerticalArm.allCars(1:end).locationHistory],'r-','LineWidth',1);
        ylabel(handles.axes5,'Position, m','FontSize',12)
        set(handles.axes5, 'Ydir', 'reverse')
    end
    if get(handles.checkbox5,'Value')
        cla(findall(handles.axes2,'type','axes'));
        idx = get(handles.listbox2,'Value');
        title(handles.axes2,'Velocity Profile','FontSize',12)
        xlabel(handles.axes2,'Time, s','FontSize',12)
        ylabel(handles.axes2,' Velocity V, m/s','FontSize',12)
        hold(handles.axes2,'on');
        grid(handles.axes2,'on');
        axis(handles.axes2,[min(cars(idx).timeHistory) max(cars(idx).timeHistory) 0 10])
        plot(handles.axes2,cars(idx).timeHistory,cars(idx).velocityHistory,'b-','LineWidth',1)
    end
end

if get(handles.checkbox9,'Value')
    if get(handles.checkbox6,'Value')
        cla(findall(handles.axes6,'type','axes'));
        title(handles.axes6,'Velocity Average Across All Cars','FontSize',12)
        xlabel(handles.axes6,'Time, s','FontSize',12)
        ylabel(handles.axes6,' Velocity <V>, m/s','FontSize',12)
        hold(handles.axes6,'on');
        grid(handles.axes6,'on');
        plot(handles.axes6,handles.t_rng(1:handles.iIteration),road.averageVelocityHistory(1:handles.iIteration),'b-','LineWidth',1)
        axis(handles.axes6,[0 handles.t_rng(handles.iIteration) 0 10])
    end
    
    if get(handles.checkbox7,'Value')
        cla(findall(handles.axes4,'type','axes'));

        for i = 1:handles.iIteration
            cumulativeAverage(i) = nanmean(road.averageVelocityHistory(1:i));
        end
        
        title(handles.axes4,'Cumulative Velocity Average','FontSize',12)
        xlabel(handles.axes4,'Time, s','FontSize',12)
        ylabel(handles.axes4,' Velocity <V>, m/s','FontSize',12)
        hold(handles.axes4,'on');
        grid(handles.axes4,'on');
        plot(handles.axes4,handles.t_rng(1:handles.iIteration),cumulativeAverage,'b-','LineWidth',1)
        axis(handles.axes4,[0 handles.t_rng(handles.iIteration) 0 10])
    end
end

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


% --- Executes during object creation, after setting all properties.
function radiobutton21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radiobutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function radiobutton22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radiobutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



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
