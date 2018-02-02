function newskel = highhips(tdskel, skelldef)
bod = skelldef.bodyparts;
if isempty(bod.hip_center)&&skelldef.hh==30
    %%% then this possibly it is the 15 joint skeleton
    hip = (tdskel(bod.LEFT_HIP,:) + tdskel(bod.RIGHT_HIP,:))/2;
else
    hip = tdskel(bod.hip_center,:);
end
%hip([1,2]) = 0; %% no idea if this right
hip(2) = 0; %%%% y is height, so we want that to be preserved.

if skelldef.novel
    hips = repmat(hip,skelldef.hh,1);
else
    hips = [repmat(hip,skelldef.hh/2,1);zeros(skelldef.hh/2,3)]; % this is so that we dont subtract the velocities
end
newskel = tdskel - hips;
end