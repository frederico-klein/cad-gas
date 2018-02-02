function varargout = gui_only_acquire(varargin)
% GUI_ONLY_ACQUIRE MATLAB code for gui_only_acquire.fig
%      GUI_ONLY_ACQUIRE, by itself, creates a new GUI_ONLY_ACQUIRE or raises the existing
%      singleton*.
%
%      H = GUI_ONLY_ACQUIRE returns the handle to a new GUI_ONLY_ACQUIRE or the handle to
%      the existing singleton*.
%
%      GUI_ONLY_ACQUIRE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_ONLY_ACQUIRE.M with the given input arguments.
%
%      GUI_ONLY_ACQUIRE('Property','Value',...) creates a new GUI_ONLY_ACQUIRE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_only_acquire_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_only_acquire_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_only_acquire

% Last Modified by GUIDE v2.5 06-Mar-2017 11:30:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @gui_only_acquire_OpeningFcn, ...
    'gui_OutputFcn',  @gui_only_acquire_OutputFcn, ...
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


% --- Executes just before gui_only_acquire is made visible.
function gui_only_acquire_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_only_acquire (see VARARGIN)

% Choose default command line output for gui_only_acquire
handles.output = hObject;

bootstrapping(hObject, handles)
% UIWAIT makes gui_only_acquire wait for user response (see UIRESUME)
uiwait(handles.gui_acquisition);

function bootstrapping(hObject, handles)
record.state = [0 0];
record.diff = 0;
record.done = 0;

%hObject.UserData.record = record;

p = ancestor(hObject,'figure');
try
    chunk = evalin('base', 'chunk');
catch    
    chunk = createchunk(hObject, handles, '');
end

p.UserData.chunk = chunk; %set(p,'UserData',chunk)

handles.listbox2.String = {p.UserData.chunk.label};

%setting button settings so that things can't be accessed that would cause
%weird errors
setbuttons(handles,'off')

assignin('base', 'record', record);

function setbuttons(handles, what)
handles.togglebutton1.Enable =  what;
handles.up_button.Enable =  what;
handles.down_button.Enable =  what;



% --- Outputs from this function are returned to the command line.
function varargout = gui_only_acquire_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isfield(handles, 'output')
    varargout{1} = handles.output;
end


function gui_acquisition_ClosingFcn(hObject, eventdata, handles, varargin)
stop(vid);
delete(vid);
%%% clear persistent variables
clear vid
%clear TimerData
%clear functions;

function gui_acquisition_DeleteFcn(hObject, eventdata, handles, varargin)
evalin('base', 'clear record');

% --- Executes when user attempts to close gui_only_acquire.
function gui_acquisition_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to gui_only_acquire (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in acquirebutton.
function acquirebutton_Callback(hObject, eventdata, handles)
% hObject    handle to acquirebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ax = gca;
% Update handles structure
guidata(hObject, handles);

% Set-up webcam video input
[vid, src] = startkinect();

%getting parent object to store src obj
p = ancestor(hObject,'figure');
p.UserData.src = src;


%acquirekinect(currax, vid);%(hObject)
%function acquirekinect(ax,vid )
%disp()
setbuttons(handles,'on')
new_chunk = realvideo(hObject, handles, ax, vid, 0);
setbuttons(handles,'off')

% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton1

updaterecordtoggle(handles);

function record = updaterecordtoggle(handles)
%record.done = 0;
try %maybe I've closed the GUI already 
record = evalin('base', 'record');

record.state(1) = record.state(2);
record.state(2) = handles.togglebutton1.Value  ;% get(hObject,'Value');

record.diff = record.state(2) - record.state(1);

assignin('base', 'record', record)

catch
record = [];    
end

function actionEdittext_Callback(hObject, eventdata, handles)
% hObject    handle to actionEdittext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of actionEdittext as text
%        str2double(get(hObject,'String')) returns contents of actionEdittext as a double


% --- Executes during object creation, after setting all properties.
function actionEdittext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to actionEdittext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function gui_acquisition_ButtonDownFcn(hObject, eventdata, handles)

% --- Executes on button press in addButton.
function addButton_Callback(hObject, eventdata, handles)
% hObject    handle to addButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
p = ancestor(hObject,'figure');
p.UserData.chunk(end+1) = createchunk(hObject, handles);
handles.listbox2.String = {p.UserData.chunk.label};


% --- Executes on button press in delButton.
function delButton_Callback(hObject, eventdata, handles)
% hObject    handle to delButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
p = ancestor(hObject,'figure');
index_selected = get(handles.listbox2,'Value');

if size(p.UserData.chunk)==1 %%% doesnt allow chunk to be empty
    p.UserData.chunk(index_selected) = createchunk(hObject, handles);
else
    p.UserData.chunk(index_selected) = [];
end
set(handles.listbox2,'Value',1)
handles.listbox2.String = {p.UserData.chunk.label};

% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2
p = ancestor(hObject,'figure');
index_selected = get(handles.listbox2,'Value');

if strcmp(get(handles.gui_acquisition,'SelectionType'),'open')
    proxyvar = inputdlg('New name of action sequence');
    if ~isempty(proxyvar)
        p.UserData.chunk(index_selected).label = proxyvar{1};
        handles.listbox2.String = {p.UserData.chunk.label};
    end
end
updatetext(p.UserData.chunk(index_selected))


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%% apparently this is not how stuff works, so to start the list with
%%% something sensible is difficult. I will start it with an empty list
%%% then.

%
%
% p = ancestor(hObject,'figure');
% if isempty(p.UserData) %%% I do not know the creation order of objects, so if bootstrapping didnt occur, do it now
%     bootstrapping(hObject, handles)
% end
% hObject.String = {p.UserData.chunk.label};

set(hObject, 'String', {''})


% --- Executes on key press with focus on togglebutton1 and none of its controls.
function togglebutton1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

function [chunk] = realvideo(hObject, handles, ax, vid, realtimevideo)
global VERBOSE
VERBOSE = false;

% Define frame rate
NumberFrameDisplayPerSecond=30;

% Open figure
%hFigure=figure();

record = evalin('base', 'record');

%record = hObject.UserData.record;

% Initialize chunk structure

p = ancestor(hObject,'figure');

% see from which chunk I am acquiring
index_selected = get(handles.listbox2,'Value');

chunk = p.UserData.chunk(index_selected);

% chunksize = 100;
% chunk.chunk = zeros(20,3,chunksize);
% chunk.timers = zeros(1,chunksize, 'uint64');
% chunk.times = zeros(1,chunksize);
% chunk.counter = 0;
% chunk.complete = 0;

%
if realtimevideo
    % set up timer object
    TimerData=timer('TimerFcn', {@FrameRateDisplay, hObject, handles ,ax, vid, chunk},'Period',1/NumberFrameDisplayPerSecond,'ExecutionMode','fixedRate','BusyMode','drop');
end

% Start video and timer object
try %maybe I have already started vid... or failed to stop it?
    start(vid);
catch
    stop(vid);
    start(vid);
end

if realtimevideo
    start(TimerData)
    %     uiwait(hFigure);
end

%%% POOR HACK, SANITIZE THIS!
env = aa_environment;
classfdata = loadfileload('realclassifier',env);



% Clean up everything
if 1
    if exist('TimerData', 'var')
        stop(TimerData);
        %waitfor(TimerData);
        delete(TimerData);
    elseif ~realtimevideo
        %%%%something should update the active chunk!
        while(~record.done&&hObject.Value)%isvalid(p))%~(chunk.complete&&~record.diff==-1)&&isvalid(p)  )
            
            if chunk.complete&&~record.done
                handleshandles = findobj('Tag','togglebutton1');
                set(handleshandles, 'Value',0) %but more stuff is necessary, because togglebutton being set to 0 is not the same as executing the callback of toggle button
                record = updaterecordtoggle(handles);
                %if ~p.UserData.chunk(index_selected).complete
                %%set(p,'UserData(end)',new_chunk)
                p.UserData.chunk(index_selected) = chunk;
                
                %else
                %%set(p,'UserData(end+1)',new_chunk)
                %    p.UserData.chunk(end+1) = chunk;
                %end
                assignin('base', 'chunk', p.UserData.chunk)
                record.done = 1;
                chunk = FrameRateDisplay([], [],hObject, handles ,ax, vid, chunk,1); %%% resets persistent_chunk
            else
                chunk = FrameRateDisplay([], [],hObject, handles, ax, vid, chunk,0);
                %%%
                %maybe classify it as well?
                if 0% chunk.times(1)~=0 %this means that there is at least one skeleton. 
                    handlestext = findobj('Tag','text8'); %% should make it persistent and maybe clean it on the top?
                    allskel3 = generate_skel_online(chunk.chunk);
                    labellabel = online_classifier(classfdata.realclass.outstruct,allskel3, classfdata.realclass.allconn, classfdata.realclass.simvar);
                    handlestext.String = labellabel;
                end
            end
%             if ~isempty(chunk.label) %% for debug...
%                     disp('')
%             else
%                 disp('ismpety now')
%             end
        end
        
        %             if isfield(realclass, 'gases')
        %                 allskel3 = generate_skel_online(chunk.chunk);
        %                 labellabel = online_classifier(realclass.gases,allskel3, realclass.allconn, realclass.simvar);
        %             else
        %                 warning('Old file??')
        %                 allskel3 = generate_skel_online(chunk.chunk);
        %                 labellabel = online_classifier(realclass.outstruct,allskel3, realclass.allconn, realclass.simvar);
        %             end
        
        
        %            assignin('base', 'labels', labellabel)
        
        
        stop(vid);
        pause(1)
        delete(vid);
        % clear persistent variables
        clear functions;
        %clear
    end
end

% This function is called by the timer to display one frame of the figure


function chunk = FrameRateDisplay(obj, event,hObject, handles,ax, vid, chunk, clearchunk)
persistent IM; % im not sure this is necessary
persistent persistent_chunk

if clearchunk
    clear persistent_chunk
    %persistent_chunk = createchunk(hObject, handles,'');
    return
end


if isempty(persistent_chunk)
    persistent_chunk = chunk;
end

%try % yeah, this makes no sense...
trigger(vid);
[IM,~,metaData]=getdata(vid,1,'uint8');

[skelskel, chunk ] = readskeleton(metaData, persistent_chunk);
updaterecordtoggle(handles);
persistent_chunk = chunk;
makeimage(ax, IM, skelskel)
% catch ME
%     ME.getReport
%     return
% end

function [skelskel, chunk ]= readskeleton(metaData,  chunk)%, record)

skelskel = [];
try
    record = evalin('base', 'record');
catch
    %I maybe closed the gui
    return
end
if any(metaData.IsSkeletonTracked)==1
    dbgmsg(strcat('Tracked: ',num2str(sum(metaData.IsSkeletonTracked)),' skeletons.'),0)
    %    dbgmsg(metaData.IsSkeletonTracked,0)
    for i = 1:length(metaData.IsSkeletonTracked)
        if metaData.IsSkeletonTracked(i)==1
            %disp(metaData.JointWorldCoordinates(:,:,i))
            %try
            dbgmsg('Reached inside of loop',0)
            skelskel =  coordshift(skeldraw_(metaData.JointWorldCoordinates(:,:,i),false));
            chunk = get_chunk(metaData, chunk,i);
            if record.state(end) %%%ok I ve got this, if I 
                %%% if I am recording the difference is that the counter
                %%% progresses. If I am not, then I only have the latest 9
                %%% samples, which is still ok for drawing and for online
                %%% classification
                dbgmsg('Recording',0)
                if record.diff
                    dbgmsg('Just started recording!',1)
                    pause(3)
                end               
                updatetext(chunk)
                if chunk.counter >= size(chunk.chunk,3)
                    chunk.complete = 1;                   
                end
            else
                chunk.counter = chunk.counter - 1; %it will acquire and store data, but it will only progress the counter if I am recording. this seems like a simple fix. let's test it
            end
            
            
            % catch ME
            %                 ME.getReport
            %                 size(chunk(:,:,1))
            %                 size(metaData.JointWorldCoordinates(:,:,i))
            %                 find(chunk==0)
            %                 disp(metaData.JointWorldCoordinates(:,:,i))
            %                 error('Something fishy happened') %why error catch if you are goint to break the program??
            %             %end
        end
    end
end
%catch
%    disp('Can''t draw! :/')
%end

function makeimage(myaxes, IM, skelskel)
persistent handlesRaw;
persistent handlesPlot;
persistent handlesmyskel;
%persistent myaxes;
if isempty(handlesRaw)||~isvalid(handlesRaw)
    % if first execution, we create the figure objects
    %subplot(2,1,1);
    handlesRaw=imagesc(IM);
    title('CurrentImage');
    hold on
    % Plot first value
    %Values=mean(IM(:));
    %subplot(2,2,2);
    %handlesPlot=plot(Values);
    %title('Average of Frame');
    %xlabel('Frame number');
    %ylabel('Average value (au)');
    
    %my skeleton
    sampleskel = [0.0697    0.1773    1.6761;
        0.0756    0.2420    1.6839;
        0.0678    0.5732    1.6773;
        0.0010    0.7354    1.5891;
        -0.0791    0.4813    1.7441;
        -0.1515    0.3129    1.4867;
        -0.1649    0.2954    1.2563;
        -0.1067    0.2954    1.2395;
        0.2255    0.4464    1.5866;
        0.2237    0.2958    1.4024;
        -0.0567    0.2926    1.2936;
        -0.1113    0.3175    1.2855;
        0.0002    0.1035    1.7097;
        0.0094   -0.3763    1.6717;
        -0.1009   -0.6928    1.6735;
        -0.1548   -0.7310    1.5964;
        0.1391    0.0965    1.6379;
        0.1254   -0.3289    1.6740;
        0.1750   -0.4106    1.2409;
        0.2620   -0.3947    1.1648];
    
    handlesmyskel = plot3(sampleskel(1,:),-sampleskel(2,:), sampleskel(3,:));
    set(handlesmyskel, 'LineWidth',4, 'Color', 'y');
    %hold off
    %subplot(2,1,2);
    %handlesmyskel=plot([]);
    %    try
    %        [~ , handlesmyskel] = skeldraw(sampleskel,true);
    %    catch
    %        disp('cant initialize axes handle')
    %    end
    myaxes = gca; %get(handlesmyskel,'Parent');
    %set(myaxes, 'color', 'none')
else
    % We only update what is needed
    set(handlesRaw,'CData',IM);
    %Value=mean(IM(:));
    %OldValues=get(handlesPlot,'YData');
    %set(handlesPlot,'YData',[OldValues Value]);
    %%%
    if exist('skelskel','var')&&~isempty(skelskel)
        %plot3(skelskel(1,:),skelskel(2,:), skelskel(3,:))
        %disp('reachedplot')
        set(handlesmyskel, 'XData',skelskel(1,:),'YData',skelskel(2,:),'ZData', skelskel(3,:))
        %set(handlesmyskel,'CData',skelskel)
        set(myaxes,'XLim', [0 640]);
        set(myaxes,'YLim', [0 480]);
        %         set(myaxes,'ZLim', [-0 5]);
        view(0,90);
    end
end

function b =  coordshift(a)
b = zeros(size(a));
b(1,:) = a(1,:)*240 +320;
b(2,:) = -a(2,:)*240 +240;
b(3,:) = a(3,:)*240;

% --- Executes during object creation, after setting all properties.
function gui_acquisition_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gui_only_acquire (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function chunk = createchunk(hObject, handles, varargin)
chunksize = str2num(handles.lengthlength.String);
if isempty(varargin)
    cellvarvar = inputdlg('New for the new action sequence:');
    if ~isempty(cellvarvar)
        chunk.label = cellvarvar{1};
    else
        chunk.label = '';
    end
else
    chunk.label = varargin{1};
end
chunk.chunk = zeros(20,3,chunksize);
chunk.timers = zeros(1,chunksize, 'uint64');
chunk.times = zeros(1,chunksize);
chunk.counter = 0;
chunk.complete = 0;

%%% after creating a chunk I should  update listbox
p = ancestor(hObject,'figure');
if ~isempty(p.UserData) %%% I do not know the creation order of objects, so if bootstrapping didnt occur, do it now
    handles.listbox2.String = {p.UserData.chunk.label};
end


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global VERBOSE
VEBOSE = true;
env = aa_environment;
classfdata = loadfileload('realclassifier',env);
realclass = classfdata.realclass;

p = ancestor(hObject,'figure');

% if ~p.UserData(end).chunk.complete
%     %%set(p,'UserData(end)',new_chunk)
%     p.UserData(end).chunk = new_chunk;
% else
%     %%set(p,'UserData(end+1)',new_chunk)
%     p.UserData(end+1).chunk = new_chunk;
% end

index_selected = get(handles.listbox2,'Value');

new_chunk = p.UserData.chunk(index_selected);

if isfield(realclass, 'gases')
    allskel3 = generate_skel_online(new_chunk);
    labellabel = online_classifier(realclass.gases,allskel3, realclass.allconn, realclass.simvar);
else
    warning('Old file??')
    allskel3 = generate_skel_online(new_chunk);
    %allskel3 = generate_skel_online(new_chunk.chunk);
    labellabel = online_classifier(realclass.outstruct,allskel3, realclass.allconn, realclass.simvar);
end

handlestext = findobj('Tag','text8'); %% should make it persistent and maybe clean it on the top?
handlestext.String = labellabel;

assignin('base', 'chunk', p.UserData.chunk)
assignin('base', 'labels', labellabel)


function lengthlength_Callback(hObject, eventdata, handles)
% hObject    handle to lengthlength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lengthlength as text
%        str2double(get(hObject,'String')) returns contents of lengthlength as a double

p = ancestor(hObject,'figure');

% see from which chunk I am acquiring
index_selected = get(handles.listbox2,'Value');

if p.UserData.chunk(index_selected).complete
    aa = questdlg('Changing this value will overwrite this aquired data sequence. Do you want to do that?');
    if strcmp(aa,'Yes')
        p.UserData.chunk(index_selected) = createchunk(hObject, handles);
    end
end


dbgmsg('Chunk length updated to ',hObject.String,0)

% --- Executes during object creation, after setting all properties.
function lengthlength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lengthlength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in up_button.
function up_button_Callback(hObject, eventdata, handles)
% hObject    handle to up_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
p = ancestor(hObject,'figure');
p.UserData.src.CameraElevationAngle = p.UserData.src.CameraElevationAngle +1;
handles.cameraelevEd.String = num2str(p.UserData.src.CameraElevationAngle);

% --- Executes on button press in down_button.
function down_button_Callback(hObject, eventdata, handles)
% hObject    handle to down_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
p = ancestor(hObject,'figure');

p.UserData.src.CameraElevationAngle = p.UserData.src.CameraElevationAngle -1;
handles.cameraelevEd.String = num2str(p.UserData.src.CameraElevationAngle);


function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to cameraelevEd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cameraelevEd as text
%        str2double(get(hObject,'String')) returns contents of cameraelevEd as a double


% --- Executes during object creation, after setting all properties.
function cameraelevEd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cameraelevEd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if 0%  ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
