function showdataset(varargin)
% function showdaset(realclass)
%
% showdataset(realclass)
%   will show you all the action labels
% showdataset(realclass,N)
%   will show you all the action examples with label equal to N
%
% showdataset(data,simvar ,N)
whatcanbeshown = {'train','val','test'};
whatIshow = whatcanbeshown{1};
plotstep = 100;
N = [];
%%% yes, overloading
if isequal(varargin{end},'allskel')
    show_notconformed(varargin{1:end-1}) %%%%% plots the allskel types
    return
end
if isempty(varargin)
    help showdataset
    error('Must have dataset!')
elseif nargin==1&&isfield(varargin{1},'outstruct')
    realclass = varargin{1};
    outstruct = realclass.outstruct;
    disp(realclass.simvar.labels_names)
elseif nargin==1
    error('Missing data!')
elseif nargin==2&&isfield(varargin{1},'outstruct')
    realclass = varargin{1};
    outstruct = realclass.outstruct;
    simvar = realclass.simvar;
    N = varargin{2};
else
    outstruct = varargin{1};
    simvar = varargin{2};
    if nargin ==3
        N = varargin{3};
    end
end

if isempty(N)
    for N = 1:length(simvar.labels_names)
        drawdraw(N,simvar.labels_names, outstruct.(whatIshow),plotstep)
    end
else
    drawdraw(N,simvar.labels_names, outstruct.(whatIshow),plotstep)
end


end
function drawdraw(N, labels, setset,plotstep)
disp(['Chosen action: ' labels(N)])
%aaa = 0;
% for i = 1:length(setset.ends)
%     if setset.y(N,realends(i))==1
%         aaa = aaa+1;
%     end
% end


setset = choosewanted(N,chopset(setset));

aaa = length(setset);
figure

for i =1:aaa
    ends = size(setset{i}.data,2);
    subplot(3,aaa,i)
    title(labels(N))
    for a = 1:plotstep:ends
        skeldraw(setset{i}.data(1:45,min(a:a+plotstep)));
        drawnow
    end
    lengthsplot = [];
    for a = 1:ends
        [~,skel ]= skeldraw(setset{i}.data(1:45,a),'t');
        lengths = skellengths(skel);
        lengthsplot(:,a) = lengths';
    end
    
    subplot(3,aaa,i+aaa)
    title('Lengths of limbs')
    plot(lengthsplot')
    drawnow
    subplot(3,aaa,i+2*aaa)
    title('whatskeltonisthis')
    plot(setset{i}.index)
    drawnow
end
% for i = 1:length(setset.ends)
%     if setset.y(N,realends(i))==1
%         bbb = bbb+1;
%         subplot(2,aaa,bbb)
%         title(labels(N))
%         for a = realends(i):plotstep:realends(i+1)
%             skeldraw(setset.data(1:45,a:a+plotstep));
%             drawnow
%         end
%         lengthsplot = [];
%         if 1
%             for a = realends(i):realends(i+1)
%                 [~,skel ]= skeldraw(setset.data(1:45,a),'t');
%                 indexlengthsplot = a-realends(i) +1;
%                 lengths = skellengths(skel);
%                 lengthsplot(:,indexlengthsplot) = lengths';
%             end
%         end
%         subplot(2,aaa,bbb+aaa)
%         title('Lengths of limbs')
%         plot(lengthsplot')
%     end
%
% end
end
% function [begins, ends] = showends(vect,offsetends)%%% this is more complex than it seems because actions can be merged if they have the same label
% %%% test with 
% %a = [0 0 0 1 1 1 1 1 1 1 0 0 ];
% %b = [3 3 4 2] %%realends 6 is actually occluded
% %showends(a,b)
% 
% realends = cumsum(offsetends);
% diffvect = diff(vect); 
% a = find(diffvect);
% if a(1)&&vect(1) % in case a starts as one, it would output nonsense
%     a = [1 a];
% end
% 
% begins = a(1:2:end)+1;
% ends = a(2:2:end);
% 
% %%% there is another caveat here...
% %%% this will only happen once, since the last action will not end into
% %%% something else
% if length(begins)~=length(ends)
%     %should redefine a for consistance
%     a = [a vect(end)];
%     % now the important part, redefining ends:
%     ends = [ends vect(end)];
% end
% 
% %%% if there is a realend in between begins and ends, then split them:
% thereisabreakbetweenthem = [];
% for i = 1:size(ends)
%     thereisabreakbetweenthem = union(intersect(begins(i):(ends(i)-1),realends),thereisabreakbetweenthem);    
% end
% 
% if ~isempty(thereisabreakbetweenthem)
%     % this didnt work
% %     %%% i guess the easier way is just to make another a and redo
% %     %%% begins and ends
% %     newdiff = diffvect;
% %     for i = 1:length(thereisabreakbetweenthem)
% %         newdiff(thereisabreakbetweenthem(i)) = -1;
% %         newdiff(thereisabreakbetweenthem(i)+1) = 1;
% %     end
% %    a = find(newdiff);
%     newa = sort([a'; thereisabreakbetweenthem;thereisabreakbetweenthem]);
%     begins = newa(1:2:end)+1;
%     ends = newa(2:2:end);
% end
% 
% 
% end
function newset = choosewanted(N, set)
newset = cell(0);
j = 0;
for i = 1:length(set)
    if set{i}.y(N,1)
        j = j+1;
        newset{j} = set{i};
    end
end

end
function show_notconformed(varargin)
%%%it is an allskel
allskel = varargin{1};
labels = unique({allskel.act_type});

plotstep = 1000;
for N = 2% 1:length(labels)
    aaa =0;
    for i =1: length(allskel)
        if isequal(labels{N},allskel(i).act_type)
            aaa = aaa+1; %%% finds all of this action type
        end
    end
    figure
    bbb = 0;
    for  i =1: length(allskel)
        if isequal(labels{N},allskel(i).act_type)
            bbb= bbb+1;
            subplot(1,aaa,bbb)
            title(labels(N))
            for a = 1:plotstep:size(allskel(i).skel,3)
                ending_arg = min([a+plotstep size(allskel(i).skel,3)]);
                if ending_arg==size(allskel(i).skel,3) %%% this is a bit overly convoluted, but I hope it will not require debugging in the future.
                    selection_index = [a a];
                else
                    selection_index = a:ending_arg;
                end
                
                skeldraw(allskel(i).skel(:,:,selection_index));
                drawnow
            end
        end
    end
    
end
end