function display_str(varargin)
str = varargin{1};
if nargin ==1
    level = 0;    
else
    level = varargin{2};
end
    
MAXNUMTOSHOW = 10;
if isstruct(str)||isobject(str)
    %disp('hello')
    for j = 1:length(str)
        try
            fn = fieldnames(str(j));
        catch
            fn = fieldnames(str);
        end
        for i = 1:length(fn)
            
            pri = repmat('\t',1,level);
            a = ([fn{i} ': ']);
            
            level = level +1;
            try
                if isstruct(str(j).(fn{i}))
                    fprintf([pri '%s\n'],a)
                else
                    fprintf([pri '%s'],a)
                end
                display_str(str(j).(fn{i}),level)
                
            catch
                %disp('Cannot expand further')
                %display_str(str.(fn{i}))
            end
            level = level -1;
        end
    end
elseif isa(str,'numeric')||iscell(str)
    a = size(str);
    if max(a)>MAXNUMTOSHOW
        capvar = MAXNUMTOSHOW*ones(size(a));
        disp('Value too big. output truncated. ')
        disp(reshape(str(logical(ones(min(a,capvar))))),MAXNUMTOSHOW,[])% logical indexing should work but it doesnt. I dont want to spend more time doing this.  
    else
        for i = 1:size(str,1)
        fprintf('\tMean: %03.2f%%\t ±%03.2f%%\t (%03.2f%%-%03.2f%%)\n',str(i,:)*100);
        end
    end
else
    %
    fprintf('%s',str)
end
end