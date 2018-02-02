function [ff, metricsname]= calculatemetrics(cst)
cstsize = length(cst);
ff = cell(cstsize,1);

metricsname = {'sensitivity','specificity','precision','f1','accuracy'};

for k = 1:cstsize
    
    [gasindex,gaslayer] = size(cst(k).metrics);
    
    A = zeros(2);
    f = zeros(gasindex,gaslayer,5,2);
    for i = 1:gasindex
        for j = 1:gaslayer
            
            A = cst(k).metrics(i,j).val;
            
            f(i,j,:,1) = allmetrics(A);
            
            A = cst(k).metrics(i,j).train;
            
            f(i,j,:,2) = allmetrics(A);
        end
    end
    ff{k} = f;
end
end
function mts = allmetrics(A)
if size(A,1)>2
    error('Calculate metrics with multiclass problems not implemented!')
end
sensitivity = A(2,2)/(A(2,2)+A(1,2));
specificity = A(1,1)/(A(1,1)+A(2,1));
precision = A(2,2)/(A(2,2)+A(2,1));
f1 = 2*A(2,2)/(2*A(2,2)+A(2,1)+A(1,2));
accuracy = (A(1,1)+A(2,2))/(A(1,1)+A(2,2)+A(1,2)+A(2,1));
mts = [sensitivity specificity precision f1 accuracy]*100;
end


