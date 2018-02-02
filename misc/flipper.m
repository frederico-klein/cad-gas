function dist = flipper(x,y)
%disp('hello')
part = 16:30;
x_f = x;
x_f(part) = -x(part);
dist = min([pdist2(x,y) pdist2(x_f,y)]);
end
