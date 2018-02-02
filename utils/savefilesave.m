function savesave = savefilesave(filename, savevar,env)
global TEST
ver = 1;
savesave = strcat(env.wheretosavestuff,env.SLASH,filename,'.mat');
while exist(savesave,'file')
    savesave = strcat(env.wheretosavestuff,env.SLASH,filename,'[ver(',num2str(ver),')].mat');
    ver = ver+1;
end
if ~TEST
    if iscell(savevar)&&(length(savevar)==3) % hack! I know the only thing I will save that has 3 cells is the dataset
        data = savevar{1}; %#ok<*NASGU>
        simvar = savevar{2};
        params = savevar{3};
        save(savesave, 'data', 'simvar','params')
    else
        save(savesave,'savevar')
    end
    dbgmsg('Saved file:',savesave,1)
end
end