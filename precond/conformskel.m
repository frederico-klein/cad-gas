function [conformstruc, skelldef] = conformskel(varargin )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dbgmsg('Applies preconditioning functions to both training and validation datasets')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath('precond/precondfun')
test = false;
skelldef = struct();
extskeldef = struct();
conformstruc = struct('data', [],'y',[]);

%%% setting up variables to remove zeros from some kernels and hopefully
%%% still allow the gas to work.
nonmatrixkilldim = [];
nonmatrixkilldim_proposals = [];

%%% some old error checking, maybe useless now.
if isempty(varargin)||strcmp(varargin{1},'test')||(isstruct(varargin{1})&&isfield(varargin{1},'data')&&isempty(varargin{1}.data))||isempty(varargin{1})
    %maybe warn that I am not doing anything\?
    return
else
    conformstruc = varargin{1};
    lindx = 2;
    awk = generate_awk(conformstruc.data);
    
    %%% initiallize variables to make skelldef
    killdim = [];
    skelldef.realkilldim = [];
    skelldef.length = size(conformstruc.data,1);
    skelldef.elementorder = 1:skelldef.length;
    
    switch skelldef.length
        case {75,60,45}
            skelldef.awk.pos = repmat(awk(setdiff(1:skelldef.length/3,killdim)),3,1);
            skelldef.awk.vel = [];
            skelldef.novel = true;
        case {150,120,90}
            skelldef.awk.pos = repmat(awk(setdiff(1:skelldef.length/6,killdim)),3,1);
            skelldef.awk.vel = repmat(awk(setdiff(1:skelldef.length/6,killdim)),3,1);
            skelldef.novel = false;
    end
    
    %%%
    skelldef.bodyparts = genbodyparts(skelldef.length);
    
    % creates the function handle cell array
    conformations = {};
    killdim = [];
    
    for i =lindx:length(varargin)
        if ischar(varargin{i})
            switch varargin{i}
                case 'nonmatrixkilldim'
                    nonmatrixkilldim = nonmatrixkilldim_proposals;
                case 'test'
                    test = true;
                case 'disthips'
                    conformations = [conformations, {@disthips}];
                    %warning('not implemented')
                    nonmatrixkilldim_proposals = nmc(@disthips, nonmatrixkilldim_proposals, skelldef);
                case 'distshoulder'
                    conformations = [conformations, {@distshoulder}];
                    %warning('not implemented')
                    nonmatrixkilldim_proposals = nmc(@distshoulder, nonmatrixkilldim_proposals, skelldef);
                case 'disthipsandshoulder'
                    conformations = [conformations, {@disthipsandshoulder}];
                    %warning('not implemented')
                    nonmatrixkilldim_proposals = nmc(@disthipsandshoulder, nonmatrixkilldim_proposals, skelldef);
                case 'disthipsandhead'
                    conformations = [conformations, {@disthipsandhead}];
                    %warning('not implemented')
                    nonmatrixkilldim_proposals = nmc(@disthipsandhead, nonmatrixkilldim_proposals, skelldef);
                case 'disthipsandheadandextendedupperlimb'
                    conformations = [conformations, {@disthipsandheadandextendedupperlimb}];
                    %warning('not implemented')
                    nonmatrixkilldim_proposals = nmc(@disthipsandheadandextendedupperlimb, nonmatrixkilldim_proposals, skelldef);
                case 'highhips'
                    conformations = [conformations, {@highhips}]; %#ok<*AGROW>
                case 'nohips'
                    conformations = [conformations, {@centerhips}];
                    killdim = [killdim, skelldef.bodyparts.hip_center];
                case 'norm_cip'
                    conformations = [conformations, {@norm_cip}];
                case 'normal'
                    conformations = [conformations, {@normnorm}];
                    %dbgmsg('Unimplemented normalization: ', varargin{i} ,true);
                case 'mirrorx'
                    conformations = [conformations, {@mirrorx}];
                case 'mirrory'
                    conformations = [conformations, {@mirrory}];
                case 'mirrorz'
                    conformations = [conformations, {@mirrorz}];
                case 'mahal'
                    conformations = [conformations, {@normalize}];
                    %dbgmsg('Unimplemented normalization: ', varargin{i} ,true);
                case 'norotate'
                    conformations = [conformations, {@norotatehips}];
                    dbgmsg('WARNING, the normalization: ' , varargin{i},' is performing poorly, it should not be used.', true);
                case 'norotatehips'
                    conformations = [conformations, {@norotatehips2}];
                    %dbgmsg('WARNING, the normalization: ' , varargin{i},' is performing poorly, it should not be used.', true);
                case 'norotateshoulders'
                    conformations = [conformations, {@norotateshoulders}];
                    dbgmsg('WARNING, the normalization: ' , varargin{i},' is performing poorly, it should not be used.', true);
                case 'notorax'
                    conformations = [conformations, {@centertorax}];
                    %dbgmsg('WARNING, the normalization: ' , varargin{i},' is performing poorly, it should not be used.', true);
                    killdim = [killdim, skelldef.bodyparts.TORSO];
                case 'nofeet'
                    conformations = [conformations, {@nofeet}]; %not sure i need this...
                    killdim = [killdim, skelldef.bodyparts.RIGHT_FOOT, skelldef.bodyparts.LEFT_FOOT];
                case 'nohands'
                    dbgmsg('WARNING, the normalization: ' , varargin{i},' is performing poorly, it should not be used.', true);
                    killdim = [killdim, skelldef.bodyparts.RIGHT_HAND, skelldef.bodyparts.LEFT_HAND];
                case 'axial'
                    %conformations = [conformations, {@axial}];
                    dbgmsg('Unimplemented normalization: ', varargin{i} ,true);
                case 'addnoise'
                    conformations = [conformations, {@abnormalize}];
                case 'spherical'
                    conformations = [conformations, {@to_spherical}];
                case 'polar'
                    conformations = [conformations, {@to_polar}];
                case 'polarC'
                    conformations = [conformations, {@to_polarSINCOSCORRECT}];
                case 'intostick'
                    conformations = [conformations, {@intostick}];
                    killdim = [4:(skelldef.length/6) (skelldef.length/6+4):(skelldef.length/3) ];
                case 'intostick2'
                    conformations = [conformations, {@intostick2}];
                    killdim = [4:(skelldef.length/6) (skelldef.length/6+4):(skelldef.length/3) ];
                otherwise
                    dbgmsg('ATTENTION: Unimplemented normalization/ typo.',varargin{i},true);
            end
        elseif isstruct(varargin{i})
            if test
                extskeldef = varargin{i};
            else
                error('struct defined without ''test'' set to on. I don''t know what to do with this parameter.')
            end
        else
            error('Unexpected input type! I don''t know what to do with this parameter.')
        end
        
    end
    
    % execute them for training and validation sets
    if ~isempty(skelldef.bodyparts)
        for i = 1:length(conformations)
            func = conformations{i};
            dbgmsg('Applying normalization: ', varargin{i+lindx-1},0);
            if isequal(func, @mirrorx)||isequal(func,@mirrory)||isequal(func, @mirrorz)
                data_mirror = conformstruc.data;
                data_ymirror = conformstruc.y;
                data_imirror = conformstruc.index;
            else
                data_mirror = [];
                data_ymirror = [];
                data_imirror = [];
            end
            
            if isequal(func,@normalize)||isequal(func,@normnorm)
                if 1%~test
                    %%% must go through whole dataset!
                    %%% if there is ever another function that requires this,
                    %%% then I should probably use a switch - if that works...
                    [allskels, skelldef.hh] = makefatskel(conformstruc.data);
                    %%% calculating the magic constants for our data
                    if skelldef.novel
                        vectdata_pos = reshape(allskels(1:skelldef.length/3,:,:),1,[]);
                        skelldef.pos_std = std(vectdata_pos);
                        skelldef.pos_mean=mean(vectdata_pos);
                        skelldef.vel_std = [];
                        skelldef.vel_mean=[];
                    else
                        vectdata_pos = reshape(allskels(1:skelldef.length/6,:,:),1,[]);
                        skelldef.pos_std = std(vectdata_pos);
                        skelldef.pos_mean=mean(vectdata_pos);
                        vectdata_vel = reshape(allskels((skelldef.length/6+1):end,:,:),1,[]);
                        skelldef.vel_std = std(vectdata_vel);
                        skelldef.vel_mean=mean(vectdata_vel);
                    end
                    
                    %lets construct a nice skeleton to normalize things by
                    %when it comes to the testing phase
                    template = maketemplate(conformstruc.data, skelldef); % maybe I should separate velocities and positions
                    skelldef.template = template;
                    skelldef.templaten = makethinskel(normalize(makefatskel(template),skelldef));
                else
                    %%%
                    %normalization will be very strange in this case and will not be a real normalization
                    %%%
                    % I want to find a constant by which I multiply the
                    % skeleton so to make my current skeleton the closest I
                    % can to my skelldef.template
                    %disp('')
                    alpha_p = sum(mean(conformstruc.data(1:45,:),2).*extskeldef.templaten(1:45))/sum(extskeldef.templaten(1:45).^2);
                    %alpha_v = sum(extskeldef.template(46:end))/sum(sum(conformstruc.data(46:end,:)))*size(conformstruc.data,2);
                    %sum(conformstruc.data.'*extskeldef.template)/size(conformstruc.data,2)/(extskeldef.template.'*extskeldef.template);
                    skelldef.pos_std =alpha_p; %%% my normalizing function didnt work, this was fitted by hand
                    skelldef.pos_mean= 0 ;
                    skelldef.vel_std = alpha_p; %alpha_v; %%% no idea if this will have the same scaling factor!
                    skelldef.vel_mean=0;
                end
            end
            nonmatrixkilldim_proposals = nmc(func, nonmatrixkilldim_proposals, skelldef);
            for j = 1:size(conformstruc.data,2)
                [tdskel,skelldef.hh] = makefatskel(conformstruc.data(:,j));
                conformstruc.data(:,j) = makethinskel(func(tdskel, skelldef));
                %                 if isequal(func,@normalize)&&(size(conformstruc.data,2)<15)
                %                     figure; skeldraw(tdskel,'f',skelldef); hold on;
                %                     skeldraw(conformstruc.data(:,j),'t',skelldef);
                %                 end
            end
            %%%%normalize with the bounding box option will need a post
            %%%%processing part
            if isequal(func,@normalize)
                %%% calculate bounding box
                %%% we will put it in skelldef. when we need to access the
                %%% bounding box of the main dataset it will be found in
                %%% extskeldef
                skelldef = boundingbox(conformstruc.data, skelldef);
            end
            conformstruc.data = [conformstruc.data data_mirror];
            conformstruc.y = [conformstruc.y data_ymirror];
            conformstruc.index = [conformstruc.index data_imirror];
        end
    end
    % squeeze them accordingly?
    
    whattokill = reshape(1:skelldef.length,skelldef.length/3,3);
    realkilldim = [reshape(whattokill(killdim,:),1,[]) nonmatrixkilldim'] ;
    conform_train = conformstruc.data(setdiff(1:skelldef.length,realkilldim),:); %sorry for the in-liners..
    skelldef.elementorder = skelldef.elementorder(setdiff(1:skelldef.length,realkilldim));
    
    
    conformstruc.data = conform_train;
    conformstruc.y = conformstruc.y;
end
skelldef.realkilldim = realkilldim;
[skelldef.pos, skelldef.vel] = generateidx(skelldef.length, skelldef);

end