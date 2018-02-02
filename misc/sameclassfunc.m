function [gas, ssvot] = sameclassfunc(gas, ssvot, vot, whatIlabel, arq_connect)
%% Gas-chain Classifier
% This part executes the chain of interlinked gases. Each iteration is one
% gas, and currently it works as follows:
% 1. Function setinput() chooses based on the input defined in allconn
% 2. Run either a Growing When Required (gwr) or Growing Neural Gas (GNG)
% on this data
% 3. Generate matrix of best matching units to be used by the next gas
% architecture

dbgmsg('Starting chain structure for GWR and GNG for nodes:',num2str(labindex),0)
dbgmsg('###Using multilayer GWR and GNG ###',0)

if ~arq_connect(1).params.multigas %%% hmm,,,,
    kindex = 1;
else
    numlabs = size(ssvot.y,1);
    kindex = 1:numlabs;
    labs = repmat('some label',12,1);  %%%% provisional. needs real labels
    %%%need to partition ssvot!
    ssvotbt = ssvot;
    ssvotbt.gas.bestmatchbyindex = [];
    ssvot = pssvot(ssvot);
    gas = repmat(gas,numlabs,1);
end

for k = kindex
    for j = 1:length(arq_connect)
        if size(ssvot(k).data,1)>0&&strcmp(vot,'train')
            %size(ssvot(k).data)
            [gas(k,j), ssvot(k)] = gas_method2(gas(k,:), ssvot(k),vot, arq_connect(j),j, k); % I had to separate it to debug it.
        elseif ~isempty(ssvot(k).data)
            [~, ssvot(k) ]= gas_method2(gas(k,:), ssvot(k), vot, arq_connect(j),j,k); %%%hmmm, is this useful at all?
        end
    end
end

%construct a combined gas

if arq_connect(1).params.multigas %%% hmm,,,,
    for k = kindex
        for j = 1:length(arq_connect)
            [~, ssvotbt] = gas_method2(gas(k,:), ssvotbt,'NOTRAIN', arq_connect(j),j,k);
        end
    end
end
%% Gas Outcomes
if strcmp(vot,'train')
    for j = 1:length(arq_connect)
        if arq_connect(j).params.PLOTIT %%% this is a mess
            for k = kindex
                %figure(k)                
                subplot(max(kindex),length(arq_connect),j*k)
                hist(gas(k,j).outparams.graph.errorvect)
                if k>1
                    title([(gas(k,j).name) labs(k,:)])
                end
            end
        end
    end
end
%%%%% time for data inspection
if exist('ssvotbt','var')
    if strcmp(vot,'train')
        
        tm = construct_tms(ssvot,ssvotbt,arq_connect,vot); %%%%% technically I should make this also work for a single gas scenario.
        assignin('base','tm', tm)
        if 0
            for i = 1:length(tm)
                figure
                for j = 1:length(tm(i).tm)
                    subplot(1,length(tm(i).tm),j);
                    spy(tm(i).tm(j).mat)
                end
            end
        end
        
    else
        tm = evalin('base','tm');
        tma = construct_tms([],ssvotbt,arq_connect,vot);
        bmtm = match_tms(tma, tm);
        bmtm2 = match_tmsv2(tma, tm);
        %y = sum(unique(ssvotbt.y','rows','stable').*[1:12]'); %not y because
        %of repetitions;
        y = findy(ssvotbt);
        assignin('base','bmtm1', sum(bmtm.vlabel==y)/length(y))
        assignin('base','bmtm2', sum(bmtm2.vlabel==y)/length(y))
    end
end
%% Labelling
% The current labelling procedure for both the validation and training datasets. As of this moment I label all the gases
% to see how adding each part increases the overall performance of the
% structure, but since this is slow, the variable whatIlabel can be changed
% to contain only the last gas.
%
% The labelling procedure is simple. It basically picks the label of the
% closest point and assigns to that. In a sense the gas can be seen as a
% dimensional (as opposed to temporal) filter, encoding prototypical
% action-lets.
% Specific part on what I want to label
for j = whatIlabel
    if length(kindex)==1
        dbgmsg('Applying labels for gas: ''',gas(j).name,''' (', num2str(j),') for process:',num2str(labindex),0)
        if strcmp(vot,'train')
            %gas(j).nodesl = arq_connect(j).params.label.prototypelabelling(ssvot.gas(j).bestmatchbyindex, gas(j).nodes,ssvot.gas(j).inputs.input,ssvot.gas(j).y); %%% new labelling scheme
            %gas(j).nodesl = labeling(gas(j).nodes,ssvot.gas(j).inputs.input,ssvot.gas(j).y);
            if isempty(ssvot.gas(j).bestmatchbyindex)&&(strcmp(arq_connect(j).method,'knn')||strcmp(arq_connect(j).method,'svm'))
                gas(j).nodesl = ssvot.gas(j).y; % the line below seems to work, but this is faster.                 
            elseif strcmp(arq_connect(j).method,'gng')||strcmp(arq_connect(j).method,'gwr')||strcmp(arq_connect(j).method,'som')%and others that will use prototypes
                gas(j).nodesl = arq_connect(j).params.label.prototypelabelling(ssvot.gas(j).bestmatchbyindex, gas(j).nodes,ssvot.gas(j).inputs.input,ssvot.gas(j).y); %%% new labelling scheme
            end
        end
        if isfield(ssvot,'gas')&&j<=length(ssvot.gas)
            [~,newlabels] = max(gas(j).nodesl);
            gas(j).model =  arq_connect(j).params.label.classlabelling(gas(j).nodes.', newlabels.'); %%% I will use knn for now, but it doesnt need to be, so this is a function handle to fitcknn
            weirdthingy = predict(gas(j).model,ssvot.gas(j).inputs.input.'  ).';            %%% we still dont have the classes the way we want because matlab is annoying 
            if ~isfield(ssvot.gas(j), 'bestmatchbyindex')||isempty(ssvot.gas(j).bestmatchbyindex)
                warning('bestmatch by index is not set!!! .IDX property will be empty as well!')
            end
            gas(j).IDX = ssvot.gas(j).bestmatchbyindex;  
            %%% now, i believe i had this problem before, so i believe
            %%% there is in my code this function, but I can't seem to find
            %%% it, so coding it again
            ssvot.gas(j).class = double(fromnumstological(weirdthingy, size(ssvot.y,1))); %%% although I liked how it was and it was saving me so much space, confmatrix does not like logicals (it seems to me that it would be the ideal place to use them, but well, i didnt code matlab)
            
            %%% demonstration that what we wanted to do is sound: uncomment
            %%% to run
%             aaaaaa = labeller(gas(j).nodesl, ssvot.gas(j).bestmatchbyindex);
%             [~,newlabels] = max(gas(j).nodesl);
%             model = fitcknn(gas(j).nodes.', newlabels.');
%             bbbbb = predict(model,ssvot.gas(1).inputs.input  );
%             [~,asdfg] = max(aaaaaa);
%             all(asdfg' == bbbbb) %%% outputs one, so we have the same results with our function than with using a knn. qed (??? not really...)
%             %%% old labeller used bestmatched gas nodes 
%             ssvot.gas(j).class = labeller(gas(j).nodesl, ssvot.gas(j).bestmatchbyindex);
        end
    else
        traindist = c_dist(ssvot); %%%% maybe I should compare with this for better results. first trial won't have it though.
        ssvotbt.gas(j).class = newlabeller(ssvotbt.gas(j).distances);
        %%% some interesting graphs here
        if 0
            for ii = 1:length(arq_connect)
                figure
                cd = ssvotbt.gas(ii).distances(find(ssvotbt.gas(ii).y==1));
                id = ssvotbt.gas(ii).distances(find(ssvotbt.gas(ii).y==0));
                histogram(cd,200);
                hold on
                histogram(id,200);
                for i = 1:length(kindex)
                    pg(i).c = ssvotbt.gas(ii).distances(find(ssvotbt.gas(ii).y(i,:)==1));
                    pg(i).i = ssvotbt.gas(ii).distances(find(ssvotbt.gas(ii).y(i,:)==0));
                end
                [ocv,ma] = findoptimalcutoffvalue({pg(:).c},{pg(:).i});
                %[ocv,ma] = findoptimalcutoffvalue(cd,id);

            end
        end
        ssvot = ssvotbt; %%% so many potential errors... :(
    end
    
end

end
