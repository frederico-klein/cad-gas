function labs = newlabeller(ssvotbtd)
%%% Interesting graphs to show here:
% hist(sum(ssvotbtd,1),200)
% hist(ssvotbtd',20)
%%% Maybe it would be interesting to know how is the distribution of
%%% distances over right values... 


labs = zeros(size(ssvotbtd));
for i = 1:size(ssvotbtd,2)
    [~, b] = min(ssvotbtd(:,i));
    labs(b,i) =1;
end
end