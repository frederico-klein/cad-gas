function [pp,A] = skeldraw(varargin)
%makes a beautiful skeleton of the 75 dimension vector
%or the 25x3 skeleton or random crazy skeletons of the 25 points type...
%will improve to draw the 20 point one...
% plot the nodes
%reconstruct the nodes from the 75 dimension vector. each 3 is a point
%I use the NaN interpolation to draw sticks which is much faster!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%MESSAGES PART
%dbgmsg('This function is very often called in drawing functions and this message will cause serious slowdown.',1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
drawconditions = [];
markers = false;
skel = varargin{1};
doIdraw = true;
numofthinskels = [];
wheretoclip = [];
pp = [];
skelldef = struct([]);
drawcolor = winter;

if nargin>1&&islogical(varargin{2})
    doIdraw = varargin{2};
elseif nargin >1
    for i= 2:nargin
        if ~isnumeric(varargin{i})&&ischar(varargin{i})
            switch varargin{i}
                case 'f'
                    drawconditions = 'single_fat';
                case 't'
                    drawconditions = 'single_thinskel';
                case 'rt'
                    drawconditions = 'row_of_thinskels';
                case 'ts'
                    drawconditions = 'tensor_skels';
                case 'm'
                    markers = true;
                case 'mt'
                    drawconditions = 'strip_of_thinskels';
                case 'W'
                    drawcolor = @winter;
                case 'A'
                    drawcolor = @autumn;
                otherwise
                    error('unknow parameter')
            end
        elseif isnumeric(varargin{i})
            numofthinskels = varargin{i};
        elseif isstruct(varargin{i})
            skelldef = varargin{i};
            skel = reconstructskel(skel,skelldef);
            wheretoclip = skelldef.hh/2; 
        end
    end
end

if isempty(skelldef)
    warning('NO SKELETON DEFINITIONS! Will try to guess parameters, but maybe something will go wrong!')
end


%%% I know hacks make your life hell, but...
% there is no way around this. everyone will receive fat 2 skeletons so
% that we can draw the pretty thing.
if isempty(drawconditions)
    if size(skel,3)==1 %%it will fail for a single fat skeleton, bt nothing is perfect...
        if size(skel,2) ~=1
            drawconditions = 'row_of_thinskels';
        else
            drawconditions = 'single_thinskel';
        end
    else
        drawconditions = 'tensor_skels';
    end
end

%%% break in parallelism here, maybe some bad programming, but this is
%%% easier:
if strcmp('strip_of_thinskels', drawconditions)
        if isempty(numofthinskels)
            error('You must define number of thin skeletons so that I know how to chop them up. I am not a mind reader.')
        else
            %%%creates row of thinskels
            skel = reshape(skel, [],numofthinskels*size(skel,2)); %%%ideally it would create 2 separate entinties united with NaNs, right?
            %%% sets drawconditions to 'row_of_thinskels'
            drawconditions = 'row_of_thinskels';
        end
end

switch drawconditions
    case 'row_of_thinskels'
        [A,cellA, tdskel] = makeA_ver1(skel,wheretoclip);
    case 'tensor_skels'
        [A,cellA, tdskel] = makeA_ver3(skel,wheretoclip);
    case 'single_thinskel'
        [A,cellA, tdskel] = makeA_ver2(skel,wheretoclip); 
    case 'single_fat'
        [A,cellA, tdskel] = makeA_ver2(makethinskel(skel),wheretoclip);
end

if doIdraw
    hold_initialstate = ishold();
    hold on
    if markers
        for ll = 1:2            
            pp = plot3(tdskel(:,1,ll), tdskel(:,2,ll), tdskel(:,3,ll),'.y','markersize',15); view(0,0); axis equal;            
            for k=1:25 % I used this to make the drawings, but now I think it looks cool and I don't want to remove it
                text(tdskel(k,1,ll), tdskel(k,2,ll), tdskel(k,3,ll),num2str(k))
            end
        end
    end
    
    mycmap = colormap( gca ,drawcolor(size(cellA,2)));
    try
        pp = plot3(cellA{:});
        
    catch
        plotA = [cellA{:}];
        pp = plot3(plotA{:});
    end
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
    for i = 1: length(pp)
        pp(i).Color = mycmap(i,:);
    end
        
    hold off
    if hold_initialstate == 1
        hold on
    end
    
end

end
function [A,cellA, tdskel] = makeA_ver1(skel,wheretoclip)
A = [];
cellA = [];
for i = 1:(size(skel,2)-1)
    tdskel = cat(3, makefatskel(skel(:,i)),makefatskel(skel(:,i+1)));
    [AA,cellAA] = constructA(remove_excess(tdskel, wheretoclip));
    cellA = cat(2, cellA, {cellAA}); % I perhaps should use the fast way, but I am lazy, so I may do this in the future
    A = cat(2, A, AA);
end
end
function [A,cellA, tdskel] = makeA_ver2(skel,wheretoclip)
tdskel = cat(3,makefatskel(skel),makefatskel(skel));
[A,cellA] = constructA(remove_excess(tdskel, wheretoclip));
%%% only markers if drawing a single skeleton
%markers = true;
end
function [A,cellA, tdskel] = makeA_ver3(skel,wheretoclip)
A = [];
cellA = [];
for i =1:(size(skel,3)-1)
    %%% has to be separated into groups of 2
    tdskel = cat(3,skel(:,:,i),skel(:,:,i+1));
    [AA,cellAA] = constructA(remove_excess(tdskel,wheretoclip));
    cellA = cat(2, cellA, {cellAA}); % I perhaps should use the fast way, but I am lazy, so I may do this in the future
    A = cat(2, A, AA);
end
end
function tdskel = remove_excess(tdskel,wheretoclip)
%check size of tdskel
% there are many different possibilities here, but the size might be enough
% to tell what is happening
%if > 50 then it has to have small paths. I will draw just the first
%then...
%if == 49 then it has velocities, I will also take those out
if ~isempty(wheretoclip)
    tdskel = tdskel(1:wheretoclip,:,:);
else
    if size(tdskel,1) > 25
        %have to remove all the n*25 parts from the end
        wheretoclip = mod(size(tdskel,1),25);
        if wheretoclip==0
            wheretoclip = 25;
        end
        tdskel = tdskel(1:wheretoclip,:,:);
    end
    
    if size(tdskel,1) == 15||size(tdskel,1) == 20, return, end %%% this will start to get very ambiguous for multiple sensor types
    
    %%%%this should receive skelldef
    if size(tdskel,1) == 24
        tdskel = cat(1,repmat([0 0 0 ],1,1,size(tdskel,3)),tdskel); % maybe it is a multidimensional array
        %tdskel = [[0 0 0 ];tdskel]; % for the hips
        %tdskel = [tdskel(1:20,:);[0 0 0 ];tdskel(21:end,:)]; % for the thorax
    elseif size(tdskel,1) < 24
        error('Don''t know what to do weird size :-( ')
    end
end

end
function [A, cellA] = constructA(tdskel)

moresticks = [];

for i=1:size(tdskel,1)
    moresticks = cat(2,moresticks,[tdskel(i,:,1);tdskel(i,:,2); [NaN NaN NaN]]');
end

A1 = stick_draw(tdskel(:,:,1));
A2 = stick_draw(tdskel(:,:,2));

A = [A1 A2 moresticks];

cellA = {A(1,:),A(2,:), A(3,:)};
end

function a = stick_draw(tdskel)
switch size(tdskel,1)
    case 25
        a = stick_draw25(tdskel);
    case 15
        a = another_stick_draw(tdskel);
    case 20
        a = other_stick_draw(tdskel);
    otherwise
        error('strange size of skeleton. no idea what I should do.')
        
end
end
function a = other_stick_draw(tdskel)

a = draw_1_stick(tdskel, 1,2);
a= [a draw_1_stick(tdskel, 2,3)];
a= [a draw_1_stick(tdskel, 3,4)];
a= [a draw_1_stick(tdskel, 3,5)];
a= [a draw_1_stick(tdskel, 5,6)];
a= [a draw_1_stick(tdskel, 6,7)];
a= [a draw_1_stick(tdskel, 7,8)];
a= [a draw_1_stick(tdskel, 3,9)];
a= [a draw_1_stick(tdskel, 9,10)];
a= [a draw_1_stick(tdskel, 10,11)];
a= [a draw_1_stick(tdskel, 11,12)];
a= [a draw_1_stick(tdskel, 1,17)];
a= [a draw_1_stick(tdskel, 17,18)];
a= [a draw_1_stick(tdskel, 18,19)];
a= [a draw_1_stick(tdskel, 19,20)];
a= [a draw_1_stick(tdskel, 1,13)];
a= [a draw_1_stick(tdskel, 13,14)];
a= [a draw_1_stick(tdskel, 14,15)];
a= [a draw_1_stick(tdskel, 15,16)];

end
function a = another_stick_draw(tdskel)
a = draw_1_stick(tdskel, 1,2);
a= [a draw_1_stick(tdskel, 2,4)];
a= [a draw_1_stick(tdskel, 4,5)];
a= [a draw_1_stick(tdskel, 5,12)];
a= [a draw_1_stick(tdskel, 2,6)];
a= [a draw_1_stick(tdskel, 6,7)];
a= [a draw_1_stick(tdskel, 7,13)];
a= [a draw_1_stick(tdskel, 2,3)];
a= [a draw_1_stick(tdskel, 3,10)];
a= [a draw_1_stick(tdskel, 3,8)];
a= [a draw_1_stick(tdskel, 10,11)];
a= [a draw_1_stick(tdskel, 11,15)];
a= [a draw_1_stick(tdskel, 10,8)];
a= [a draw_1_stick(tdskel, 8,9)];
a= [a draw_1_stick(tdskel, 9,14)];
end
function a = stick_draw25(tdskel)
%
%in the end the end the text command upstairs was what did the job and I
%wrote down the connection of the skeleton points
%it is as follows:
% 1-2-21-3 torso
% 3-4 head
%
% 5-6-7 right arm
% 8 22 23 right hand
%
% 9-10-11 left arm
% 12 24 25 left hand
%
% 5-21-9 shoulder
%
% 13-1-17 hip
%
% 13-14-15 right leg
% 15-16 right foot
%
% 17-18-19 left leg
% 19-20 left foot

a = draw_1_stick(tdskel, 1,2);
%draw_1_stick(tdskel, 2,3)
a= [a draw_1_stick(tdskel, 2,21)];
a= [a draw_1_stick(tdskel, 21,3)];
a= [a draw_1_stick(tdskel, 3,4)];

a= [a draw_1_stick(tdskel, 5,21)];
a= [a draw_1_stick(tdskel, 21,9)];
%a= [a draw_1_stick(tdskel, 5,9)]; %%%% just to draw the thorax thing

a= [a draw_1_stick(tdskel, 5,6)];
a= [a draw_1_stick(tdskel, 6,7)];

a= [a draw_1_stick(tdskel, 7,8)]; % unsure

a= [a draw_1_stick(tdskel, 8,22)];
a= [a draw_1_stick(tdskel, 22,23)]; % unsure
a= [a draw_1_stick(tdskel, 8,23)]; % unsure

a= [a draw_1_stick(tdskel, 9,10)];
a= [a draw_1_stick(tdskel, 10,11)];

a= [a draw_1_stick(tdskel, 11,12)]; % unsure
a= [a draw_1_stick(tdskel, 12,24)];
a= [a draw_1_stick(tdskel, 12,25)]; % unsure
a= [a draw_1_stick(tdskel, 24,25)];
a= [a draw_1_stick(tdskel, 13,1)];
a= [a draw_1_stick(tdskel, 1,17)];
a= [a draw_1_stick(tdskel, 13,17)]; % draw a thick hip, because we like hips

a= [a draw_1_stick(tdskel, 13,14)];
a= [a draw_1_stick(tdskel, 14,15)];
a= [a draw_1_stick(tdskel, 15,16)];
a= [a draw_1_stick(tdskel, 17,18)];
a= [a draw_1_stick(tdskel, 18,19)];
a= [a draw_1_stick(tdskel, 19,20)];

end

function A = draw_1_stick(tdskel, i,j)
A = [[tdskel(i,1) tdskel(j,1) NaN]; [tdskel(i,2) tdskel(j,2) NaN]; [tdskel(i,3) tdskel(j,3) NaN]];
end
