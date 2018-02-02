function lengths = skellengths(skel)
removezeros = false;
lengths = zeros(1,length(skel));
for i = 2:length(skel)
    lengths(i) = sqrt(sum((skel(:,i-1)- skel(:,i)).^2));
end
%now I need to remove all NaNs
lengths(isnan(lengths)) = [];
%%%hmmm, lets remove the zeros as well
if removezeros
    lengths(lengths==0) = [];
end