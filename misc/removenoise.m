function allkill = removenoise(nodes, data, oldwhotokill, gamma, indexes)
% function gas = removenoise(gas, params)
% 
% gas.whotokill = eliminatespointsIdislike(gas.bestmatch, gas.inputs.input, gas.activations, params.gamma);
% 
% end
%%% if instead I calculate activations here, I can use this also for the
%%% gng! the activations is basically the exp part of the expression below
%%% which is calculated during execution time of the gwr. One must bear in
%%% mind however that the activation at runtime and the activation after
%%% the gas is done are completely different things.
sizetr = strcat('size',num2str(size(indexes,1)));
activations = exp(-pdist2(nodes',data','euclidean','Smallest',1));

meana = mean(activations);
stda = std(activations);
% if ~iscell(oldwhotokill)
%     oldwhotokill = num2cell(oldwhotokill);
%     dbgmsg('Someone is making a wrong type conversion!!!',1)
% end
whotokill = setdiff((activations<(meana-gamma*stda)).*(1:size(activations,2)),0);%% here the element order and the index should line up. I think at some point it didnt and I need to debug this or I will be removing the wrong point!

if isfield(oldwhotokill, sizetr)
    allkill.(sizetr) = [indexes(whotokill), oldwhotokill.(sizetr)];
else
    allkill.(sizetr) = indexes(whotokill);
end

%%% old function definition
% function allkill = eliminatespointsIdislike(nodes, data, oldwhotokill, gamma, indexes)
% %%% if instead I calculate activations here, I can use this also for the
% %%% gng! the activations is basically the exp part of the expression below
% %%% which is already calculated during execution time of the gwr. I can
% %%% create an empty variable and calculate it only if it is empty.
% 
% activations = exp(-pdist2(nodes',data','euclidean','Smallest',1));
% 
% meana = mean(activations);
% stda = std(activations);
% if ~iscell(oldwhotokill)
%     oldwhotokill = num2cell(oldwhotokill);
%     dbgmsg('Someone is making a wrong type conversion!!!',1)
% end
% whotokill = (activations<(meana-gamma*stda)).*(1:size(activations,2));
% allkill = [indexes(whotokill~=0), oldwhotokill];
% end
end