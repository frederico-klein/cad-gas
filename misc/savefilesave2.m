function savesave = savefilesave2(filename,env)

ver = 1;
savesave = strcat(env.wheretosavestuff,env.SLASH,filename,'.mat');
while exist(savesave,'file')
    savesave = strcat(env.wheretosavestuff,env.SLASH,filename,'[ver(',num2str(ver),')].mat');
    ver = ver+1;
end