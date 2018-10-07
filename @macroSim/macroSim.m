function varargout = macroSim(varargin)
% MACROSIM MATLAB code for macroSim.fig
%      MACROSIM, by itself, creates a new MACROSIM or raises the existing
%      singleton*.
%
%      H = MACROSIM returns the handle to a new MACROSIM or the handle to
%      the existing singleton*.
%
%      MACROSIM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MACROSIM.M with the given input arguments.
%
%      MACROSIM('Property','Value',...) creates a new MACROSIM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before macroSim_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to macroSim_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help macroSim

% Last Modified by GUIDE v2.5 24-Jul-2018 00:41:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @macroSim_OpeningFcn, ...
    'gui_OutputFcn',  @macroSim_OutputFcn, ...
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


% --- Executes just before macroSim is made visible.
function macroSim_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to macroSim (see VARARGIN)
handles.carTypes = {@IdmCar, @HdmCar, @AggressiveCar, @PassiveCar, @HesitantCar, @ManualCar};
handles.roadTypes = {@LoopRoad @FiniteRoad};
handles.noSpawnAreaLength = 24.4;   % length of no spawn area around the junction + length of a car for safe respawn
handles.max_density = 1/6.4; % number of cars per metre (0.1562)

% Choose default command line output for macroSim
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes macroSim wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = macroSim_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton6.
function handles = pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = pushbutton3_Callback(handles.pushbutton7,eventdata,handles);
handles = pushbutton1_Callback(handles.pushbutton1,eventdata,handles);

roadStart = str2double(get(handles.edit27,'String'));
roadEnd = str2double(get(handles.edit28,'String'));
roadWidth =str2double(get(handles.edit29,'String'));
dt = str2double(get(handles.edit2,'String'));
nIterations = str2double(get(handles.pushbutton1,'String'));
fixedSeed = get(handles.checkbox7,'Value');

densityFlag = get(handles.radiobutton10,'Value');

if densityFlag
    handles = edit44_Callback(handles.edit44,eventdata,handles);
    for k = 1:handles.numberOfSimRuns_V
        handles.Arm(k).V = SpawnCars([{handles.allCarsNumArray_V(k,:)},fixedSeed,{handles.carTypes}],'vertical',roadStart,roadEnd,roadWidth,dt,nIterations);
    end
else
    handles.numberOfSimRuns_V = str2double(get(handles.edit46,'String'));
    flowRange = str2num(get(handles.edit43,'String'));

    spawnRate = linspace(flowRange(1),flowRange(2),handles.numberOfSimRuns_V);
    carTypeRatios = str2num(get(handles.edit45,'String'));
    for k = 1:handles.numberOfSimRuns_V
        handles.Arm(k).V = [{carTypeRatios},spawnRate(k),fixedSeed,dt,nIterations];
    end
end
guidata(hObject,handles);

% --- Executes on button press in pushbutton2.
function handles = pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = pushbutton3_Callback(handles.pushbutton3,eventdata,handles);
handles = pushbutton1_Callback(handles.pushbutton1,eventdata,handles);

roadStart = str2double(get(handles.edit5,'String'));
roadEnd = str2double(get(handles.edit6,'String'));
roadWidth =str2double(get(handles.edit7,'String'));
dt = str2double(get(handles.edit2,'String'));
nIterations = str2double(get(handles.pushbutton1,'String'));
fixedSeed = get(handles.checkbox2,'Value');

densityFlag = get(handles.radiobutton3,'Value');

if densityFlag
    handles = edit_Callback(handles.edit,eventdata,handles);
    for k = 1:handles.numberOfSimRuns_H
        handles.Arm(k).H = SpawnCars([{handles.allCarsNumArray_H(k,:)},fixedSeed,{handles.carTypes}],'horizontal',roadStart,roadEnd,roadWidth,dt,nIterations);
    end
else
    handles.numberOfSimRuns_H = str2double(get(handles.edit42,'String'));
    flowRange = str2num(get(handles.edit8,'String'));

    spawnRate = linspace(flowRange(1),flowRange(2),handles.numberOfSimRuns_H);
    carTypeRatios = str2num(get(handles.edit10,'String'));
    for k = 1:handles.numberOfSimRuns_H
        handles.Arm(k).H = [{carTypeRatios},spawnRate(k),fixedSeed,dt,nIterations];
    end
end
guidata(hObject,handles);

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


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




% --- Executes on button press in pushbutton1.
function handles = pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
runTime = str2double(get(handles.edit1,'String'));
dt = str2double(get(handles.edit2,'String'));
nIterations = (runTime/dt)+1;
set(hObject,'String',nIterations);
nDigits = numel(num2str(dt))-2;
handles.t_rng = 0:dt:runTime;

% handles.t_rng = round(linspace(0,runTime,nIterations),nDigits);

guidata(hObject,handles);

% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1



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


% --- Executes on button press in pushbutton3.
function handles = pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
p1 = str2double(get(handles.edit6,'String'));
p2 = str2double(get(handles.edit5,'String'));
p3 = p1 - p2;
set(hObject, 'String', p3);


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



function handles = edit_Callback(hObject, eventdata, handles)
% hObject    handle to edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
densityRange = str2num(get(hObject,'String'));

roadLength = str2double(get(handles.pushbutton3,'String'));

initNumCars = round(densityRange(1) * roadLength);
endNumCars = round(densityRange(end) * roadLength);
nCarsRange = initNumCars:1:endNumCars;
RealDensityRange = nCarsRange/roadLength;

assert(all(RealDensityRange(end) <= handles.max_density),'wrong max limit of densities. Have to be 0.1562 max');
assert(all(RealDensityRange(1) >= 0),'wrong min limit of densities. have to be positive');
string1 = sprintf(' %.4f',RealDensityRange);
set(hObject, 'String', string1);
if numel(nCarsRange) == 1 && nCarsRange == 0
    handles.numberOfSimRuns_H = 1;
    handles.allCarsNumArray_H = zeros(1,numel(handles.carTypes));
else
    handles.numberOfSimRuns_H = numel(nCarsRange);
    carTypeRatios = str2num(get(handles.edit10,'String'));
    handles.allCarsNumArray_H = zeros(handles.numberOfSimRuns_H,numel(handles.carTypes));
    for k = 1:handles.numberOfSimRuns_H
        for j = 1:numel(handles.carTypes)
            if j == numel(handles.carTypes)
                handles.allCarsNumArray_H(k,j) = nCarsRange(k) - sum(handles.allCarsNumArray_H(k,1:j-1));
            else
                handles.allCarsNumArray_H(k,j) = round(nCarsRange(k)*carTypeRatios(j));
            end
        end
    end
end
guidata(hObject,handles)
% Hints: get(hObject,'String') returns contents of edit as text
%        str2double(get(hObject,'String')) returns contents of edit as a double


% --- Executes during object creation, after setting all properties.
function edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


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


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6



function edit41_Callback(hObject, eventdata, handles)
% hObject    handle to edit41 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit41 as text
%        str2double(get(hObject,'String')) returns contents of edit41 as a double


% --- Executes during object creation, after setting all properties.
function edit41_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit41 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit40_Callback(hObject, eventdata, handles)
% hObject    handle to edit40 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit40 as text
%        str2double(get(hObject,'String')) returns contents of edit40 as a double


% --- Executes during object creation, after setting all properties.
function edit40_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit40 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit39_Callback(hObject, eventdata, handles)
% hObject    handle to edit39 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit39 as text
%        str2double(get(hObject,'String')) returns contents of edit39 as a double


% --- Executes during object creation, after setting all properties.
function edit39_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit39 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit27_Callback(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit27 as text
%        str2double(get(hObject,'String')) returns contents of edit27 as a double


% --- Executes during object creation, after setting all properties.
function edit27_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
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



function edit29_Callback(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
p1 = str2double(get(handles.edit28,'String'));
p2 = str2double(get(handles.edit27,'String'));
p3 = p1 - p2;
set(hObject, 'String', p3);


function edit42_Callback(hObject, eventdata, handles)
% hObject    handle to edit42 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit42 as text
%        str2double(get(hObject,'String')) returns contents of edit42 as a double


% --- Executes during object creation, after setting all properties.
function edit42_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit42 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function handles = edit43_Callback(hObject, eventdata, handles)
% hObject    handle to edit43 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit43 as text
%        str2double(get(hObject,'String')) returns contents of edit43 as a double


% --- Executes during object creation, after setting all properties.
function edit43_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit43 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function handles = edit44_Callback(hObject, eventdata, handles)
% hObject    handle to edit44 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
densityRange = str2num(get(hObject,'String'));

roadLength = str2double(get(handles.pushbutton3,'String'));

initNumCars = round(densityRange(1) * roadLength);
endNumCars = round(densityRange(end) * roadLength);
nCarsRange = initNumCars:1:endNumCars;
RealDensityRange = nCarsRange/roadLength;

assert(all(RealDensityRange(end) <= handles.max_density),'wrong max limit of densities. Have to be 0.1562 max');
assert(all(RealDensityRange(1) >= 0),'wrong min limit of densities. have to be positive');
string1 = sprintf(' %.4f',RealDensityRange);
set(hObject, 'String', string1);
if numel(nCarsRange) == 1 && nCarsRange == 0
    handles.numberOfSimRuns_V = 1;
    handles.allCarsNumArray_V = zeros(1,numel(handles.carTypes));
else
    handles.numberOfSimRuns_V = numel(nCarsRange);
    carTypeRatios = str2num(get(handles.edit45,'String'));
    handles.allCarsNumArray_V = zeros(handles.numberOfSimRuns_V,numel(handles.carTypes));
    for k = 1:handles.numberOfSimRuns_V
        for j = 1:numel(handles.carTypes)
            if j == numel(handles.carTypes)
                handles.allCarsNumArray_V(k,j) = nCarsRange(k) - sum(handles.allCarsNumArray_V(k,1:j-1));
            else
                handles.allCarsNumArray_V(k,j) = round(nCarsRange(k)*carTypeRatios(j));
            end
        end
    end
end
guidata(hObject,handles)
% Hints: get(hObject,'String') returns contents of edit44 as text
%        str2double(get(hObject,'String')) returns contents of edit44 as a double


% --- Executes during object creation, after setting all properties.
function edit44_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit44 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit45_Callback(hObject, eventdata, handles)
% hObject    handle to edit45 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit45 as text
%        str2double(get(hObject,'String')) returns contents of edit45 as a double


% --- Executes during object creation, after setting all properties.
function edit45_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit45 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7



function edit46_Callback(hObject, eventdata, handles)
% hObject    handle to edit46 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit46 as text
%        str2double(get(hObject,'String')) returns contents of edit46 as a double


% --- Executes during object creation, after setting all properties.
function edit46_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit46 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton10.
function handles = pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nRuns = handles.numberOfSimRuns_H * handles.numberOfSimRuns_V;
set(hObject, 'String', nRuns);

% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
p = get(hObject,'Value');
if p == 0
    set([ handles.edit],'Enable','off');
    set([ handles.edit8,handles.edit42],'Enable','on');
elseif p == 1
    set([ handles.edit],'Enable','on');
    set([ handles.edit8,handles.edit42],'Enable','off');
end
% Hint: get(hObject,'Value') returns toggle state of radiobutton3


% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
p = get(hObject,'Value');
if p == 0
    set([ handles.edit],'Enable','on');
    set([ handles.edit8,handles.edit42],'Enable','off');
elseif p == 1
    set([ handles.edit],'Enable','off');
    set([ handles.edit8,handles.edit42],'Enable','on');
end
% Hint: get(hObject,'Value') returns toggle state of radiobutton4


% --- Executes on button press in radiobutton10.
function radiobutton10_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
p = get(hObject,'Value');
if p == 0
    set([ handles.edit44],'Enable','off');
    set([ handles.edit43,handles.edit46],'Enable','on');
elseif p == 1
    set([ handles.edit44],'Enable','on');
    set([ handles.edit43,handles.edit46],'Enable','off');
end
% Hint: get(hObject,'Value') returns toggle state of radiobutton10


% --- Executes on button press in radiobutton9.
function radiobutton9_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
p = get(hObject,'Value');
if p == 0
    set([ handles.edit44],'Enable','on');
    set([ handles.edit43,handles.edit46],'Enable','off');
elseif p == 1
    set([ handles.edit44],'Enable','off');
    set([ handles.edit43,handles.edit46],'Enable','on');
end
% Hint: get(hObject,'Value') returns toggle state of radiobutton9


% --- Executes on button press in pushbutton12.
function handles = pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = pushbutton2_Callback(handles.pushbutton2, eventdata, handles);
handles = pushbutton6_Callback(handles.pushbutton6, eventdata, handles);
handles = pushbutton10_Callback(handles.pushbutton10, eventdata, handles);

if get(handles.radiobutton3,'Value') && get(handles.radiobutton4,'Value') == 0
    roadType.H = 1;
else
    roadType.H = 2;
end
if get(handles.radiobutton10,'Value') && get(handles.radiobutton9,'Value') == 0
    roadType.V = 1;
else
    roadType.V = 2;
end

roadDims.Start = [str2num(get(handles.edit5,'String')); str2num(get(handles.edit27,'String'))];
roadDims.End = [str2num(get(handles.edit6,'String')); str2num(get(handles.edit28,'String'))];
roadDims.Width = [str2num(get(handles.edit7,'String')); str2num(get(handles.edit29,'String'))];
roadDims.Length = roadDims.End - roadDims.Start;

plotFlag = get(handles.checkbox8,'Value');
priority = get(handles.checkbox1,'Value');
nIterations = str2double(get(handles.pushbutton1,'String'));
dt = str2double(get(handles.edit2,'String'));

for k = 1:handles.numberOfSimRuns_H
    for l = 1:handles.numberOfSimRuns_V
%         tic
          Arm.H = handles.Arm(k).H;
          Arm.V = handles.Arm(l).V;
          sim(k,l) = run_simulation({handles.roadTypes{roadType.H},...
            handles.roadTypes{roadType.V}},...
            handles.carTypes,...
            Arm,...
            handles.t_rng,...
            plotFlag,...
            priority,...
            roadDims,...
            nIterations,...
            dt);
%         runTime(k,l) = toc;
    end
end
RunTime = handles.t_rng(end);
road = roadDims;
uisave({'dt','RunTime','road','sim'},'var1');

% --- Executes on button press in checkbox8.
function checkbox8_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox8


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
