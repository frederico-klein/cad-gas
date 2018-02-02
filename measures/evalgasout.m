function acc = evalgasout(savevar)
acc = zeros(1,5);
for j = 1:5
    aaaa = zeros(14,14,4);
    for i = 1:4
        aaaa(:,:,i) = savevar.metrics(i,j).val;
    end
    aa = sum(aaaa,3);
    clear aaaa
    acc(j) = sum(diag(aa))/sum(sum(aa));
end