function chunk = makechunk(varargin)
%will use the allskel1
data = varargin{1};
if nargin==1
    offset = 0;
    act_num = ceil(rand()*size(data,2));
else
    
end


chunk.skel = data(act_num).skel(:,:,1+offset:9+offset);
chunk.vel = data(act_num).vel(:,:,1+offset:9+offset);

chunk.act_type = data(act_num).act_type;

end
