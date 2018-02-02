function newskel = to_polarSINCOSCORRECT(tdskel, skelldef)

angle = [];
[newskel1, newskel2pol, newskel3pol,avp, newskel4 , newskel5, newskel] = polar_core(tdskel, skelldef, angle);
%%%%%%%% test version
if 0&&avp(1)>0.9
    figure
    skeldraw(tdskel(1:15,:),'f');hold on;
    maxrot = avp;
    rangerange = 0:.01:maxrot;
    rangei = 1:size(rangerange,2);
    arrayofskels = zeros([size(tdskel),size(rangerange,2)]);
    for i = rangei
        [~, ~, ~,~, ~ , newskel5, ~] = polar_core(tdskel, skelldef, rangerange(i));
        
        arrayofskels(:,:,i) = newskel5;
    end
    skeldraw(arrayofskels(1:15,:,:),'W');
    
end

end
function [newskel1, newskel2pol, newskel3pol,avp, newskel4 , newskel5, newskel] = polar_core(tdskel, skelldef, angle)
%newskel3 = zeros(size(tdskel));
%lets break this down into steps so that I don't mess up

%figure
%skeldraw(tdskel(1:15,:),'f');hold on;
%for i = 0:.01:1
%first change y with z
newskel1(:,1) = tdskel(:,1);
newskel1(:,2) = tdskel(:,3);
newskel1(:,3) = tdskel(:,2);

%put into polar coordinates
[newskel2pol(:,1),newskel2pol(:,2),newskel2pol(:,3)] = cart2pol(newskel1(:,1),newskel1(:,2),newskel1(:,3));

%make a new skeleton that will have the smallest mean theta
newskel3pol = newskel2pol;
%newskel3pol(:,1) = newskel2pol(:,1)-i;%mean(newskel2pol(:,1));
%newskel3pol(:,1) = newskel2pol(:,1)-mean(newskel2pol(:,1));
%maybe using the means of angles is not a good idea. what about using the
%means of their signs and cosines and then just guessing the angle back
%with atan2?

rs = tdskel(skelldef.bodyparts.RIGHT_SHOULDER,:);
rh = tdskel(skelldef.bodyparts.RIGHT_HIP,:);
ls = tdskel(skelldef.bodyparts.LEFT_SHOULDER,:);
lh = tdskel(skelldef.bodyparts.LEFT_HIP,:);

av = (rs+rh-(ls+lh))/2;

%plot3([0 av(1)],[0 av(2)],[0 av(3)],'r')
if isempty(angle)
    [avp(1),avp(2),avp(3)] = cart2pol(av(1),av(3),av(2)); %%% this is y-z switched!
else
    avp = angle; %in radians!
end
newskel3pol(:,1) = newskel2pol(:,1)-avp(1);

%put it back into cartesian coordinates
[newskel4(:,1),newskel4(:,2),newskel4(:,3)] = pol2cart(newskel3pol(:,1),newskel3pol(:,2),newskel3pol(:,3));

%invert y and z again
newskel5(:,1) = newskel4(:,1);
newskel5(:,2) = newskel4(:,3);
newskel5(:,3) = newskel4(:,2);

newskel = newskel5;
%skeldraw(newskel1(1:15,:),'f');
%skeldraw(newskel4(1:15,:),'f');

%skeldraw(newskel5(1:15,:),'f');
%end

end
