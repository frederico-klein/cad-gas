classdef Datavar
    properties
        skelldef
        data
        env
        validationtype
        sampling_type
        pc
        Alldata
        datainputvectorsize
        TrainSubjectIndexes
        ValSubjectIndexes
        AllSubjects
        featuresall
        disablesconformskel
        generatenewdataset
        datasettype
        activity_type
        prefilter
        normrepair
        affinerepair
        affrepvel
        labels_names
        randSubjEachIteration
        extract
        preconditions
        trialdataname
        trialdataname_old
        trialdatafile
        allmatpath
        scene
    end
    methods
        function datavar = Datavar(varargin)
            datavar.featuresall = 1;
            
            datavar.env = aa_environment; % load environment variables
            datavar.datainputvectorsize = [];
            datavar.TrainSubjectIndexes = [];
            datavar.ValSubjectIndexes = [];
            %datavar.paramsZ(length(datavar.P)) = [];
            datavar.labels_names = []; % necessary so that same actions keep their order number
            datavar.disablesconformskel = 0;
            datavar.pc = 999;
            
            datavar.generatenewdataset = false;
            datavar.datasettype = 'Ext!';
            datavar.sampling_type = '';
            datavar.activity_type = ''; %'act_type' or 'act'
            datavar.prefilter = {'none' 0}; % 'filter', 'none', 'median?'
            datavar.labels_names = []; % necessary so that same actions keep their order number
            datavar.TrainSubjectIndexes = [];%[9,10,11,4,8,5,3,6]; %% comment these out to have random new samples
            datavar.ValSubjectIndexes = [];%[1,2,7];%% comment these out to have random new samples
            datavar.AllSubjects = 1:4;
            datavar.randSubjEachIteration = true;
            datavar.extract = {''};
            datavar.preconditions = {''};
            datavar.trialdataname = strcat('other',datavar.datasettype,'_',datavar.sampling_type,datavar.activity_type,'_',datavar.prefilter, [datavar.extract{:}],[datavar.preconditions{:}]);
            datavar.trialdatafile = strcat(datavar.env.wheretosavestuff,datavar.env.SLASH,datavar.trialdataname,'.mat');
            
            if nargin>0
                for i = 1:nargin
                    switch varargin{i}{1}
                        case 'validationtype'
                            datavar.validationtype = varargin{i}{2};
                            datavar = datavar.updatevalidationtype;
                    end
                end
            end
        end
        function datavar = updatevalidationtype(datavar)
            switch datavar.validationtype
                case 'wholeset'
                    datavar.Alldata = 1:68;
                case 'cluster'
                    pcspecs = load([datavar.env.homepath datavar.env.SLASH '..' datavar.env.SLASH 'clust.mat']);
                    datavar.Alldata = pcspecs.idxs;
                    datavar.pc = pcspecs.pcid;
                case 'quarterset'
                    datavar.Alldata = (1:17)+17*(randi(4,1,17)-1);
                case 'type2'
                    datavar.Alldata = randperm(4,1);
                case 'type2notrandom'
                    datavar.Alldata = 3;
                case 'type2all'
                    datavar.Alldata = datavar.AllSubjects;
            end
            if strcmp(datavar.validationtype,'type2')||strcmp(datavar.validationtype,'type2notrandom')||strcmp(datavar.validationtype,'type2all')
                datavar.sampling_type = 'type2';
                %datavar.ValSubjectIndexes = {alldata};
                %datavar.TrainSubjectIndexes = setdiff(1:4,[datavar.ValSubjectIndexes{:}]);
            else
                datavar.sampling_type = 'type1';
                %datavar.TrainSubjectIndexes = [];%[];%'loo';%[9,10,11,4,8,5,3,6]; %% comment these out to have random new samples
                %datavar.ValSubjectIndexes = {alldata};%num2cell(1:68);%, [2]};%[1,2,7];%% comment these out to have random new samples
            end
        end
        function datavar = updatesavenames(datavar)
            simextractname = [datavar.extract{:}];
            datavar.trialdataname_old = strcat('skel',datavar.datasettype,'_',datavar.sampling_type,datavar.activity_type,'_',[datavar.prefilter{1} num2str(datavar.prefilter{2})], [simextractname{:}],[datavar.preconditions{:}],['V' num2str(datavar.ValSubjectIndexes)],['T' num2str(datavar.TrainSubjectIndexes)]);
            a = ['DATA' datavar.scene '_V' num2str(datavar.ValSubjectIndexes) '_T' num2str(datavar.TrainSubjectIndexes) '_' datavar.env.currhash ];
            datavar.trialdataname =  a(find(~isspace(a)));

            datavar.trialdatafile = strcat(datavar.env.wheretosavestuff,datavar.env.SLASH,datavar.trialdataname,'.mat');
            datavar.allmatpath = datavar.env.allmatpath;
        end
        function datavar = init(datavar)
            datavar = datavar.updatevalidationtype;
            datavar = datavar.updatesavenames;
        end
        function datavartrial = loop(datavar, varargin)
            %% Begin loop
            trialcount = 0;
            datavartrial = repmat(datavar,datavar.featuresall*length(datavar.Alldata),1);
            for featuress = 1:datavar.featuresall
                for valaction = datavar.Alldata %% iterate over different validation data
                    if strcmp(datavar.validationtype,'type2')||strcmp(datavar.validationtype,'type2notrandom')||strcmp(datavar.validationtype,'type2all')
                        
                        datavar.ValSubjectIndexes = valaction;
                        datavar.TrainSubjectIndexes = setdiff(datavar.AllSubjects,[datavar.ValSubjectIndexes]);
                    else
                        
                        datavar.TrainSubjectIndexes = [];%[];%'loo';%[9,10,11,4,8,5,3,6]; %% comment these out to have random new samples
                        datavar.ValSubjectIndexes = valaction;%num2cell(1:68);%, [2]};%[1,2,7];%% comment these out to have random new samples
                    end
                    
                    %%%%%%% MUST UPDATE DATAVAR.TRIALDATAFILE!!!!
                    datavar = datavar.updatesavenames;
                    
                    trialcount = trialcount +1;
                    
                    
                    %% Loading data
                    datavartrial(trialcount).data = makess(1,0); % starts with single layer data
                    if ~strcmp(datavar.datasettype,'Ext!')
                        datasetmissing = false;
                        if ~exist(datavar.trialdatafile, 'file')&&~datavartrial(trialcount).generatenewdataset
                            dbgmsg('There is no data on the specified location. Will generate new dataset.',1)
                            datasetmissing = true;
                        end
                        if datavartrial(trialcount).generatenewdataset||datasetmissing
                            [allskel1, allskel2, datavartrial(trialcount).TrainSubjectIndexes, datavartrial(trialcount).ValSubjectIndexes] = generate_skel_data(datavar.datasettype, datavar.sampling_type, datavar.TrainSubjectIndexes, datavar.ValSubjectIndexes, datavar.randSubjEachIteration);
                            [datavartrial(trialcount).data.train,datavartrial(trialcount).labels_names, datavartrial(trialcount).skelldef] = all3(allskel1, datavartrial(trialcount));
                            %%%% for debuggin only - remove or comment
                            %%%% out!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                            %                         for newindex = 1:10
                            %                             [zskel, notzeroedaction, labact] = zeromostout(allskel1);
                            %                             simvar.notzeroedaction = notzeroedaction;
                            %                             simvar.labact = labact;
                            %                             [zdata,simvar.labels_names, datavartrial(trialcount).skelldef] = all3(zskel, simvar);
                            %                         end
                            %showdataset(data,simvar)
                            %%%%
                            %%%%
                            [datavartrial(trialcount).data.val,datavartrial(trialcount).labels_names, ~] = all3(allskel2, datavartrial(trialcount));
                            datavartrial(trialcount).trialdatafile = savefilesave(datavar.trialdataname, {[], datavartrial(trialcount)},datavar.env);
                            dbgmsg('Training and Validation data saved.')
                            %                 clear datasetmissing
                        else
                            loadedtrial = loadfileload(datavar.trialdataname,datavar.env);
                            datavartrial(trialcount) = loadedtrial.savevar{1, 2};
                            %datavartrial(trialcount).skelldef = loadedtrial.skelldef;
                            datavartrial(trialcount).generatenewdataset = false;
                        end
                        datavartrial(trialcount).datainputvectorsize = size(datavartrial(trialcount).data.train.data,1);
                    else
                        datavartrial(trialcount).data = varargin{1};
                        datavartrial(trialcount).data = datavartrial(trialcount).data(featuress);
                        datavar.datainputvectorsize = size(datavartrial(trialcount).data.inputs,2);
                        datavartrial(trialcount).skelldef = struct('length', datavartrial(trialcount).datainputvectorsize, 'notskeleton', true, 'awk', struct('pos', [],'vel',[]), 'pos', datavartrial(trialcount).datainputvectorsize, 'vel', []);
                        datavartrial(trialcount).data.train.data = data.inputs'; % not empty so that the algorithm doesnt complain
                        datavartrial(trialcount).data.train.y = data.labelsM;
                        datavartrial(trialcount).data.train.ends = ones(1,size(data.inputs,1));
                        datavartrial(trialcount).data.val.data = data.inputs';
                        datavartrial(trialcount).data.val.y = data.labelsM;
                        datavartrial(trialcount).data.val.ends = ones(1,size(data.inputs,1));
                    end
                    
                end
            end
            
            
        end
    end
end
