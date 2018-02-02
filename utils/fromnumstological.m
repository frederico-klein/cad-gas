function class = fromnumstological(weirdthingy,numclasses)
%FROMNUMSTOLOGICAL This function will transform the number for classes
%definition in the y with the vector definition that confusion matrices
%require. 
warning('Don''t use this. use vec2ind instead!')
class = false(numclasses,size(weirdthingy,2));
for i =1:size(weirdthingy,2)
    class(weirdthingy(i),i) = true;
end
end

