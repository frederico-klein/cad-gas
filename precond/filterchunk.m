function [chunk] = filterchunk(chunk, whichfilter,fsz)
%%%disp('hello')
%whichfilter = 'median';

switch whichfilter
    case 'filter'
        %%% this filter is likely bad because it introduces phase shift!!
        %windowSize = 5;
        windowSize = fsz;
        b = (1/windowSize)*ones(1,windowSize);
        a = 1;
        filterfun = @(x)filter(b,a,x);
    case 'median'
        %medianmedian = 5;
        medianmedian = fsz;
        filterfun = @(x)medfilt1(x,medianmedian);
    case 'none'
        return
    otherwise
        error('Unknown filter.')
end

for i = 1:size(chunk,2)
    for j = 1:size(chunk(i).chunk,1)
        for k = 1:size(chunk(i).chunk,2)
            chunk(i).chunk(j,k,:) = filterfun(chunk(i).chunk(j,k,:));
        end
    end
end
