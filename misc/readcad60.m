function allskel = readcad60(subject)

if length(subject)>1
    allskel = [];
    for i = subject
        allskel = [allskel readcad60(i)];
    end
    return
end

[slash, pathtodata] = OS_VARS;
%%% read
realpath = strcat(pathtodata, '..',slash,'CAD60',slash,'data', num2str(subject), slash);
ftoopen = strcat(realpath, 'activityLabel.txt');
fidfid = fopen(ftoopen, 'r');
Axr = textscan(fidfid, '%f,%s','Delimiter', '\n', 'CollectOutput', true);
fclose(fidfid);

% allskel = Axr

for i=1:length(Axr{1})
    activitytoopen = strcat(realpath, num2str(Axr{1}(i)), '.txt');
    fidfid = fopen(activitytoopen, 'r');
    if fidfid == -1
        activitytoopen = strcat(realpath, '0', num2str(Axr{1}(i)), '.txt');
        fidfid = fopen(activitytoopen, 'r');
        if fidfid == -1
            error(strcat('could not open file',activitytoopen))
        end
    end
    ori_def =  strcat(repmat('%f,',1,9),'%u8,');
    j_def = strcat(repmat('%f,',1,3),'%u8,');
    massofformlessdata = textscan(fidfid, strcat('%u,',repmat(strcat(ori_def, j_def),1,11),repmat(j_def,1,4)),'Delimiter', '\n', 'CollectOutput', true);
    fclose(fidfid);
    actlen = size(massofformlessdata{1},1);
    skel = nan(15,3,actlen); %initalize it with nans, because why not?
    vel = zeros(15,3,actlen);
    skelori = nan(11,9,actlen);
    act_name = Axr{2}{i}(1:end-1);
    jskelstruc = struct('skel',skel,'skelori', skelori,'act_type', act_name, 'index', Axr{1}(i), 'subject', subject,'time',[],'vel',vel);
    for j = 1:actlen
        for k = 1:11
            skel(k,:,j) = massofformlessdata{4*k}(j,:);
            skelori(k,:,j) = massofformlessdata{4*k-2}(j,:);
        end
        for k = 12:15
            skel(k,:,j) = massofformlessdata{22+2*k}(j,:);
        end
        if j>1
            for k = 1:15
                vel(k,:,j) = skel(k,:,j)-skel(k,:,j-1);
            end
        end
        
    end
    jskelstruc.skel = skel;
    jskelstruc.skelori = skelori;
    jskelstruc.vel = vel;
    % size(jskelstruc.skel) % this was here for debugging
    if exist('allskel','var') % initialize my big matrix of skeletons
        allskel = cat(2,allskel,jskelstruc);
    else
        allskel = jskelstruc;
    end
    
    
end
end