function dist = dtw_wrapper(x,y)
try
    for i=1:size(y,1)
        dist(i,1) = dtw(x,y(i,:));
    end
catch me
    disp(me)
    size(x)
    size(y)
    error('hmm')
end
end