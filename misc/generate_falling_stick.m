function allskel = generate_falling_stick(numsticks)

% if length(numsticks)>1
%     allskel = [];
%     for i = subject
%         allskel = [allskel generate_falling_stick(i)];
%     end
%     return
% end
stickmodel = 'skel25'; % 'rod', 'skel25', 'skel15'
thetanoisepower = 0.01;
translationnoisepower = 1;
floorsize = 1500;

for kk = 1:numsticks
    num_of_points_in_stick = 25;
    
    %%% random size
    %%% random start location
    %%% random initial velocity for falling stick
    
    l = (1.6+rand()*.3)*1000;
    
    for akk = [0,1]
        
        startlocation = floorsize*[rand(), 0.01*rand(), rand()];
        phi = 2*pi*rand();
        phinoisepower = 0.1*rand;
        initial_velocity = -1*rand();
        
        if akk
            act = 'Fall';
            % from http://www.chem.mtu.edu/~tbco/cm416/MatlabTutorialPart2.pdf and
            % from http://ocw.mit.edu/courses/mechanical-engineering/2-003j-dynamics-and-control-i-spring-2007/lecture-notes/lec10.pdf
            % the equation from the falling stick is
            %
            % -m*g*l/2*cos(t) = (Ic+m*l^2/4*cos(t)^2)*tdd - m*l^2/4*cos(t)*sin(t*td^2)
            %
            % tdd = diff(td)
            % td = diff(t)
            
            testOptions = odeset('RelTol',1e-3,'AbsTol', [1e-4; 1e-2]);
            notsatisfiedwithmodel = true;
            while(notsatisfiedwithmodel)
                [t,x] =     ode45(@stickfall, [0 2+1.5*rand()], [pi/2;initial_velocity], testOptions);
                
                
                
                %%% resample to kinect average sample rate, i.e. 15 or 30 hz
                x = resample(x(:,1),t,30);
                
                %%% upon visual inpection we see that the beginnings and ends
                %%% of the results from ode45 sequence are very noisy, possibly
                %%% due to the unnatural constraints on the differential
                %%% equation mode. Some doctoring is required:
                
                x(1,:) = x(2,:)+0.01*rand(); %%% fixing initial point
                %             %now to fix the ends it is even dirtier:
                %             plot(x(:,1))
                %             hold on
                diffx = abs(diff(x));
                for i = length(diffx):-1:3
                    if all([diffx(i-2), diffx(i-1), diffx(i)]<0.07) %this was done on trial and error basis
                        x = x(1:i);
                        if abs(x(end))<0.1||abs(x(end)-pi)<0.1 %%it has to end in a natural resting angle
                            notsatisfiedwithmodel = false;
                        end
                        break
                    end
                end
            end
            padding = x(end).*ones(round(130*rand()),1);
            padding = padding+thetanoisepower*rand(size(padding));
            x = [x;padding];
            %             plot(x(:,1))
            %             hold off
            phinoise = zeros(size(x)); %%% a freefalling stick would never change angle, ok maybe if it were spinning, or hit by something...
            translationnoise = translationnoisepower*zeros(size(x,1),3);
            [skel, vel] = construct_skel(x,l,num_of_points_in_stick ,startlocation, translationnoise, phi, phinoise, stickmodel);
            
        else
            act = 'Walk';
            %%% non falling activity
            x = pi/2*ones(90+round(25*rand()),1)+0*thetanoisepower; % does it even make sense if the velocity changes and the position does not?
            phinoise = 0*phinoisepower*rand(size(x));
            %%% the walk now
            t = linspace(0,1,length(x));
            realtransx = 2*sin(phi)*t*floorsize;
            realtransy = 0*t*floorsize;
            realtransz = 2*cos(phi)*t*floorsize;
            translationnoise = 0*translationnoisepower*rand(size(x,1),3)+[realtransx; realtransy; realtransz]';
            [skel, vel] = construct_skel(x, l, num_of_points_in_stick, startlocation, translationnoise , phi, phinoise, stickmodel);
            
        end
        %for i = 1:s
        construct_sk_struct = struct('x',x,'l',l,'num_points', num_of_points_in_stick,'startlocation',startlocation,'phi',phi);
        jskelstruc = struct('skel',skel,'act_type', act, 'index', kk, 'subject', kk,'time',[],'vel', vel, 'construct_sk_struct', construct_sk_struct);
        
        %plot(stickstick(:,1), stickstick(:,2), '*')
        if exist('allskel','var') % initialize my big matrix of skeletons
            allskel = cat(2,allskel,jskelstruc);
        else
            allskel = jskelstruc;
        end
    end
end
end
function dx = stickfall(t,x)

m = 1;
g = 9.8;
l = 1.6;
t = 0;

Ic = 1/3*m*l^2;%% for a slender rod rotating on one end

x1 = x(1);
x2 = x(2);

% state equations
% I can put any nonlinearilty I want, so I will make so that when  x1 == 0
% or x1 = pi, then the velocity changes sign, i.e. it bounces

if ((x1 < 0)&&x2<0)||((x1> pi)&&x2>0)
    dx1 = -0.5*x2; %so that it dampens as well
else
    dx1 = x2;
end

dx2 = (m*l^2/4*cos(x1*x2^2) -m*g*l/2*cos(x1))/(Ic+m*l^2/4*cos(x1)^2);

dx = [dx1;dx2];

end
function [stickstick,stickvel] = construct_skel(thetha, l, num_of_points_in_stick, displacement, tn, phi, phinoise, stickmodel)

bn = [rand(), rand(), rand()]/10; %% I need a bit of noise or the classifier gets insane

simdim = size(thetha,1); % 4;%

stickstick = zeros(num_of_points_in_stick,3,simdim);
stickvel = stickstick; %%%
switch stickmodel
    case 'rod'
        for i=1:simdim
            dpdp =  displacement+tn(i,:);
            tt=thetha(i);
            PHI = phi+phinoise(i);
            
            stickstick(1,:,i) = dpdp-l/2*cos(tt)*[cos(PHI) 0 sin(PHI)];
            for j = 2:num_of_points_in_stick
                stickstick(j,:,i) = ([cos(tt)*cos(PHI), sin(tt), cos(tt)*sin(PHI)]+bn)*l*j/num_of_points_in_stick+dpdp-l/2*cos(tt)*[cos(PHI) 0 sin(PHI)];
            end
        end
    case 'skel25'
        num_of_points_in_stick = 25;
        %%%% skeleton model was obtained after using generate_skel_data
        %protoskel = allskel1(3).skel(:,:,1) -repmat(mean(allskel1(3).skel(:,:,1)),25,1);
        prot = load('protoskel.mat');
        height = 1552;
        if ~isfield(prot,'protoskel')
            error('Problems to load protoskel.mat: skeleton model not found.')
        end
        for i=1:simdim
            dpdp =  displacement+tn(i,:);
            tt=thetha(i);
            PHI = phi+phinoise(i);
            %%% will need to make 2 rotation matrices
            % PHI is first, it is a rotation around the y axis
            %             PHIMAT = [[cos(PHI) 0 sin(PHI)];[0 1 0];[-sin(PHI) 0 cos(PHI)]];
            %             % now, is a fall a rotation on x or z axis?
            %             % I will do both and comment out the one I dislike; or maybe I
            %             % can make it a different kind of fall.
            %             %around x
            %             if 1
            %                 ttmatx = [[1 0 0 ];[0 cos(tt) -sin(tt)];[0 sin(tt) cos(tt)]];
            %                 ttmatz = eye(3);
            %             else
            %                 %around z
            %                 ttmatx = eye(3);
            %                 ttmatz = [[cos(tt) -sin(tt) 0];[sin(tt) cos(tt) 0 ];[0 0 1]];
            %             end
            %stickstick(1,:,i) = dpdp;
            askel = rotskel(prot.protoskel2+repmat([0 height/2 0],num_of_points_in_stick,1),0,PHI,pi/2-tt);
            for j = 1:num_of_points_in_stick
                %                 stickstick(j,:,i) = (ttmatz*PHIMAT*ttmatx*prot.protoskel2(j,:).').'/height*l+dpdp-l/2*cos(tt)*[cos(PHI) 0 sin(PHI)]+[0 height/2 0];
                stickstick(j,:,i) = askel(j,:)/height*l+dpdp-l/2*cos(tt)*[cos(PHI) 0 sin(PHI)];
                
            end
            %there is something wrong with my matrix multiplication I think,   but I have no time to be elegant about it
            %or probably means I am wrong about the kinect data's axis; in any case, this would only affect conformskel mirror functions,
            %I should plot database(posei), hold and plot
            %mirrordatabase(posei) to see if the skeleton is upsidedown...
            %2/3 chances it isnt...
            %quick and dirty
            %stickstick(:,1,i) = - stickstick(:,1,i);
            
        end
end
%%% the initial velocities are not zero, but I had to artificially change
%%% the x point because of limitations of the simulated stick. They are
%%% already zeroed, so I just need to start from the second point

%%% for the next ones I will calculate the points
for i = 2:simdim
    stickvel(:,:,i-1) = stickstick(:,:,i)-stickstick(:,:,i-1);
end

%stickstick; % ok, I forgot that the reshape happens latter %reshape(stickstick,[],simdim);


end