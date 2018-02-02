function runpar = setrunpars()
runpar.method = 'compressors';
runpar.scene = {'or'};% {'bathroom'};% {'bathroom','bedroom','kitchen','livingroom','office'} ; %{'or'}; %{'all'};
runpar.precon = 'pop';% 'cip';
runpar.savesimvar = false;