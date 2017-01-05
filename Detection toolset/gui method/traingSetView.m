function varargout = traingSetView(varargin)
% TRAINGSETVIEW MATLAB code for traingSetView.fig
%      TRAINGSETVIEW, by itself, creates a new TRAINGSETVIEW or raises the existing
%      singleton*.
%
%      H = TRAINGSETVIEW returns the handle to a new TRAINGSETVIEW or the handle to
%      the existing singleton*.
%
%      TRAINGSETVIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRAINGSETVIEW.M with the given input arguments.
%
%      TRAINGSETVIEW('Property','Value',...) creates a new TRAINGSETVIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before traingSetView_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to traingSetView_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help traingSetView

% Last Modified by GUIDE v2.5 14-Dec-2016 16:00:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @traingSetView_OpeningFcn, ...
                   'gui_OutputFcn',  @traingSetView_OutputFcn, ...
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


% --- Executes just before traingSetView is made visible.
function traingSetView_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to traingSetView (see VARARGIN)

% Choose default command line output for traingSetView
handles.output = hObject;

% show black image
handles.imageCursor = 0;
showTsImage(handles);

%
handles.slider2.Enable = 'off';
handles.leftImageTxt.Enable = 'off';

% set view mode
handles.viewmode = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes traingSetView wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = traingSetView_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loadtsBtn.
function loadtsBtn_Callback(hObject, eventdata, handles)
% hObject    handle to loadtsBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
try
    if strcmp(handles.loadtsBtn.String,'Load Training Set')
        [handles,successOpened] = TrainingSet.openTrainingSet(handles,true);
        if successOpened
            % store image
            handles.label = handles.ts.label;
            imageData = handles.ts.data;
            imageSize = ceil(sqrt(size(imageData,1)));
            handles.imageNum = size(imageData,2);
            handles.imageSize = imageSize;
            handles.imageStack = cell(handles.imageNum,1);
            for k = 1 : handles.imageNum
                handles.imageStack{k} = reshape(imageData(:,k,:),...
                    imageSize,imageSize,3);
            end
            % show image
            if isfield(handles,'checkpoint') && handles.checkpoint ~= -1
                answer = questdlg('start over or resume?','','start over','resume',...
                    'resume');
                if strcmp(answer,'start over')
                    handles.imageCursor = 0;
                else
                    handles.imageCursor = handles.checkpoint;
                end
            end
            handles.imageCursor = handles.imageCursor + 1;
            showTsImage(handles);
            % set
            handles.slider2.Enable = 'on';
            handles.leftImageTxt.Enable = 'on';
            handles.slider2.Min = 1;
            handles.slider2.Max = handles.imageNum;
            handles.slider2.SliderStep = [1/handles.imageNum, 0.05];
            handles = updateSlider(handles);
            %
            handles.loadtsBtn.String = 'Save & Quit';
        end
    elseif strcmp(handles.loadtsBtn.String,'Save & Quit')
        % save ts
%         if isequal(handles.label,handles.ts.label)
%             successSaved = true;
%         else
        handles.ts.label = handles.label;
        handles.ts.name = 'noneName';
        handles.ts.savePath = 'noneName';
        handles.checkpoint = handles.imageCursor;
        [handles,successSaved] = TrainingSet.saveTrainingSet(handles);
%         end
        % show black image
        if successSaved
            handles.imageCursor = 0;
            showTsImage(handles);
            %
            handles.slider2.Enable = 'off';
            handles.leftImageTxt.Enable = 'off';
            handles.slider2.Value = 1;
            handles.leftImageTxt.String = num2str(0);
            handles.totalImageTxt.String = num2str(0);
            %
            handles.loadtsBtn.String = 'Load Training Set';
        end
    end
catch ME
    msg = [ME.message,'Error file:',ME.stack(1).file,'Error function:',...
        ME.stack(1).name,'Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in previousImageBtn.
function handles = previousImageBtn_Callback(hObject, eventdata, handles)
% hObject    handle to previousImageBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
try
    handles.imageCursor = handles.imageCursor - 1;
    showTsImage(handles);
    handles = updateSlider(handles);
catch ME
    msg = [ME.message,'Error file:',ME.stack(1).file,'Error function:',...
        ME.stack(1).name,'Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in nextImageBtn.
function handles = nextImageBtn_Callback(hObject, eventdata, handles)
% hObject    handle to nextImageBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
try
    if handles.viewmode
        flag = false;
        while(~flag)
            if handles.imageCursor < handles.imageNum
                handles.imageCursor = handles.imageCursor + 1;
                flag = isequal(handles.imageStack{handles.imageCursor}(:,end,1),...
                    zeros(handles.imageSize,1));
                if flag
                   showTsImage(handles);
                   handles = updateSlider(handles);
                end
            else
                flag = true;
            end
        end
    else
        handles.imageCursor = handles.imageCursor + 1;
        showTsImage(handles);
        handles = updateSlider(handles);
    end
catch ME
    msg = [ME.message,'Error file:',ME.stack(1).file,'Error function:',...
        ME.stack(1).name,'Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in changeLabelBtn.
function handles = changeLabelBtn_Callback(hObject, eventdata, handles)
% hObject    handle to changeLabelBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
try
    handles.label(handles.imageCursor) = xor(...
        handles.label(handles.imageCursor),1);
    showTsImage(handles);
catch ME
    msg = [ME.message,'Error file:',ME.stack(1).file,'Error function:',...
        ME.stack(1).name,'Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function labelText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to labelText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
%
try
   keyPress = get(gcf,'CurrentCharacter');
   if strcmp(keyPress,'j') && handles.imageCursor > 0 && ...
           strcmp(handles.previousImageBtn.Enable, 'on')
       handles = previousImageBtn_Callback(hObject, eventdata, handles);
   elseif strcmp(keyPress,'k') && handles.imageCursor < handles.imageNum &&...
           strcmp(handles.nextImageBtn.Enable, 'on')
       handles = nextImageBtn_Callback(hObject, eventdata, handles);
   elseif strcmp(keyPress,'c') && handles.imageCursor ~= 0
       handles = changeLabelBtn_Callback(hObject, eventdata, handles);
   elseif strcmp(keyPress,'r') || strcmp(keyPress,'t') ...
           && isequal(handles.viewmode,1)
       handles = reshapeImage(handles,keyPress);
   elseif strcmp(keyPress,'d')
       handles = deleteImage(handles);
   end 
catch ME
    msg = [ME.message,'Error file:',ME.stack(1).file,'Error function:',...
        ME.stack(1).name,'Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);

function slider2_Callback(hObject, eventdata, handles)
%
try
    value = round(handles.slider2.Value);
    handles.imageCursor = value;
    showTsImage(handles);
    handles = updateSlider(handles);
catch ME
    msg = [ME.message,'Error file:',ME.stack(1).file,'Error function:',...
        ME.stack(1).name,'Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);
    
function leftImageTxt_Callback(hObject, eventdata, handles)
%
try
    value = round(str2double(handles.leftImageTxt.String));
    handles.imageCursor = value;
    showTsImage(handles);
    handles = updateSlider(handles);
catch ME
    msg = [ME.message,'Error file:',ME.stack(1).file,'Error function:',...
        ME.stack(1).name,'Error line:',num2str(ME.stack(1).line)];
    msgShow(handles,msg,'error');
end
% Update handles structure
guidata(hObject, handles);

function showTsImage(handles)
if handles.imageCursor == 0
    handles.previousImageBtn.Enable = 'off';
    handles.nextImageBtn.Enable = 'off';
    handles.changeLabelBtn.Enable = 'off';
    handles.labelText.Visible = 'off';
    imshow(zeros(500),[],'Parent',handles.imageAxes);
    imshow(zeros(500), [], 'Parent', handles.colorImageAxes);
else
    handles.previousImageBtn.Enable = 'on';
    handles.nextImageBtn.Enable = 'on';
    handles.changeLabelBtn.Enable = 'on';
    handles.labelText.Visible = 'on';
    % show label
    if handles.label(handles.imageCursor) == 1
        handles.labelText.String = 'TRUE';
        handles.labelText.ForegroundColor = [0,1,0];
    else
        handles.labelText.String = 'FALSE';
        handles.labelText.ForegroundColor = [1,0,0];
    end
    % show image
    img = handles.imageStack{handles.imageCursor};
    if true
        if size(img, 3) == 3
            grayImg = rgb2gray(img);
        end
    end
    imshow(grayImg, [],'Parent',handles.imageAxes);
    imshow(img, [], 'Parent', handles.colorImageAxes);
    if handles.imageCursor == 1
        handles.previousImageBtn.Enable = 'off';
    elseif handles.imageCursor == handles.imageNum
        handles.nextImageBtn.Enable = 'off';
    end
end

function handles = updateSlider(handles)
handles.slider2.Value = handles.imageCursor;
handles.leftImageTxt.String = num2str(handles.imageCursor);
handles.totalImageTxt.String = num2str(handles.imageNum);

function handles = reshapeImage(handles, keypress)
img = handles.imageStack{handles.imageCursor};
medimg = medfilt2(img(:,:,2),[3,3]);
yPosi = 1;
for k = 20 : size(medimg,2)
    if isequal(medimg(:,k),zeros(handles.imageSize,1))
        yPosi = k;
        break;
    end
end
if strcmp(keypress, 'r')
    img = imresize(img(:,1:yPosi-1,:),[handles.imageSize,handles.imageSize]);
elseif strcmp(keypress,'t')
    img = handles.ts.data(:,handles.imageCursor,:);
    img = reshape(img(1:handles.imageSize * (yPosi-1),:,:),...
        [yPosi-1,handles.imageSize,3]);
    img = imresize(img,[handles.imageSize, handles.imageSize]);
end
handles.imageStack{handles.imageCursor} = img;
showTsImage(handles);
handles.ts.data(:,handles.imageCursor,:) = reshape(img,[handles.imageSize^2,1,3]);

function handles = deleteImage(handles)
k = handles.imageCursor;
handles.imageNum = handles.imageNum - 1;
handles.imageStack(k) = [];
handles.ts.data(:,k,:) = [];
handles.label(k) = [];
showTsImage(handles);
handles = updateSlider(handles);


