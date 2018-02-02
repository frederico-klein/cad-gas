function newmt = mtmodefilter(varargin)
%%% function newmt = mtmodefilter(mt,numnum, filtertrain)
%%% or use as newmt = mtmodefilter(mt,numnum)
%%% setting inputs
mt = varargin{1};
numnum = varargin{2};

if nargin == 2
    filtertrain = true;
else
    filtertrain = varargin{3};
end



%newmt(size(mt)) = struct(); %%% this failed for some weird reason!

a = size(mt);
newmt(a(1),a(2)) = struct();

for i = 1:size(newmt,1)
    for j = 1:size(newmt,2)
        newmt(i,j).conffig.val{1} = mt(i,j).conffig.val{1};
        newmt(i,j).conffig.val{2} = modefilter(mt(i,j).conffig.val{2},numnum);
        newmt(i,j).conffig.val{3} = strcat(mt(i,j).conffig.val{3},'m',num2str(numnum)); % so that I remember this is after the mode filter
        
        if filtertrain %%%% and same thing for training set
            newmt(i,j).conffig.train{1} = mt(i,j).conffig.train{1};
            newmt(i,j).conffig.train{2} = modefilter(mt(i,j).conffig.train{2},numnum);
            newmt(i,j).conffig.train{3} = strcat(mt(i,j).conffig.train{3},'m',num2str(numnum)); % so that I remember this is after the mode filter
        else %%% where classes should have been used, but you know...
            newmt(i,j).conffig.train{1} = [];
            newmt(i,j).conffig.train{2} = [];
            newmt(i,j).conffig.train{3} = []; 
        end
    end
end
function bigx= old_modefilter(series,numnum)

%%%first we need to transfor the large matriz into a vector
num_classes = size(series,1);
serieslength = size(series,2);
diagmat = diag(1:num_classes);

newseries = sum(diagmat*series,1);

x = zeros(1,serieslength);

for ii = numnum:serieslength
     x((ii-numnum+1):ii) = mode(newseries((ii-numnum+1):ii));
end

if num_classes == 1 %%% if it is onedimensional thing, then it is done
    bigx = x;
else
    
    %%%Otherwise we need to go back to were came from
    bigx = zeros(num_classes,serieslength);
    
    for ii = 1:serieslength
        bigx(x(ii),ii) = 1;
    end

end
function bigx= modefilter(series,numnum)
%%%now we may need to deal with fractional numbers, so the old function
%%%above doesn't cut it

%so instead of really using a mode, we will use something else.  
serieslength = size(series,2);
bigx = zeros(size(series));

for i = 1:serieslength
    lim = min([serieslength i+numnum]);
    bigx(:,i) = sum(series(:,i:lim),2)/(lim-i); %%% not numnum as a divisor, but lim-i, cause in the end it is smaller than numnum
end
    