function showconfmatrices(arq_connect, whatIlabel, metrics, ss_gas_end_fig)
%% Actual display of the confusion matrices:
metitems = [];
for j = whatIlabel
    if arq_connect(j).params.PLOTIT
        metitems = [metitems j*arq_connect(j).params.PLOTIT];
    end
end
if ~isempty(metitems)
    figure
    plotconf(metrics(metitems));
end
%plotconf(ss.figset{:})
if isfield( ss_gas_end_fig, 'val')&&~isempty( ss_gas_end_fig.val)
    figure
    plotconfusion( ss_gas_end_fig.val{:});
end
end