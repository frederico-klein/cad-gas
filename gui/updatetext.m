function updatetext(chunk)
persistent statictexthandle otherhandle
if isempty(statictexthandle)||~isvalid(statictexthandle)
    statictexthandle = findobj('Tag','text5');
end

set(statictexthandle, 'String',['Frames acquired: ' num2str(chunk.counter)])
otherhandle = findobj('Tag','text10');
set(otherhandle, 'String',['Description: ' chunk.description])