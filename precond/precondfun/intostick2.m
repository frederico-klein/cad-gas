function zeroskel = intostick2(tdskel, skelldef)
bod = skelldef.bodyparts;
UCI = [bod.HEAD bod.NECK bod.LEFT_SHOULDER  bod.RIGHT_SHOULDER bod.LEFT_ELBOW bod.RIGHT_ELBOW  ];
uppercentroid = mean(tdskel(UCI ,:));
uppercentroidvel  = mean(tdskel(UCI+skelldef.hh/2,:));
middlecentroid = tdskel(bod.TORSO,:);
middlecentroidvel = tdskel(bod.TORSO+skelldef.hh/2,:);
LCI = [ bod.LEFT_KNEE bod.RIGHT_KNEE bod.LEFT_HIP bod.RIGHT_HIP];
lowercentroid =mean(tdskel(LCI,:));
lowercentroidvel =mean(tdskel(LCI+skelldef.hh/2,:));
zeroskel = zeros(size(tdskel));
zeroskel(1:3,:) = [uppercentroid;middlecentroid;lowercentroid];
zeroskel((skelldef.hh/2+1):(skelldef.hh/2+3),:) = [uppercentroidvel;middlecentroidvel;lowercentroidvel];
end