function params = setparsk(skelldef, argarg, params)
%% This function sets the parameters for the compressors
switch argarg
    case 'init'       
        params.skelldef = skelldef;
        % set parameters for gas:
        params.normdim = false; %% if true normalize the distance by the number of dimensions
        params.distancetype.source = 'gas'; % 'gas' or 'ext'
        params.distancetype.metric = 'euclidean';%'3dsum'; %either '3dsum' or 'euclidean'
        params.distancetype.noaffine = true; %if false will correct affine transformations on the distance function as well. Quite slow - if on ext.
        params.distancetype.cum = false;
        params.distance.simple = true; %if false will rotate stuff around to a better position. TO DO: all these distances have to be condensed into a single thing...
        params.flippoints = false;
        
        params.layertype = '';
        params.MAX_EPOCHS = [];
        params.removepoints = true;
        params.oldremovepoints = false;
        params.startdistributed = false;
        params.RANDOMSTART = false; % if true it overrides the .startingpoint variable
        params.RANDOMSET = false; %true; % if true, each sample (either alone or sliding window concatenated sample) will be presented to the gas at random
        params.savegas.resume = false; % do not set to true. not working
        params.savegas.save = false;
        %params.savegas.path = simvar.env.wheretosavestuff;
        params.savegas.parallelgases = true;
        params.savegas.parallelgasescount = 0;
        params.savegas.accurate_track_epochs = true;
        %params.savegas.P = simvar.P;
        params.startingpoint = [1 2];
        params.amax = 50; %greatest allowed age
        params.nodes = []; %maximum number of nodes/neurons in the gas
        params.numlayers = []; %%% will depend on the architecture used in simvar.
        params.en = 0.006; %epsilon subscript n
        params.eb = 0.2; %epsilon subscript b
        params.gamma = 4; % for the denoising function
        
        params.PLOTIT = false;
        params.plottingstep = 0; % zero will make it plot only every epoch
        params.plotonlyafterallepochs = true;

        params.alphaincrements.run = false;
        params.alphaincrements.zero = 0;
        params.alphaincrements.inc = 1;
        params.alphaincrements.threshold = 0.9;
        params.multigas = false; %%%% creates a different gas for each action sequence. at least it is faster.
        
        %Exclusive for gwr
        params.STATIC = true;
        %params.at = 0.999832929230424; %activity threshold
        params.at = 0.95; %activity threshold
        params.h0 = 1;
        params.ab = 0.95;
        params.an = 0.95;
        params.tb = 3.33;
        params.tn = 3.33;
        
        %Exclusive for gng
        params.age_inc                  = 1;
        params.lambda                   = 3;
        params.alpha                    = .5;     % q and f units error reduction constant.
        params.d                           = .995;   % Error reduction factor.
        
        %Exclusive for SOM
        params.nodesx = 8;
        params.nodesy = 8;
        
        %Labelling exclusive variables
        params.label.tobelabeled = true; % not used right now, to substitute whatIlabel
        params.label.prototypelabelling = @altlabeller; % @labeling is the old version
        params.label.classlabelling = @fitcknn;
        
    case 'layerdefs'
        %% Classifier structure definitions
        
        %paramsP = repmat(params,simvar.numlayers,1);
        
        params = repmat(params,10,1);
        
        %%% we need to enable the gas distance for first and
        %%% second layers only
        
%         params(1).distancetype.source = 'gas'; % or 'ext'
%         params(2).distancetype.source = 'gas'; % or 'ext'
%         params(1).at = 0.0099983; %activity threshold
%         params(2).at = 0.0099999; %activity threshold
%         params(3).at = 0.0099995; %activity threshold
%         params(4).at = 0.00999998; %activity threshold
%         params(5).at = 0.0099999; %activity threshold
         
        
end
end