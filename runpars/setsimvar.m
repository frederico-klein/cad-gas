function simvar = setsimvar(params,parsc,useroptions)

%%% sets the running parameters for the classifier.


simvar = Simvargas({'PARA' 1});

simvar.NODES_VECT = [35];
simvar.MAX_EPOCHS_VECT = [1];
simvar.ARCH_VECT = [22];

simvar.MAX_NUM_TRIALS = 1;
simvar.MAX_RUNNING_TIME = 1;%3600*10; %%% in seconds, will stop after this

simvar = simvar.init(params,parsc,useroptions);

end