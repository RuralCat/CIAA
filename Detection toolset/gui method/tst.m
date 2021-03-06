function varargout = tst(varargin)
% tst MATLAB code for tst.fig
%      tst, by itself, creates a new tst or raises the existing
%      singleton*.
%
%      H = tst returns the handle to a new tst or the handle to
%      the existing singleton*.
%
%      tst('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in tst.M with the given input arguments.
%
%      tst('Property','Value',...) creates a new tst or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tst_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tst_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tst

% Last Modified by GUIDE v2.5 15-Dec-2016 18:33:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tst_OpeningFcn, ...
                   'gui_OutputFcn',  @tst_OutputFcn, ...
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

% --- Executes just before tst is made visible.
function tst_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tst (see VARARGIN)

% Choose default command line output for tst
handles.output = hObject;

try
    % set default parameters
    handles = HandlesMethod.initializeHandles(handles);
    handles = HandlesMethod.setFigureName(handles,'Untitled Training Set');
    % show a black image
    handles = LabelMethod.showImage(handles,zeros(1000));
    LabelMethod.showCiliaImage(handles,-1);
%     LabelMethod.showCiliaFeatrue(handles,-1);
    waitbarImage = ones(30,250);
    waitbarImage(1,:) = 0; waitbarImage(end,:) = 0;
    waitbarImage(:,1) = 0; waitbarImage(:,end) = 0;
    imshow(waitbarImage,'Parent',handles.waitbarAxes);
    if ispc
        progressbarImage= ones(30,300);
        progressbarImage(1:2,:) = 0; progressbarImage(end-1:end,:) = 0;
        progressbarImage(:,1) = 0; progressbarImage(:,end) = 0;
    elseif ismac
        progressbarImage= ones(30,300);
        progressbarImage(1,:) = 0; progressbarImage(end,:) = 0;
        progressbarImage(:,1) = 0; progressbarImage(:,end) = 0;
    end
    imshow(progressbarImage,'Parent',handles.progressbarAxes);
    % create new training set
    handles = TrainingSet.newTrainingSet(handles);
    % create a waitbar
    handles.waitbar = embedWaitbar(0,'No Image',handles.uipanel3,...
        handles.waitbarAxes.Position,handles.waitbarStatusTxt);
    handles.progressbar = embedWaitbar(0,'',handles.uipanel1,...
        handles.progressbarAxes.Position);
    % set control status
    controlStatus.setImageBtn(handles,{'on','off','off','off'});
    set(handles.startLabelBtn,'string','Start Analysis');
    controlStatus.setTxt(handles);
    controlStatus.setOperationMenu(handles,true);
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes tst wait for user response (see UIRESUME)
% uiwait(handles.tstFigure);


% --- Outputs from this function are returned to the command line.
function varargout = tst_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.tstFigure)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.tstFigure,'Name') '?'],...
                     ['Close ' get(handles.tstFigure,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.tstFigure)

% --------------------------------------------------------------------
function fileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to fileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function newtsMenu_Callback(hObject, eventdata, handles)
% hObject    handle to newtsMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
try
    if handles.isExistTs && ~TrainingSet.tsIsSaved(handles)
        isNewQues = questdlg(['Current training set has not been saved.',...
            'Is it sure to continue creating new training set?'],'New Training Set',...
            'Yes', 'No', 'No');
        if strcmp(isNewQues,'No')
            return;
        end
    end
    handles = HandlesMethod.initializeHandles(handles);
    handles = TrainingSet.newTrainingSet(handles);
    handles = LabelMethod.showImage(handles,zeros(500));
    handles = LabelMethod.showCiliaImage(handles);
    controlStatus.setTxt(handles);
    controlStatus.setImageBtn(handles,{'on','off','off','off'});
    handles = HandlesMethod.setFigureName(handles,'Untitled Training Set');
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);


% --------------------------------------------------------------------
function opentsMenu_Callback(hObject, eventdata, handles)
% hObject    handle to opentsMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
try
    [handles, successOpened] = TrainingSet.openTrainingSet(handles);
    if successOpened
        handles.tsCursor = length(handles.ts.label);
        handles = HandlesMethod.setFigureName(handles,handles.ts.name);
        controlStatus.setTxt(handles);
    end
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);

% --------------------------------------------------------------------
function handles = savetsMenu_Callback(hObject, eventdata, handles)
% hObject    handle to savetsMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
try
    [handles, successSaved] = TrainingSet.saveTrainingSet(handles);
    if successSaved
        handles = HandlesMethod.setFigureName(handles,handles.ts.name);
    end
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);

% --------------------------------------------------------------------
function saveasMenu_Callback(hObject, eventdata, handles)
% hObject    handle to saveasMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
try
    oldName = handles.ts.name;
    handles.ts.name = 'noneName';
    [handles, successSaved] = TrainingSet.saveTrainingSet(handles);
    if successSaved
        handles = HandlesMethod.setFigureName(handles,handles.ts.name);
    else
        handles.ts.name = oldName;
    end
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);


% --------------------------------------------------------------------
function operationMenu_Callback(hObject, eventdata, handles)
% hObject    handle to operationMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mergetsMenu_Callback(hObject, eventdata, handles)
% hObject    handle to mergetsMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
try
    uiwait(mergets(handles.ts, handles.tstFigure.Position)); 
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);


% --------------------------------------------------------------------
function helpMenu_Callback(hObject, eventdata, handles)
% hObject    handle to helpMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function trainingSetView_Callback(hObject, eventdata, handles)
% hObject    handle to trainingSetView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
try
    uiwait(traingSetView); 
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);

% --------------------------------------------------------------------
function cnnTrainingTool_Callback(hObject, eventdata, handles)
% hObject    handle to trainingSetView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
try
    uiwait(cnnTrainingTool); 
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in startLabelBtn.
function startLabelBtn_Callback(hObject, eventdata, handles)
% hObject    handle to startLabelBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
try
    if handles.totalImage == 0
        return;
    end
    startBtnStatus = get(handles.startLabelBtn,'string');
    if strcmp(startBtnStatus,'Start Analysis')
        % change button string
        set(handles.startLabelBtn,'string','End Analysis');
        % create a report
        handles.report = ReportMethod.createNewReport(handles);
        % move image's cursor
        handles.imageCursor = handles.imageCursor + 1;
        handles = ImageMethod.processCurrentImage(handles);
        handles = LabelMethod.showImage(handles, handles.image);
        handles.ciliaShowIdx = 1;
        handles = LabelMethod.showCiliaImage(handles);
        % change btn status
        if handles.totalImage > 1
            hasNextImage = 'on';
        else
            hasNextImage = 'off';
        end
        controlStatus.setImageBtn(handles,{'off','on',...
                hasNextImage, 'on'});
        controlStatus.setTxt(handles);
        % set image path text
        handles.imagePathTxt.String = handles.imageStack{handles.imageCursor};
    else
        set(handles.startLabelBtn,'string','Start Analysis');
        % save current ts
        if handles.haveCilia
            handles.ts = handles.ts.MergeTrainingSet(TrainingSet(handles));
        end
        % add current image infomation to report
        handles = ReportMethod.addToCurrentReport(handles);
        % move ts cursor
        handles.tsCursor = handles.tsCursor + handles.roiNum;
        % show first image in image stack
        handles.imageCursor = 0;
        handles = HandlesMethod.initializeImage(handles);
        handles = LabelMethod.showImage(handles, handles.imageStack{1});
        LabelMethod.showCiliaImage(handles,-1);
        % set image path text
        handles.imagePathTxt.String = handles.imageStack{1};
        % save
        handles = savetsMenu_Callback(hObject, eventdata, handles);
        % change btn status
        controlStatus.setImageBtn(handles,{'on','on','off','off'});
        controlStatus.setTxt(handles);
    end
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structur e
guidata(hObject, handles);

% --- Executes on button press in nextImageBtn.
function handles = nextImageBtn_Callback(hObject, eventdata, handles)
% hObject    handle to nextImageBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
try
    % save ts buffer
    if handles.haveCilia
        handles.ts = handles.ts.MergeTrainingSet(TrainingSet(handles));
    end
    % add current image infomation to report
    handles = ReportMethod.addToCurrentReport(handles);
    % move ts cursor
    handles.tsCursor = handles.tsCursor + handles.roiNum;
    handles = HandlesMethod.initializeImage(handles);
    % move image cursor
    handles.imageCursor = handles.imageCursor + 1;
    % show next image
    handles = LabelMethod.showImage(handles,handles.imageStack{handles.imageCursor});
    % process image
    handles = ImageMethod.processCurrentImage(handles);
    % set image path text
    handles.imagePathTxt.String = handles.imageStack{handles.imageCursor};
    % change btn status
    if isequal(handles.imageCursor, handles.totalImage)
        hasNextImage = 'off';
    else
        hasNextImage = 'on';
    end
    controlStatus.setImageBtn(handles,{'off','on',hasNextImage,'on'});
    controlStatus.setTxt(handles);
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in previousImageBtn.
function previousImageBtn_Callback(hObject, eventdata, handles)
% hObject    handle to previousImageBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
try
    % read buffer
    ts = handles.tsBuffer;
    handles.roiNum = ts.tsNum;
    handles.roiPosition = ts.tsPosition;
    handles.roiRegion = ts.tsRegion;
    handles.data = ts.data;
    handles.label = ts.label;
    % move ts cursor
    handles.tsCursor = handles.tsCursor - handles.roiNum;
    % show next image
    handles.imageCursor = handles.imageCursor - 1;
    handles = LabelMethod.showImage(handles,handles.imageStack{handles.imageCursor});
    % show cilia in axes
    for i = 1 : handles.roiNum
        handles = LabelMethod.showCilia(handles,i);
    end
    % change btn status
    controlStatus.setImageBtn(handles,{'off','on','on','off','on','on'});
    controlStatus.setTxt(handles);
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in importImageBtn.
function importImageBtn_Callback(hObject, eventdata, handles)
% hObject    handle to importImageBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 
try
    handles = LabelMethod.importImage(handles);
    if handles.totalImage > 0
        % init
        handles = HandlesMethod.initializeImage(handles);
        handles = LabelMethod.showImage(handles,handles.imageStack{1});
        % set image path text
        handles.imagePathTxt.String = handles.imageStack{1};
        controlStatus.setTxt(handles);
        controlStatus.setImageBtn(handles,{'on','on','off','off'});
    end
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on selection change in imModePopmenu.
function imModePopmenu_Callback(hObject, eventdata, handles)
% hObject    handle to agmPopmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
try
    handles = LabelMethod.showImage(handles, handles.image, hObject.Value);
catch ME
	msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end

% Update handles structure
guidata(hObject, handles);


% --- Executes when user attempts to close tstFigure.
function tstFigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to tstFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 
try
    if ~isfield(handles,'ts')
        delete(hObject);
    else
        if ~TrainingSet.tsIsSaved(handles)
            questAnswer = questdlg(['Do you want to save modified ',handles.ts.name,'?'],...
                'Quit Training Set Tool','Yes', 'No', 'Cancel','Cancel');
           switch questAnswer
               case 'Yes'
                    [~, successSaved] = TrainingSet.saveTrainingSet(handles);
                    if successSaved
                        delete(hObject);
                    else
                        return;
                    end
               case 'No'
                   delete(hObject);
               case 'Cancel'
                   return;
           end
        else
            % Hint: delete(hObject) closes the figure
            delete(hObject);
        end
    end
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end


% --- Executes on mouse press over axes background.
function imageAxes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to imageAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
try
    if strcmp(get(handles.startLabelBtn,'Enable'),'off') || ...
            strcmp(get(handles.startLabelBtn,'string'),'Start Analysis')
        return;
    end
    curPoint = get(gca,'CurrentPoint');
    x = max(floor(curPoint(1,2)),1);
    y = max(floor(curPoint(1,1)),1);
    idx = handles.roiRegion(x,y);
    if isequal(idx,0) return; end
    selectionType = get(gcbf,'SelectionType');
    switch selectionType
        case 'normal'
            handles.label(idx) = xor(handles.label(idx),1);
            handles = LabelMethod.showCilia(handles,idx);    
        case 'alt'
            handles.label(idx) = min(bitxor(handles.label(idx),2),2);
            handles = LabelMethod.showCilia(handles,idx);
        case 'open'
            handles.label(idx) = xor(handles.label(idx),1);
            handles = LabelMethod.showCilia(handles,idx);  
            handles.ciliaShowIdx = idx;
            handles = LabelMethod.showCiliaImage(handles);
    end
catch ME
	msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in changeLabelModeBtn.
function changeLabelModeBtn_Callback(hObject, eventdata, handles)
% hObject    handle to changeLabelModeBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
try
    if handles.labelMode == 1
        handles.labelMode = 0;
    else
%         set(handles.changeLabelModeBtn,'string','Label True');
        handles.labelMode = 1;
    end
    handles.label(:) = handles.labelMode;
    LabelMethod.showAllCilia(handles);
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in skipImageBtn.
function skipImageBtn_Callback(hObject, eventdata, handles)
% hObject    handle to skipImageBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
try
    handles.label(:) = 2;
    handles = nextImageBtn_Callback(hObject, eventdata, handles);
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);


% --------------------------------------------------------------------
function viewHelp_Callback(hObject, eventdata, handles)
% hObject    handle to viewHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
try
    open('CIAA Help.html');
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);


% --------------------------------------------------------------------
function aboutTst_Callback(hObject, eventdata, handles)
% hObject    handle to aboutTst (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
try
    uiwait(aboutTst(handles.tstFigure.Position));
end


% --- Executes on button press in showRectCheckbox.
function showRectCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to showRectCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showRectCheckbox
%
try
    if strcmp(handles.startLabelBtn.String,'Start Analysis')
        return;
    end
    LabelMethod.showAllCilia(handles);
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in showOutlineCheckbox.
function showOutlineCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to showOutlineCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showOutlineCheckbox
%
try
    if strcmp(handles.startLabelBtn.String,'Start Analysis')
        return;
    end
    LabelMethod.showAllCilia(handles);
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in showLenCheckbox.
function showLenCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to showLenCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showLenCheckbox
%
try
    if strcmp(handles.startLabelBtn.String,'Start Analysis')
        return;
    end
    LabelMethod.showAllCilia(handles);
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in addCiliaBtn.
function addCiliaBtn_Callback(hObject, eventdata, handles)
% hObject    handle to addCiliaBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
try
    if strcmp(handles.addCiliaBtn.String,'Add Cilia')
        % set btn status
        hasNext = handles.nextImageBtn.Enable;
        controlStatus.setImageBtn(handles,{'off','off','off','off'});
        [pointX,pointY] = getpts(handles.imageAxes);
        pointX = min(max(pointX,1),handles.imageH);
        pointY = min(max(pointY,1),handles.imageW);
        pointX = pointX(end);
        pointY = pointY(end);
        % find cilia
        idx = handles.bwCiliaRegion(round(pointY),round(pointX));
        if idx~=0 && isempty(find(handles.ciliaIdx == idx, 1))
            % update handles
            handles.roiNum = handles.roiNum + 1;
            handles.ciliaIdx = cat(2,handles.ciliaIdx,idx);
            k = handles.roiNum;
            handles.label = cat(2,handles.label,handles.labelMode);
            handles.parentImage = cat(2, handles.parentImage, handles.imageCursor);
            [handles,data] = CiliaMethod.getCiliaRegion(handles,handles.roiPosition,k);
%             data = reshape(data,[size(data,1),1,3]);
            handles.data = cat(2,handles.data,data);
            % compute cilia length
            im = im2double(handles.image);
            handles.autoAnalysisTime = cat(2, handles.autoAnalysisTime, 0);
            handles.manualAnalysisTime = cat(2, handles.manualAnalysisTime, 0);
            if size(im, 3) == 3
                if isequal(handles.imageMode, 'r')
                    histIm = imagePreProcessing(im(:,:,1));
                else
                    histIm = imagePreProcessing(im(:,:,2));
                end
            else
                histIm = imagePreProcessing(im);
            end
            tic;
            handles = CiliaMethod.computeCiliaLength(handles, histIm, ...
                handles.roiPosition, k);
            handles.autoAnalysisTime(k) = handles.autoAnalysisTime(k) + toc;
            if isequal(handles.imageMode, 'merged')
                histIm = imagePreProcessing(im(:,:,1));
                tic;
                handles = CiliaMethod.computeOuterCiliaLength(handles, ...
                    histIm, handles.roiPosition, k);
                handles.autoAnalysisTime(k) = handles.autoAnalysisTime(k) + toc;
            end
            % create show handle
            handles = CiliaMethod.createShowHandle(handles, handles.roiPosition, k);
            % show new cilia
            LabelMethod.showCilia(handles,k);
            handles.ciliaShowIdx = k;
            handles = LabelMethod.showCiliaImage(handles);
        end
        % set btn status
        controlStatus.setImageBtn(handles,{'off','on',hasNext,'off','on',hasNext,'on','on'});
    else
    end
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in previousCiliaBtn.
function previousCiliaBtn_Callback(hObject, eventdata, handles)
% hObject    handle to previousCiliaBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
try
    handles.ciliaShowIdx = handles.ciliaShowIdx - 1;
    handles = LabelMethod.showCiliaImage(handles);
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in nextCiliaBtn.
function nextCiliaBtn_Callback(hObject, eventdata, handles)
% hObject    handle to nextCiliaBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
try
    handles.ciliaShowIdx = handles.ciliaShowIdx + 1;
    handles = LabelMethod.showCiliaImage(handles);
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in correctBtn.
function correctBtn_Callback(hObject, eventdata, handles)
% hObject    handle to correctBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
try
    if strcmp(handles.correctBtn.String,'Correct')
        tic;
        handles.freehand = imfreehand(handles.ciliaAxes,'Closed',false);
        handles.ciliaSkeCorrectTime = toc;
        handles.correctBtn.String = 'Cancel';
        handles.okBtn.Enable = 'on';
    else
        delete(handles.freehand);
        handles.correctBtn.String = 'Correct';
        handles.okBtn.Enable = 'off';
    end
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in okBtn.
function okBtn_Callback(hObject, eventdata, handles)
% hObject    handle to okBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
try
    % get skeleton position
    position = getPosition(handles.freehand);
    idx = handles.ciliaShowIdx;
    % compute cilia length
    len = 0;
    for k = 1 : size(position,1)-1
        len = len + sqrt(sum((position(k,:)-position(k+1,:)).^2,2));
    end
    handles.showLengthHandle{idx}.String = num2str(len);
    % show skeleton
%     LabelMethod.showCiliaImage(handles, idx);
    delete(handles.skeletonHandle);
    hold(handles.ciliaAxes,'on');
    handles.skeletonHandle = plot(handles.ciliaAxes,...
        position(:,1), position(:,2), 'r', 'LineWidth', 0.01);
    hold(handles.ciliaAxes,'off');
    % update cilia information
    box = handles.roiPosition(handles.ciliaIdx(idx),:);
    xStart = max(box(1) - ceil(handles.padFactor * box(5)), 1);
    yStart = max(box(2) - ceil(handles.padFactor * box(6)), 1);
    imType = handles.imModePopmenu.String{handles.imModePopmenu.Value};
    if isequal(imType, 'Merged') || isequal(imType, 'FITC') || ...
            (strcmp(imType, 'Cy3') && strcmp(handles.imageMode, 'Cy3'))
        handles.skeleton{idx} = [position(:,2) + xStart, position(:,1) + yStart];
        handles.manualCiliaLength(idx) = len;
    elseif isequal(imType, 'Cy3')
        handles.outerSkeleton{idx} = [position(:,2) + xStart,position(:,1) + yStart];
        handles.manualOuterCiliaLength(idx) = len;
    end
    handles.manualAnalysisTime(idx) = handles.manualAnalysisTime(idx) ...
        + handles.ciliaSkeCorrectTime;
    % set btn status
    delete(handles.freehand);
    handles.correctBtn.String = 'Correct';
    handles.okBtn.Enable = 'off';
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);

% --- Execute on button press in zoomInBtn
function zoomInBtn_Callback(hObject, eventdata, handles)
%
try
    idx = handles.ciliaShowIdx;
    handles.padFactor = max(handles.padFactor - 0.3, 0.0);
    handles = LabelMethod.showCiliaImage(handles, idx);
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);

% --- Execute on button press in zoomOutBtn
function zoomOutBtn_Callback(hObject, eventdata, handles)
%
try
    idx = handles.ciliaShowIdx;
    handles.padFactor = handles.padFactor + 0.3;
    handles = LabelMethod.showCiliaImage(handles, idx);
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);

function snrThresTxt_Callback(hObject, eventdata, handles)
% hObject    handle to snrThresTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
try
    % get changed snr threshold value
    value = str2double(handles.snrThresTxt.String);
    if isnan(value)
        masShow(handles,'SNR Threshold must be a number!','error');
    else
        % snr threshold in [0.0, 3.0]
        if value < handles.snrSlider.Min
            value = handles.snrSlider.Min;
        elseif value > handles.snrSlider.Max
            value = handles.snrSlider.Max;
        end
        % set value to text and slider
        handles.snrThresTxt.String = num2str(value);
        handles.snrSlider.Value = value;
        % display cilia
        handles.snrThreshold = value;
        handles = LabelMethod.changeSlider(handles);
    end
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function snrThresTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to snrThresTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function snrSlider_Callback(hObject, eventdata, handles)
% hObject    handle to snrSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
try
    % get changed snr threshold value
    value = handles.snrSlider.Value;
    handles.snrThresTxt.String = num2str(value);
    % display cilia
    handles.snrThreshold = value;
    handles = LabelMethod.changeSlider(handles);
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function snrSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to snrSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function directionThresTxt_Callback(hObject, eventdata, handles)
% hObject    handle to directionThresTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
try
    % get changed snr threshold value
    value = str2double(handles.directionThresTxt.String);
    if isnan(value)
        masShow(handles,'SNR Threshold must be a number!','error');
    else
        % snr threshold in [0.0, 3.0]
        if value < handles.directionSlider.Min
            value = handles.directionSlider.Min;
        elseif value > handles.directionSlider.Max
            value = handles.directionSlider.Max;
        end
        % set value to text and slider
        handles.directionThresTxt.String = num2str(value);
        handles.directionSlider.Value = value;
        % display cilia
        handles.directionThreshold = value;
        handles = LabelMethod.changeSlider(handles);
    end
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function directionThresTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to directionThresTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function directionSlider_Callback(hObject, eventdata, handles)
% hObject    handle to directionSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
try
    % get changed snr threshold value
    value = handles.directionSlider.Value;
    handles.directionThresTxt.String = num2str(value);
    % display cilia
    handles.directionThreshold = value;
    % detect cilia
    handles = LabelMethod.changeSlider(handles);
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function directionSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to directionSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Excutes on button press
function cnnPredictBtn_Callback(hObject, eventdata, handles)
% hObject handle to cnnPredictBtn
% eventdata
% handles structure with handles and user data
%
try 
    % get all candidate cilia data
    h = waitbar(0, 'Cilia CNN Prediction...','WindowStyle','modal');
    ciliaNum = length(handles.candidateCiliaIdx);
    bbox = handles.roiPosition(handles.candidateCiliaIdx,:);
    smallCiliaData = cell(1, 2*ciliaNum);
    bigCiliaData = cell(1, 2*ciliaNum);
    for k = 1 : ciliaNum
        [smallCiliaData{k}, smallCiliaData{k+ciliaNum}] = ...
            CiliaMethod.getCiliaTrainingRegion(handles.image, bbox(k,:), 45, 0.4);
        [bigCiliaData{k}, bigCiliaData{k+ciliaNum}] = ...
            CiliaMethod.getCiliaTrainingRegion(handles.image, bbox(k,:), 79, 1.0);
    end
    CiliaMethod.deleteShowHandle(handles);
    % augment data and run python script
    dataAugmentation(smallCiliaData, -1, 'cnn\\', 'test');
    dataAugmentation(bigCiliaData, -1, 'cnn\\', 'image');
    waitbar(0.1);
    system('python cnn\\cnnPredict.py');
    % load saved label's file
    count = 0;
    while(1)
        pause(1);
        count = count + 1;
        waitbar(0.1 + min(count, 10) * 0.07);
        if exist('cnn\\label.npy','file')
            waitbar(0.8);
            label = py.numpy.load('cnn\\label.npy');
            label = int8(py.array.array('d', label));
            delete('cnn\\label.npy');
            break;
        end
    end
    % get cilia idx
    waitbar(0.9);
    handles.ciliaIdx = handles.candidateCiliaIdx(label == 1);
    % delete old show handle
    CiliaMethod.deleteShowHandle(handles);
    % compute and show
    handles.labelMode = 1; % show all cilia true
    handles = LabelMethod.computeAndShowCilia(handles);
    waitbar(1);
    close(h);
    clc;
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);

% Min nuclei area text -- callback function
function minNucleiAreaTxt_Callback(hObject, eventdata, handles)
%
try
    handles = NucleiMethod.deleteNucleiHandle(handles);
    handles = NucleiMethod.detectNuclei(handles);
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);

% Nuclei's edge factor text -- callback function
function edgeFactorTxt_Callback(hObject, eventdata, handles)
%
try
    handles = NucleiMethod.deleteNucleiHandle(handles);
    handles = NucleiMethod.detectNuclei(handles);
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);

% if show nuclei's outline
function showNucleiCheckbox_Callback(hObject, eventdata, handles)
%
try
    handles = NucleiMethod.showNucleiBound(handles);
catch ME
    msg = [ME.message,char(13,10)','Error file:',ME.stack(1).file,char(13,10)','Error function:',...
        ME.stack(1).name,char(13,10)','Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);


