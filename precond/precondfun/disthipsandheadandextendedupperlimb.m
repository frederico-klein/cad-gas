function newskel = disthipsandheadandextendedupperlimb(tdskel,skelldef)
hip = (tdskel(skelldef.bodyparts.LEFT_HIP,:) + tdskel(skelldef.bodyparts.RIGHT_HIP,:))/2;
head= tdskel(skelldef.bodyparts.HEAD,:);

%DEFINE THE HANDS AND SHOULDERS TO SEE WHICH ONE IS EXTENDED
rs = tdskel(skelldef.bodyparts.RIGHT_SHOULDER  ,:);
ls = tdskel(skelldef.bodyparts.LEFT_SHOULDER   ,:);
rh = tdskel(skelldef.bodyparts.RIGHT_HAND  ,:);
lh = tdskel(skelldef.bodyparts.LEFT_HAND   ,:);

%FIGURE OUT WHICH ONE IS EXTENDED
rul = sqrt(sum((rs-rh).^2,2));
lul = sqrt(sum((ls-lh).^2,2));
if rul>lul %right hand is more extended
    dhand = rh;
else
    dhand = lh;
end
%%% calculate distances from dominant hand below

%disp('Hello')
%%% first calculate new next skeleton with adding velocities if necessary
if isfield(skelldef.awk,'vel') %%% we have velocity!
    tdskel1 = tdskel(1:skelldef.hh/2,:);
    tdskel2 = tdskel(skelldef.hh/2+1:end,:) +tdskel1;
else
    tdskel1 = tdskel;
    tdskel2 = [];
end
%%% then calculate the distances twice for old and new skeleton if
%%% necessary
distmat1s = sqrt(sum((tdskel1-head).^2,2));
vel2s = [];

distmat1h = sqrt(sum((tdskel1-hip).^2,2));
vel2h = [];

distmat1m = sqrt(sum((tdskel1-dhand).^2,2));
vel2m = [];

if isfield(skelldef.awk,'vel') %%% we have velocity!
    distmat2s = sqrt(sum((tdskel2-head).^2,2));
    distmat2h = sqrt(sum((tdskel2-hip).^2,2));
    distmat2m = sqrt(sum((tdskel2-dhand).^2,2));
    vel2s = distmat2s-distmat1s;
    vel2h = distmat2h-distmat1h;
    vel2m = distmat2m-distmat1m;
end
%%% then subtract to create velocities if necessary
newskel = zeros(size(tdskel));
newskel(:,1) = [distmat1s; vel2s];
newskel(:,2) = [distmat1h; vel2h];
newskel(:,3) = [distmat1m; vel2m];

end