function c = structcat2(a,b)
if isempty(a)
    c = b;
    return
end
if isempty(b)
    c = a;
    return
end
aa = fieldnames(a);
c = b;
for i = 1:length(aa)
    if isfield(b,aa{i})
        if isstruct(b.(aa{i}))
            c.(aa{i}) = structcat2(b.(aa{i}),a.(aa{i}));
        else
            c.(aa{i}) = union(b.(aa{i}),a.(aa{i}));
        end
    else
    c.(aa{i}) = a.(aa{i});
    end
end
%disp('hello')
end