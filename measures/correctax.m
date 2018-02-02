function correctax()
%%makes all axes the same size. important if i want to plot things without
%%being distorted
ax = gca;
xlim = ax.XLim;
ylim = ax.YLim;
zlim = ax.ZLim;

axmat = [xlim, ylim, zlim];
maxlim = max(axmat);
minlim = min(axmat);

ax.XLim = [minlim , maxlim];
ax.YLim = [minlim , maxlim];
ax.ZLim = [minlim , maxlim];
end