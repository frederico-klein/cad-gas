function [allskel, a, labact] = zeromostout(allskel)
a = randperm(length(allskel),1);
for i = 1:length(allskel)
    if i~=a
        allskel(i).skel = zeros(size(allskel(i).skel));
        allskel(i).vel = zeros(size(allskel(i).vel));
        allskel(i).skelori = zeros(size(allskel(i).skelori));
    else
        labact = allskel(i).act_type;
        disp(labact)
    end
end
% for i =1:68, if any(allskel(i).skel(:,:,1)), disp(i),end,end