function varargout = mergets(varargin)
% MERGETS MATLAB code for mergets.fig
%      MERGETS, by itself, creates a new MERGETS or raises the existing
%      singleton*.
%
%      H = MERGETS returns the handle to a new MERGETS or the handle to
%      the existing singleton*.
%
%      MERGETS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MERGETS.M with the given input arguments.
%
%      MERGETS('Property','Value',...) creates a new MERGETS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mergets_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mergets_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mergets

% Last Modified by GUIDE v2.5 20-Nov-2016 20:36:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mergets_OpeningFcn, ...
                   'gui_OutputFcn',  @mergets_OutputFcn, ...
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


% --- Executes just before mergets is made visible.
function mergets_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mergets (see VARARGIN)

% Choose default command line output for mergets
handles.output = hObject;

% create uitable
try
    % define data
    handles.screenSize = get(0,'ScreenSize');
    if ~isempty(varargin)
        currentTs = varargin{1};
        handles.data = {currentTs.name, length(currentTs.label), true};
        handles.parentPosi = varargin{2};
    else
        currentTs = [];
        handles.data = [];
        handles.parentPosi = min(handles.screenSize - 200,1);
    end
    % column names and column format
    colName = {'Training Set Name','Training Set Size','Merge Avaliable'};
    colFormat = {'char','numeric','logical'};
    % create uitable
    handles.tsTable = uitable('Data',handles.data,...
        'ColumnName',colName,...
        'ColumnFormat',colFormat,...
        'ColumnEditable',[false false true],...
        'RowName',[]);
    % set figure position
    handles.mergetsFigure.Position(1) = handles.parentPosi(1)+200;
    handles.mergetsFigure.Position(2) = handles.parentPosi(2)+200;
    % set uitable position
    handles.tsTable.Position(3) = handles.tsTable.Extent(3);
    handles.tsTable.Position(4) = handles.tsTable.Extent(4);
    handles.tsTable.Position(1) = 20;
    handles.tsTable.Position(2) = handles.mergetsFigure.Position(4)-handles.tsTable.Position(4)-10;
    % define training set stack
    handles.tsStack{1} = currentTs;
catch ME
    msg = [ME.message,'Error file:',ME.stack(1).file,'Error function:',...
        ME.stack(1).name,'Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mergets wait for user response (see UIRESUME)
% uiwait(handles.mergetsFigure);


% --- Outputs from this function are returned to the command line.
function varargout = mergets_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in importTsBtn.
function importTsBtn_Callback(hObject, eventdata, handles)
% hObject    handle to importTsBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
try
    [filename,pathname] = uigetfile('*mat','Import Training Set','MultiSelect','on');
    if isequal(filename,0) || isequal(pathname,0)
        return;
    else
        if ~iscell(filename)
            tmp = filename;
            filename = cell(1,1);
            filename{1} = tmp;
        end
        for i = 1 : length(filename)
            ts = open(fullfile(pathname,filename{i}));
            if ~isfield(ts,'tsCheckCode') || ~strcmp(ts.tsCheckCode,'A ts file!')
                msgShow(handles,[filename{i},' is not a training set file!'],'error');
                continue;
            end
            handles.tsStack{length(handles.tsStack)+1} = ts.ts;
            handles.data = cat(1,handles.data,{ts.ts.name,length(ts.ts.label),true});
        end
        set(handles.tsTable,'Data',handles.data);
        oldHeight = handles.tsTable.Position(4);
        handles.tsTable.Position(4) = handles.tsTable.Extent(4);
        handles.mergetsFigure.Position(4) = handles.mergetsFigure.Position(4)...
            + (handles.tsTable.Position(4) - oldHeight);
        handles.tsTable.Position(1) = 20;
        handles.tsTable.Position(2) = handles.mergetsFigure.Position(4)-handles.tsTable.Position(4)-10;
        movegui([handles.parentPosi(1)+200,handles.parentPosi(2)+200]);
    end
catch ME
    msg = [ME.message,'Error file:',ME.stack(1).file,'Error function:',...
        ME.stack(1).name,'Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in saveTsBtn.
function saveTsBtn_Callback(hObject, eventdata, handles)
% hObject    handle to saveTsBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
try
    % create a null training set 
    handles = HandlesMethod.initializeHandles(handles);
    handles = TrainingSet.newTrainingSet(handles);
    % merge training set
    handles.data = get(handles.tsTable,'Data');
    for i = 1 : length(handles.tsStack)
        if handles.data{i,3}
            handles.ts = handles.ts.MergeTrainingSet(handles.tsStack{i});
        end
    end
    % save training set
    TrainingSet.saveTrainingSet(handles);
catch ME
    msg = [ME.message,'Error file:',ME.stack(1).file,'Error function:',...
        ME.stack(1).name,'Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)
% hObject    handle to cancelBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
try
    questAnwer = questdlg('Is sure to quit?','Quit merge training set tool',...
        'Yes','No','Yes');
    if strcmp(questAnwer,'Yes')
        delete(handles.mergetsFigure);
    end
catch ME
    msg = [ME.message,'Error file:',ME.stack(1).file,'Error function:',...
        ME.stack(1).name,'Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end


% --- Executes when user attempts to close mergetsFigure.
function mergetsFigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to mergetsFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
cancelBtn_Callback(hObject, eventdata, handles);
