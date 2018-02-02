function [data, lab] = extractdata(structure, typetype, inputlabels,varargin)
ORDER = false;
labremove = {};
for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            case 'wantvelocity'
                WANTVELOCITY = true;
            case 'rand'
                RANDSQE = true;
            case 'novelocity'
                WANTVELOCITY = true;
            case 'seq'
                RANDSQE = false;
            case 'order'
                ORDER = true; %%% will order the training set according to y values. this will hopefully prevent point merger in the output gas
            otherwise
                error('unexpected argument')
        end
    elseif iscell(varargin{i})
        a = varargin{i};
        for j=1:length(a)
            switch a{j}
                case 'removeaction'
                otherwise
                    if ~isempty(a{j})
                        labremove = [labremove {a{j}}];
                    end
            end
        end
    end
end

%%%%%%%%Messages part. Feedback for the user about the algorithm
dbgmsg('Extracting data from skeleton structure')
if WANTVELOCITY
    dbgmsg('Constructing long vectors with velocity data as well')
end
%%%%%%%%
%typetype= 'act_type';
%typetype= 'act';

Data = [];
ends = [];
% approach
if strcmp(typetype,'act')
    [labelZ,~] = alllabels(structure,inputlabels);
elseif strcmp(typetype,'act_type')
    [~, labelZ] = alllabels(structure,inputlabels);
else
    error('weird typetype!')
end
lab = sort(labelZ);

Y = [];
index = [];

if RANDSQE
    randseq = randperm(length(structure));
else
    randseq = 1:length(structure);
end


%%% remove labels if labels need to be removed


[randseq, lab] = removeelements(lab,labremove,structure,randseq);



if ORDER
    %disp('hello')
    randseq = order(lab,typetype,structure,randseq,RANDSQE);
end

for i = randseq % I think each iteration is one action
    Data = cat(3, Data, structure(i).skel);
    Y = cat(2, Y, repmat(whichlab(structure(i),lab,typetype),1,size(structure(i).skel,3)));
    index = cat(2, index, repmat(structure(i).indexact,1,size(structure(i).skel,3)));
    ends = cat(2, ends, size(structure(i).skel,3));
end
%%% check y
% yy = sum(Y.*[1:12]',1);
% plot(yy)
%%%

if WANTVELOCITY
    Data_vel = [];
    for i = randseq % I think each iteration is one action
        Data_vel = cat(3, Data_vel, structure(i).vel);
    end
    Data = cat(1,Data, Data_vel);
end
% It will also construct data for a clustering analysis, whatever the hell
% that might mean in this sense
vectordata = [];
if isempty(Data)
    vectordata = [];
else
    for i = 1:size(Data,3)
        vectordata = cat(2,vectordata, [Data(:,1,i); Data(:,2,i); Data(:,3,i)]);
    end
end
%Y = Y';
%Data, vectordata, Y, ends, lab]
%data = makess(1,0);

data.data = vectordata;
%data.tensor = Data;
data.y = Y;
data.ends = ends;
data.seq = randseq;
data.index = index;
end
function [lab, biglab] = alllabels(st,lab)
%lab = cell(0);
biglab = lab;
for i = 1:length(st) % I think each iteration is one action
    if isfield(st,'act')&&isfield(st,'act_type')
        %for i = 1:length(st) % I think each iteration is one action
        cu = strfind(lab, st(i).act);
        if isempty(lab)||isempty(cell2mat(cu))
            lab = [{st(i).act}, lab];
            biglab = [{[st(i).act st(i).act_type]}, biglab];
        end
        bgilab = [st(i).act st(i).act_type];
        cu = strfind(biglab, bgilab);
        if isempty(biglab)||isempty(cell2mat(cu))
            biglab = [{bgilab}, biglab];
        end
        % end
    end
    if isfield(st,'act_type')
        %for i = 1:length(st) % I think each iteration is one action
        cu = strfind(biglab, st(i).act_type);
        if isempty(biglab)||isempty(cell2mat(cu))
            biglab = [{st(i).act_type}, biglab];
        end        
        % end
    elseif isfield(st,'act')
        %for i = 1:length(st) % I think each iteration is one action
        cu = strfind(lab, st(i).act);
        if isempty(lab)||isempty(cell2mat(cu))
            lab = [{st(i).act}, lab];
        end
        %end        
    else
        error('No action fields in data structure.')
    end
end
end
function outlab = whichlab(st,lb,tt)
numoflabels = size(lb,2);
switch tt
    case 'act_type'
        if isfield(st, 'act')
            comp_act = [st.act st.act_type];
        else
            comp_act = st.act_type;
        end
    case 'act'
        comp_act = st.act;
    otherwise
        error('Unknown classification type!')
end

for i = 1:numoflabels
    if strcmp(lb{i},comp_act)
        lab = i;%i-1;
    end
end


%I thought lab was a good choice, but matlab
outlab = zeros(numoflabels,1);
outlab(lab) = 1;
end
function nrandseq = order(lab,typetype,structure,randseq,RANDSQE)
%nrandseq = zeros(size(randseq));
nrandseq = [];
if RANDSQE
    labord = randperm(length(lab));
else
    labord = 1:length(lab);
end
for j=labord
    for i =randseq
        a = whichlab(structure(i),lab,typetype);
        if a(j)
            nrandseq = [nrandseq i];
        end
    end
end
end
function [randseq, lab] = removeelements(lab,labremove,structure,randseq)
%rseq = randseq;
killlab = [];
for i=1:length(lab)
    for j=1:length(labremove)
        if strcmp(lab{i},labremove{j})
            killlab = [killlab i];
        end
    end
end
lab(killlab) = [];


killdim = [];
for i = randseq
    for j=1:length(labremove)
        if strcmp(structure(i).act_type, labremove{j})%%%% attention, should use whichlab!!!! but I am lazy and doing this the simple way now. if it breaks, this is what has to be done, check the matrix and whatnot
            
            killdim = [killdim i];
        end
    end
end
randseq = randseq(~ismember(randseq,killdim));

end