function metrics = gen_cst(b)
metrics = struct;
metrics(length(b),length(b(1).mt)) = struct; %,2,size(b(1).mt(1).confusions.val,1),size(b(1).mt(1).confusions.val,2));
for ii = 1:length(b)
    for jj= 1:length(b(ii).mt)
        metrics(ii,jj).conffig = b(ii).mt(jj).conffig;
        metrics(ii,jj).val = b(ii).mt(jj).confusions.val;
        metrics(ii,jj).train = b(ii).mt(jj).confusions.train;
        if isfield( b(ii).mt(jj),'outparams')&&isfield(b(ii).mt(jj).outparams, 'accumulatedepochs')
            metrics(ii,jj).accumulatedepochs = b(ii).mt(jj).outparams.accumulatedepochs;            
        else
            metrics(ii,jj).accumulatedepochs = nan;            
        end
    end
end
% function cst = gen_cst(b)
% cst = struct([]);
% cst(end).metrics(length(b),length(b(1).mt)) = struct; %,2,size(b(1).mt(1).confusions.val,1),size(b(1).mt(1).confusions.val,2));
% for ii = 1:length(b)
%     for jj= 1:length(b(ii).mt)
%         cst(end).metrics(ii,jj).conffig = b(ii).mt(jj).conffig;
%         cst(end).metrics(ii,jj).val = b(ii).mt(jj).confusions.val;
%         cst(end).metrics(ii,jj).train = b(ii).mt(jj).confusions.train;
%         if ~isfield(b(ii).mt(jj).outparams, 'accumulatedepochs')
%             cst(end).metrics(ii,jj).accumulatedepochs = paramsZ(ii).MAX_EPOCHS;
%         else
%             cst(end).metrics(ii,jj).accumulatedepochs = b(ii).mt(jj).outparams.accumulatedepochs;
%         end
%     end
% end
end