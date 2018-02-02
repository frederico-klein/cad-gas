function outskel =  reconstructskel(skel, skeldef )
outskel = zeros(skeldef.length,size(skel,2));
for i = 1:length(skeldef.elementorder )
    outskel(skeldef.elementorder(i),:) = skel(i,:);  
    %disp('hello')
end
end