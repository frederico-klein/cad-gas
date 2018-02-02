function plotgwr(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%MESSAGES PART
%dbgmsg('Plots gwr (or gng as well). Either in 2 or 3 dimensions. Handles 75 dimension and 72 dimension skeletons gracefully')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin == 0
    theactualplot('','','', '', 'clear')
    return
else
    [A,C, error_vect, epoch_vect, nodes, skelldef, layertype] = varargin{:};
end

%%%%%%%%%%%%%hack to plot 147 dimension vector. I will just discard
%%%%%%%%%%%%%velocity information
if size(A,1) >50 % == 147 || size(A,1) == 150
    A = rebuild(A,skelldef,layertype);
end

[row,col] = find(C);
ax = A(1,row);
ay = A(2,row);
bx = A(1,col);
by = A(2,col);

X = reshape([ax;bx;NaN*ones(size(ax))],size(ax,2)*3,1)'; %based on the idea to use NaNs to break the lines from GnGplot which is faster than what I was doing...
Y = reshape([ay;by;NaN*ones(size(ax))],size(ax,2)*3,1)'; %this shit is verticalllllllllll, thennnnn it gets horizonta----------------

if size(A,1) == 75||size(A,1) == 72|| size(A,1) == 45
    if size(A,1) == 72
        tdskel = zeros(24,3,size(A,2));
        for k = 1:size(A,2)
            for i=1:3
                for j=1:24
                    tdskel(j,i,k) = A(j+24*(i-1),k);
                end
            end
        end
        tdskel = cat(1,zeros(1,3,size(A,2)), tdskel);     
    else
        %%%this is a reshape...
        aaaa= size(A,1)/3;
        tdskel = zeros(aaaa,3,size(A,2));
        for k = 1:size(A,2)
            for i=1:3
                for j=1:aaaa
                    tdskel(j,i,k) = A(j+aaaa*(i-1),k);
                end
            end
        end
    end
    if 0%all(size(tdskel) ~= [25 3 size(A,2)])
        error('wrong skeleton building procedure!')
    end
    %q = size(squeeze(tdskel(1,:,row)),2);
    
    %quattro = cat(4, tdskel(:,:,row),tdskel(:,:,col));
    moresticks = [];
    
    %moresticks = zeros(3,3*size(row));
    for i=1:size(tdskel,1)
        for j=1:size(row)
            moresticks = cat(2,moresticks,[tdskel(i,:,row(j));tdskel(i,:,col(j)); [NaN NaN NaN]]');
        end
    end
    
    [~, SK] = skeldraw(A(:,1),false);
    for i = 2:size(A,2)
        intermedskel = skeldraw(A(:,i),false);
        SK = [SK intermedskel];
    end
    T = [SK moresticks];
    
    % make A into a sequence of 3d points
    A = threedeeA(A);
    theactualplot(A', error_vect, epoch_vect, nodes, T(1,:),T(2,:),T(3,:))
elseif size(A,1)>=3&&size(A,1)<75&&size(A,1)~=72
    az = A(3,row);
    bz = A(3,col);
    Z = reshape([az;bz;NaN*ones(size(ax))],size(ax,2)*3,1)';
    theactualplot(A, error_vect, epoch_vect, nodes, X, Y, Z)   
else
    theactualplot(A, error_vect, epoch_vect, nodes, X, Y)
 
end
end
function AA = rebuild(A, skelldef, layertype) %it should work with all the Nx3 stuff I have, but who knows...
a = size(A,1)/3;
c = size(A,2);

switch layertype
    case 'pos'
        assumed_q = a/(size(skelldef.pos,2)/3);
    case 'vel'
        assumed_q = a/(size(skelldef.vel,2)/3);
    case 'all'
         if a > 25&&((size(skelldef.elementorder,2))<=a) % maybe this is useless
             assumed_q = a/size(skelldef.elementorder,2)*3;
         else
             assumed_q = 1;
             disp('Warning. Unexpected condition while reshaping skeletons.')
         end
end

B = reshape(A,ceil(a/assumed_q),3,[]); %%%after I will have to put it back as a normal skeleton
%needtoputback = reshape(skelldef.realkilldim,[],3);
if a == 49
    %this was apparently working, so I will not change
    
    A = B(1:24,:,:);
    AA = reshape(A,72,c);
    return
else    
    %knowing q would help, but I don't need it. 
    
    AA = zeros(skelldef.length/6,3,c*assumed_q) ;%this is wrong and it will break. I need in the skeldef a variable telling me how many points are there in my skeleton originally (either 25 or 20)
    switch layertype
        case 'pos'
            AA(skelldef.elementorder(1:a/assumed_q),:,:) = B;
            AA = reshape(AA,skelldef.length/2,c*assumed_q);
            return
        case 'vel'
             ini = size(skelldef.pos,2)/3+1;
             een = size(skelldef.vel,2)/3+ini-1;
             AA(skelldef.elementorder(ini:een)-skelldef.length/6,:,:) = B;
             AA = reshape(AA,skelldef.length/2,c*assumed_q);
            %AA = B;
         case 'all'
            a = size(skelldef.pos,2);
            AA(skelldef.elementorder(1:a/3),:,:) = B(1:a/3,:,:);
            %%%no idea what I wanted with the following line. I will change
            %%%to what I think is right...
            %AA(skelldef.elementorder(1:a/assumed_q),:,:) = B(1:a/assumed_q,:,:);
            %BB = AA(1:skelldef.length/6,:,:);
            AA = reshape(AA,[],c*assumed_q);
            %%% Wait, no double work, let us be smart about this// ok,
            %%% being smart is not so smart, because separating the data is
            %%% a hassle... this is also probably why the thing on top is
            %%% not working
            %             VEL_ini = size(skelldef.pos,2)/3+1;
            %             VEL_een = size(skelldef.vel,2)/3+VEL_ini-1;
            %
            %             fatA = makefatskel(A);
            %             serialfatA = makeserial(fatA, skeldef);
            %             posA = serialfatA(1:VEL_ini-1,:
            %             A_pos = rebuild(A, skelldef, 'pos');
            %             A_vel = rebuild(A, skelldef, 'vel');
            
        otherwise
            
            error('unknown layer type.')
    end
    %disp('Strange skelleton definition... hope I work for this size')
end

 
end
function theactualplot(A, error_vect, epoch_vect, nodes, varargin)
persistent hdl_main hdl_main_p hdl_error hdl_nodes axmain %axmaincopy

if strcmp(varargin{1},'clear')
    clear hdl_main hdl_main_p hdl_error hdl_nodes axmain
    return
end

if isempty(hdl_main)||isempty(hdl_error)||isempty(hdl_nodes) % initialize the plot window
    axmain = subplot(1,2,1);

end

if length(varargin)==3
    if isempty(hdl_main)
        hdl_main = plot3(axmain,varargin{1},varargin{2},varargin{3});
        hold on
        hdl_main_p = plot3(axmain,A(1,:),A(2,:),A(3,:), '.r');
        hold off
    else
        set(hdl_main, 'XData',varargin{1},'YData',varargin{2},'ZData',varargin{3});
        set(hdl_main_p, 'XData',A(1,:),'YData',A(2,:),'ZData',A(3,:));
    end
else
    if isempty(hdl_main)
        hdl_main = plot(axmain,varargin{1},varargin{2});
        hold on
%         %limlim = axis;
%         axmaincopy = axes('position', get(axmain, 'position'));
        hdl_main_p = plot(axmain,A(1,:),A(2,:), '.r');
        hold off
%         set(axmaincopy, 'Color', 'none');
        %axis([axmain axmaincopy],limlim);
    else
        set(hdl_main, 'XData',varargin{1},'YData',varargin{2});
        set(hdl_main_p, 'XData',A(1,:),'YData',A(2,:));
    end
    
end

set(gca,'box','off')
%%% will set the same scale for axmain and axmaincopy

%%% Now I will plot the error
axerror = subplot(2,2,2);
if ~isempty(hdl_error)
    set(hdl_error, 'XData',epoch_vect,'YData',error_vect);
else
    title('Activity or RMS error')
    hdl_error = plot(axerror, epoch_vect, error_vect);
end
axnodes = subplot(2,2,4);
if ~isempty(hdl_nodes)
    set(hdl_nodes, 'XData',epoch_vect,'YData',nodes);
else
    hdl_nodes = plot(axnodes, epoch_vect, nodes);
    title('Number of Nodes')
end

end
function B = threedeeA(A)

C = makefatskel(A);
B = [];
for i = 1:size(C,3)
    B = cat(1, C(:,:,i), B);
end

end