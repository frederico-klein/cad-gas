classdef Simvar
    properties
        PARA
        P
        metrics
        realtimeclassifier
        MAX_NUM_TRIALS
        MAX_RUNNING_TIME
        method
        excfun
        model
    end
    methods
        function simvar = Simvar(varargin)
            simvar.method = '';
            simvar.excfun = '';
            
            simvar.realtimeclassifier = false;
            simvar.PARA = 1;
            simvar = simvar.updateparallelprocessors;
            
            simvar.metrics = struct;
            
            simvar.MAX_NUM_TRIALS = 1;
            simvar.MAX_RUNNING_TIME = 1;%3600*10; %%% in seconds, will stop after this
            
            if nargin>0
                for i = 1:nargin
                    switch varargin{i}{1}
                        case 'PARA'
                            simvar.PARA = varargin{i}{2};
                            simvar = simvar.updateparallelprocessors;
                    end
                end
            end
        end
        function simvar = updateparallelprocessors(simvar)
            if simvar.PARA
                simvar.P = feature('numCores');
            else
                simvar.P = 1;
            end
            
        end
        function simvar = init(simvar)
            simvar = simvar.updateparallelprocessors;
        end
        function confusions = showmetrics(simvar)
            confusions = plotconf(simvar.metrics);
            function confusions = plotconf(mt)
                %%% Reads metrics structure, loading targets and outputs and shows
                %%% confusion matrices, as well as display some nice
                %
                if size(mt,1)~=1
                    error('cannot deal well with multiply dimensions. What do you want me to do?')
                end
                
                al = length(mt);
                if isfield(mt(1).conffig, 'val')&&~isempty(mt(1).conffig.val)
                    figset = cell(6*al,1);
                    for i = 1:al
                        figset((i*6-5):i*6) = [mt(i).conffig.val mt(i).conffig.train];
                    end
                else
                    figset = cell(3*al,1);
                    for i = 1:al
                        figset((i*3-2):i*3) = mt(i).conffig.train;
                    end
                    
                end
                %%%%%%%%%%%% ->>>>> uncomment to show!
                %plotconfusion(figset{:})
                %%%%%%%%%%%% ->>>>> uncomment to show!
                confusions.a = zeros(size(figset{1},1), size(figset{1},1),size(mt,2));
                confusions.b = confusions.a;
                for i=1:size(figset,1)/6
                    index = (i-1)*6 +1;
                    [~, confusions.a(:,:,i)] = confusion(figset{index}, figset{index+1});
                    [~, confusions.b(:,:,i)] = confusion(figset{index+3}, figset{index+4});
                end
                cc.b = confusions.a;
                disp('validation')
                analyze_outcomes(cc)
                disp('training')
                analyze_outcomes(confusions)
            end
        end
    end
end
