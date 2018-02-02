function newskel = distshoulder(tdskel,skelldef)
%disp('Hello')
%bod = skelldef.bodyparts;
shoulder= tdskel(skelldef.bodyparts.TORSO,:);

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
distmat1 = sqrt(sum((tdskel1-shoulder).^2,2));
vel2 = [];
if isfield(skelldef.awk,'vel') %%% we have velocity!
    distmat2 = sqrt(sum((tdskel2-shoulder).^2,2));
    vel2 = distmat2-distmat1;
end
%%% then subtract to create velocities if necessary
newskel = zeros(size(tdskel));
newskel(:,1) = [distmat1; vel2];

end