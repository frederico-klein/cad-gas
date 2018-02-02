function newskel = norm_cip(tdskel, skelldef)

norm_dist = norm(tdskel(skelldef.bodyparts.NECK,:)-tdskel(skelldef.bodyparts.TORSO,:));
newskel = tdskel/norm_dist;
% figure
% skeldraw(tdskel(1:15,:),'f')
% figure 
% skeldraw(newskel(1:15,:),'f')

%disp('hello')

%error('not tested!')
% if skelldef.novel
%     upperlim = skelldef.hh;
% else
%     upperlim = skelldef.hh/2;
% end
% 
% % for i = 1:upperlim
% %     tdskel(i,:) = (tdskel(i,:) - skelldef.pos_mean)/skelldef.pos_std; %- skelldef.pos_mean
% % end
% 
% if ~skelldef.novel
%     for i = (skelldef.hh/2+1):skelldef.hh
%         tdskel(i,:) = (tdskel(i,:))*skelldef.pos_std/skelldef.vel_std;%- skelldef.vel_mean
%     end
% end
end