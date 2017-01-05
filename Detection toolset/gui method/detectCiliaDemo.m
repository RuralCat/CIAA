function varargout = detectCiliaDemo(varargin)
% DETECTCILIADEMO MATLAB code for detectCiliaDemo.fig
%      DETECTCILIADEMO, by itself, creates a new DETECTCILIADEMO or raises the existing
%      singleton*.
%
%      H = DETECTCILIADEMO returns the handle to a new DETECTCILIADEMO or the handle to
%      the existing singleton*.
%
%      DETECTCILIADEMO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DETECTCILIADEMO.M with the given input arguments.
%
%      DETECTCILIADEMO('Property','Value',...) creates a new DETECTCILIADEMO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before detectCiliaDemo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to detectCiliaDemo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help detectCiliaDemo

% Last Modified by GUIDE v2.5 27-Dec-2016 15:18:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @detectCiliaDemo_OpeningFcn, ...
                   'gui_OutputFcn',  @detectCiliaDemo_OutputFcn, ...
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


% --- Executes just before detectCiliaDemo is made visible.
function detectCiliaDemo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to detectCiliaDemo (see VARARGIN)

%
% show a black image
LabelMethod.showImage(hObject,handles,zeros(500));
handles.showRectCheckbox.Value = 1;
handles.showOutlineCheckbox.Value = 0;
handles.showLenCheckbox.Value = 0;
handles.ts.roiSize = 45;

% Choose default command line output for detectCiliaDemo
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes detectCiliaDemo wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = detectCiliaDemo_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loadImageBtn.
function loadImageBtn_Callback(hObject, eventdata, handles)
% hObject    handle to loadImageBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
handles = LabelMethod.importImage(handles);
if handles.totalImage > 0
    % set default parameters
    handles.imageCursor = 0;
    LabelMethod.showImage(hObject,handles,handles.imageStack{1});
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in detectCiliaBtn.
function detectCiliaBtn_Callback(hObject, eventdata, handles)
% hObject    handle to detectCiliaBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
if handles.totalImage == 0
    return;
end
% detect cilia
handles.imageCursor = handles.imageCursor + 1;
LabelMethod.showImage(hObject,handles,handles.imageStack{handles.imageCursor});
handles = detectCilia(handles);
% CiliaMethod.deleteShowHandle(handles);
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in nextImageBtn.
function nextImageBtn_Callback(hObject, eventdata, handles)
% hObject    handle to nextImageBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function handles = detectCilia(handles)
    % read image
    disp('>> read image');
    imagePath = handles.imageStack{handles.imageCursor};
    handles.image = imread(imagePath);
    handles.imageW = size(handles.image,2);
    handles.imageH = size(handles.image,1);
    % get candidate cilia
    disp('>> get candidate cilia');
    [~, ciliaBox, ciliaIdx] = semiCiliaDetection(imagePath);
    handles.ciliaBox = ciliaBox;
    % get roi position
    disp('>> get cilia roi');
    handles.candidateCiliaNum = length(ciliaIdx);
    handles.ciliaIdx = ciliaIdx;
    bbox = zeros(size(ciliaBox,1),6);
    if handles.candidateCiliaNum > 0
        bbox(:,1) = ciliaBox(:,2);
        bbox(:,2) = ciliaBox(:,1);
        bbox(:,3) = min(ciliaBox(:,2) + ciliaBox(:,4),handles.imageW);
        bbox(:,4) = min(ciliaBox(:,1) + ciliaBox(:,3),handles.imageH);
        bbox(:,5:6) = bbox(:,3:4) - bbox(:,1:2);
    end
    handles.roiPosition = bbox;
    roiSize = handles.ts.roiSize;
    data = zeros(roiSize*roiSize ,handles.candidateCiliaNum, 3, 'uint8');
    % compute cilia
    for k = 1 : handles.candidateCiliaNum
       [handles, ciliaRegion] =  CiliaMethod.getCiliaRegion(handles, bbox, k);
       data(:,k,:) = ciliaRegion;
    end
    % data augmentation
    disp('>> data augmentation');
    dataAugmentation(data);
    % for test
    disp('>> predict cilia using cnn');
    idx = randperm(handles.candidateCiliaNum);
    sampleSize = min(10,handles.candidateCiliaNum);
    handles.label = zeros(1,handles.candidateCiliaNum);
    handles.label(idx(1:sampleSize)) = 1;
    % read label from py
    idx = find(handles.label == 1);
    handles.ciliaIdx = idx(1:sampleSize);
    handles.label = handles.label(handles.label == 1);
    % show cilia
    disp('>> show cilia');
    ciliaNum = length(handles.ciliaIdx);
    hold(handles.imageAxes,'on'); 
    for k = 1 : ciliaNum
        % rect handle
        handles.showRectHandle{k} = rectangle('parent',handles.imageAxes,...
            'Position',[...
            bbox(handles.ciliaIdx(k),2),...
            bbox(handles.ciliaIdx(k),1),...
            bbox(handles.ciliaIdx(k),6),...
            bbox(handles.ciliaIdx(k),5)],...
            'LineWidth',0.01,'EdgeColor','r','Visible','on',...
            'Tag',num2str(k));
    end
    hold(handles.imageAxes,'off');
    LabelMethod.showAllCilia(handles);
    %%
