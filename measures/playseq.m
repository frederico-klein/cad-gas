function playseq(data)
myfig = figure;
seq = data(1:45,:);
a.hh = 45*2/3; %% not really doing much... 
lines = skeldraw(seq,'rt',a);
playaction(lines,myfig,0.1)
