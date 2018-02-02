function varargout = new_chunk_gui(varargin)
% NEW_CHUNK_GUI MATLAB code for new_chunk_gui.fig
%      NEW_CHUNK_GUI, by itself, creates a new NEW_CHUNK_GUI or raises the existing
%      singleton*.
%
%      H = NEW_CHUNK_GUI returns the handle to a new NEW_CHUNK_GUI or the handle to
%      the existing singleton*.
%
%      NEW_CHUNK_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NEW_CHUNK_GUI.M with the given input arguments.
%
%      NEW_CHUNK_GUI('Property','Value',...) creates a new NEW_CHUNK_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before new_chunk_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to new_chunk_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help new_chunk_gui

% Last Modified by GUIDE v2.5 04-Apr-2017 15:08:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @new_chunk_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @new_chunk_gui_OutputFcn, ...
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


% --- Executes just before new_chunk_gui is made visible.
function new_chunk_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to new_chunk_gui (see VARARGIN)

%defining labels
if nargin ~=0
c = findobj('Tag', 'labellist');
c.String = varargin{1};
else
    error('need input parameter, a cell array with a list of possible actions to classify.')    
end
% Choose default command line output for new_chunk_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes new_chunk_gui wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = new_chunk_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%%% OutputFCN
a = findobj('Tag', 'description');
b = findobj('Tag', 'seqlength');
c = findobj('Tag', 'labellist');
outputstruct.seqlen = str2num(b.String);
outputstruct.description = a.String;
outputstruct.label = c.String{c.Value};
varargout{1} = outputstruct;%handles.output;
% The figure can be deleted now
delete(handles.figure1);

function description_Callback(hObject, eventdata, handles)
% hObject    handle to description (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of description as text
%        str2double(get(hObject,'String')) returns contents of description as a double
p = ancestor(hObject,'figure');
p.UserData.description = hObject.Value;

% --- Executes during object creation, after setting all properties.
function description_CreateFcn(hObject, eventdata, handles)
% hObject    handle to description (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function seqlength_Callback(hObject, eventdata, handles)
% hObject    handle to seqlength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of seqlength as text
%        str2double(get(hObject,'String')) returns contents of seqlength as a double

% --- Executes during object creation, after setting all properties.
function seqlength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to seqlength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in labellist.
function labellist_Callback(hObject, eventdata, handles)
% hObject    handle to labellist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns labellist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from labellist


% --- Executes during object creation, after setting all properties.
function labellist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to labellist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%% CloseReqFCN
if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end