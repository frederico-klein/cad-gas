function y = findy(s)
%disp('hello')
realends = cumsum(s.ends);
%realbeginins = [1 (realends(1:end-1)+1)]
for i = 1:length(realends)
    y(i) = sum(s.y(:,realends(i))'.*(1:12));
end
end