function dist = tdsum(a,b,q)
ta = reshape(a,[],3,q);
mylength = size(b,1);
dist = nan(mylength,1);
for i = 1:mylength
tb = reshape(b(i,:),[],3,q);
dftatb = ta-tb;
dist(i) = sum(sum(sqrt(sum(dftatb.*dftatb,2))));
end