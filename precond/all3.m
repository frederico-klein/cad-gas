function [data,labels_names, skelldef] = all3(allskel, datavar)
[allskel] = conformactions(allskel, datavar.prefilter{:});
for i= 1:length(allskel)
    allskel(i).indexact = i;
    %%%
    if datavar.normrepair
        allskel(i) = normrepair(allskel(i));
    end
    
    if datavar.affinerepair
        allskel(i) = affinerepair(allskel(i), datavar);
    end
end

[data, labels_names] = extractdata(allskel ,datavar.activity_type, datavar.labels_names,datavar.extract{:});
if 0 %isfield(simvar, 'notzeroedaction')
      
    a.train = data;
    pld = data.data.';
    figure
    plot(pld)
    %error('stops!')
    showdataset(a,simvar)
    disp('hello')
end
if datavar.disablesconformskel
    %no more conformskel!
    %erm actually i need skelldef, so i will maybe run conformskel without
    %parameters
    [data, skelldef] = conformskel(data);
else
    %in case you wish to run it:
    [data, skelldef] = conformskel(data, datavar.preconditions{:});
end
%disp('hello')
end
