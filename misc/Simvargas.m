classdef Simvargas < Simvar
    properties
        allconn
        NODES_VECT
        MAX_EPOCHS_VECT
        ARCH_VECT
        numlayers
        arq_connect
    end
    methods
        function simvar = Simvargas(varargin)
            %% Object Initialization %%
            % Call superclass constructor before accessing object
            % You cannot conditionalize this statement
            simvar = simvar@Simvar(varargin{:});
            
            %% Post initialization
            simvar.method = 'gas';
            %simvar.excfun = @(data,ii)executioncore_in_starterscript(simvar(ii).arq_connect, data); %useless to set here, since arq_connect is empty! 
            simvar.allconn = [];
            
            simvar.NODES_VECT = [3]; %%% minimum number is 3
            simvar.MAX_EPOCHS_VECT = [1];
            simvar.ARCH_VECT = [1];
            
            
        end
        function simvar = init(simvar,params,parsc, useroptions)
            simvar.numlayers = (length(baq(allconnset(simvar.ARCH_VECT, [],[],useroptions))));
            simvar = simvar.loop(params,parsc,useroptions);
            %%% I need to set after everything is done, since in the 
            %%% not sure this is correct, this function should loop inside
            %%% loop...
            %%% also numlayers also varies, so this is very bad... maybe
            %%% all of this should just be the loop, or inside the loop. 
            for i = 1:length(simvar)
                simvar(i).excfun = @(data,ii)executioncore_in_starterscript(simvar(ii).arq_connect, data);
            end
        end
        function [endacc, combinedval] = analyze_outcomes(simvartrial)
            if isempty(simvartrial.metrics)
                error('Metrics not set! Ending.')
            end
            combsize = [size(simvartrial(1).metrics(1, 1).val) size(simvartrial(1).metrics,2)];
            combinedval = zeros(combsize);
            for i=1:size(simvartrial.metrics,3)
                for gaslayer = 1: size(simvartrial(1).metrics,2)
                    for worker =1:size(simvartrial(1).metrics,1)
                        %%doesn't exist anymore... this will break all the time if I
                        %%insist on using workers for different things.
                        %worker = 1;
                        combinedval(:,:,gaslayer) = simvartrial.metrics(worker, gaslayer,i).val + combinedval(:,:,gaslayer);
                    end
                end
            end
            endaccsize = size(simvartrial(1).metrics,2);
            endacc = zeros(endaccsize,1);
            for gaslayer = 1: endaccsize
                endacc(gaslayer) = sum(diag(combinedval(:,:,gaslayer)))/sum(sum(combinedval(:,:,gaslayer)));%%% actually some function of combinedval, but not now...
            end
        end
        function simvartrial = loop(simvar,params,parsc,useroptions)
            %% Begin loop
            trialcount = 0;
            simvartrial = repmat(simvar,length(simvar.ARCH_VECT)*length(simvar.NODES_VECT)*length(simvar.MAX_EPOCHS_VECT),1);
            for architectures = simvar.ARCH_VECT
                for NODES = simvar.NODES_VECT
                    for MAX_EPOCHS = simvar.MAX_EPOCHS_VECT
                        if NODES ==100000 && (simvar.MAX_EPOCHS==1||simvar.MAX_EPOCHS==1)
                            dbgmsg('Did this already',1)
                            break
                        end
                        trialcount = trialcount +1;
                        params.MAX_EPOCHS = MAX_EPOCHS;% simvar.trial(trialcount).MAX_EPOCHS;
                        params.nodes = NODES;%simvar.trial(trialcount).NODES; %maximum number of nodes/neurons in the gas
                        
                        %%%
                        parsk_ = setparsk([], 'layerdefs', params);
                        parsc_ = setparsc('layerdefs', parsc);
                        %parsc = setparsc();
                        simvartrial(trialcount).allconn = allconnset(architectures, parsk_, parsc_,useroptions);
                        
                        %%% ATTENTION 2: PARALLEL PROCESSES ARE NO LONGER DOING WHAT THEY
                        %%% USUALLY DID. SO THEY ARE NOT STARTING THE GAS AT DIFFERENT
                        %%% RANDOM POINTS. ALTHOUGH THAT SEEMS LIKE A GOOD IDEA, I NEED
                        %%% PARALLEL PROCESSING FOR OTHER THINGS, AND THIS WILL HAVE TO
                        %%% WAIT.
                        
                        
                        %             %% Setting up different parameters for each of parallel trial
                        %             % Maybe you want to do that; in case you don't, then we just
                        %             % use a for to put the same parameters for each.
                        %             paramsZ = repmat(paramsP,1,simvar.P);
                        %             for i = 1:simvar.P
                        %                 %paramsZ(i) = params;
                        %
                        %                 n = randperm(size(data.train.data,2),2);
                        %                 paramsZ(1,i).startingpoint = [n(1) n(2)];
                        %                 simvartrial(trialcount).allconn{1,1}{1,6} = paramsZ(i); % I only change the initial points of the position gas
                        %                 %pallconn{1,3}{1,6} = paramsZ; %but I want the concatenation to reflect the same position that I randomized. actually this is not going to happen because of the sliding window scheme
                        %                 %pallconn{1,4}{1,6} = pallconn{1,2}{1,6};
                        %                 simvartrial(trialcount).arq_connect(i,:) = baq(simvartrial(trialcount).allconn);
                        %
                        %             end
                        %
                        simvartrial(trialcount).arq_connect = baq(simvartrial(trialcount).allconn);
                    end
                    
                end
            end
        end
    end
end
