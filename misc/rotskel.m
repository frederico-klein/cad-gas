function ns = rotskel(s,a,b,g)
ns = zeros(size(s));

ry = [[cos(b) 0 sin(b)];[0 1 0];[-sin(b) 0 cos(b)]];
rx = [[1 0 0 ];[0 cos(g) -sin(g)];[0 sin(g) cos(g)]];
rz = [[cos(a) -sin(a) 0];[sin(a) cos(a) 0 ];[0 0 1]];

for j = 1:size(s,3)
    for i = 1:size(s,1)
        ns(i,:,j) = (rz*ry*rx*s(i,:,j).').';
    end
end
end