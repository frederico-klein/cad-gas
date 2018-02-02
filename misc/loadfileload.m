function loadload = loadfileload(filename,env)
ver = 0;
loadfile = strcat(env.wheretosavestuff,env.SLASH,filename,'.mat');
while exist(loadfile,'file')
    ver = ver+1;
    loadfile = strcat(env.wheretosavestuff,env.SLASH,filename,'[ver(',num2str(ver),')].mat');
end
if ver == 1
    loadfile = strcat(env.wheretosavestuff,env.SLASH,filename,'.mat');
else
    ver = ver - 1;
    loadfile = strcat(env.wheretosavestuff,env.SLASH,filename,'[ver(',num2str(ver),')].mat');
end
loadload = load(loadfile);
dbgmsg('Loaded file:',loadfile,1)
end