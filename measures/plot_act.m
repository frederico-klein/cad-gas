function plot_act(data, other, skelldef, numskels)

%%% so many functions!!!! who can keep track of all of them without
%%% documentation?
%%%
%%% Certainly not me
%%%
%%% This function will plot an action sequence recorded from the sensor in
%%% matlab environment and then plot the bestmatching action sequence it
%%% found from the gas.
%%%
%%% This function should be called from the scope of online_classifier and
%%% it needs this kind of data.
%numskels = 3;
%maybe plot with subplot and show also bestmatching
subplot(3,1,1)
skeldraw(other(:,1:numskels),'rt', skelldef); %%to plot this i need the skelldef :-(
% I will just plot the last one...

%%%listen this function should be more generic and accept parameters, the
%%%whole 405 thing is disgusting. it is a 45*9 samples long
subplot(3,1,2)
i = 5;
%%%% here there is a funny fact. we only have 9 skeletons long so we need
%%%% to check if we have an overflow

skeldraw(data.gas(i).nodes(:,data.test.gas(i).bestmatchbyindex(1:numskels)),'mt',9,skelldef);

subplot(3,1,3)
skeldraw(other(:,1:numskels),'rt', skelldef);
hold
skeldraw(data.gas(i).nodes(:,data.test.gas(i).bestmatchbyindex(1:numskels)),'mt',9,skelldef);
hold off