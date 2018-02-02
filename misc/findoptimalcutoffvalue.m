function [ocv,ma, oc] = findoptimalcutoffvalue(cd,id)
if iscell(cd)&&iscell(id)
    figure
    hold on
    for i = 1:length(cd)
    [ocv(i),ma(i), oc] = findoptimalcutoffvalue(cd{i}',id{i}');
    plot(oc)
    end
    return
end
all_ = [cd;id];
minc = min(all_);
maxc = max(all_);
nump = 100;
oc = zeros(1,nump);
y = linspace(minc,maxc,100);
for i = 1:nump
    oc(i) = sum(cd<y(i))^2/sum(all_<y(i));
end
ma = max(i);
ocv = y(i);
end