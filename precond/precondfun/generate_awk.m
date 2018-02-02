
function awk = generate_awk(data_val)
%% Awk definition:
important = 1;%0.1;
relevant = 1;%0.03;
minor = 1;%0.005;

awk = [...
    important;...   %1    hips
    important;...   %2    abdomen
    important;...   %3    neck or something
    relevant;...    %4    tip of the head
    important;...   %5    right shoulder
    relevant;...    %6    right also shoulder or elbow
    relevant;...    %7    right elbow maybe
    relevant;...    %8    right hand
    important;...   %9    left part of shoulder
    relevant;...    %10   left something maybe elbow
    relevant;...    %11   left maybe elbow
    relevant;...    %12   left hand
    important;...   %13   left hip
    relevant;...    %14   left knee
    minor;...       %15   left part of foot
    minor;...       %16   left tip of foot
    important;...   %17   right hip %important because hips dont lie
    relevant;...    %18   right knee
    minor;...       %19   right part of foot
    minor;...       %20   right tip of foot
    important;...   %21   middle of upper torax
    minor;...       %22   right some part of the hand
    minor;...       %23   right some other part of the hand
    minor;...       %24   left some part of the hand
    minor];         %25   left some other part of the hand

if size(awk,1)*6~=size(data_val,1)
    if floor(size(data_val,1)/2)==size(data_val,1)/2
        awk = ones(size(data_val,1)/6,1);
    else
        awk = ones(size(data_val,1)/3,1);
    end
    dbgmsg('Must update awk for a skeleton this size.',0)
end


end