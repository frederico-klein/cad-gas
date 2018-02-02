function ss = makess(lenlen,isgas)
    ss.train.indexes = [];
    ss.val.indexes = [];
    ss.test.indexes = [];
    for i = 1:lenlen % oh, I don't know how to do it elegantly
        ss.figset = {};
    end

if isgas
    inputs = struct('input_clip',[],'input',[],'input_ends',[],'oldwhotokill',struct([]), 'index', []);
    gas_data = struct('name','','class',[],'y',[],'inputs',inputs,'bestmatch',[],'bestmatchbyindex',[],'whotokill',struct([]), 'distances', []);
    %gas_methodss = struct;
    gas_methodss = struct('name','','edges',[],'nodes',[],'fig',[],'nodesl',[], 'method',[],'layertype',[],'outparams',[],'gasgas',[]); %bestmatch will have the training matrix for subsequent layers
    for i =1:lenlen
        gas_methods(i) = gas_methodss;
    end
    ss.gas = gas_methods;
    ss.train.gas = gas_data;
    ss.val.gas = gas_data;
    ss.test.gas = gas_data;    

end
end
