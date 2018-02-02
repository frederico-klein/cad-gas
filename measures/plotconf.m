function plotconf(mt)
%%% Reads metrics structure, loading targets and outputs and shows
%%% confusion matrices, as well as display some nice 
% 


al = length(mt);
if isfield(mt(1).conffig, 'val')&&~isempty(mt(1).conffig.val)
    figset = cell(6*al,1);
    for i = 1:al
        figset((i*6-5):i*6) = [mt(i).conffig.val mt(i).conffig.train];
    end
else
    figset = cell(3*al,1);
    for i = 1:al
        figset((i*3-2):i*3) = mt(i).conffig.train;
    end
    
end
% plotconfusion(figset{:})

confusions.a = zeros(size(figset{1},1), size(figset{1},1),size(mt,2));
confusions.b = confusions.a;
for i=1:size(figset,1)/6
    index = (i-1)*6 +1;
    [~, confusions.a(:,:,i)] = confusion(figset{index}, figset{index+1});
    [~, confusions.b(:,:,i)] = confusion(figset{index+3}, figset{index+4});
end
cc.b = confusions.a;
disp('validation')
analyze_outcomes(cc)
disp('training')
analyze_outcomes(confusions)
end