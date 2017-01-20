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

% Last Modified by GUIDE v2.5 19-Jan-2017 21:18:52

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
try
    % initialize control
    cttMethod.SetDataGeneratorEnable(handles, false);
    handles.dataPathTxt.String = pwd;
    handles.agmPopmenu.String = {'1';'8';'16'};
    handles.earlystoppingCheckbox.Value = 1;
catch ME
     msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
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
%
try
    filePath = cttMethod.GetDirectory();
    if ~isequal(filePath, 0)
       handles.dataPathTxt.String = filePath;
    end
catch ME
     msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);


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
%
try
    cttMethod.SetDataGeneratorEnable(handles, hObject.Value);
    handles.generateSaveBtn.Enable = 'off';
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);

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
%
try
    cttMethod.SetStatus(handles,'Loading data...','b');
    handles.ciliaData = cttMethod.OpenCiliaData();
    if ~isequal(handles.ciliaData, 0)
        handles.generateSaveBtn.Enable = 'on';
    end
    cttMethod.SetStatus(handles,'Status','black');
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);



function lrTxt_Callback(hObject, eventdata, handles)
% hObject    handle to lrTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
if ~cttMethod.CheckNumeric(hObject.String)
    hObject.String = '0.0001';
end


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
%
if ~cttMethod.CheckNumeric(hObject.String)
    hObject.String = '0.90';
end
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
%
if ~cttMethod.CheckNumeric(hObject.String)
    hObject.String = '0.003';
end
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
%
if ~cttMethod.CheckNumeric(hObject.String)
    hObject.String = '200';
end
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
%
if ~cttMethod.CheckNumeric(hObject.String)
    hObject.String = '128';
end
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
%
try
    % check directory
    rootPath = handles.dataPathTxt.String;
    if exist(fullfile(rootPath,'trainData.mat'), 'file') && ...
            exist(fullfile(rootPath,'trainLabel.mat'), 'file') && ...
            exist(fullfile(rootPath,'trainImageData.mat'), 'file') && ...
            exist(fullfile(rootPath,'valData.mat'), 'file') && ...
            exist(fullfile(rootPath,'valLabel.mat'), 'file') && ...
            exist(fullfile(rootPath,'valImageData.mat'), 'file') && ...
            exist(fullfile(rootPath, 'augmentation.mat'), 'file')
        % set status
        cttMethod.SetStatus(handles, 'Training...', 'b');
        % update number result
        trainLabel = load(fullfile(rootPath, 'trainLabel.mat'));
        trainLabel = trainLabel.label;
        valLabel = load(fullfile(rootPath, 'valLabel.mat'));
        valLabel = valLabel.label;
        handles.trainTotalTxt.String = num2str(length(trainLabel));
        handles.trainTrueTxt.String = num2str(length(find(trainLabel==1)));
        handles.trainFalseTxt.String = num2str(length(find(trainLabel==0)));
        handles.valTotalTxt.String = num2str(length(valLabel));
        handles.valTrueTxt.String = num2str(length(find(valLabel==1)));
        handles.valFalseTxt.String = num2str(length(find(valLabel==0)));
        % pack parameter
        hyperPara = cell(7,1);
        hyperPara{1} = rootPath;
        hyperPara{2} = str2double(handles.lrTxt.String);
        hyperPara{3} = str2double(handles.momentumTxt.String);
        hyperPara{4} = str2double(handles.lrdTxt.String);
        hyperPara{5} = str2double(handles.epochTxt.String);
        hyperPara{6} = str2double(handles.batchsizeTxt.String);
        hyperPara{7} = handles.earlystoppingCheckbox.Value;
        hyperPara = cell2table(hyperPara);
        hpSavePath = fullfile('cnn', 'hyperPara.txt');
        if exist(hpSavePath, 'file')
            delete(hpSavePath);
        end
        writetable(hyperPara, hpSavePath);
        % training
        dos('python cnn\\cnnTrain.py','-echo');
        %read result
        augmentation = load(fullfile(rootPath, 'augmentation.mat'));
        augmentation = augmentation.augmentation; 
        valNum = length(valLabel) / augmentation;
        trainNum = length(trainLabel) / augmentation;
        valPreLabel = py.numpy.load(fullfile(rootPath, 'valLabel.npy'));
        valPreLabel = int8(py.array.array('d', valPreLabel));
        valPreLabel = reshape(valPreLabel, [valNum, augmentation]);
        valPreLabel = mean(valPreLabel,2);
        valPreLabel(valPreLabel >= 0.5) = 1;
        valPreLabel(valPreLabel < 0.5) = 0;
        trainPreLabel = py.numpy.load(fullfile(rootPath, 'trainLabel.npy'));
        trainPreLabel  = int8(py.array.array('d', trainPreLabel ));
        trainPreLabel  = reshape(trainPreLabel , [trainNum, augmentation]);
        trainPreLabel = mean(trainPreLabel,2);
        trainPreLabel(trainPreLabel >= 0.5) = 1;
        trainPreLabel(trainPreLabel < 0.5) = 0;
        % show result
        valLabel = valLabel(1:valNum)';
        trainLabel = trainLabel(1:trainNum)';
        handles.valAcuTxt.String = cttMethod.ConvertStr(mean(valLabel == valPreLabel));
        handles.valFprTxt.String = cttMethod.ConvertStr(mean(valLabel == 0 & valPreLabel == 1));
        handles.valFnrTxt.String = cttMethod.ConvertStr(mean(valLabel == 1 & valPreLabel == 0));
        handles.trainAcuTxt.String = cttMethod.ConvertStr(mean(trainLabel == trainPreLabel));
        handles.trainFprTxt.String = cttMethod.ConvertStr(mean(trainLabel == 0 & trainPreLabel == 1));
        handles.trainFnrTxt.String = cttMethod.ConvertStr(mean(trainLabel == 1 & trainPreLabel == 0));
        % set status
        cttMethod.SetStatus(handles, 'Status', 'black');
    else
        msgShow(handles, ['An invalid directory.', char(13,10)', ...
            'Lack of essential files.'], 'error');
    end
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);     



function valRatioTxt_Callback(hObject, eventdata, handles)
% hObject    handle to valRatioTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~cttMethod.CheckNumeric(hObject.String)
    hObject.String = '0.1';
end
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


% --- Executes on button press in generateSaveBtn.
function generateSaveBtn_Callback(hObject, eventdata, handles)
% hObject    handle to generateSaveBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
try
    cttMethod.SetStatus(handles,'Generating data...','b');
    filePath = cttMethod.GetDirectory();
    if ~isequal(filePath, 0)
        handles.dataPathTxt.String = filePath;
        cttMethod.GenerateTrainAndValData(handles);
        handles.trainBtn.Enable = 'on';
    end
    cttMethod.SetStatus(handles,'Status','black');
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);    
