function newskel = makethinskel(skel)
newskel = [skel(:,1);skel(:,2);skel(:,3)]; % Is reshape faster?
% if ~(all(size(newskel) == [72 1])||all(size(newskel) == [147 1])||all(size(newskel) == [75 1])||all(size(newskel) == [150 1]))
%     error('wrong/strange skeleton size!')
% end
end