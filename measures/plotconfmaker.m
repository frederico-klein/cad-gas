function [ss, metrics] = plotconfmaker(ss, metrics,whatIlabel)
ss.figset = {}; %% you should clear the set first if you want to rebuild them
dbgmsg('Displaying multiple confusion matrices for GWR and GNG for nodes:',num2str(labindex),0)

for j = whatIlabel
    [~,metrics(j).confusions.train,~,~] = confusion(ss.train.gas(j).y,ss.train.gas(j).class);
    ss.gas(j).fig.train = {ss.train.gas(j).y,   ss.train.gas(j).class,strcat(ss.gas(j).name,ss.gas(j).method,'T')};
    
    if isfield(ss.val, 'data')&&~isempty(ss.val.data)%&&~isempty(ss.val.data)
        [~,metrics(j).confusions.val,~,~] = confusion(ss.val.gas(j).y,ss.val.gas(j).class);      
        
        dbgmsg(ss.gas(j).name,' Confusion matrix on this validation set:',writedownmatrix(metrics(j).confusions.val),0)
        ss.gas(j).fig.val =   {ss.val.gas(j).y,     ss.val.gas(j).class,  strcat(ss.gas(j).name,ss.gas(j).method,'V')};
        %ss.figset = [ss.figset, ss.gas(j).fig.val, ss.gas(j).fig.train];
        %%%
    else
        metrics(j).confusions.val = [];
        ss.gas(j).fig.val = [];
    end
    metrics(j).conffig = ss.gas(j).fig;
end
end