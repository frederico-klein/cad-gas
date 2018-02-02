function norma = normalizeskeleton_tensor(b)
%i will find the norm of b, but b is a sequence, so i need to make a new b
%which is only the first skeleton doubled
newb = cat(3, b(:,:,1), b(:,:,1));

% I calculate the lengths using the sticks from my ploting function, so
% lets create the sticks without drawing them:
[~, linesb] = skeldraw(newb,false,0);

%the lengths:
blengths = skellengths(linesb);
%and finally the norm
norma = sum(blengths);
end

