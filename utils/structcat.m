function c = structcat(a,b)
if isempty(a)
    c = b;
    return
end
if isempty(b)
    c = a;
    return
end
aa = fieldnames(a);
c = a;
for i = 1:length(aa)
    if isfield(b,aa{i})
        c.(aa{i}) = union(b.(aa{i}),a.(aa{i}));
    else
    c.(aa{i}) = a.(aa{i});
    end
end
%disp('hello')
end