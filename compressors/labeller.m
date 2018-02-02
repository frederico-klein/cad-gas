function vot_class = labeller(nodesl, vot_bestmatchbyindex)

votcsize = size(vot_bestmatchbyindex,2);
ycsize = size(nodesl,1);
vot_class = zeros(ycsize,votcsize);

for i =1:votcsize
    vot_class(:,i) = nodesl(:,vot_bestmatchbyindex(i));
end
end