function chopset = chopset(s2c)
%%% make it into a nice cell array
numseq = length(s2c.ends);
chopset = cell(numseq,1);

%%%calculate real ends and real beginnings
realends = cumsum(s2c.ends);
realbeginnings(1) = 1; %%% the first one starts at one
for i = 2:numseq %%% the first one starts at one
realbeginnings(i) = realends(i-1) + 1;
end

for i = 1: numseq
    chopsetstruc.data = s2c.data(:,realbeginnings(i):realends(i));
    chopsetstruc.y = s2c.y(:,realbeginnings(i):realends(i));
    chopsetstruc.index = s2c.index(:,realbeginnings(i):realends(i));
    chopset{i} = chopsetstruc;
    clear chopsetstruc   
end
end