function distancegraph(gas)
figure
mmm = length(gas);
nnn = 3;
for i = 1:mmm
    %acc = accordance(gas(i).y, gas(i).class);
    acc = all(gas(i).y==gas(i).class);
    %if any(acc==0)
    subplot(mmm,nnn,i*nnn-2)
    %         for j = 1:size(gas(i).class,1)
    %             hold on
    %             scatter(1:length(acc),j*gas(i).class(j,:))
    %
    %         end
    scatter(1:length(acc),vec2ind(gas(i).class))
    hold on
    plot(1:length(acc),vec2ind(gas(i).y))
    ax0 = gca;
    ax0.YLim = [0.0001 14.001];
    hold off
    subplot(mmm,nnn,i*nnn-1)
    scatter(gas(i).distances, acc);
    ax = gca;
    ax.XLim(1) = 0;
    %ax.XLim(2) = 0.5;
    ax.YLim = [0 1];
    subplot(mmm,nnn,i*nnn)
    hist(gas(i).distances,20);
    ax1 = gca;
    ax1.XLim = ax.XLim;
    %end
end
end
function acc = accordance(a, b)
if length(a)~=length(b)
    error('Labels and real values don''t have the same dimensions!')
end
lengtha = length(a);
acc = zeros(lengtha,1);
for i = 1:lengtha
    if a(:,i)==b(:,i)
        acc(i) = 1;
    else
        acc(i) = 0;
    end
end
end