function aoutout = online_classifier(data, allskel, arq_connect, simvar)
global VERBOSE LOGIT
VERBOSE = 0; % true;
LOGIT = false;
%a = struct();

%runs conformactions

[data.test,~,~] = all3(allskel, simvar);
%data.test = datatest; %matlab was complaining about this...

% 
% [allskel] = conformactions(allskel, simvar.prefilter); %%% should be split in 2
% 
% %extractdata
% [data.test, ~] = extractdata(allskel, simvar.activity_type, simvar.labels_names,simvar.extract{:}); %%% I dont know if I need this, or if it makes sense to use this function
% %conformskel
% [data.test, ~ ] = conformskel(data.test, simvar.preconditions{:}, 'test', simvar.paramsZ.skelldef);
%loop from l.65 of starter_sc -> make it into a function???

whatIlabel = 1:length(data.gas);
[data.gas, data.test] = sameclassfunc(data.gas, data.test, 'test', whatIlabel, arq_connect);

% for j = 1:length(arq_connect)
%     [~, data.test] = gas_method(data, data.test, 'vot', arq_connect(j),j,size(data.train.data,1));
% end
% 
% 
% for i = 1:length(arq_connect)
%     %labeller
%     %for i gases... like above
%     [data.test.gas(i).class, ~] = find(data.gas(i).nodesl(:, data.test.gas(i).bestmatchbyindex));
% end
%numskells = size(data.test.gas(i).class,2);
numskells = 40000;
if isfield(simvar,'labels_names')&&~isempty(simvar.labels_names)
    %size(simvar.labels_names)
    aoutout = cell(length(arq_connect));
    for i = 1:length(arq_connect)
        if numskells > size(data.test.gas(i).class,2)
            numskells = size(data.test.gas(i).class,2);
            dbgmsg('Oveflow: Number of skeletons reduced to ', num2str(numskells),0)
        end
        claas = sum(data.test.gas(i).class(:,1:numskells).*(1:size(data.test.gas(i).class,1)).');
        [a, b ]= hist(claas, unique(claas));
        [~, ii] = sort(a,'descend');
        for j = ii
            if a(j) >0
                aoutout{i} = ([ aoutout{i} num2str(a(j)) ' ' simvar.labels_names{b(j)} '-   ']);
            end
        end, 
        %disp(aoutout{i}), 
        %clear aoutout 
    end
else
    disp('something went wrong')
    disp('no label names defined!')
end
%disp('')
if 0% simvar.paramsZ.PLOTIT
    figure
    plot_act(data, data.test.data, simvar.paramsZ.skelldef, numskells) %% data.test!!!!
end

end