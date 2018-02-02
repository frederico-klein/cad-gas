function boxshow_cst(cst)

show_bothsets = false; % if true it will create also the legends for the training set and plot more info
gas_to_plot = 'validation';

switch gas_to_plot
    case 'validation'
        gas_plot_index = 1;
    case 'training'
        gas_plot_index = 2;
end

[cst_metrics_cell,metricsname] = calculatemetrics(cst);
%metricsname = {'sensitivity','specificity','precision','f1','accuracy'};

%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
num_of_gases = size(cst_metrics_cell{1},2);
numcsttrials = length(cst_metrics_cell);
number_of_metrics = length(metricsname);
comparablenumberoftrials = Inf;
for j=1:numcsttrials
    cst_metrics = cst_metrics_cell{j};
    comparablenumberoftrials = min(comparablenumberoftrials, size(cst_metrics,1));
end
nti = 1:comparablenumberoftrials;
for j=1:numcsttrials
    cst_metrics = cst_metrics_cell{j};
    for i=1:number_of_metrics
        if show_bothsets
            plotcell{i,j} = {cst_metrics(nti,num_of_gases,i,1),cst_metrics(nti,num_of_gases,i,2)};
        else
            plotcell{i,j} = {cst_metrics(nti,num_of_gases,i, gas_plot_index)};            
        end
    end
end

for i=1:number_of_metrics
    
    ax = subplot(1,number_of_metrics,i);
    plotvar = [plotcell{i,:}];
    cfpm_v = length(plotvar); 
    plotmat = [plotvar{:}];
    p = boxplot(ax,plotmat,'notch','on','Color',colormap(winter(cfpm_v)));%,cst_metrics(:,i,whattoshow(1),2),cst_metrics(:,i,whattoshow(2),2),'Linestyle','none','Marker','o')
    title(metricsname{i});
    if show_bothsets
        legendvar = cell(numcsttrials*2,1);
    else
        legendvar = cell(numcsttrials,1);
    end
    for j = 1:size(p,2)%length(p)
        %p(j).LineStyle ='none';
        if show_bothsets
            alconstrucforcurgas = cst(ceil(j/2)).allconn{1,num_of_gases}{1,6};
        else
            alconstrucforcurgas = cst(j).allconn{1,num_of_gases}{1,6};
        end
        prefixstr = strcat( 'Nodes:', num2str(alconstrucforcurgas.nodes),' Epochs:' ,num2str(alconstrucforcurgas.MAX_EPOCHS));
        if show_bothsets            
            if mod(j,2)==0
                %p(j).Color = p(j-1).Color;
                %p(j).Marker = 'o';
                legendvar{j} = strcat(prefixstr ,' training');
            else
                %p(j).Marker = '*';
                legendvar{j} = strcat(prefixstr,' validation');
            end
        else
            legendvar{j} = prefixstr;
        end
    end
    hLegend = legend(findall(ax,'Tag','Box'), legendvar{end:-1:1});
    % if ~ishold
    %     gg = gca;
    set(ax,'YLim', [0 100]); % 'YDir', 'reverse',
    % end
end

% senplot = subplot(1,4,1); boxplot(senplot, sensitivity,'notch','on')
% title(senplot, 'Sensitivity')
% ylim(senplot,[0 100])
% speplot = subplot(1,4,2); boxplot(speplot, specificity,'notch','on')
% title(speplot, 'Specificity')
% ylim(speplot,[0 100])
% preplot = subplot(1,4,3); boxplot(preplot, precision,'notch','on')
% title(preplot, 'Precision')
% ylim(preplot,[0 100])
% f1plot = subplot(1,4,4); boxplot(f1plot, f1,'notch','on')
% title(f1plot, 'F1')
% ylim(f1plot,[0 100])