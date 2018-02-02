function datavar = setdatavar(scene,precon)
%% defines some standard preconditioning for datasets

makedata = true; %%% premature optimization
only_hips = {'nohips'};
parisi_preconditions = {'nohips','mirrorx'};
cipiteli_preconditions = {'nohips','norm_cip','mirrorx'};
polar_pc = {'nohips','mirrorx','polarC'};

extract_only_relevant = {'removeaction','still','random'};

bathroom = {'removeaction','still','random', 'cooking (chopping)', 'cooking (stirring)','drinking water','opening pill container','relaxing on couch','talking on couch','talking on the phone','working on computer','writing on whiteboard'};
bedroom = {'removeaction','still','random', 'brushing teeth', 'cooking (chopping)', 'cooking (stirring)','relaxing on couch','rinsing mouth with water','talking on couch','wearing contact lenses','working on computer','writing on whiteboard'};
kitchen = {'removeaction','still','random', 'brushing teeth', 'relaxing on couch','rinsing mouth with water','talking on couch','talking on the phone','wearing contact lenses','working on computer','writing on whiteboard'};
livingroom = {'removeaction','still','random', 'brushing teeth', 'cooking (chopping)', 'cooking (stirring)','opening pill container','rinsing mouth with water','wearing contact lenses','working on computer','writing on whiteboard'};
office = {'removeaction','still','random', 'brushing teeth', 'cooking (chopping)', 'cooking (stirring)','opening pill container','relaxing on couch','rinsing mouth with water','talking on couch','wearing contact lenses'};

switch precon
    case 'no'
        preconCell = {};
    case 'oh'
        preconCell = only_hips;
    case 'pap' 
        preconCell = parisi_preconditions;
    case 'cip'
        preconCell = cipiteli_preconditions;
    case 'pop'
        preconCell = polar_pc;
    otherwise
        error('precondition sequence not defined.')
end

switch scene
    case 'all'
        sceneCell = {};
    case 'or'
        sceneCell = extract_only_relevant;
    case 'bathroom'
        sceneCell = bathroom;
    case 'bedroom'
        sceneCell = bedroom;
    case 'kitchen'
        sceneCell = kitchen;
    case 'livingroom'
        sceneCell = livingroom;
    case 'office'
        sceneCell = office;
    otherwise
        error('scene not defined')
end
%% Initializes datavar
datavar = Datavar({'validationtype' 'type2all'});

%starts the dataset and do the preconditioning and feature selection.

datavar.validationtype = 'type2all'; %'type2notrandom'; 'cluster' 'quarterset' 'type2' 'type2notrandom' 'type2all'

datavar.scene = scene; % save the scene so we can load the right dataset.

%% Choose dataset
if makedata
    datavar.AllSubjects = [1 2 3 4];%2 %[1 2 3 4]; %% 
    datavar.disablesconformskel = 0;
    datavar.generatenewdataset = false; %true;
    datavar.datasettype = 'CAD60'; % datasettypes are 'CAD60', 'tstv2' and 'stickman'
    datavar.activity_type = 'act_type'; %'act_type' or 'act'
    datavar.prefilter = {'none', 15};%{'filter',10}; % 'filter', 'none', 'median?'
    datavar.normrepair = false;
    datavar.affinerepair = false;
    datavar.affrepvel = false;
    datavar.randSubjEachIteration = false; %%% must be set to false for systematic testing
    datavar.extract = {'rand', 'wantvelocity','order',sceneCell};
%   datavar.extract = {'rand', 'wantvelocity','order',{'removeaction','still','random'}};

    datavar.preconditions = preconCell;%{'nohips','polarC'};%'disthips', 'nonmatrixkilldim'};%, 'mirrorx'};% {'nohips'};% {'nohips', 'mirrorz', 'mirrorx'}; %,'normal'};%{'nohips', 'norotatehips' ,'mirrorx'}; %,
else
    datavar.featuresall = 3;%size(varargin{1},2);

end

%is this necessary? 
%datavar = datavar.init;
end