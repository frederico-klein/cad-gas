function bmtm = match_tms(tmv, tm)

%disp('hello')
%measure all of them agains one another and see where stuff is
tmt = tm(end);
rtm = tm(1:end-1);
clear tm
%regularize tms
for i =1:length(rtm)
    for j = 1:length(rtm(i).tm)
        rtm(i).tm(j).mat = rtm(i).tm(j).mat/sum(sum(rtm(i).tm(j).mat));
    end
end

for j = 1:length(tmt.tm)
    tmt.tm(j).mat = tmt.tm(j).mat/sum(sum(tmt.tm(j).mat));
end

for j = 1:length(tmv.tm)
    tmv.tm(j).mat = tmv.tm(j).mat/sum(sum(tmv.tm(j).mat));
end

[dist, label] = flabel_tm(tmv,rtm);
%measure all of them agains one another and see where stuff is
bmtm.vdist = dist;
bmtm.vlabel = label; 

[bmtm.tdist, bmtm.tlabel] = flabel_tm(tmt,rtm);


end
function [dist, label] = flabel_tm(tmv,rtm)

for j = 1:length(tmv.tm)
    mindist = [];
    minindex = [];
    for i = 1:length(rtm)      
        distances = [];
        for k = 1:length(rtm(i).tm)
        distances(k) = sum(sum((tmv.tm(j).mat -rtm(i).tm(k).mat).^2));        
        end
        [mindist(i), minindex(i)] = min(distances);
    end
    [dist(j), label(j)] = min(mindist); 
end

end