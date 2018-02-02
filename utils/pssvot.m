function ssvotp = pssvot(ssvot)
%%% separates data into different actions

%disp('hello')
%%% at first glance this seems correct.

nssvotl = size(ssvot.y,1);
ssvotp(nssvotl) = struct;
alldatasize = size(ssvot.data,2);
for i = 1:nssvotl
    newindex = 0;
    ends = [];
    for j = 1:alldatasize
        if ssvot.y(i,j) == 1
            newindex = newindex +1;
            ssvotp(i).data(:,newindex) = ssvot.data(:,j);
            ssvotp(i).y(:,newindex) = ssvot.y(:,j);
            ssvotp(i).index(:,newindex) = ssvot.index(j);
            %%% now need to create ends
            %if index of next point changes or does not exist then it is an end
            if j+1>alldatasize||ssvot.index(j+1)~=ssvot.index(j)
                ends = [ends newindex-sum(ends)];
            end
        end
    end
    ssvotp(i).ends = ends;
    ssvotp(i).seq = unique(ssvotp(i).index,'stable');
    ssvotp(i).gas = struct;
end
end