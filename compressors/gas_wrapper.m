function [A,  C , outparams, gasgas] = gas_wrapper(data, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%cf parisi,  2015 and cf marsland,  2002 based on the GNG algorithm from the
%guy that did the GNG algorithm for matlab

% some tiny differences: in the 2002 paper,  they want to show the learning
% of topologies ability of the GWR algorithm,  which is not our main goal.
% In this sense they have a function that can generate new points as
% pleased p(eta). This is not our case,  we will just go through our data
% 'sequentially' (or with a random permutation)

% Also,  I am not taking time into account. the h(time) function is
% therefore something that yields a constant value

% As of yet,  the gpu use is poor and not optimized,  running at 10x slower
% speed than on the cpu. Also,  resuming is only perhaps functional when not
% using parallel threads; this is due to the fact that with many different
% initialization parameters it gets hard to know exactly the
% characteristics of the gas before training time. There are many ways this
% can be solved,  it just hasn't been priority yet.

%the initial parameters for the algorithm: global maxnodes at en eb h0 ab
%an tb tn amax
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%maxnodes = params.nodes; %maximum number of nodes/neurons in the gas at =
%params.at;%0.95; %activity threshold en = params.en;%= 0.006; %epsilon
%subscript n eb = params.eb;%= 0.2; %epsilon subscript b amax =
%params.amax;%= 50; %greatest allowed age
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin == 3
    params = varargin{1};
    gastype = varargin{2};
    arq_connect = struct();
else
    arq_connect = varargin{1};
    gastype = [];
end


if isfield(arq_connect,  'params')&&~isempty(arq_connect.params)
    params = arq_connect.params;
end
if isfield(arq_connect,  'method')&&~isempty(arq_connect.method)
    gastype = arq_connect.method;
elseif 0
    gastype = 'gwr';
    %error('Method must be declared')
end
if ~isfield(params,  'savegas')
    params.savegas.name = 'gas';
    params.savegas.resume = false;
    params.savegas.path = '~/Dropbox/octave_progs/';
end

if isempty(params)
    
    NODES = 100;
    
    params = struct();
    params.normdim = true; %% if true normalize the distance by the number of dimensions
    params.use_gpu = false;
    params.PLOTIT = true; %
    params.RANDOMSTART = false; % if true it overrides the .startingpoint variable
    params.RANDOMSET = false;
    params.savegas.name = 'gas';
    params.savegas.resume = false;
    params.savegas.path = '~/Dropbox/octave_progs/';
    params.savegas.gasindex = 1;
    
    n = randperm(size(data, 2), 2);
    params.startingpoint = [n(1), n(2)];
    
    params.amax = 500; %greatest allowed age
    params.nodes = NODES; %maximum number of nodes/neurons in the gas
    params.en = 0.006; %epsilon subscript n
    params.eb = 0.2; %epsilon subscript b
    params.gamma = 1; %%% technically only for gwr since not implemented for gng yet. change this comment when this is done
    
    %Exclusive for gwr
    params.STATIC = true;
    params.MAX_EPOCHS = 1; % this means data will be run over twice
    params.at = 0.80; %activity threshold
    params.h0 = 1;
    params.ab = 0.95;
    params.an = 0.95;
    params.tb = 3.33;
    params.tn = 3.33;
    
    %Exclusive for gng
    params.age_inc                  = 1;
    params.lambda                   = 3;
    params.alpha                    = .5;     % q and f units error reduction constant.
    params.d                           = .99;   % Error reduction factor.
else
    %
    
end
if  isfield(arq_connect, 'name')&&params.savegas.resume
    params.savegas.name = strcat(arq_connect.name, '-n', num2str(params.nodes), '-s', num2str(size(data, 1)), '-q', num2str(params.q), '-i', num2str(params.savegas.gasindex));
elseif params.savegas.resume
    error('Strange arq_connect definition. ''.name'' field is needed.')
end


MAX_EPOCHS = params.MAX_EPOCHS;
PLOTIT = params.PLOTIT;

%%% things that are specific for skeletons:
if isfield(params, 'skelldef')
    skelldef = params.skelldef;
else
    skelldef = [];
end
if isfield(params, 'layertype')
    layertype = params.layertype;
else
    layertype = [];
end

if isfield(params, 'plottingstep')
    if params.plottingstep == 0
        plottingstep = size(data, 2);
    else
        plottingstep = params.plottingstep;
    end
else
    plottingstep = fix(size(data, 2)/20);
end
if ~isfield(params, 'use_gpu')|| gpuDeviceCount==0
    params.use_gpu = false;
    %or break or error or warning...
end

if PLOTIT
    figure
    plotgwr() % clears plot variables
end

datasetsize = size(data, 2);
errorvect = nan(1, MAX_EPOCHS*datasetsize);
epochvect = nan(1, MAX_EPOCHS*datasetsize);
nodesvect = nan(1, MAX_EPOCHS*datasetsize);

if  params.use_gpu
    data = gpuArray(data);
    errorvect = gpuArray(errorvect);
    epochvect = gpuArray(epochvect);
    nodesvect = gpuArray(nodesvect);
end


switch gastype
    case 'gwr'
        gasfun = @gwr_core;
        gasgas = gas;
        gasgas = gasgas.gwr_create(params, data);
    case 'gng'
        gasfun = @gng_core;
        gasgas = gas;
        gasgas = gasgas.gng_create(params, data);
    otherwise
        error('Unknown method.')
end

%%% ok, I will need to be able to resume working on a gas if I want to
if isfield(params, 'savegas')&&params.savegas.resume
    savegas = strcat(params.savegas.path, '/', params.savegas.name);
    %%% checks if savegas exists
    if 0&&exist(savegas, 'file') %%% if it does, then it loads it, because it should have the same %% disabled
        %dbgmsg('Found gas with the same characteristics as this one. Will try loading gas', params.savegas.name, 1)
        load(savegas)
        try
            gasfun(data(:, 1), gasgas);
        catch
            %dbgmsg('I failed. Will start a new gas. ')
            
            switch gastype
                case 'gwr'
                    gasfun = @gwr_core;
                    gasgas = gas;
                    gasgas = gasgas.gwr_create(params, data);
                case 'gng'
                    gasfun = @gng_core;
                    gasgas = gas;
                    gasgas = gasgas.gng_create(params, data);
                otherwise
                    error('Unknown method.')
            end
        end
    else
        %dbgmsg('Didn''t find gas with the same characteristics as this one. Will use a new gas with name:\t', params.savegas.name, 1)
    end
end


therealk = 0; %% a real counter for epochs

alphaincrement = params.alphaincrements.zero;
%%%starting main loop
while(isnan(nodesvect(end))||nodesvect(end)<gasgas.params.nodes*params.alphaincrements.threshold) %%%% these need to be changed for each gas because they are dependent on the values of the input
    if params.alphaincrements.run
        alphaincrement = alphaincrement +params.alphaincrements.inc ;
        gasgas.params.at = 1-exp(-alphaincrement);
    end
    for num_of_epochs = 1:MAX_EPOCHS % strange idea: go through the dataset more times - actually this makes it overfit the data, but, still it is interesting.
        
        if params.RANDOMSET
            kset = randperm(datasetsize);
        else
            kset = 1:datasetsize;
            if params.RANDOMSTART %% IF THE START IS RANDOM SO SHOULD BE THE BEGGING OF THE DATASET
                kset = circshift(kset,randperm(datasetsize,1));
            end
            %%%%
            if params.startdistributed
                a = kset(1:ceil(size(kset,2)/params.nodes):end);
                b = setdiff(kset,a);
                kset = [a,b];
            end
        end
        % start of the loop
        for k = kset %step 1
            therealk = therealk+1;
            
            gasgas = gasfun(data(:, k), gasgas);
            
            %to make it look nice...
            errorvect(therealk) = gasgas.a;
            epochvect(therealk) = therealk;
            nodesvect(therealk) = gasgas.r-1;
            if PLOTIT&&mod(k, plottingstep)==0&&numlabs==1&&~params.plotonlyafterallepochs % also checks to see if it is inside a parpool
                plotgwr(gasgas.A, gasgas.C, errorvect, epochvect, nodesvect, skelldef, layertype)
                drawnow
            end
        end
        
        % updating the number of epochs the gas has run
        gasgas = gasgas.update_epochs(num_of_epochs);
        
        % updating the standard deviation of activations:
        gasgas = gasgas.update_meanandstddev(errorvect(1:therealk));
        
        % now save the resulting gas
        if isfield(params, 'savegas')&&isfield(params.savegas, 'save')&&params.savegas.save
            save(strcat(savegas, '-e', num2str(num_of_epochs)), 'gasgas')
        end
    end
    disp(['reached:' num2str(nodesvect(end))] )
    if PLOTIT&&numlabs==1&&params.plotonlyafterallepochs
        plotgwr(gasgas.A, gasgas.C, errorvect, epochvect, nodesvect, skelldef, layertype)
        drawnow
    end
    % disp('==========================================================================================')
    % disp(['final number of nodes reached: ' num2str(nodesvect(end))])
    %
    if ~params.alphaincrements.run %%% jumps out of while loop after this single execution if we are not running incremental alphas. 
        break
    end
end
outparams.graph.errorvect = errorvect;
outparams.graph.epochvect = epochvect;
outparams.graph.nodesvect = nodesvect;
outparams.accumulatedepochs = gasgas.params.accumulatedepochs;
outparams.initialnodes = [gasgas.ni1, gasgas.ni2];
A = gasgas.A;
C = gasgas.C;
disp('==========================================================================================')
disp('==========================================================================================')
disp(['final number of nodes reached: ' num2str(nodesvect(end))])
disp('==========================================================================================')
disp('==========================================================================================')

end %#codegen
function gasgas = gng_core(eta, gasgas)

PARAMS = gasgas.params;
% Unsupervised Self Organizing Map. Growing Neural Gas (GNG) Algorithm.

% Main paper used for development of this neural network was:
% Fritzke B. "A Growing Neural Gas Network Learns Topologies", in
%                         Advances in Neural Information Processing Systems, MIT Press, Cambridge MA, 1995.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%NumOfEpochs   = 5;
%NumOfSamples = fix(size(Data, 2)/NumOfEpochs);
%age_inc               = PARAMS.age_inc;
%max_age             = PARAMS.amax;
max_nodes               = PARAMS.nodes;
%eb                         = PARAMS.eb;
%en                         = PARAMS.en;
lamda                   = PARAMS.lambda;%3;
alpha                    = PARAMS.alpha;%.5;     % q and f units error reduction constant.
d                           = PARAMS.d;%.99;   % Error reduction factor.

%RMSE                  = zeros(1, NumOfEpochs);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Define the params vector where the GNG algorithm parameters are stored:
params = [ PARAMS.age_inc;
    PARAMS.amax;
    PARAMS.nodes;
    PARAMS.eb;
    PARAMS.en;
    PARAMS.alpha;
    PARAMS.lambda;
    PARAMS.d;
    0;   % Here, we insert the sample counter.
    1;   % This is reserved for s1 (bmu);
    2;]; % This is reserved for s2 (secbmu);

n = gasgas.n;
ages = gasgas.C_age;
nodes = gasgas.A;
edges = gasgas.C;
errorvector = gasgas.errorvector;


NumOfNodes = size(nodes, 2);
params(9) = gasgas.n;

% Step 2. Find the two nearest units s1 and s2 to the new data sample.
[s1, s2, distances] = findTwoNearest(eta, nodes);
params(10) = s1;
params(11) = s2;

% Steps 3-6. Increment the age of all edges emanating from s1 .
[nodes, edges, ages, errorvector] = edgeManagement(eta, nodes, edges, ages, errorvector, distances, params);

% Step 7. Dead Node Removal Procedure.
[nodes, edges, ages, errorvector] = removeUnconnected(nodes, edges, ages, errorvector);

% Step 8. Node Insertion Procedure.
if mod(n, lamda)==0 && size(nodes, 2)<max_nodes
    [nodes, edges, ages, errorvector] = addNewNeuron(nodes, edges, ages, errorvector, alpha);
end

% Step 9. Finally, decrease the error of all units.
gasgas.errorvector = d*errorvector;

%update n
n = n+1;
%%%% writing stuff to gas:

gasgas.C_age = ages;
gasgas.A = nodes;
gasgas.C = edges;
gasgas.n = n;
gasgas.a = norm(errorvector)/sqrt(NumOfNodes);
gasgas.r = NumOfNodes+1;

end
function [s1, s2, distances] = findTwoNearest(Input, nodes) %#codegen

NumOfNodes = size(nodes, 2);

distances = zeros(1, NumOfNodes);
for i=1:NumOfNodes
    distances(i) = norm(Input - nodes(:, i));
end

[~, indices] = sort(distances);

s1 = indices(1);
s2 = indices(2);

% MEX Code Generation:

% mexcfg = coder.config('mex');
% mexcfg.DynamicMemoryAllocation = 'AllVariableSizeArrays';
% codegen -config mexcfg findTwoNearest -args {coder.typeof(In(:, n), [Inf 1]), coder.typeof(nodes, [Inf Inf])}

end
function [nodes, edges, ages, error] = edgeManagement(Input, nodes, edges, ages, error, distances, params)  %#codegen

age_inc   = params(1);
max_age = params(2);
eb = params(4);
en = params(5);
s1 = params(10);
s2 = params(11);

NumOfNodes = size(nodes, 2);

% Step 3. Increment the age of all edges emanating from s1.
s1_Neighbors = find(edges(:, s1)==1);
SizeOfNeighborhood = length(s1_Neighbors);

ages(s1_Neighbors, s1) = ages(s1_Neighbors, s1) + age_inc;
ages(s1, s1_Neighbors) = ages(s1_Neighbors, s1);

% Step 4. Add the squared distance to a local error counter variable:
error(s1) = error(s1) + distances(s1)^2;

% Step 5. Move s1 and its topological neighbors towards î.
nodes(:, s1) = nodes(:, s1) + eb*(Input-nodes(:, s1));
nodes(:, s1_Neighbors) = nodes(:, s1_Neighbors) + en*(repmat(Input, [1 SizeOfNeighborhood])-nodes(:, s1_Neighbors));

% Step 6.
% If s1 and s2 are connected by an edge, set the age of this edge to zero.
% If such an edge does not exist, create it.
edges(s1, s2) = 1;
edges(s2, s1) = 1;
ages(s1, s2) = 0;
ages(s2, s1) = 0;

% Step 7. Remove edges with an age>max_age.
[DelRow, DelCol] = find(ages>max_age);
SizeDeletion = length(DelRow);
for i=1:SizeDeletion
    edges(DelRow(i), DelCol(i)) = 0;
    ages(DelRow(i), DelCol(i)) = NaN;
end

% MEX-code generation:

% mexcfg = coder.config('mex');
% mexcfg.DynamicMemoryAllocation = 'AllVariableSizeArrays';
% codegen -config mexcfg edgeManagement.m -args {coder.typeof(In(:, n), [Inf 1]), coder.typeof(nodes, [Inf Inf]), coder.typeof(edges, [Inf Inf]), coder.typeof(ages, [Inf Inf]), coder.typeof(error, [1 Inf]), coder.typeof(distances, [1 Inf]), coder.typeof(params, [11, 1])}
end
function [nodes, edges, ages, error] = addNewNeuron(nodes, edges, ages, error, alpha)  %#codegen
% Checks whether this function is
% suitable for automatic .mex code generation.
NumOfNodes = size(nodes, 2);

[~, q] = max(error);

% Find q-Neighborhood
q_Neighbors = find(edges(:, q)==1);

% Find the neighbor f with the largest accumulated error.
[~, index] = max(error(q_Neighbors));
f = q_Neighbors(index);

% Add the new node half-way between nodes q and f:
nodes = [nodes .5*(nodes(:, q) + nodes(:, f))];

% Remove the original edge between q and f.
edges(q, f) = 0;
edges(f, q) = 0;
ages(q, f) = NaN;
ages(f, q) = NaN;

NumOfNodes = NumOfNodes + 1;
r = NumOfNodes;

% Insert edges connecting the new unit r with units q anf f.
edges = [edges  zeros(NumOfNodes-1, 1)];
edges = [edges; zeros(1, NumOfNodes)];

edges(q, r) = 1;
edges(r, q) = 1;
edges(f, r) = 1;
edges(r, f) = 1;

ages = [ages  NaN*ones(NumOfNodes-1, 1)];
ages = [ages; NaN*ones(1, NumOfNodes)];

ages(q, r) = 0;
ages(r, q) = 0;
ages(f, r) = 0;
ages(r, f) = 0;

error(q) = alpha*error(q);
error(f) = alpha*error(f);

error = [error error(q)];

% MEX-code Generation:

% mexcfg = coder.config('mex');
% mexcfg.DynamicMemoryAllocation = 'AllVariableSizeArrays';
% codegen -config mexcfg addNewNeuron.m -args {coder.typeof(nodes, [Inf Inf]), coder.typeof(edges, [Inf Inf]), coder.typeof(ages, [Inf Inf]), coder.typeof(error, [1 Inf]), double(0)}
end
function [nodes, edges, ages, error] = removeUnconnected(nodes, edges, ages, error) %#codegen

NumOfNodes = size(nodes, 2);

i = 1;
while NumOfNodes >= i
    if any(edges(i, :)) == 0
        
        edges = [edges(1:i-1, :); edges(i+1:NumOfNodes, :);];
        edges = [edges(:, 1:i-1)  edges(:, i+1:NumOfNodes);];
        
        ages = [ages(1:i-1, :); ages(i+1:NumOfNodes, :);];
        ages = [ages(:, 1:i-1)  ages(:, i+1:NumOfNodes);];
        
        nodes = [nodes(:, 1:i-1) nodes(:, i+1:NumOfNodes);];
        error = [error(1, 1:i-1) error(1, i+1:NumOfNodes);];
        
        NumOfNodes = NumOfNodes - 1;
        
        i = i -1;
    end
    i = i+1;
end

% MEX-code generation

% mexcfg = coder.config('mex');
% mexcfg.DynamicMemoryAllocation = 'AllVariableSizeArrays';
% codegen -config mexcfg removeUnconnected -args {coder.typeof(nodes, [Inf Inf]), coder.typeof(edges, [Inf Inf]), coder.typeof(ages, [Inf Inf]), coder.typeof(error, [1 Inf])}
end
function [gas]= gwr_core(eta, gas)

%A = gas.A;
%C = gas.C;
%C_age = gas.C_age;
%h = gas.h;
%r = gas.r;
%hizero = gas.hizero;
%hszero = gas.hszero;
%awk = gas.awk;
%params = gas.params;
%en = params.en;
%eb = params.eb;

%%%%%%%%%%%%%%%%%%% ATTENTION STILL MISSING FIRING RATE! will have problems
%%%%%%%%%%%%%%%%%%% when algorithm not static!!!!
%%%%%%%%%%%%%%%%%%%

%eta = data(:, k); % this the k-th data sample
[eta, gas.gwr.ws, ~, gas.gwr.s, gas.gwr.t,d1,~, ~] = gas.findnearest(eta); %step 2 and 3

%%% changed order so I can avoid changing anything in the algorithm if the
%%% point is too unusual
%gas.a = exp(-norm((eta-gas.gwr.ws).*gas.awk)); %step 5
%%% changed the expression so that I don't need to calculate the distance
%%% twice. note that awk now does nothing.
gas.a = exp(-d1); %step 5

if gas.params.removepoints&&(gas.a < gas.amean - gas.params.gamma*gas.astddev)
    gas.skippedpoints = gas.skippedpoints +1;
    return
end

if gas.C(gas.gwr.s, gas.gwr.t)==0 %step 4
    gas.C = spdi_bind(gas.C, gas.gwr.s, gas.gwr.t);
else
    gas.C_age = spdi_del(gas.C_age, gas.gwr.s, gas.gwr.t);
end

%algorithm has some issues, so here I will calculate the neighbours of
%s
[gas.gwr.neighbours] = findneighbours(gas.gwr.s, gas.C);
gas.gwr.num_of_neighbours = size(gas.gwr.neighbours, 2);

if (gas.a < gas.params.at) && (gas.r <= gas.params.nodes) %step 6
    gas.gwr.wr = 0.5*(gas.gwr.ws+eta); %too low activity, needs to create new node r
    gas.A(:, gas.r) = gas.gwr.wr;
    gas.C = spdi_bind(gas.C, gas.gwr.t, gas.r);
    gas.C = spdi_bind(gas.C, gas.gwr.s, gas.r);
    gas.C = spdi_del(gas.C, gas.gwr.s, gas.gwr.t);
    gas.r = gas.r+1;
else %step 7
    %for j = 1:gas.gwr.num_of_neighbours % check this for possible indexing errors
    %       i = gas.gwr.neighbours(j);
    %size(A)
    gas.gwr.wi = gas.A(:, gas.gwr.neighbours);
    gas.A(:, gas.gwr.neighbours) = gas.gwr.wi + gas.params.en*(repmat(eta, 1, gas.gwr.num_of_neighbours)-gas.gwr.wi).*repmat(gas.h(gas.gwr.neighbours), size(eta, 1), 1);
    %end
    %     for j = 1:gas.gwr.num_of_neighbours % check this for possible indexing errors
    %         i = gas.gwr.neighbours(j);
    %         %size(A)
    %         gas.gwr.wi = gas.A(:, i);
    %         gas.A(:, i) = gas.gwr.wi + gas.params.en*gas.h(i)*(eta-gas.gwr.wi);
    %     end
    gas.A(:, gas.gwr.s) = gas.gwr.ws + gas.params.eb*gas.h(gas.gwr.s)*(eta-gas.gwr.ws); %adjusts nearest point MORE;;; also, I need to adjust this after the for loop or the for loop would reset this!!!
end
%step 8 : age edges with end at s
%first we need to find if the edges connect to s

% for j = 1:gas.gwr.num_of_neighbours % check this for possible indexing errors
%     i = gas.gwr.neighbours(j);
gas.C_age = spdi_add(gas.C_age, gas.gwr.s, gas.gwr.neighbours);
% end
% for j = 1:gas.gwr.num_of_neighbours % check this for possible indexing errors
%     i = gas.gwr.neighbours(j);
%     gas.C_age = spdi_add(gas.C_age, gas.gwr.s, i);
% end


%step 9: again we do it inverted, for loop first
%%%% this strange check is a speedup for the case when the algorithm is static
if gas.params.STATIC % skips this if algorithm is static
    gas.h = gas.hizero;
    gas.h(gas.gwr.s) = gas.hszero;
else
    for i = 1:gas.r %%% since this value is the same for all I can compute it once and then make all the array have the same value...
        gas.h(i) = gas.hi(gas.time, gas.params); %ok, is this sloppy or what? t for the second nearest point and t for time
    end
    gas.h(gas.gwr.s) = gas.hs(gas.time, gas.params);
    gas.time = (cputime - gas.t0)*1;
end

%step 10: check if a node has no edges and delete them
%[C, A, C_age, h, r ] = removenode(C, A, C_age, h, r);
%check for old edges

% makes the algorithm slightly faster when the matrices are not full
if gas.r > gas.params.nodes
    %R = gas.params.nodes;
    [gas.C, gas.C_age ] = removeedge(gas.C, gas.C_age, gas.params.amax);
    [gas.C, gas.A, gas.C_age, gas.h, gas.r ] = removenode(gas.C, gas.A,  gas.C_age,  gas.h,  gas.r);
elseif gas.r>2
    R = gas.r-1;
    [gas.C(1:R, 1:R), gas.C_age(1:R, 1:R) ] = removeedge(gas.C(1:R, 1:R), gas.C_age(1:R, 1:R), gas.params.amax);
    [gas.C(1:R, 1:R), gas.A(:, 1:R), gas.C_age(1:R, 1:R), gas.h, gas.r ] = removenode(gas.C(1:R, 1:R), gas.A(:, 1:R),  gas.C_age(1:R, 1:R),  gas.h,  gas.r);
end
%
% if gas.r>2 % don't remove everything
%     [gas.C(1:R, 1:R), gas.C_age(1:R, 1:R) ] = removeedge(gas.C(1:R, 1:R), gas.C_age(1:R, 1:R), gas.params.amax);
%     [gas.C(1:R, 1:R), gas.A(:, 1:R), gas.C_age(1:R, 1:R), gas.h, gas.r ] = removenode(gas.C(1:R, 1:R), gas.A(:, 1:R),  gas.C_age(1:R, 1:R),  gas.h,  gas.r);       %inverted order as it says on the algorithm to remove points faster
% end

%gas.A = A;
%gas.C = C;
%gas.C_age = C_age;
%gas.h = h;
%gas.r = r;
%gas.a = a;
end
function sparsemat = spdi_add(sparsemat,  a,  b) %increases the number so that I don't have to type this all the time and forget it...
sparsemat(a, b) = sparsemat(a, b) + 1;
sparsemat(b, a) = sparsemat(a, b) + 1;
end
function sparsemat = spdi_bind(sparsemat,  a,  b) % adds a 2 way connection,  so that I don't have to type this all the time and forget it...
sparsemat(a, b) = 1;
sparsemat(b, a) = 1;
end
function sparsemat = spdi_del(sparsemat,  a,  b) % removes a 2 way connection,  so that I don't have to type this all the time and forget it...
sparsemat(a, b) = 0;
sparsemat(b, a) = 0;
end
function [C,  C_age, row ] = removeedge(C,  C_age,  amax)
[row,  col] = find(C_age > amax);
a = size(row, 2);
if ~isempty(row)
    for i = 1:a
        C_age(row(i), col(i)) = 0;
        C_age(col(i), row(i)) = 0;
        C(row(i), col(i)) = 0;
        C(col(i), row(i)) = 0;
    end
end
end
function [C,  A,  C_age,  h, r ] = removenode(C,  A,  C_age,  h, r) %depends only on C operates on everything
pointstoremove = find(~any(C));
if ~isempty(pointstoremove)
    numnum = length(pointstoremove); %sloppy,  I know...
    C = clipsimmat(C, pointstoremove, numnum);
    if any(pointstoremove>size(A, 2))
        disp('wrong stuff going on')
    end
    A = clipA(A, pointstoremove, numnum);
    C_age = clipsimmat(C_age, pointstoremove, numnum);
    h = clipvect(h, pointstoremove, numnum);
    r = r-numnum;
    if r<1||r~=fix(r)
        error('something fishy happening. r is either zero or fractionary!')
    end
end
end
function C = clipsimmat(C, i, n)
C(i, :) = [];
C(:, i) = [];
C = padarray(C, [n n], 'post');
end
function V = clipvect(V,  i,  n)
V(i) = [];
V = [V zeros(1, n)];
end
function A = clipA(A,  i, n)
A(:, i) = [];
ZERO = zeros(size(A, 1), n);
A = [A ZERO];
end
function neighbours = findneighbours(s, C)
ne = find(C(s, :));
neighbours = ne(ne~=0);
end

function [n1,  n2,  ni1,  ni2,  distvector] = findnearest_deactivated(p, data)
maxindex = size(data, 2);
% distvector = inf(1, maxindex, 'gpuArray');
% ni1 = 0;
% ni2 = 0;
ppp = repmat(p, 1, maxindex);
dada = data - ppp;
dada = dada.*dada;
distvector = sum(dada).^(1/2);

[~, ni1] = min(distvector);
n1 = data(:, ni1);
pushdist = distvector(ni1);
distvector(ni1) = NaN; % I use some cleverness. Hopefully this is fast.
[~, ni2] = min(distvector);
n2 = data(:, ni2);
distvector(ni1) = pushdist;
end