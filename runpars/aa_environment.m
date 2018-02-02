function env = aa_environment()
[env.SLASH, env.pathtodata] = OS_VARS();
nameofcurrentrepo = 'cad-gas';
env.currhash = '';
global logpath
if ismac
    env.wheretosavestuff = '/Volumes/Elements/savesave';
    env.homepath = ['~/matlabprogs/' nameofcurrentrepo];
    env.allmatpath = '/Volumes/Elements/Dropbox/all.mat/'; %['~/Dropbox/all.mat/'];
    %error('define allmathpath!')
    %disp('reached ismac')
    [elel, gitout] = system('git rev-parse HEAD');
    if elel
        error('could not get current hash')
    end
    env.currhash = gitout(1:end-1);
    
elseif isunix
    [~,cmdout] = system('echo $USER');
    env.wheretosavestuff = ['/media/' cmdout(1:end-1) '/docs/savesave'];
    env.homepath = ['~/matlab/' nameofcurrentrepo];
    env.allmatpath = ['~/Dropbox/all.mat/'];
    %disp('reached isunix')
    [elel, gitout] = system('git rev-parse HEAD');
    if elel
        error('could not get current hash')
    end
    env.currhash = gitout(1:end-1);
elseif ispc
    [~,cmdout] = system('echo %HOMEPATH%');
    list_dir = {'d', 'e', 'f', 'g', 'h'};
    list_ind = 1;
    while (~exist([list_dir{list_ind} ':\savesave'],'dir')) 
        list_ind = list_ind +1;
        if list_ind > length(list_dir)
            error('Could not find suitable save directory')
        end
    end
    [elel,cmdout1] = system('where /r \ git.exe');
    if any(strfind(cmdout1,'INFO:'))||elel
        error('cant find git.exe')
    end
    cmdcmd = strsplit(cmdout1,'git.exe');
    [elel, gitout] = system(['"' cmdcmd{1} 'git" rev-parse HEAD']);
    if elel
        error('could not get current hash')
    end
    env.currhash = gitout(1:end-1);
    %env.wheretosavestuff = 'd:\'; %%% should check if there is permission for saving!!!
    %env.wheretosavestuff = 'e:\'; %%% should check if there is permission for saving!!!
    env.wheretosavestuff = [list_dir{list_ind} ':\\savesave']; %%% should check if there is permission for saving!!!
    env.homepath = ['C:\' cmdout(1:end-1) '\Documents\\GitHub\\' nameofcurrentrepo];
    env.allmatpath = ['C:\' cmdout(1:end-1) '\Dropbox\all.mat\'];
else
    disp('oh-oh')
end
%addpath(genpath(homepath))
%open dialog box?
%have to see how to do it

if ispc
    logpath = strcat(env.wheretosavestuff, env.SLASH , env.SLASH ,'var',env.SLASH ,env.SLASH,'log.txt');
else
    logpath = strcat(env.wheretosavestuff, env.SLASH ,'var',env.SLASH,'log.txt');
end
if ~exist(logpath,'file')
    %if this fails there may be a broken path,,, usually happens when I
    %change the computer I am using
    fid = fopen( logpath, 'wt' );
    if fid <0
        error(['the directory where I am trying to save things does not exist: ' logpath])
    else
        fprintf( fid, 'New logfile created.');
    end
    fclose(fid);
end
end