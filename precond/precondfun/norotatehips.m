function tdskel = norotatehips(tdskel, skelldef)

bod = skelldef.bodyparts;
rvec = tdskel(bod.RIGHT_HIP,:)-tdskel(bod.LEFT_HIP,:);
rotmat = vecRotMat(rvec/norm(rvec),[1 0 0 ]); % arbitrary direction. hope I am not doing anything too stupid
for i = 1:skelldef.hh
    tdskel(i,:) = (rotmat*tdskel(i,:)')';
end
end