function TMs = construct_tms(ssvot,ssvotbt,arq_connect,vot)
%actually maxnodes can change for each gas
for i = 1:length(arq_connect)
maxnodes(i) = arq_connect(i).params.nodes;
end
%go through all Gases(A) and chop them. save it into asmatched
A = 0;
%for j = 1:length(ssvot(1).gas)
j = 1; %%%%%%%%%%%%%%%%%% I need the
if strcmp(vot,'train')
    for A = 1:size(ssvot,2)
        
        asmatched(A).gas(j).cactions = chop_action(ssvot(A).gas(j).bestmatchbyindex(A,:),ssvot(A).ends);
        
    end
end
asmatched(A+1).gas(j).cactions = chop_action(ssvotbt.gas(j).bestmatchbyindex,ssvotbt.ends);
%end

%disp('hello')
%%% Now I will actually build the transition matrices for the training
%%% data
for i= 1:size(asmatched,2)
    %for j... when gases have their ends i will need to make this extra for
    %loop
    j = 1;
    for k = 1:size(asmatched(i).gas.cactions,2)
        TMs(i,j).tm(k).mat = buildtm(asmatched(i).gas(j).cactions(k).bmus,maxnodes(j));
    end
end


end
function cactions = chop_action(bmus, ends)
%disp('hello!')
realends = cumsum(ends);
realbeginnings = [1 (realends(1:end-1)+1)];
for i =1:length(ends)
    cactions(i).bmus = bmus(:,realbeginnings(i):realends(i));
end
end
function tm = buildtm(bmus,maxnodes)
% disp('hello')
tm = zeros(maxnodes);
for i = 1:(length(bmus)-1)
    tm(bmus(i),bmus(i+1)) = tm(bmus(i),bmus(i+1))+1;
end
end