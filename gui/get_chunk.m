function chunk = get_chunk(metaData,chunk,i)
chunk.chunk(:,:,2:end) = chunk.chunk(:,:,1:end-1);
chunk.chunk(:,:,1) = metaData.JointWorldCoordinates(:,:,i); %%% this only gets one frame. if i get more frames I don't know the timestamps between them!
chunk.counter = chunk.counter +1;
dbgmsg('chunk.counter', num2str(chunk.counter),0)
if chunk.counter>1
    chunk.times(chunk.counter-1) = toc(chunk.timers(chunk.counter-1));
end
chunk.timers(chunk.counter) = tic;