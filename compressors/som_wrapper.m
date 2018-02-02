function [A,  C , outparams, net, distances, BMU] = som_wrapper(inp, arq_connect)
%x = simplecluster_dataset;
net = selforgmap([arq_connect.params.nodesx   arq_connect.params.nodesy  ]);
net = train(net,inp);
view(net)
y = net(inp);
BMU = vec2ind(y);
C = [];
outparams = [];
distances = [];
warning('LOTS OF VARIABLES NOT IMPLEMENTED!!!!')

A = net.IW;
end
