function [allskel] = conformactionsboth(allskel, whichfilter)
%%%disp('hello')
%whichfilter = 'median';

switch whichfilter
    case 'filter'
        %%% this filter is likely bad because it introduces phase shift!!
        windowSize = 5;
        b = (1/windowSize)*ones(1,windowSize);
        a = 1;
        filterfun = @(x)filter(b,a,x);
    case 'median'
        medianmedian = 5;
        filterfun = @(x)medfilt1(x,medianmedian);
    case 'none'
        return
    otherwise
        error('Unknown filter.')
end

for i = 1:size(allskel,2)
    for j = 1:size(allskel(i).vel,1)
        for k = 1:size(allskel(i).vel,2)
            allskel(i).vel(j,k,:) = filterfun(allskel(i).vel(j,k,:));
            allskel(i).skel(j,k,:) = filterfun(allskel(i).skel(j,k,:));

        end
    end
end


% create the matrix from the structure to access the database and run the
% classification....
end