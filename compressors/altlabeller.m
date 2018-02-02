function nodecount = altlabeller(bmbi, nodes, data, y)
%disp('hello')
numnodes = max(bmbi);

%%% this labeller has an additional problem that it may leave some points
%%% without any label . this will make a 0/0 division and some points will
%%% be labelled NaN. 
%%% to prevent this we initialize nodecount it with the old labelling type
%%% so instead of:
%nodecount = zeros(size(y,1),numnodes);
%%% we write
nodecount = labeling([],nodes, data, y);
%%% now this ofc creates the issue of importance, which is most important,
%%% the previous label or the new one. Right now its importance is equal to
%%% one sample. there should be obviously a scalling factor that could be
%%% adjusted. Right now I will leave it alone, since there are already too
%%% many parameters to adjust. 

for node =1:numnodes
    for i = 1:size(bmbi,2)
        if bmbi(i) == node
        nodecount(:,node) = nodecount(:,node) +y(:,i);
        end
    end
    nodecount(:,node) = nodecount(:,node)/sum(nodecount(:,node)); %%% so that is adds to one
end