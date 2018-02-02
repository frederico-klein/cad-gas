function [endacc, combinedval] = analyze_outcomes(varvar)
%%%% can receive the simvar or the outcomes as a struct
if isstruct(varvar)
    if isfield(varvar, 'trial')
        simvar = varvar;
        clear varvar
        combsize = [size(simvar.trial(1).metrics(1, 1).val) size(simvar.trial(1).metrics,2)];
        combinedval = zeros(combsize);
        for i=1:size(simvar.trial,2)
            for gaslayer = 1: size(simvar.trial(1).metrics,2)
                for worker =1:size(simvar.trial(1).metrics,1)
                    combinedval(:,:,gaslayer) = simvar.trial(i).metrics(worker, gaslayer).val + combinedval(:,:,gaslayer);
                end
            end
        end
        endaccsize = size(simvar.trial(1).metrics,2);
    elseif isfield(varvar, 'b')
        outcomes = varvar;
        clear varvar
        i = 1;
        while(isempty(outcomes(i).b))
            i = i+1;
        end
        combinedval = zeros(size(outcomes(i).b));
        endaccsize = size(outcomes(i).b,3);
        %combinedval = zeros(size(outcomes(1).b));
        for i =1:length(outcomes)
            if ~isempty(outcomes(i).b)
                combinedval = combinedval + outcomes(i).b;
            end
        end
        %endaccsize = size(outcomes(1).b,3);
    else
        error('Unknown structure type')
    end
else
    error('Unknown input type')
end



endacc = zeros(endaccsize,1);
for gaslayer = 1: endaccsize
    endacc(gaslayer) = sum(diag(combinedval(:,:,gaslayer)))/sum(sum(combinedval(:,:,gaslayer)));%%% actually some function of combinedval, but not now...
end