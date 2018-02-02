function newskel = to_polar(tdskel, skelldef)
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
newskel3pol(:,1) = newskel2pol(:,1)-mean(newskel2pol(:,1));

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

%%%%%%%% test version
if 0&&mean(newskel2pol(:,1))>0.5
    figure
    skeldraw(tdskel(1:15,:),'f');hold on;
    maxrot = mean(newskel2pol(:,1));
    for i = 0:.01:maxrot
        %first change y with z
        newskel1(:,1) = tdskel(:,1);
        newskel1(:,2) = tdskel(:,3);
        newskel1(:,3) = tdskel(:,2);
        
        %put into polar coordinates
        [newskel2pol(:,1),newskel2pol(:,2),newskel2pol(:,3)] = cart2pol(newskel1(:,1),newskel1(:,2),newskel1(:,3));
        
        %make a new skeleton that will have the smallest mean theta
        newskel3pol = newskel2pol;
        newskel3pol(:,1) = newskel2pol(:,1)-i;%mean(newskel2pol(:,1));
        %newskel3pol(:,1) = newskel2pol(:,1)-mean(newskel2pol(:,1));
        
        %put it back into cartesian coordinates
        [newskel4(:,1),newskel4(:,2),newskel4(:,3)] = pol2cart(newskel3pol(:,1),newskel3pol(:,2),newskel3pol(:,3));
        
        %invert y and z again
        newskel5(:,1) = newskel4(:,1);
        newskel5(:,2) = newskel4(:,3);
        newskel5(:,3) = newskel4(:,2);
        
        newskel = newskel5;
        %skeldraw(newskel1(1:15,:),'f');
        %skeldraw(newskel4(1:15,:),'f');
        
        skeldraw(newskel5(1:15,:),'f');
    end
    
end

end

