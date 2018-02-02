function drawerrorskels(rt,tn,range)
figure
skeldraw(rt.datavar(tn, 1).data.val.data(:,range),rt.datavar(1, 1).skelldef,'A')
skeldraw(rt.datavar(tn, 1).data.train.data(:,rt.trials.model(tn).IDX(range)),rt.datavar(1, 1).skelldef,'W')