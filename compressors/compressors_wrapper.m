function [A,  C , outparams, gasgas] = compressors_wrapper(inp, arq_connect)
switch arq_connect.method
    case {'gng','gwr'}'
        [A,  C , outparams, gasgas] = gas_wrapper(inp, arq_connect);
    case 'som'
        [A,  C , outparams, gasgas] = som_wrapper(inp, arq_connect);
end
end
function [A,  C , outparams, net] = som_wrapper(inp, arq_connect)
%x = simplecluster_dataset;
net = selforgmap([arq_connect.params.nodesx   arq_connect.params.nodesy  ]);
net = train(net,inp);
view(net)
y = net(inp);
BMU = vec2ind(y);
C = [];
outparams = [];
end
