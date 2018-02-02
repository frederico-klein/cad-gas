function data = flipdata(data)
wtf = randi(3,size(data));
for i = 1:size(data,2)
    switch wtf(i)
        case 1
            %do nothing
        case 2
            %flipx
            data(1,i) = -data(1,i);
        case 3
            %flipy
            data(2,i) = -data(2,i);
    end
    
end