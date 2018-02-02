function outskel = maketemplate(data, skelldef)
%%% find which is the most common of all skeletons. I am just estimating, i
%%% hope this works
%%%find the mean of all allskels
%outskel = [];
meanskel = mean(data, 2); %?

%%%find the real skeleton that is more like the average one
[~, outskeli] =  pdist2(data', meanskel', 'euclidean', 'Smallest',1);
outskel = data(:,outskeli);
%skeldraw(meanskel,'t',skelldef)
%hold on; skeldraw(outskel,'t',skelldef)
end
