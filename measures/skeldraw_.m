function [A,plotexs] = skeldraw_(skel,doIdraw)
%makes a beautiful skeleton of the 75 dimension vector
%or the 25x3 skeleton
% plot the nodes
%reconstruct the nodes from the 75 dimension vector. each 3 is a point
%I use the NaN interpolation to draw sticks which is much faster!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%MESSAGES PART
%dbgmsg('This function is very often called in drawing functions and this message will cause serious slowdown.',1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%checks if skeleton is 72x1 which is a hip-less skeleton
if all(size(skel) == [72 1])
    tdskel = zeros(24,3);
    for i=1:3
        for j=1:24
            tdskel(j,i) = skel(j+24*(i-1));
        end
    end
    tdskel = [[0 0 0 ]; tdskel];
    if all(size(tdskel) ~= [25 3])
        error('wrong skeleton building procedure!')
    end
elseif all(size(skel) == [75 1]) % checks if the skeleton is a 75x1
    tdskel = zeros(25,3);
    for i=1:3
        for j=1:25
            tdskel(j,i) = skel(j+25*(i-1));
        end
    end
else
        tdskel = skel;
end
if size(tdskel,1)==25
    A = stick_draw(tdskel);
elseif size(tdskel,1)==20
    A = other_stick_draw(tdskel);
else
    error('wrong size??')
end

if doIdraw ==true 
    hold_initialstate = ishold();
    plot3(tdskel(:,1), tdskel(:,2), tdskel(:,3),'.y','markersize',15); view(0,0); axis equal;
    hold on
    for k=1:size(tdskel,1) % I used this to make the drawings, but now I think it looks cool and I don't want to remove it
        text(tdskel(k,1), tdskel(k,2), tdskel(k,3),num2str(k))
    end
    plotexs = plot3(A(1,:),A(2,:), A(3,:));
    hold off
    if hold_initialstate == 1
        hold on
    end
   
end
end

function a = stick_draw(tdskel)

%
%in the end the end the text command upstairs was what did the job and I
%wrote down the connection of the skeleton points
%it is as follows:
% 1-2-21-3 torso
% 3-4 head
%
% 5-6-7 right arm
% 8 22 23 right hand
% 
% 9-10-11 left arm
% 12 24 25 left hand
%
% 5-21-9 shoulder
%
% 13-1-17 hip
%
% 13-14-15 right leg
% 15-16 right foot
%
% 17-18-19 left leg
% 19-20 left foot

a = draw_1_stick(tdskel, 1,2);
%draw_1_stick(tdskel, 2,3)
a= [a draw_1_stick(tdskel, 2,21)];
a= [a draw_1_stick(tdskel, 21,3)];
a= [a draw_1_stick(tdskel, 3,4)];

a= [a draw_1_stick(tdskel, 5,21)];
a= [a draw_1_stick(tdskel, 21,9)];

a= [a draw_1_stick(tdskel, 5,6)];
a= [a draw_1_stick(tdskel, 6,7)];

a= [a draw_1_stick(tdskel, 7,8)]; % unsure

a= [a draw_1_stick(tdskel, 8,22)];
a= [a draw_1_stick(tdskel, 22,23)]; % unsure
a= [a draw_1_stick(tdskel, 8,23)]; % unsure

a= [a draw_1_stick(tdskel, 9,10)];
a= [a draw_1_stick(tdskel, 10,11)];

a= [a draw_1_stick(tdskel, 11,12)]; % unsure
a= [a draw_1_stick(tdskel, 12,24)];
a= [a draw_1_stick(tdskel, 12,25)]; % unsure
a= [a draw_1_stick(tdskel, 24,25)];
a= [a draw_1_stick(tdskel, 13,1)];
a= [a draw_1_stick(tdskel, 1,17)];
a= [a draw_1_stick(tdskel, 13,17)]; % draw a thick hip, because we like hips

a= [a draw_1_stick(tdskel, 13,14)];
a= [a draw_1_stick(tdskel, 14,15)];
a= [a draw_1_stick(tdskel, 15,16)];
a= [a draw_1_stick(tdskel, 17,18)];
a= [a draw_1_stick(tdskel, 18,19)];
a= [a draw_1_stick(tdskel, 19,20)];

end
function a = other_stick_draw(tdskel)

a = draw_1_stick(tdskel, 1,2);
a= [a draw_1_stick(tdskel, 2,3)];
a= [a draw_1_stick(tdskel, 3,4)];
a= [a draw_1_stick(tdskel, 3,5)];
a= [a draw_1_stick(tdskel, 5,6)];
a= [a draw_1_stick(tdskel, 6,7)];
a= [a draw_1_stick(tdskel, 7,8)];
a= [a draw_1_stick(tdskel, 3,9)];
a= [a draw_1_stick(tdskel, 9,10)];
a= [a draw_1_stick(tdskel, 10,11)];
a= [a draw_1_stick(tdskel, 11,12)];
a= [a draw_1_stick(tdskel, 1,17)];
a= [a draw_1_stick(tdskel, 17,18)];
a= [a draw_1_stick(tdskel, 18,19)];
a= [a draw_1_stick(tdskel, 19,20)];
a= [a draw_1_stick(tdskel, 1,13)];
a= [a draw_1_stick(tdskel, 13,14)];
a= [a draw_1_stick(tdskel, 14,15)];
a= [a draw_1_stick(tdskel, 15,16)];

end
function a = another_stick_draw()
a = draw_1_stick(tdskel, 1,2);
a= [a draw_1_stick(tdskel, 2,3)];
end
function A = draw_1_stick(tdskel, i,j)
A = [[tdskel(i,1) tdskel(j,1) NaN]; [tdskel(i,2) tdskel(j,2) NaN]; [tdskel(i,3) tdskel(j,3) NaN]];
end
