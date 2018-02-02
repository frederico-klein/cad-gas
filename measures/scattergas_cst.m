function scattergas_cst( cst )

cst_metrics_cell = calculatemetrics(cst);

%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
num_of_gases = size(cst_metrics_cell{1},2);

%whattoshow = [1,2,3];
whattoshow = [4,5,1];
numcsttrials = length(cst_metrics_cell);
plotcell = cell(num_of_gases,numcsttrials);
comparablenumberoftrials = Inf;
for j=1:numcsttrials
    cst_metrics = cst_metrics_cell{j};
    comparablenumberoftrials = min(comparablenumberoftrials, size(cst_metrics,1));
end
nti = 1:comparablenumberoftrials;
for j=1:numcsttrials
    cst_metrics = cst_metrics_cell{j};
    for i=1:num_of_gases
        plotcell{i,j} = {cst_metrics(nti,i,whattoshow(1),1),cst_metrics(nti,i,whattoshow(2),1),cst_metrics(nti,i,whattoshow(1),2),cst_metrics(nti,i,whattoshow(2),2)};
    end
end

for i=1:num_of_gases
    
    ax = subplot(1,num_of_gases,i);
    plotvar = [plotcell{i,:}];
    p = plot(ax,plotvar{:});%,cst_metrics(:,i,whattoshow(1),2),cst_metrics(:,i,whattoshow(2),2),'Linestyle','none','Marker','o')
    legendvar = cell(numcsttrials*2,1);
    for j = 1:length(p)
        p(j).LineStyle ='none';
        alconstrucforcurgas = cst(ceil(j/2)).allconn{1,i}{1,6}; %.MAX_EPOCHS
        prefixstr = strcat( 'Nodes:', num2str(alconstrucforcurgas.nodes),' Epochs:' ,num2str(alconstrucforcurgas.MAX_EPOCHS));
        if mod(j,2)==0
            p(j).Color = p(j-1).Color;
            p(j).Marker = 'o';
            legendvar{j} = strcat(prefixstr ,' training');
        else
            p(j).Marker = '*';
            legendvar{j} = strcat(prefixstr,' validation');
        end
    end
    legend(legendvar{:});
    % if ~ishold
    %     gg = gca;
    set(ax, 'XLim', [0 100],'YLim', [0 100]); % 'YDir', 'reverse',
    % end
end