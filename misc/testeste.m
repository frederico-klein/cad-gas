function testeste(varargin)
for i = 1:nargin
    if isstruct(varargin{i})
        fprintf('structure %i', i)
    end
    if         iscell(varargin{i})
        fprintf('cell %i', i)
    end
end