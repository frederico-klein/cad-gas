function allskel = normrepair(allskel)
allskel.skel = allskel.skel - mean(allskel.skel); %%the repmat is done implicitly, and this should work

NN = size(allskel.skel,3);
allnorms = zeros(NN,1);
for i = 1:NN
    allnorms(i) = normalizeskeleton_tensor(allskel.skel(:,:,i));
end
meannorm = mean(allnorms);
allskel.skel = allskel.skel/meannorm;
%%% let's not forget to normalize velocities as well:
allskel.vel = allskel.vel/meannorm;
end