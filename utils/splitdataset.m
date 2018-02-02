function datasplit = splitdataset(data)
realends = cumsum(data.ends);
realbeginnings = [1 (realends(1:end-1)+1)];
lr = length(realends);
datasplit(lr) = struct;
for i =1:lr
    datasplit(i).data = data.data(:,realbeginnings(i):realends(i));
    datasplit(i).y = data.y(:,realbeginnings(i):realends(i));
    datasplit(i).index = data.index(:,realbeginnings(i):realends(i));
end
end