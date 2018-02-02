function [allskel1, allskel2, allskeli1, allskeli2] = generate_skel_data(varargin)
% generates the .mat files that have the generated datasets for training and
% validation
% based on 2 types of random sampling
%
%%%% type 1 data sampling: known subjects, unknown individual activities from them:
%
%%%% type 2 data sampling: unknown subjects, unknown individual activities from them:
%
%
% data_train, y_train
% data_val, y_val
%

%aa_environment
if nargin<2
    error('I need at least the name of the data set (either ''CAD60'' or ''tstv2'') and the data sampling type (either ''type1'' or ''type2'')')
end

dataset = varargin{1};
sampling_type = varargin{2};
if nargin>2
    allskeli1 = varargin{3};
end
if nargin>3
    allskeli2 = varargin{4};
end
loo = 0;
partition = 0.8;

switch dataset
    case 'CAD60'
        loadfun = @readcad60;
        datasize = 4;
    case 'tstv2'
        loadfun = @LoadDataBase;
        datasize = 11;
    case 'stickman'
        loadfun = @generate_falling_stick;
        datasize = 20;
        if strcmp(sampling_type,'type1')
            dbgmsg('Sampling type1 not implemented for falling_stick!!! Using type2',1)
            sampling_type = 'type2';
        end
    otherwise
        error('Unknown database.')
end

if varargin{5} %If simvar(end).randSubjEachIteration is true, then generate a new sample.
    clear allskeli1
    clear allskeli2
end


%%%% TODO: this message is wrong. FIX THIS!
%%%%%%%%Messages part: provides feedback for the user
dbgmsg('Generating random datasets for training and validation')
if exist('allskeli1','var')
    %    dbgmsg('Variable allskeli1 is defined. Will skip randomization.')
end
%%%%%%%%%%%%

if ischar(allskeli1)
    switch allskeli1
        case 'all'
            allskeli1 = 1:datasize;
            sampling_type = 'type2';
        case 'loo'
            if strcmp(sampling_type,'type1')
                %%%% this will be tested further down the line...
                loo = 1;
                clear allskeli1
            else
                allskeli1 = randperm(datasize,datasize -1);
            end
        case 'l6o'
            if strcmp(sampling_type,'type1')
                %%%% this will be tested further down the line...
                loo = 6;
                clear allskeli1
            else
                if datasize>6
                    allskeli1 = randperm(datasize,datasize -6);
                else
                    error('Not enough subjects for selected method')
                end
            end
        otherwise
            error(['Strange argument:' allskeli1])
    end
end

%%% checks to see if indices will be within array range
%%% these only work for type2 - leave subjects out
%%% TODO: implement better checking for type1 - leave actions out
% if exist('allskeli1','var')
%     if any(allskeli1>datasize)
%         error('Index 1 is out of range for selected dataset.')
%     end
% end
% if exist('allskeli2','var')
%     if any(allskeli2>datasize)
%         error('Index 2 is out of range for selected dataset.')
%     end
% end




%%%% type 1 data sampling: known subjects, unknown individual activities from them:
if strcmp(sampling_type,'type1')
    allskel = loadfun(1:datasize); %main data
    allset = length(allskel);
    %%%%    
    if ~ischar(allskeli1) && (isempty(allskeli1)||isempty(allskeli2))
        if isempty(allskeli1)&& ~isempty(allskeli2)
            %%% so we know who we want to choose for validation,,, the training
            %%% set will be everything else
            allskeli1 = setdiff(1:allset, allskeli2);
        elseif ~isempty(allskeli1)&& isempty(allskeli2)
            allskeli2 = setdiff(1:allset, allskeli1);
        else
            error('Both validation and training sets cannot be defined as empty.')
        end        
    end
    
    switch loo
        case 1
            allskelimembers = allset - 1;
        case 6
            if allset>6
                allskelimembers = allset - 6;
            else
                error('not enough data to do selected randomization')
            end
        otherwise
            allskelimembers = fix(allset*partition);
    end
    %%%%
    if ~exist('allskeli1','var')
        allskeli1 = randperm(allset,allskelimembers); % generates the indexes for sampling the dataset
    end
    allskel1 = allskel(allskeli1);
    
    %%% I will change this bit. In the past allskel2 was whatever you
    %%% defined it to be, now it will be the complementary set to allskel1
    if ~exist('allskeli2','var')
        allskeli2 = setdiff(1:length(allskel),allskeli1); % use the remaining data as validation set
    end
    allskel2 = allskel(allskeli2);
end

%%%% type 2 data sampling: unknown subjects, unknown individual activities from them:
if strcmp(sampling_type,'type2')
    if ~exist('allskeli1','var')
        allskeli1 = randperm(datasize,fix(datasize*partition)); % generates the indexes for sampling the dataset
    end
    if isempty(allskeli1)
        if ~isempty(allskeli2)
        allskeli1 = setdiff(1:datasize,allskeli2);        
        else
            error('no definitions for allskeli1 or allskeli2. don''t know what to do.')
        end
    end
    allskel1 = loadfun(allskeli1(1)); %initializes the training dataset
    
    for i=2:length(allskeli1)
        allskel1 = cat(2,loadfun(allskeli1(i)),allskel1 );
    end
    
    if isempty(allskeli2)
        allskeli2 = setdiff(1:datasize,allskeli1); % use the remaining data as validation set if allskeli2 not defined.
    end
    allskel2 = []; %initializes the training dataset
    for i=1:length(allskeli2)
        allskel2 = cat(2,loadfun(allskeli2(i)),allskel2 );
    end
end
%%%%%%
% saves data
%%%%%%

end