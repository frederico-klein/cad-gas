function [polidx, velidx] = generateidx(varargin)
%oh, this is not unique, probably should a varargin and check for both
%size and a label value
lllen = varargin{1};
if nargin==1
    switch lllen %%% i should find an elegant way of doing this
        case 75
            %%%%regular skeleton
            polidx = [1:75];
            velidx = [];
        case 150
            %%%%skeleton + velocities
            polidx = [1:25 51:75 101:125];
            velidx = [26:50 76:100 126:150];
        case 72
            %%%%skeleton - hips
            polidx = [1:72];
            velidx = [];
        case 147
            %%%%skeleton - hips + velocities
            polidx = [1:24 50:73 99:122];
            velidx = [25:49 74:98 123:147];
        case 90
            %%%%simple skeleton+ velocities from CAD60
            polidx = [1:15 31:45 61:75];
            velidx = [16:30 46:60 76:90];
        otherwise
            error('Strange size!')
            %%%%regular skeleton
    end
else
    % with 2 inputs we can have a skeleton definition as the second one
    % skeleton definition will have a
    skelldef = varargin{2};
    if isfield(skelldef, 'notskeleton')
        polidx = 1:lllen;
        velidx = [];
        return
    end
    pick = skelldef.length;
    [polidx, velidx] = generateidx(pick);
    % need to remove points from polidx and velidx based on skelldef
    polidx = setdiff(polidx,skelldef.realkilldim);
    velidx = setdiff(velidx,skelldef.realkilldim);
    
    %humm, this is not so simple as I thought. OK
    polflag = 1*ones(1,size(polidx,2)); polidxf = [polidx; polflag]; % constructing flagged vectors
    velflag = 0*ones(1,size(velidx,2)); velidxf = [velidx; velflag]; % just for consistency. If I ever want to add anything else, this should stay the same
    
    if isempty(velidx)
        wholeskel = polidxf;
    else
        wholeskel = [polidxf velidxf]; %put them together
    end
    [~, II] = sort(wholeskel(1,:)); %sort them based on the first line only
    sortedskel = wholeskel(:,II);
    sortedskel(1,:) = 1:size(wholeskel,2); % replace with the actual indexes after removing elements
    polidx = sortedskel(:,sortedskel(2,:)==1);%.*(1:size(sortedskel,2)); %% the trailing multiplication is not necessary because the A == 1 works differently when you have an array
    velidx = sortedskel(:,sortedskel(2,:)==0);%.*(1:size(sortedskel,2));
    % now I need to remove the tags
    polidx = polidx(1,:);
    velidx = velidx(1,:);
    
    %     %now I need to remove zeros %since A == 1 is different then I don`t
    %     need to do this anymore
    %     polidx = polidx(polidx~=0);
    %     velidx = velidx(velidx~=0);
end
end
