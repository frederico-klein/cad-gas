function [extinput_clipped, extinput, inputends,y, removeremove, indexes, awko, extaccdist] = setinput(arq_connect, savestrucgas,data_size, svst_t_v,k) %needs to receive the correct data size so that generateidx may work well
%%%%%% this is the place to get long inputs actually.
%arqconnect has only the current layer, so it is flat
%inputends need to be the same for everything to work out fine
%theoretically it makes sense that they are not the same size and then the
%smallest should be used and the end bits of each action set, discarded and
%then rematched to fit the real correspondent. I don't really know how to
%do that, maybe I need to match each action with some extra indexing, or
%make a clever indexing function that will discard the right amount of end
%bits at the right part
% Or I perhaps should carry each action separatelly, because it would make
% things easier, but this would require a major rewrite of everything I did
% so far. So in short: same "ends" for every component.
extinput = [];
midremove = [];
awko = [];
extaccdist = [];
inputinput = cell(length(arq_connect.sourcelayer),1);
removeremove = struct([]);
awk = inputinput; %it is also the same size...
accdist = awk; %%% I am not really thinking, just copying what I did for the other variables. 
%if inputends dont coincide this function will give a strange error
inputends = [];
[posidx, velidx] = generateidx(data_size, arq_connect.params.skelldef);
for j = 1:length(arq_connect.sourcelayer)
    foundmysource = false;
    for i = 1:length(savestrucgas)
        if strcmp(arq_connect.sourcelayer{j}, savestrucgas(i).name)
            if isempty( svst_t_v.gas(i).bestmatchbyindex)
                error('wrong computation order. bestmatch field not yet defined.')
            end
            oldinputends = inputends;
            switch arq_connect.inputtype %?
                case 'nodes'
                    %%% depending on arqconnect make it the input with the gas
                    %%% nodes                    
                    inputssss = savestrucgas(i).nodes(:,svst_t_v.gas(i).bestmatchbyindex(k,:));                    
                case 'indexes'
                    %%% or gas indexes
                    inputssss = svst_t_v.gas(i).bestmatchbyindex(k,:);
            end
            [inputinput{j},inputends,y, indexes, accdist{j}] = longinput(inputssss , arq_connect.q, svst_t_v.gas(i).inputs.input_ends, svst_t_v.gas(i).y,svst_t_v.gas(i).inputs.index, svst_t_v.gas(i).distances(k,:));
            
            %%%check for misalignments of inputends
            if ~isempty(oldinputends)
                if ~all(oldinputends==inputends)
                    error('Misaligned layers! Alignment not yet implemented.')
                end
            end
            %%% old  longinput call. I will no longer create .bestmatch, so
            %%% I need to create it on the fly from gasnodes
            %            [inputinput{j},inputends,y] = longinput( svst_t_v.gas(i).bestmatch, arq_connect.q, svst_t_v.gas(i).inputs.input_ends, svst_t_v.gas(i).y);
            
            %inputinput{j} = longinput(savestruc.gas(i).bestmatch; %
            if isfield(svst_t_v.gas(i), 'whotokill')
                removeremove = structcat(svst_t_v.gas(i).whotokill, removeremove);
            else
                removeremove = struct();
            end
            %%% this part will construct my newly created awk vector out of
            %%% initial awk vectors
            awk{j} = makeawk(arq_connect.q, svst_t_v.gas(i).inputs.awk);
            foundmysource = true;
        end
    end
    if ~foundmysource
        if strcmp(arq_connect.layertype, 'pos')
            [inputinput{j},inputends,y, indexes,accdist{j}] = longinput(svst_t_v.data(posidx,:), arq_connect.q, svst_t_v.ends, svst_t_v.y, (1:size(svst_t_v.data,2)),zeros(1,size(svst_t_v.data,2))); %%% distance starts off as zero. 
            %inputinput{j} = svst_t_v.data(posidx,:); %
            %ends is savestructure.train.ends
            awk{j} = makeawk(arq_connect.q, arq_connect.params.skelldef.awk.pos);
        elseif strcmp(arq_connect.layertype, 'vel')
            [inputinput{j},inputends,y, indexes,accdist{j}] = longinput(svst_t_v.data(velidx,:), arq_connect.q, svst_t_v.ends, svst_t_v.y, (1:size(svst_t_v.data,2)),zeros(1,size(svst_t_v.data,2)));
            %inputinput{j} = svst_t_v.data(velidx,:); %
            %ends is savestructure.train.ends
            awk{j} = makeawk(arq_connect.q, arq_connect.params.skelldef.awk.vel);
        elseif strcmp(arq_connect.layertype, 'all')
            [inputinput{j},inputends,y, indexes,accdist{j}] = longinput(svst_t_v.data, arq_connect.q, svst_t_v.ends, svst_t_v.y, (1:size(svst_t_v.data,2)),zeros(1,size(svst_t_v.data,2)));
            %inputinput{j} = svst_t_v.data; %
            %ends is savestructure.train.ends
            awk{j} = makeawk(arq_connect.q, [arq_connect.params.skelldef.awk.pos;  arq_connect.params.skelldef.awk.vel] );
        end
    end
    if isempty(inputinput)
        error(strcat('Unknown layer type:', arq_connect.layertype,'or sourcelayer:',arq_connect.sourcelayer))
    end
end
if length(inputinput)>1
    for i = 1:length(inputinput)
        extinput = cat(1,extinput,inputinput{i}); % this part should check for the right ends, ends should also be a cell array, and they should be concatenated properly
        %%% dealing with possible empty sets::
        if ~isempty(removeremove)
            midremove = structcat(midremove,removeremove); %{i}
            %midremove = cat(1,midremove,removeremove{i}); %{i}
        end
        if isempty(extaccdist)
            extaccdist = accdist{i};
        else
            extaccdist = extaccdist + accdist{i};
        end
        %extaccdist = cat(1,extaccdist,accdist{i});
        awko = cat(1,awko,awk{i});
    end
else
    extaccdist = accdist{:};
    extinput = inputinput{:};
    midremove = removeremove; %no turtles!
    awko = awk{:};
    %oh, it may be wrong,,, have
    %to check wrappung and unwrapping %%it was wrong, I will check
    %unwrapping inside removebaddata
    %[extinput_clipped, inputends_clipped, y_clipped]= removebaddata(extinput, inputends, y, removeremove); % this wrong, since I will only avoid putting bad sets into the gas. so it is fortunately simpler than I thought!
    
end
extinput_clipped= removebaddata(extinput, indexes, midremove, arq_connect.q);
end
function awk = makeawk(q,inawk)
awk = repmat(inawk,q(1),1);
end
function [linput,newends, newy, indexes,newdist] = longinput(shortinput, qp, ends, y, iindex,shortdist)
% this function was getting messy, so I decided to recreate the structure
% that generated her, so to make easier debugging
% It is very disellegant of me. I apologise.
newdist = shortdist; 

q = qp(1);
switch length(qp)
    case 1
        p = 0;
        r = 1;
    case 2
        p = qp(2);
        r = 1;
    case 3
        p = qp(2);
        r = qp(3);
end

realends = cumsum(ends,2);
actionstructure = struct;
actionstructure(1:size(ends,2)) = struct();
actionstructure(1).pose = shortinput(:,1:realends(1));
actionstructure(1).end = ends(1);
actionstructure(1).y = y(:,realends(1));
actionstructure(1).index = iindex(1:ends(1));
actionstructure(1).dist = shortdist(1:ends(1));
%%% matlab was stopping here for some unknown reason. I think it is because
%%% it is trying to execute stuff ahead of time, so I have to start empty
%%% variables to have adequate placeholders. At least this is my best
%%% attempt of explaining this behaviour so far. 
for an_index=1:length(actionstructure)
    actionstructure(an_index).long.vec = [];
    actionstructure(an_index).long.index = [];
    actionstructure(an_index).long.dist = [];
    actionstructure(an_index).newend = [];
    actionstructure(an_index).longinput = [];
    actionstructure(an_index).longy = [];
    actionstructure(an_index).longindex = [];
    actionstructure(an_index).longdist = [];
end

for i = 2:size(ends,2)
    actionstructure(i).pose = shortinput(:,realends(i-1)+1:realends(i));
    actionstructure(i).end = ends(i);
    actionstructure(i).y = y(:,realends(i));
    actionstructure(i).index = iindex(realends(i-1):realends(i));
    actionstructure(i).dist = shortdist(realends(i-1):realends(i));
end
shortdim = size(shortinput,1);
flag_set = false;
for i = 1:length(actionstructure)
    m = 1;
 
    [actionstructure(i), flag_set] = complicated_concatenator(actionstructure(i),m,shortdim,q,r,p,flag_set);
    %since I am not sure of what the hell matlab is doing, i will check if
    %it ran my for loop...
    if isempty(actionstructure(i).long(1).vec)||isempty(actionstructure(i).long(1).index)||isempty(actionstructure(i).long(1).dist)
        error('it will break again....')
    end
    %should concatenate long now
    actionstructure(i).newend = length(actionstructure(i).long);
    actionstructure(i).longinput = zeros(q*shortdim,actionstructure(i).newend);
    actionstructure(i).longy = repmat(actionstructure(i).y,1,actionstructure(i).newend);
    actionstructure(i).longindex = zeros(q,size(actionstructure(i).longy,2));
    actionstructure(i).longdist = zeros(1,size(actionstructure(i).longy,2)); 
    for j = 1:actionstructure(i).newend
        actionstructure(i).longinput(:,j) = actionstructure(i).long(j).vec;
        actionstructure(i).longindex(:,j) = actionstructure(i).long(j).index;
        actionstructure(i).longdist(j) = actionstructure(i).long(j).dist;
    end
end
linput = actionstructure(1).longinput;
newy = actionstructure(1).longy;
newends = zeros(1,length(actionstructure));
newends(1) = actionstructure(1).newend;
indexes = actionstructure(1).longindex;
newdist = actionstructure(1).longdist;
for i = 2:length(actionstructure)
    linput = cat(2,linput,actionstructure(i).longinput);
    newy = cat(2,newy, actionstructure(i).longy);
    newends(i) = actionstructure(i).newend;
    indexes = cat(2,indexes, actionstructure(i).longindex);
    newdist = cat(2,newdist, actionstructure(i).longdist);
end
end