% function affine_restore_demo()
%% normalization and cancelation of offset, improved.
% to begin load file with an action,

allskelf = load('h:/all.mat/example_allskel.mat');
allskel = allskelf.allskel;

%%
% Load also our sample skeleton from the kinect for windows sensor,

skelex = load('h:/all.mat/skellstoplaywith.mat');
b = skelex.b;
% Also need to make b a tensor:
tb = makefatskel(b);
%%
% Note: maybe if i corrected to the torso, say shoulders and hips i would get the
% best results


%% Next lose center
% Read it that it makes more sense to center around the centroid [citation needed]. 
% Well, the basis for this is kabsh algorithm, which we are trying to
% replicate.
allskel.skel = allskel.skel - mean(allskel.skel); %%the repmat is done implicitly, and this should work

%%
% Do the same for b:
tbcentered = tb - mean(tb);
%%
% it makes sense to plot what we have so far so
% But first let's select from allskel the first 3 skeletons so that we have
% the same as our sample from kinect, the b variable:
newskel = allskel.skel(:,:,1:3); 

figure
skeldraw(tbcentered);
hold on
skeldraw(newskel);
% we need to correct the axis so that we can correct the non-uniform
% scaling
correctax

%%
% the skeleton from one dataset is circa 1000x bigger than the other, so
% one is merely a dot on the origin. To correct this we need to normalize
% them.
%% Norms
% Now calculating the norms:

bnorm = normalizeskeleton_tensor(tbcentered)
%%
% Now for the skeleton in the database:

skelnorm = normalizeskeleton_tensor(newskel)
%%
% normalizing

newb = tbcentered/bnorm;

nnewskel = newskel/skelnorm;

%%
% Now plotting what we've got:

figure
skeldraw(newb);
hold on 
skeldraw(nnewskel);
% correcting the axis again:
correctax
%% Normalizing the whole set:
% since we know that a person's limbs do not grow or shrink during an
% action, the best estimator for the norm of the skeleton is the average of
% all norms, that is:

NN = size(allskel.skel,3);
allnorms = zeros(NN,1);
for i = 1:NN
    allnorms(i) = normalizeskeleton_tensor(allskel.skel(:,:,i));
end
meannorm = mean(allnorms)

%%
% Let's see what it the difference from the norm calculated from one
% skeleton and the norm calculated from the whole action:
skelnorm/meannorm-1

%%
% we see the difference from skelnorm is pretty small, but if we, by any
% chance start with a skeleton with an acquisition error, this would have
% consequences. We can see this with a histogram:
figure
hist(allnorms,30)
% and range
range(allnorms)

%% 
% we can also maybe show some other skeletons at random to see if they are
% all behaving nicely
figure
randskelidx = randperm(NN,3);
skeldraw(allskel.skel(:,:,randskelidx(1):(randskelidx(1)+2))/meannorm);
skeldraw(allskel.skel(:,:,randskelidx(2):(randskelidx(2)+2))/meannorm);
skeldraw(allskel.skel(:,:,randskelidx(3):(randskelidx(3)+2))/meannorm);
correctax
%% 
%cleaning up
close all