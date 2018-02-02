function playaction(lines,myfig, pp)
%myfig = figure;
a = 10;
b = 1;
%lines = skeldraw(chunk.skel);

maxsize = size(lines,1);
ax = gca;
% ax.XLimMode = 'manual';
% ax.ZLimMode = 'manual';
% ax.YLimMode = 'manual';

xlim = ax.XLim;
ylim = ax.YLim;
zlim = ax.ZLim;

correctax()

for i = 1:maxsize
    %lines(i).Color = [1 1 1];
    lines(i).Visible = 'off';
end

ax.XLim = xlim;
ax.YLim = ylim;
ax.ZLim = zlim;

drawnow

while(isvalid(myfig))
    if a*b>maxsize
        b = 1;
    end
    for i = 1:maxsize
        %lines(i).Color = [1 1 1];
        lines(i).Visible = 'off';
    end
    for i = (1+ a*(b-1)):(a*b)
        %lines(i).Color = [0 0 1];
        lines(i).Visible = 'on';
    end
    
    ax.XLim = xlim;
    ax.YLim = ylim;
    ax.ZLim = zlim;
    
    drawnow
    pause(pp)
    b=b+1;
end
end