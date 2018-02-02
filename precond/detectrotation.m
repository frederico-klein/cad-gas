function [angle, vectvect] = detectrotation(skel, skelldef, joint)
%angle = 0;
switch joint
    case 'hips'
        vectvect = skel(skelldef.bodyparts.LEFT_HIP,:) - skel(skelldef.bodyparts.RIGHT_HIP,:);
    case 'torax'
        vectvect = skel(skelldef.bodyparts.LEFT_SHOULDER,:) - skel(skelldef.bodyparts.RIGHT_SHOULDER,:);
end
[angle, ~, ~] = cart2pol(vectvect(1), vectvect(3), vectvect(2));
%angle = angle +pi/2;
%angle = [a, b, c];
end