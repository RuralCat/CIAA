function varargout = aboutTst(varargin)
% ABOUTTST MATLAB code for aboutTst.fig
%      ABOUTTST, by itself, creates a new ABOUTTST or raises the existing
%      singleton*.
%
%      H = ABOUTTST returns the handle to a new ABOUTTST or the handle to
%      the existing singleton*.
%
%      ABOUTTST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ABOUTTST.M with the given input arguments.
%
%      ABOUTTST('Property','Value',...) creates a new ABOUTTST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before aboutTst_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to aboutTst_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help aboutTst

% Last Modified by GUIDE v2.5 21-Nov-2016 18:32:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @aboutTst_OpeningFcn, ...
                   'gui_OutputFcn',  @aboutTst_OutputFcn, ...
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


% --- Executes just before aboutTst is made visible.
function aboutTst_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to aboutTst (see VARARGIN)

% Choose default command line output for aboutTst
handles.output = hObject;

% %
% if ~isempty(varargin)
%     handles.parentPosi = varargin{1};
%     handles.aboutTstFigure.Position(1) = handles.parentPosi(1)+200;
%     handles.aboutTstFigure.Position(2) = handles.parentPosi(2)+200;
% end
% movegui(handles.aboutTstFigure,[handles.parentPosi(1)+200,handles.parentPosi(2)+200]);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes aboutTst wait for user response (see UIRESUME)
% uiwait(handles.aboutTstFigure);


% --- Outputs from this function are returned to the command line.
function varargout = aboutTst_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
