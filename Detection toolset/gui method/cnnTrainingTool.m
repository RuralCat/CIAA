function varargout = cnnTrainingTool(varargin)
% CNNTRAININGTOOL MATLAB code for cnnTrainingTool.fig
%      CNNTRAININGTOOL, by itself, creates a new CNNTRAININGTOOL or raises the existing
%      singleton*.
%
%      H = CNNTRAININGTOOL returns the handle to a new CNNTRAININGTOOL or the handle to
%      the existing singleton*.
%
%      CNNTRAININGTOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CNNTRAININGTOOL.M with the given input arguments.
%
%      CNNTRAININGTOOL('Property','Value',...) creates a new CNNTRAININGTOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cnnTrainingTool_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cnnTrainingTool_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cnnTrainingTool

% Last Modified by GUIDE v2.5 19-Jan-2017 19:26:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cnnTrainingTool_OpeningFcn, ...
                   'gui_OutputFcn',  @cnnTrainingTool_OutputFcn, ...
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


% --- Executes just before cnnTrainingTool is made visible.
function cnnTrainingTool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cnnTrainingTool (see VARARGIN)

% Choose default command line output for cnnTrainingTool
handles.output = hObject;

% 
handles.agmPopmenu.String = {'1';'8';'16'};

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes cnnTrainingTool wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = cnnTrainingTool_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in dataPathBtn.
function dataPathBtn_Callback(hObject, eventdata, handles)
% hObject    handle to dataPathBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function dataPathTxt_Callback(hObject, eventdata, handles)
% hObject    handle to dataPathTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dataPathTxt as text
%        str2double(get(hObject,'String')) returns contents of dataPathTxt as a double


% --- Executes during object creation, after setting all properties.
function dataPathTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataPathTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in generateTsCheckbox.
function generateTsCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to generateTsCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of generateTsCheckbox


% --- Executes on selection change in agmPopmenu.
function agmPopmenu_Callback(hObject, eventdata, handles)
% hObject    handle to agmPopmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns agmPopmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from agmPopmenu


% --- Executes during object creation, after setting all properties.
function agmPopmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to agmPopmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loadCiliaDataBtn.
function loadCiliaDataBtn_Callback(hObject, eventdata, handles)
% hObject    handle to loadCiliaDataBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function lrTxt_Callback(hObject, eventdata, handles)
% hObject    handle to lrTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lrTxt as text
%        str2double(get(hObject,'String')) returns contents of lrTxt as a double


% --- Executes during object creation, after setting all properties.
function lrTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lrTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function momentumTxt_Callback(hObject, eventdata, handles)
% hObject    handle to momentumTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of momentumTxt as text
%        str2double(get(hObject,'String')) returns contents of momentumTxt as a double


% --- Executes during object creation, after setting all properties.
function momentumTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to momentumTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lrdTxt_Callback(hObject, eventdata, handles)
% hObject    handle to lrdTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lrdTxt as text
%        str2double(get(hObject,'String')) returns contents of lrdTxt as a double


% --- Executes during object creation, after setting all properties.
function lrdTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lrdTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function epochTxt_Callback(hObject, eventdata, handles)
% hObject    handle to epochTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of epochTxt as text
%        str2double(get(hObject,'String')) returns contents of epochTxt as a double


% --- Executes during object creation, after setting all properties.
function epochTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epochTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function batchsizeTxt_Callback(hObject, eventdata, handles)
% hObject    handle to batchsizeTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of batchsizeTxt as text
%        str2double(get(hObject,'String')) returns contents of batchsizeTxt as a double


% --- Executes during object creation, after setting all properties.
function batchsizeTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to batchsizeTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in earlystoppingCheckbox.
function earlystoppingCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to earlystoppingCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of earlystoppingCheckbox


% --- Executes on button press in trainBtn.
function trainBtn_Callback(hObject, eventdata, handles)
% hObject    handle to trainBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function valRatioTxt_Callback(hObject, eventdata, handles)
% hObject    handle to valRatioTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of valRatioTxt as text
%        str2double(get(hObject,'String')) returns contents of valRatioTxt as a double


% --- Executes during object creation, after setting all properties.
function valRatioTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to valRatioTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in savePathBtn.
function savePathBtn_Callback(hObject, eventdata, handles)
% hObject    handle to savePathBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function savePathTxt_Callback(hObject, eventdata, handles)
% hObject    handle to savePathTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of savePathTxt as text
%        str2double(get(hObject,'String')) returns contents of savePathTxt as a double


% --- Executes during object creation, after setting all properties.
function savePathTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to savePathTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
