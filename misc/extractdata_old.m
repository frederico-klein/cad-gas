function [data, lab] = extractdata(structure, typetype, inputlabels,varargin)
for i = 1:length(varargin)
    switch varargin{i}
        case 'wantvelocity'
            WANTVELOCITY = true;
        case 'rand'
            RANDSQE = true;
        case 'novelocity'
            WANTVELOCITY = true;
        case 'seq'
            RANDSQE = false;
        otherwise
            error('unexpected argument')
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

if RANDSQE
    randseq = randperm(length(structure));
else
    randseq = 1:length(structure);
end

for i = randseq % I think each iteration is one action
    Data = cat(3, Data, structure(i).skel);
    Y = cat(2, Y, repmat(whichlab(structure(i),lab,typetype),1,size(structure(i).skel,3)));
    ends = cat(2, ends, size(structure(i).skel,3));
end
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

data.data = vectordata;
%data.tensor = Data;
data.y = Y;
data.ends = ends;
data.seq = randseq;

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