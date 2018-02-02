function showtrainlabels(opp3)
YY = logical(opp3.datavar.data.train.y);
m = repmat(1:12,length(opp3.datavar.data.train.y),1)';
a = m(YY);
figure
plot(a)