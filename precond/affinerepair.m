function allskel = affinerepair(allskel, simvar)

%maybe if i corrected to the torso, say shoulders and hips i wuld get the
%best results

%now we can maybe check this against our sample skeleton
aaa = load([simvar.allmatpath 'skellstoplaywith.mat']);%allskel.skel(:,:,1);
longsamp = aaa.a(:,1)';
NN = size(allskel.skel,3);

sampskel = reshape(longsamp,[],3);

for i = 1:NN
    %cov_ = allskel.skel(:,:,i).'*sampskel; %%maybe I will need to make it into a for
    cov_ = sampskel.'*allskel.skel(:,:,i); %%maybe I will need to make it into a for

    [u,s,v] = svd(cov_);
    
    r = v*u.';
    
    rotskel = allskel.skel(:,:,i)*r; %or the other way around... better to change the cov_ calculation because there will be fewer operations
    %%%check whether I have the right orientation:
    longskel = reshape(allskel.skel(:,:,i),1,[]);
    longrskel = reshape(rotskel,1,[]);
    a = pdist2(longsamp,longrskel,'euclidean','Smallest',1);
    b = pdist2(longsamp, longskel,'euclidean','Smallest',1);
    if a<b
    allskel.skel(:,:,i) = rotskel;
    else
        error('Wrong order!')
    end
    %%% all of this should be commented out!
    if simvar.affrepvel
        allskel.vel(:,:,i) = allskel.vel(:,:,i)*r; %because it was also rotated
    end
end

end
