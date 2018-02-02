function varargout = gui_gas(varargin)
% GUI_GAS MATLAB code for gui_gas.fig
%      GUI_GAS, by itself, creates a new GUI_GAS or raises the existing
%      singleton*.
%
%      H = GUI_GAS returns the handle to a new GUI_GAS or the handle to
%      the existing singleton*.
%
%      GUI_GAS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_GAS.M with the given input arguments.
%
%      GUI_GAS('Property','Value',...) creates a new GUI_GAS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_gas_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_gas_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_gas

% Last Modified by GUIDE v2.5 02-Feb-2017 13:28:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_gas_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_gas_OutputFcn, ...
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


% --- Executes just before gui_gas is made visible.
function gui_gas_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_gas (see VARARGIN)

% Choose default command line output for gui_gas
%handles.output = hObject;
handles.output = [];


% Update handles structure
guidata(hObject, handles);

global VERBOSE LOGIT TEST
VERBOSE = true;
LOGIT = false;
TEST = false; % set to false to actually run it
%%%% STARTING MESSAGES PART FOR THIS RUN

dbgmsg('=======================================================================================================================================================================================================================================')
dbgmsg('Running starter script')
dbgmsg('=======================================================================================================================================================================================================================================')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

simvar = struct();

env = aa_environment; % load environment variables

handles.figure1.UserData.env = env;

handles.edit26.String = handles.figure1.UserData.env.wheretosavestuff;

% 
simvar.featuresall = 1;
simvar.realtimeclassifier = false;
simvar.generatenewdataset = 1; %true;
simvar.datasettype = 'CAD60'; % datasettypes are 'CAD60', 'tstv2' and 'stickman'
simvar.sampling_type = 'type1';
simvar.activity_type = 'act_type'; %'act_type' or 'act'
simvar.prefilter = 'none'; % 'filter', 'none', 'median?'
simvar.labels_names = []; % necessary so that same actions keep their order number
simvar.TrainSubjectIndexes = 'loo';%[9,10,11,4,8,5,3,6]; %% comment these out to have random new samples
simvar.ValSubjectIndexes = [];%[1,2,7];%% comment these out to have random new samples
simvar.randSubjEachIteration = true;
simvar.extract = {'rand', 'wantvelocity'};
simvar.preconditions = {'nohips', 'normal', 'norotatehips','mirrorx'};% {'nohips', 'norotatehips','mirrorx'}; %
simvar.trialdataname = strcat('skel',simvar.datasettype,'_',simvar.sampling_type,simvar.activity_type,'_',simvar.prefilter, [simvar.extract{:}],[simvar.preconditions{:}]);
simvar.trialdatafile = strcat(env.wheretosavestuff,env.SLASH,simvar.trialdataname,'.mat');

simvar.TEST = TEST; %change this in the beginning of the program
simvar.PARA = 0;
simvar.P = 1;
simvar.NODES_VECT = 1000;
simvar.MAX_EPOCHS_VECT = [1];
simvar.ARCH_VECT = [11];
simvar.MAX_NUM_TRIALS = 1;
simvar.MAX_RUNNING_TIME = 1;%3600*10; %%% in seconds, will stop after this

params.layertype = '';
params.MAX_EPOCHS = [];
params.removepoints = true;
params.PLOTIT = true;
params.RANDOMSTART = true; % if true it overrides the .startingpoint variable
params.RANDOMSET = true; % if true, each sample (either alone or sliding window concatenated sample) will be presented to the gas at random
params.savegas.resume = false; % do not set to true. not working
params.savegas.save = false;
params.savegas.path = env.wheretosavestuff;
params.savegas.parallelgases = true;
params.savegas.parallelgasescount = 0;
params.savegas.accurate_track_epochs = true;
params.savegas.P = simvar.P;
params.startingpoint = [1 2];
params.amax = 50; %greatest allowed age
params.nodes = []; %maximum number of nodes/neurons in the gas
params.en = 0.006; %epsilon subscript n
params.eb = 0.2; %epsilon subscript b
params.gamma = 1; % for the denoising function
params.plottingstep = 0; % zero will make it plot only the end-gas

%Exclusive for gwr
params.STATIC = true;
params.at = 0.95; %activity threshold
params.h0 = 1;
params.ab = 0.95;
params.an = 0.95;
params.tb = 3.33;
params.tn = 3.33;

%Exclusive for gng
params.age_inc                  = 1;
params.lambda                   = 3;
params.alpha                    = .5;     % q and f units error reduction constant.
params.d                           = .99;   % Error reduction factor.

%%%save this stuff in a place convenient to everyone

handles.figure1.UserData.params = params;
handles.figure1.UserData.simvar = simvar;

%     handles.figure1.UserData.simvar.preconditions = updatepreconditions(hObject,handles);

updategui(handles)

if 0% get(hObject,'Value')
    handles.figure1.UserData.simvar

end
% UIWAIT makes gui_gas wait for user response (see UIRESUME)
uiwait(handles.figure1);

function updategui(handles)
%%% this is supposed to update the what the gui shows based on the
%%% variables set at the begining of the program
if isempty(handles.figure1.UserData.params)||isempty(handles.figure1.UserData.simvar )
    error('Initialization variables not set!')    
end
params = handles.figure1.UserData.params;
simvar = handles.figure1.UserData.simvar;

%%% update global variables
global VERBOSE LOGIT TEST
handles.verbose_box.Value = VERBOSE;
handles.logit_box.Value = LOGIT;
handles.test_box.Value = TEST;

%%%update dataset
switch simvar.datasettype
    case 'CAD60'
        handles.radiobutton1.Value = true;
    case 'tstv2'
        handles.radiobutton2.Value = true;
    case 'stickman'
        handles.radiobutton3.Value = true;
    case 'Ext!'
        handles.radiobutton4.Value = true;
    otherwise
        error('weird? dataset choice')
end
%%% update prefiltering
switch simvar.prefilter
    case 'none'
        handles.radiobutton7.Value = true;
    case 'filter'
        handles.radiobutton8.Value = true;
    case 'median'
        handles.radiobutton9.Value = true;
    otherwise
        error('unrecognized filter choice')
end

%%% update randomization type
switch simvar.sampling_type
    case 'type1'
        handles.radiobutton5.Value = true;        
    case 'type2'
        handles.radiobutton6.Value = true; 
    otherwise
        error('unexpected randomization type choice')
end

switch simvar.TrainSubjectIndexes
    case 'loo'
        handles.radiobutton10.Value = true; 
    case 'lno'
        handles.radiobutton11.Value = true;         
    otherwise
        handles.radiobutton12.Value = true;
        %%%this can be improved...
        %error('unexpected ? choice')
end

for i = 1:length(simvar.extract)
    switch simvar.extract{i}
        case 'rand'
            handles.radiobutton15.Value = true;
        case 'seq'
            handles.radiobutton16.Value = true;
        case 'wantvelocity'
            handles.checkbox27.Value = true;
        otherwise
            error('unexpected!')
    end
end


%%% updating preconditions
handles.precond_text.String = writecellas(simvar.preconditions);
for i = 1:length(simvar.preconditions)
    fieldname = simvar.preconditions{i};
    handles.(fieldname).Value = true;
%     switch simvar.preconditions{i}
%         case 'test'
%             
%         case 'highhips'
%             handles.highhips.Value = true;
%         case 'nohips'
%             handles.nohips.Value = true;
%         case 'normal'
%             handles.normal.Value = true;
%         case 'mirrorx'
%             handles.mirrorx.Value = true;
%         case 'mirrory'
%             handles.mirrory.Value = true;
%         case 'mirrorz'
%             handles.mirrorz.Value = true;
%         case 'mahal'
%             dbgmsg('Unimplemented normalization: ', varargin{i} ,true);
%         case 'norotate'
%             handles.norotate.Value = true;
%         case 'norotatehips'
%             handles.norotatehips.Value = true;
%         case 'norotateshoulders'
%             handles.norotateshoulders.Value = true;
%         case 'notorax'
%             handles.notorax.Value = true;
%         case 'nofeet'
%             handles.nofeet.Value = true;
%         case 'nohands'
%             handles.nohands.Value = true;
%         case 'axial'
%             %conformations = [conformations, {@axial}];
%             dbgmsg('Unimplemented normalization: ', varargin{i} ,true);
%         case 'addnoise'
%             handles.addnoise.Value = true;
%         case 'spherical'
%             handles.spherical.Value = true;
%         case 'intostick'
%             handles.intostick.Value = true;
%         case 'intostick2'
%             handles.intostick2.Value = true;
%         otherwise
%             dbgmsg('ATTENTION: Unimplemented normalization/ typo.',varargin{i},true);
%             
%             %%%this can be improved...
%             error('unexpected parameter for .extract ? choice')
%     end
end
%update gas properties
handles.n_nodes.String = simvar.NODES_VECT;
handles.n_epochs.String = simvar.MAX_EPOCHS_VECT;
handles.archarch.String = simvar.ARCH_VECT;

handles.checkbox17.Value = params.removepoints;
handles.checkbox18.Value = params.RANDOMSTART;

handles.checkbox19.Value = params.RANDOMSET;

handles.checkbox20.Value = simvar.PARA;
handles.npargas.String = simvar.P;

handles.checkbox21.Value = params.PLOTIT;

handles.plotstep.String = params.plottingstep;

if isequal(params.plottingstep,0)
    handles.checkbox22.Value = 1;
else
    handles.checkbox22.Value = 0;
end

handles.startpoints.String = params.startingpoint;

handles.mage_ed.String = params.amax;
handles.en_ed.String = params.en;
handles.eb_ed.String = params.eb;
handles.gamma_ed.String = params.gamma;

handles.edit13.String = params.at;
handles.edit14.String = params.h0;
handles.edit15.String = params.ab;
handles.edit16.String = params.an;
handles.edit17.String = params.tb;
handles.edit18.String = params.tn;

handles.checkbox23.Value = params.STATIC;

handles.edit19.String = params.age_inc;
handles.edit20.String = params.lambda;
handles.edit21.String = params.alpha;
handles.edit22.String = params.d;


function preconditions = updatepreconditions(hObject, handles)

if ~isfield(handles.figure1.UserData.simvar, 'preconditions')||isempty(handles.figure1.UserData.simvar.preconditions)
    handles.figure1.UserData.simvar.preconditions = {};
end

%%% if you don't have it at the end, add it
if isempty(handles.figure1.UserData.simvar.preconditions)||~strcmp(handles.figure1.UserData.simvar.preconditions{end},hObject.Tag)
    preconditions = [handles.figure1.UserData.simvar.preconditions {hObject.Tag}];
% elseif  length(handles.figure1.UserData.simvar.preconditions)==1%%% if you have it at the end, you have to remove it ---- wait, if it will result in an empty cell array this is problematic
%     preconditions = {};
else
    preconditions = [handles.figure1.UserData.simvar.preconditions(1:end-1)];
end
handles.precond_text.String = writecellas(preconditions);
%preconditions = [];

function stringstring = writecellas(cellcell)
stringstring = '{';
for i =1:length(cellcell)
    stringstring = [stringstring ' ''' cellcell{i} ''' '];
end
stringstring = [stringstring '}']; 

% --- Outputs from this function are returned to the command line.
function varargout = gui_gas_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

%%%this is weird because argument i receive when running this is empty and
%%%the hObject handle is deleted, so isvalid() gives me a zero. I think
%%%this is an implementation issue, as I can't really output anything here.
%%%I would have to use assignin('base',...) to actually set an output. 

%my solution is not using this. 

%varargout{1} = handles.output; %%%commented out because it errs. 
varargout = '';


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1
if get(hObject,'Value')
handles.figure1.UserData.simvar.datasettype = 'CAD60'; % datasettypes are 'CAD60', 'tstv2' and 'stickman'
end

function n_nodes_Callback(hObject, eventdata, handles)
% hObject    handle to n_nodes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of n_nodes as text
%        str2double(get(hObject,'String')) returns contents of n_nodes as a double

handles.figure1.UserData.simvar.NODES_VECT = str2double(get(hObject,'String'));%1000;

% --- Executes during object creation, after setting all properties.
function n_nodes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to n_nodes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function n_epochs_Callback(hObject, eventdata, handles)
% hObject    handle to n_epochs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of n_epochs as text
%        str2double(get(hObject,'String')) returns contents of n_epochs as a double
handles.figure1.UserData.simvar.MAX_EPOCHS_VECT = str2double(get(hObject,'String'));%1000;


% --- Executes during object creation, after setting all properties.
function n_epochs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to n_epochs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function archarch_Callback(hObject, eventdata, handles)
% hObject    handle to archarch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of archarch as text
%        str2double(get(hObject,'String')) returns contents of archarch as a double
handles.figure1.UserData.simvar.ARCH_VECT = str2double(get(hObject,'String'));%1000;


% --- Executes during object creation, after setting all properties.
function archarch_CreateFcn(hObject, eventdata, handles)
% hObject    handle to archarch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox17.
function checkbox17_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox17
%if hObject.Value
    handles.figure1.UserData.params.removepoints = hObject.Value;
%else
%end

% --- Executes on button press in checkbox18.
function checkbox18_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    handles.figure1.UserData.params.RANDOMSTART = hObject.Value;

% Hint: get(hObject,'Value') returns toggle state of checkbox18
if hObject.Value
    handles.startpoints.Enable = false;
else
    handles.startpoints.Enable = true;
end
% --- Executes on button press in checkbox19.
function checkbox19_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox19
    handles.figure1.UserData.params.RANDOMSET = hObject.Value;


% --- Executes on button press in checkbox20.
function checkbox20_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox20
    handles.figure1.UserData.simvar.PARA = hObject.Value;

if hObject.Value
    handles.npargas.Enable = 'on';
else
    handles.npargas.Enable = 'off';
end


function npargas_Callback(hObject, eventdata, handles)
% hObject    handle to npargas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of npargas as text
%        str2double(get(hObject,'String')) returns contents of npargas as a double
    handles.figure1.UserData.simvar.P = str2double(get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function npargas_CreateFcn(hObject, eventdata, handles)
% hObject    handle to npargas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox21.
function checkbox21_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox21
    handles.figure1.UserData.params.PLOTIT = hObject.Value;


% --- Executes on button press in nohips.
function nohips_Callback(hObject, eventdata, handles)
% hObject    handle to nohips (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of nohips
    handles.figure1.UserData.simvar.preconditions = updatepreconditions(hObject,handles);


% --- Executes on button press in highhips.
function highhips_Callback(hObject, eventdata, handles)
% hObject    handle to highhips (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of highhips
    handles.figure1.UserData.simvar.preconditions = updatepreconditions(hObject,handles);


% --- Executes on button press in normal.
function normal_Callback(hObject, eventdata, handles)
% hObject    handle to normal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of normal
    handles.figure1.UserData.simvar.preconditions = updatepreconditions(hObject,handles);


% --- Executes on button press in mirrorx.
function mirrorx_Callback(hObject, eventdata, handles)
% hObject    handle to mirrorx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of mirrorx
    handles.figure1.UserData.simvar.preconditions = updatepreconditions(hObject,handles);


% --- Executes on button press in mirrory.
function mirrory_Callback(hObject, eventdata, handles)
% hObject    handle to mirrory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of mirrory
    handles.figure1.UserData.simvar.preconditions = updatepreconditions(hObject,handles);


% --- Executes on button press in mirrorz.
function mirrorz_Callback(hObject, eventdata, handles)
% hObject    handle to mirrorz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of mirrorz
    handles.figure1.UserData.simvar.preconditions = updatepreconditions(hObject,handles);


% --- Executes on button press in norotate.
function norotate_Callback(hObject, eventdata, handles)
% hObject    handle to norotate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of norotate
    handles.figure1.UserData.simvar.preconditions = updatepreconditions(hObject,handles);


% --- Executes on button press in norotatehips.
function norotatehips_Callback(hObject, eventdata, handles)
% hObject    handle to norotatehips (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of norotatehips
    handles.figure1.UserData.simvar.preconditions = updatepreconditions(hObject,handles);


% --- Executes on button press in norotateshoulders.
function norotateshoulders_Callback(hObject, eventdata, handles)
% hObject    handle to norotateshoulders (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of norotateshoulders
    handles.figure1.UserData.simvar.preconditions = updatepreconditions(hObject,handles);


% --- Executes on button press in notorax.
function notorax_Callback(hObject, eventdata, handles)
% hObject    handle to notorax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of notorax
    handles.figure1.UserData.simvar.preconditions = updatepreconditions(hObject,handles);


% --- Executes on button press in nohands.
function nohands_Callback(hObject, eventdata, handles)
% hObject    handle to nohands (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of nohands
    handles.figure1.UserData.simvar.preconditions = updatepreconditions(hObject,handles);


% --- Executes on button press in nofeet.
function nofeet_Callback(hObject, eventdata, handles)
% hObject    handle to nofeet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of nofeet
    handles.figure1.UserData.simvar.preconditions = updatepreconditions(hObject,handles);


% --- Executes on button press in addnoise.
function addnoise_Callback(hObject, eventdata, handles)
% hObject    handle to addnoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of addnoise
    handles.figure1.UserData.simvar.preconditions = updatepreconditions(hObject,handles);


% --- Executes on button press in spherical.
function spherical_Callback(hObject, eventdata, handles)
% hObject    handle to spherical (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of spherical
    handles.figure1.UserData.simvar.preconditions = updatepreconditions(hObject,handles);


% --- Executes on button press in intostick.
function intostick_Callback(hObject, eventdata, handles)
% hObject    handle to intostick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of intostick
    handles.figure1.UserData.simvar.preconditions = updatepreconditions(hObject,handles);


% --- Executes on button press in intostick2.
function intostick2_Callback(hObject, eventdata, handles)
% hObject    handle to intostick2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of intostick2
    handles.figure1.UserData.simvar.preconditions = updatepreconditions(hObject,handles);


% --- Executes on button press in radiobutton10.
function radiobutton10_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton10

if get(hObject,'Value')
    handles.figure1.UserData.simvar.TrainSubjectIndexes = 'loo';%[9,10,11,4,8,5,3,6]; %% comment these out to have random new samples
    handles.figure1.UserData.simvar.ValSubjectIndexes = [];%[1,2,7];%% comment these out to have random new samples
end


function mage_ed_Callback(hObject, eventdata, handles)
% hObject    handle to mage_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mage_ed as text
%        str2double(get(hObject,'String')) returns contents of mage_ed as a double
handles.figure1.UserData.params.amax = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function mage_ed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mage_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function en_ed_Callback(hObject, eventdata, handles)
% hObject    handle to en_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of en_ed as text
%        str2double(get(hObject,'String')) returns contents of en_ed as a double
handles.figure1.UserData.params.en = str2double(get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function en_ed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to en_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eb_ed_Callback(hObject, eventdata, handles)
% hObject    handle to eb_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eb_ed as text
%        str2double(get(hObject,'String')) returns contents of eb_ed as a double
handles.figure1.UserData.params.eb = str2double(get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function eb_ed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eb_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gamma_ed_Callback(hObject, eventdata, handles)
% hObject    handle to gamma_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gamma_ed as text
%        str2double(get(hObject,'String')) returns contents of gamma_ed as a double
handles.figure1.UserData.params.gamma = str2double(get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function gamma_ed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gamma_ed (see GCBO)
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



function plotstep_Callback(hObject, eventdata, handles)
% hObject    handle to plotstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of plotstep as text
%        str2double(get(hObject,'String')) returns contents of plotstep as a double
    handles.figure1.UserData.params.plottingstep = hObject.Value;


% --- Executes during object creation, after setting all properties.
function plotstep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plotstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox22.
function checkbox22_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox22
if  hObject.Value
    handles.figure1.UserData.params.plottingstep = 0;
else
    handles.figure1.UserData.params.plottingstep = handles.figure1.plotstep.Value;
end



function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double
handles.figure1.UserData.params.at = str2double(get(hObject,'String'));


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



function startpoints_Callback(hObject, eventdata, handles)
% hObject    handle to startpoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startpoints as text
%        str2double(get(hObject,'String')) returns contents of startpoints as a double
handles.figure1.UserData.params.startingpoint = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function startpoints_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startpoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox24.
function checkbox24_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox24



function edit24_Callback(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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



function edit23_Callback(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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



function edit22_Callback(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit22 as text
%        str2double(get(hObject,'String')) returns contents of edit22 as a double
handles.figure1.UserData.params.d = str2double(get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function edit22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
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
handles.figure1.UserData.params.alpha = str2double(get(hObject,'String'));


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



function edit20_Callback(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit20 as text
%        str2double(get(hObject,'String')) returns contents of edit20 as a double
handles.figure1.UserData.params.lambda = str2double(get(hObject,'String'));


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



function edit19_Callback(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit19 as text
%        str2double(get(hObject,'String')) returns contents of edit19 as a double
handles.figure1.UserData.params.age_inc = str2double(get(hObject,'String'));


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



function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double
handles.figure1.UserData.params.h0 = str2double(get(hObject,'String'));


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
handles.figure1.UserData.params.ab = str2double(get(hObject,'String'));


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



function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double
handles.figure1.UserData.params.an = str2double(get(hObject,'String'));


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

% Hints: get(hObject,'String') returns contents of edit17 as text
%        str2double(get(hObject,'String')) returns contents of edit17 as a double
handles.figure1.UserData.params.tb = str2double(get(hObject,'String'));


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



function edit18_Callback(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit18 as text
%        str2double(get(hObject,'String')) returns contents of edit18 as a double
handles.figure1.UserData.params.tn = str2double(get(hObject,'String'));


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


% --- Executes on button press in checkbox23.
function checkbox23_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox23
handles.figure1.UserData.params.STATIC = get(hObject,'Value');


% --- Executes on button press in checkbox25.
function checkbox25_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox25
if get(hObject,'Value')
    handles.edit26.Enable = true;
else
    handles.edit26.Enable = false;
end


function edit26_Callback(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit26 as text
%        str2double(get(hObject,'String')) returns contents of edit26 as a double
handles.figure1.UserData.env.wheretosavestuff = handles.edit26.String;

env = handles.figure1.UserData.env;
simvar = handles.figure1.UserData.simvar;

simvar.trialdataname = strcat('skel',simvar.datasettype,'_',simvar.sampling_type,simvar.activity_type,'_',simvar.prefilter, [simvar.extract{:}],[simvar.preconditions{:}]);
simvar.trialdatafile = strcat(env.wheretosavestuff,env.SLASH,simvar.trialdataname,'.mat');

handles.figure1.UserData.simvar = simvar;

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


% --- Executes on button press in checkbox26.
function checkbox26_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox26


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
classifier_loop(handles.figure1.UserData.simvar,handles.figure1.UserData.params, handles.figure1.UserData.env)

% --- Executes on button press in checkbox27.
function checkbox27_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox27
setextract(handles)


% --- Executes on button press in radiobutton13.
function radiobutton13_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton13


% --- Executes on button press in radiobutton14.
function radiobutton14_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton14


% --- Executes on button press in verbose_box.
function verbose_box_Callback(hObject, eventdata, handles)
% hObject    handle to verbose_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global VERBOSE 
VERBOSE = hObject.Value;
% Hint: get(hObject,'Value') returns toggle state of verbose_box


% --- Executes on button press in logit_box.
function logit_box_Callback(hObject, eventdata, handles)
% hObject    handle to logit_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of logit_box
global LOGIT
LOGIT = hObject.Value;

% --- Executes on button press in test_box.
function test_box_Callback(hObject, eventdata, handles)
% hObject    handle to test_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of test_box
global TEST
TEST = hObject.Value;


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2
if get(hObject,'Value')
    handles.figure1.UserData.simvar.datasettype = 'tstv2'; % datasettypes are 'CAD60', 'tstv2' and 'stickman'
end


% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3
if get(hObject,'Value')
    handles.figure1.UserData.simvar.datasettype = 'stickman'; % datasettypes are 'CAD60', 'tstv2' and 'stickman'
end


% --- Executes on button press in radiobutton7.
function radiobutton7_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton7
if get(hObject,'Value')
    handles.figure1.UserData.simvar.prefilter = 'none'; % 'filter', 'none', 'median?'
end
    


% --- Executes on button press in radiobutton8.
function radiobutton8_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton8
if get(hObject,'Value')
    handles.figure1.UserData.simvar.prefilter = 'filter'; % 'filter', 'none', 'median?'
end


% --- Executes on button press in radiobutton9.
function radiobutton9_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton9
if get(hObject,'Value')
    handles.figure1.UserData.simvar.prefilter = 'median?'; % 'filter', 'none', 'median?'
end


% --- Executes on button press in radiobutton5.
function radiobutton5_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton5
if get(hObject,'Value')
    handles.figure1.UserData.simvar.sampling_type = 'type1';

end


% --- Executes on button press in radiobutton6.
function radiobutton6_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton6
if get(hObject,'Value')
    handles.figure1.UserData.simvar.sampling_type = 'type2';

end


% --- Executes on button press in radiobutton17.
function radiobutton17_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton17
if get(hObject,'Value')
    handles.figure1.UserData.simvar.activity_type = 'act_type'; %'act_type' or 'act'
end


% --- Executes on button press in radiobutton18.
function radiobutton18_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton18
if get(hObject,'Value')
    handles.figure1.UserData.simvar.activity_type = 'act'; %'act_type' or 'act'
end


% --- Executes on button press in radiobutton11.
function radiobutton11_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton11


%%%%%% this has to be changed. the way i am passing parameters is
%%%%%% horrible!!!
if get(hObject,'Value')
    handles.figure1.UserData.simvar.TrainSubjectIndexes = 'lno';%[9,10,11,4,8,5,3,6]; %% comment these out to have random new samples
    handles.figure1.UserData.simvar.ValSubjectIndexes = [];%[1,2,7];%% comment these out to have random new samples
end


% --- Executes on button press in radiobutton12.
function radiobutton12_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton12
if get(hObject,'Value')
    handles.figure1.UserData.simvar.TrainSubjectIndexes = '';%[9,10,11,4,8,5,3,6]; %% comment these out to have random new samples
    handles.figure1.UserData.simvar.ValSubjectIndexes = [];%[1,2,7];%% comment these out to have random new samples

end


% --- Executes on button press in radiobutton15.
function radiobutton15_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton15
setextract(handles)


% --- Executes on button press in radiobutton16.
function radiobutton16_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton16
setextract(handles)

function setextract(handles)
if handles.radiobutton15.Value
    if handles.checkbox27.Value
        handles.figure1.UserData.simvar.extract = {'rand', 'wantvelocity'};
    else
        handles.figure1.UserData.simvar.extract = {'rand'};
    end
elseif handles.radiobutton16.Value
    if handles.checkbox27.Value
        handles.figure1.UserData.simvar.extract = {'seq', 'wantvelocity'};
    else
        handles.figure1.UserData.simvar.extract = {'seq'};
    end
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


% --- Executes on button press in checkbox33.
function checkbox33_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox33
