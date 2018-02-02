function playchunk(chunk)
myfig = gcf;
lines = skeldraw(chunk.skel);
playaction(lines,myfig,0.1)
