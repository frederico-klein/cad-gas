classdef gas
    properties
        params
        A
        C
        C_age
        errorvector
        hizero
        hszero
        time
        t0
        n
        r
        h
        a
        awk
        ni1
        ni2
        n1n2
        gwr
        astddev
        amean
        skippedpoints
    end
    methods
        function X = hs(gasgas, t)
            h0 = gasgas.params.h0;%= 1;
            ab = gasgas.params.ab;%= 0.95;
            tb = gasgas.params.tb;%= 3.33;
            X = h0 - gasgas.S(t)/ab*(1-exp(-ab*t/tb));
        end
        function X = hi(gasgas, t)
            h0 = gasgas.params.h0;%= 1;
            an = gasgas.params.an;%= 0.95;
            tn = gasgas.params.tn;%= 3.33;
            X = h0 - gasgas.S(t)/an*(1-exp(-an*t/tn));
        end
        function X = S(~,t)
            X = 1;
        end
        function gasgas = update_meanandstddev(gasgas, errorvect)
            gasgas.astddev = std(errorvect);
            gasgas.amean = mean(errorvect);
        end
        function [n1n2, ni1,ni2] = initialnodes(gasgas, data)
            
            RANDOMSTART = gasgas.params.RANDOMSTART;
            
            % (1)
            % pick n1 and n2 from data
            ni1 = 1;
            ni2 = 2;
            if RANDOMSTART
                nn = randperm(size(data,2),2);
                ni1 = nn(1);
                ni2 = nn(2);
            elseif isfield(gasgas.params,'startingpoint')&&~isempty('params.startingpoint')
                ni1 = gasgas.params.startingpoint(1);
                ni2 = gasgas.params.startingpoint(2);
            end
            if ni1> size(data,2)
                warning('n1 overflow. using last data point')
                n1 = data(:,end);
            else
                n1 = data(:,ni1);
            end
            if ni2> size(data,2)
                warning('n2 overflow. using last data point')
                n2 = data(:,end);
            else
                n2 = data(:,ni2);
            end
            n1n2 = [n1, n2];
        end
        function gasgas = gas_create(gasgas, params,data)
            % sets initial std and mean for activations for an untrained
            % gas
            gasgas.astddev = Inf;
            gasgas.amean = 0;
            gasgas.skippedpoints = 0;
            
            % assigns params to gas class being created
            gasgas.params = params;
            gasgas.params.accumulatedepochs = 0;
            gasgas = gasgas.gas_finalize;
            [gasgas.n1n2, gasgas.ni1,gasgas.ni2] = initialnodes(gasgas, data);
            
            %%%%
            if gasgas.params.use_gpu  %%% I wanted to cleanly move everything to the gpu only in the end of the gas initialization procedure, so that this code would make sense, but I cannot
                gasgas.n1n2 = gather(gasgas.n1n2);
            end
            
            
            %%%%%% NEW ADDITION: the adjusting weighting constant parameter
            %%%% this is not so simple because the input vectors
            if isfield(gasgas.params, 'skelldef')&&isfield(gasgas.params.skelldef, 'awk')&&isfield(params, 'layertype')
                %%% setting awk based on which layer I am in
                %%% inputlayers, q(1) and layertype influence awk :'(
                switch gasgas.params.layertype
                    case 'pos'
                        gasgas.awk = repmat(params.skelldef.awk.pos,1,params.q(1));
                    case 'vel'
                        gasgas.awk = repmat(params.skelldef.awk.vel,1,params.q(1));
                end
                gasgas.awk = reshape(gasgas.awk,[],1); %%% probably not the soundest programming here, but it solves the problem
                %%% actually this will only work for the first
                %%% concatenation. I should save and generate awk in the
                %%% same way the input is generated. this is difficult and
                %%% also probably not very useful. I will only avoid the
                %%% error.
                try
                    %%%omg,,, this bug n1 = gasgas.n1n2(:,1)
                    %n1.*gasgas.awk;
                    gasgas.n1n2(:,1).*gasgas.awk;
                catch
                    % error('Tried to use your awk definition, but I failed. Please debug')
                    gasgas.awk = ones(size(gasgas.n1n2,1),1);
                end
            else
                gasgas.awk = ones(size(gasgas.n1n2,1),1);
            end
        end
        function gasgas = gng_create(gasgas,params,data)
            
            gasgas = gasgas.gas_create(params,data);
            
            %%% gng specific init
            
            gasgas.A = zeros(size(gasgas.n1n2,1),2);
            gasgas.A(:,[1 2]) = gasgas.n1n2;
            
            % Initial connections (edges) matrix.
            edges = [0  1;
                1  0;];
            gasgas.C = edges;
            % Initial ages matrix.
            ages = [ NaN  0;
                0  NaN;];
            gasgas.C_age = ages;
            % Initial Error Vector.
            gasgas.errorvector = [0 0];
            
            gasgas.n = 0; %samplercounter
            gasgas = gasgas.gas_finalize;
        end
        function gasgas = gwr_create(gasgas, params, data)
            
            gasgas = gasgas.gas_create(params,data);
            %%% creating gwr structure
            gasgas.gwr = struct('s',[],'t',[],'wi',[],'wr',[],'ws',[],'num_of_neighbours',[],'neighbours',[]);
            gasgas.A = zeros(size(gasgas.n1n2,1),params.nodes);
            gasgas.A(:,[1 2]) = gasgas.n1n2;
            
            %%%gwr specific initialization
            %test some algorithm conditions:
            if ~(0 < params.en || params.en < params.eb || params.eb < 1)
                error('en and/or eb definitions are wrong. They are as: 0<en<eb<1.')
            end
            
            % (2)
            % initialize empty set C
            
            gasgas.C = sparse(params.nodes,params.nodes); % this is the connection matrix.
            gasgas.C_age = gasgas.C;
            
            gasgas.r = 3; %the first point to be added is the point 3 because we already have n1 and n2
            gasgas.h = zeros(1,params.nodes);%firing counter matrix
            
            %%% SPEEDUP CHANGE
            if params.STATIC
                gasgas.hizero = gasgas.hi(0)*ones(1,params.nodes);
                gasgas.hszero = gasgas.hs(0);
            else
                gasgas.time = 0;
            end
            gasgas.t0 = cputime; % my algorithm is not necessarily static!
            gasgas = gasgas.gas_finalize;
        end
        function gasgas = gas_finalize(gasgas)
            if isfield(gasgas.params, 'use_gpu')&&gasgas.params.use_gpu
                gasgas.C = gpuArray(full(gasgas.C));
                gasgas.C_age = gpuArray(full(gasgas.C_age));
                gasgas.A = gpuArray(gasgas.A);
                gasgas.errorvector = gpuArray(gasgas.errorvector);
                gasgas.hizero = gpuArray(gasgas.hizero);
                gasgas.hszero= gpuArray(gasgas.hszero);
                gasgas.time= gpuArray(gasgas.time);
                gasgas.t0= gpuArray(gasgas.t0);
                gasgas.n= gpuArray(gasgas.n);
                gasgas.r= gpuArray(gasgas.r);
                gasgas.h= gpuArray(gasgas.h);
                gasgas.a= gpuArray(gasgas.a);
                gasgas.awk= gpuArray(gasgas.awk);
                gasgas.n1n2 = gpuArray(gasgas.n1n2);
                gasgas.params.en = gpuArray(gasgas.params.en);
                gasgas.params.eb = gpuArray(gasgas.params.eb);
                gasgas.params.at = gpuArray(gasgas.params.at);
                gasgas.params.ab = gpuArray(gasgas.params.ab);
                gasgas.params.an = gpuArray(gasgas.params.an);
                gasgas.params.tb = gpuArray(gasgas.params.tb);
                gasgas.params.tn = gpuArray(gasgas.params.tn);
                gasgas.params.h0 = gpuArray(gasgas.params.h0);
                gasgas.params.amax = gpuArray(gasgas.params.amax);
                gasgas.params.STATIC = gpuArray(gasgas.params.STATIC);
                gasgas.params.eb = gpuArray(gasgas.params.eb);
                gasgas.params.nodes = gpuArray(gasgas.params.nodes);
                
                gasgas.gwr.s = gpuArray();
                gasgas.gwr.t = gpuArray();
                gasgas.gwr.wi = gpuArray();
                gasgas.gwr.wr = gpuArray();
                gasgas.gwr.ws = gpuArray();
                gasgas.gwr.num_of_neighbours = gpuArray();
                gasgas.gwr.neighbours = gpuArray();
            end
        end
        function gasgas = update_epochs(gasgas,epochs)
            if isfield(gasgas.params, 'accumulatedepochs')
                gasgas.params.accumulatedepochs = gasgas.params.accumulatedepochs + epochs;
            else
                gasgas.params.accumulatedepochs = epochs;
            end
        end
        function distvector = fnearest(gasgas,eta) %%% this seems strange and unusual, but to generate the genbestmatrix, it is simpler if I just write this wrapper like this.
            [~, ~,  ~,  ~,  ~, ~, ~,  distvector] = gasgas.findnearest(eta);
        end
        function [eta, n1,  n2,  ni1,  ni2, d1, d2,  distvector] = findnearest(gasgas,eta)
            if gasgas.params.flippoints
                % flip every which way and see which is best
                %first reshape. I will assume I am dealing with collection of
                %2d or 3d points. at some point this has to also become a
                %parameter I can turn on or off, but TO DO list...
                % this will likely not change during the execution, so it could
                % be a property, but not yet.
                %also guessing these parameters seems pretty dumb. they should
                %be defined somewhere.
                datainputsize = size(eta,1);
                if mod(datainputsize,3)==0 % it is divisible by 3, but does that mean that it is a 3d space? I will assume yes for now.
                    whattoflip = 1:7; % [1,2,4] is the old behaviour, that is, only flip each dimension once
                    xflipvect = floor(mod((whattoflip)/1,2));
                    yflipvect = floor(mod((whattoflip)/2,2));
                    zflipvect = floor(mod((whattoflip)/4,2));
                    feta = reshape(eta,[],3);
                    [n1,  n2,  ni1,  ni2, d1, d2,  distvector] = findnearest_c(gasgas,eta);
                    for dimdim = 1:length(whattoflip)
                        if xflipvect(dimdim)
                            feta(:,1) = -feta(:,1);
                        end
                        %%% so I can flip it in the y direction
                        if yflipvect(dimdim)
                            feta(:,2) = -feta(:,2);
                        end
                        %%% so I can flip it in the x direction
                        if zflipvect(dimdim)
                            feta(:,3) = -feta(:,3);
                        end
                        etaf = reshape(feta,[],1);
                        [fn1,  fn2,  fni1,  fni2, fd1, fd2,  fdistvector] = findnearest_c(gasgas,etaf);
                        if fd1< d1 %% then this flipping is the best
                            n1 = fn1;
                            n2 = fn2;
                            ni1 = fni1;
                            ni2 = fni2;
                            d1 = fd1;
                            d2 = fd2;
                            distvector = fdistvector;
                            eta = etaf;
                        end
                    end
                elseif mod(datainputsize,2)==0 % it is divisible by 3, but does that mean that it is a 3d space? I will assume yes for now.
                    feta = reshape(eta,[],2);
                    %%% so I can flip it in the x direction
                    fetaxf = feta;
                    fetaxf(:,1) = -feta(:,1);
                    %%% so I can flip it in the y direction
                    fetayf = feta;
                    fetayf(:,2) = -feta(:,2);
                    etaxf = reshape(fetaxf,[],1);
                    etayf = reshape(fetayf,[],1);
                    [n1,  n2,  ni1,  ni2, d1, d2,  distvector] = findnearest_c(gasgas,eta);
                    [xn1,  xn2,  xni1,  xni2, xd1, xd2,  xdistvector] = findnearest_c(gasgas,etaxf);
                    [yn1,  yn2,  yni1,  yni2, yd1, yd2,  ydistvector] = findnearest_c(gasgas,etayf);
                    if xd1< d1 %% then xflipping is the best
                        n1 = xn1;
                        n2 = xn2;
                        ni1 = xni1;
                        ni2 = xni2;
                        d1 = xd1;
                        d2 = xd2;
                        distvector = xdistvector;
                        eta = etaxf;
                    end
                    if yd1< d1 %% then yflipping is the best
                        n1 = yn1;
                        n2 = yn2;
                        ni1 = yni1;
                        ni2 = yni2;
                        d1 = yd1;
                        d2 = yd2;
                        distvector = ydistvector;
                        eta = etayf;
                    end
                else
                    [n1,  n2,  ni1,  ni2, d1, d2,  distvector] = findnearest_c(gasgas,eta);
                end
                %%% new addition, so that the distance is normalized by the
                %%% number of dimensions
                if gasgas.params.normdim
                    d1 = d1/length(eta); %or size(,x)?
                    d2 = d2/length(eta);
                end
            else
                [n1,  n2,  ni1,  ni2, d1, d2,  distvector] = findnearest_c(gasgas,eta);
            end
        end
        function [n1,  n2,  ni1,  ni2, d1, d2,  distvector] = findnearest_c(gasgas,eta)
            if gasgas.params.distance.simple
                distvector = gasgas.finddist(eta);
            else
                distvector = gasgas.fafdis(eta);
            end
            [n1,  n2,  ni1,  ni2, d1, d2] = gasgas.fnear(distvector);
        end
        function [n1,  n2,  ni1,  ni2, d1, d2] = fnear(gasgas, distvector)
            [d1, ni1] = min(distvector);
            n1 = gasgas.A(:, ni1);
            %pushdist = distvector(ni1);
            distvector(ni1) = NaN; % I use some cleverness. Hopefully this is fast.
            [d2, ni2] = min(distvector);
            n2 = gasgas.A(:, ni2);
            %distvector(ni1) = pushdist;
        end
        function distvector = fafdis(gasgas,eta)
            distvector = nan(1,size(gasgas.A,2));
            for i =1:size(gasgas.A,2)
                b = gasgas.A(:,i);
                distvector(i) = afdis(eta, b);
            end
            function dis = afdis(a,b)
                mata = reshape(a,[],3);
                matb = reshape(b,[],3);
                
                meana = mean(mata);
                meanb = mean(matb);
                
                ca = mata - meana;
                cb = matb - meanb;
                
                cov_ = ca.'*cb;
                
                %[u,s,v] = svd(cov_);
                [u,~,v] = svd(cov_);
                
                r_ = v*u.';
                
                tsb = cb*r_;
                tsa = (r_*ca.').';
                
                longa = a(:,1);
                longb = b(:,1);
                
                longca = reshape(ca,[],1);
                longcb = reshape(cb,[],1);
                
                longtsb = reshape(tsb,[],1);
                longtsa = reshape(tsa,[],1);
                
                %calculate the distance without any change between vectors a and b
                
                %disp('Original distance:')
                % I'm retarded...
                dis = norm(longa-longb);
                %dis = pdist2(longa',longb','euclidean','Smallest',1);
                
                %calculate the distance with means removed (centered around the centroids)
                
                %disp('Distance with means removed (a and b centered):')
                ndis = norm(longca-longcb);
                %ndis = pdist2(longca',longcb','euclidean','Smallest',1);
                
                if dis<ndis
                    warning('Removing centroids is actually worse!!!!')
                else
                    dis = ndis;
                end
                
                %calculates the distance with svd rotation matrix
                
                %disp('Distance with rotation on a, b just centered:')
                ndis1 = norm(longtsa-longcb);
                %ndis1 = pdist2(longtsa',longcb','euclidean','Smallest',1);
                
                %disp('Distance with rotation on a and b:')
                ndis2 = norm(longtsa-longtsb);% this shouldnt
                %be the fastest
                
                %disp('Distance with rotation on b, a just centered:')
                dis3 = norm(longtsb-longca);
                
                [dis,iii] = min([ndis1 dis ndis2 dis3]); %nndis = min([ndis1 ndis2 ndis3]);
                if (~(iii==1||iii==4)||abs(ndis1-dis3)>100000*eps(ndis1))&&(ndis1/norm(a)>0.01/100) %%% i mean, maybe the distances are different, but it is such a small distance that it doesn't matter. 
                    warning(['you thought that your function is always giving better results, but it doesnt!' num2str(iii)])
                end
                
            end
        end
        function distvector = finddist(gasgas,eta)
            %data = gasgas.A;
            maxindex = size(gasgas.A, 2);
            % distvector = inf(1, maxindex, 'gpuArray');
            % ni1 = 0;
            % ni2 = 0;
            ppp = repmat(eta, 1, maxindex);
            dada = gasgas.A - ppp;
            dada = dada.*dada;
            distvector = sum(dada).^(1/2);
        end
        function [n1,  n2,  ni1,  ni2, d1, d2,  distvector] = findnearest_c_old(gasgas,eta)
            %data = gasgas.A;
            maxindex = size(gasgas.A, 2);
            % distvector = inf(1, maxindex, 'gpuArray');
            % ni1 = 0;
            % ni2 = 0;
            ppp = repmat(eta, 1, maxindex);
            dada = gasgas.A - ppp;
            dada = dada.*dada;
            distvector = sum(dada).^(1/2);
            
            [d1, ni1] = min(distvector);
            n1 = gasgas.A(:, ni1);
            pushdist = distvector(ni1);
            distvector(ni1) = NaN; % I use some cleverness. Hopefully this is fast.
            [d2, ni2] = min(distvector);
            n2 = gasgas.A(:, ni2);
            distvector(ni1) = pushdist;
            
            %             %%%old version
            %             maxindex = size(data, 2);
            %             % distvector = inf(1, maxindex, 'gpuArray');
            %             % ni1 = 0;
            %             % ni2 = 0;
            %             ppp = repmat(p, 1, maxindex);
            %             dada = data - ppp;
            %             dada = dada.*dada;
            %             distvector = sum(dada).^(1/2);
            %
            %             [~, ni1] = min(distvector);
            %             n1 = data(:, ni1);
            %             pushdist = distvector(ni1);
            %             distvector(ni1) = NaN; % I use some cleverness. Hopefully this is fast.
            %             [~, ni2] = min(distvector);
            %             n2 = data(:, ni2);
            %             distvector(ni1) = pushdist;
            
        end
    end
end