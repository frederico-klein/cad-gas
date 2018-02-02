function tdskel = norotateshoulders(tdskel, skelldef)
bod = skelldef.bodyparts;
rvec = tdskel(bod.RIGHT_SHOULDER,:)-tdskel(bod.LEFT_SHOULDER,:);
rotmat = vecRotMat(rvec/norm(rvec),[1 0 0 ]); % arbitrary direction. hope I am not doing anything too stupid
for i = 1:skelldef.hh
    tdskel(i,:) = (rotmat*tdskel(i,:)')';
end
end