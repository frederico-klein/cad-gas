function allskel = LoadDataBase(idx_folderi)

%%%%%%Messages part. Provides feedback for the user about what is being
%%%%%%done
dbgmsg('Loading Database and building allskel structure. Please wait, this takes a while.')
%%%%%%


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % Choose:
%startFoldIdx = 1;   % Index of the first test folder to load (1->'Data1')
%stopFoldIdx = 5;    % Index of the last test folder to load (11->'Data11')
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%The script loads:
% - PckVal_*:       packet from wearable device
% - TStamp_QPC_*:   timestamp assigned by the PC to the packet, when it arrives to the PC [us]
% - TStamp_Int_*:   internal timestamp of the wearable device [ms]
% - *_acc_raw_*:    acceleration data
% - M:              depth frame
% - KinectTime:     timestamps assigned by the PC to the frame, when it is available to the PC [100ns]/[us]
% - jMatDep:        skeleton joints in depth space
% - jMatSkl:        skeleton joints in skeleton space
% - KinectTimeBody: timestamps assigned by the PC to the skeleton, when it is available to the PC [100ns]/[us]

[SLASH, pathtodata] = OS_VARS(); % adjust environment variables to system in question (PC, MAC, UNIX)

ADLFolderName = {'sit','grasp','walk','lay'};
FallFolderName = {'front','back','side','EndUpSit'};
%*****Wearable device*****
device1 = '35EE'; %Number of device1
device2 = '36F9'; %Number of device2

%*******Kinect - V2*******
rowPixel = 424; %[pixel] number of row
columnPixel = 512;  %[pixel] number of column
frameIdx = 1; %depth frame number

% Load selected folders
for idx_folder = idx_folderi
    for groupName = {'ADL' 'Fall'}
        if strcmp(groupName,'ADL')
            subfolder = ADLFolderName;
        else
            subfolder = FallFolderName;
        end
        for name_Subfolder = subfolder
            for idx_test = 1:3
                Folder = strcat(pathtodata, 'Data',num2str(idx_folder),SLASH,cell2mat(groupName),SLASH,cell2mat(name_Subfolder),SLASH,num2str(idx_test)); %Folder where are stored the data
                %*************************
                %Load wearable device data
                %*************************
                %**35EE**
                PckVal_35EE = loadPackets(device1,Folder);
                PckValSize_35EE = size(PckVal_35EE);
                TStamp_QPC_35EE = csvread(strcat(Folder,SLASH,'Time',SLASH,'TimeStamps',device1,'.csv'));
                TStamp_Int_35EE = (PckVal_35EE(:,3)+256.*PckVal_35EE(:,4)+256.*256.*PckVal_35EE(:,5));
                %accelerometer values
                X_acc_raw_35EE = PckVal_35EE(:,8)+256*PckVal_35EE(:,9);
                Y_acc_raw_35EE = PckVal_35EE(:,10)+256*PckVal_35EE(:,11);
                Z_acc_raw_35EE = PckVal_35EE(:,12)+256*PckVal_35EE(:,13);
                %36F9
                PckVal_36F9 = loadPackets(device2,Folder);
                PckValSize_36F9 = size(PckVal_36F9);
                TStamp_QPC_36F9 = csvread(strcat(Folder,SLASH,'Time',SLASH,'TimeStamps',device2,'.csv'));
                TStamp_Int_36F9 = (PckVal_36F9(:,3)+256.*PckVal_36F9(:,4)+256.*256.*PckVal_36F9(:,5));
                %accelerometer values
                X_acc_raw_36F9 = PckVal_36F9(:,8)+256*PckVal_36F9(:,9);
                Y_acc_raw_36F9 = PckVal_36F9(:,10)+256*PckVal_36F9(:,11);
                Z_acc_raw_36F9 = PckVal_36F9(:,12)+256*PckVal_36F9(:,13);
                
                %*************************
                %****Load depth frame*****
                %*************************
                fid = fopen(strcat(Folder,SLASH,'Depth',SLASH,'Filedepth_',num2str(frameIdx-1),'.bin'),'r');
                arrayFrame = fread(fid,'uint16');
                fclose(fid);
                M = zeros(rowPixel, columnPixel);
                for r=1:rowPixel
                    M(r,:) = arrayFrame((r-1)*columnPixel+1:r*columnPixel);
                end
                %Load time information
                KinectTime = csvread(strcat(Folder,SLASH,'Time',SLASH,'DepthTime.csv'));
                
                %*************************
                %******Load skeleton******
                %*************************
                fileNameSk1DS = strcat(Folder,SLASH,'Body',SLASH,'Fileskeleton.csv'); %joint in the depth frame
                fileNameSk1SS = strcat(Folder,SLASH,'Body',SLASH,'FileskeletonSkSpace.csv'); %joint in 3D space
                Sk1SkDepth = csvread(fileNameSk1DS);
                Sk1SkSpace = csvread(fileNameSk1SS);
                %Find player number
                for idx_player = 1:6
                    if Sk1SkDepth(25*(idx_player-1)+1,1) ~= 0
                        break;
                    end
                end
                %Find row index of the specific player in Sk1SkDepth
                row_idx = find(Sk1SkDepth(:,5) == idx_player-1);
                Sk1SkDepth = Sk1SkDepth(row_idx,:);
                NumFrameSkelDepth = fix(length(Sk1SkDepth(:,1))/25);
                Sk1SkSpace = Sk1SkSpace(row_idx,:);
                NumFrameSkelSpace = fix(length(Sk1SkSpace(:,1))/25);
                %restore 25 joints in groups
                jMatDep = zeros(25, 3, NumFrameSkelDepth);
                jMatSkl = zeros(25, 3, NumFrameSkelSpace);
                for n = 1:NumFrameSkelDepth
                    jMatDep(:,:,n) = Sk1SkDepth(((n-1)*25+1):n*25,1:3);
                end
                for n = 1:NumFrameSkelSpace
                    jMatSkl(:,:,n) = Sk1SkSpace(((n-1)*25+1):n*25,1:3);
                end
                %Load time information
                KinectTimeBody = csvread(strcat(Folder,SLASH,'Time',SLASH,'BodyTime.csv'));
                
                % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
                % % Put here your code!
                % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
                deltatimes = diff(KinectTimeBody(:,1));
                meany = mean(deltatimes);
                steady = std(deltatimes);
                if any(((deltatimes)-meany)>.8*meany)||steady>6e3||any((deltatimes-meany).^2/steady^2>3)||meany<2e5||meany>6e5
                    figure
                    hist(deltatimes)
                    %error('You will have to handle sample rate!!!')
                end
                %%% Calculate velocities!!
                vel = zeros(size(jMatSkl)); % initial velocity is zero
                ncnc = meany*30; %normalizing constant since the sensor is hopefully always at 30 fps
                for i = 2:size(jMatSkl,3)
                    vel(:,:,i) = ncnc*(jMatSkl(:,:,i) - jMatSkl(:,:,i-1))/(KinectTimeBody(i,1)-KinectTimeBody(i-1,1));
                end
                jskelstruc = struct('skel',jMatSkl, 'act',groupName,'act_type', name_Subfolder, 'index', idx_test, 'subject', idx_folder,'time',KinectTimeBody,'vel',vel);
                %%%%%% size(jskelstruc.skel) % this was here for debugging
                if exist('allskel','var') % initialize my big matrix of skeletons
                    allskel = cat(2,allskel,jskelstruc);
                else
                    allskel = jskelstruc;
                end
                % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
                % Plot raw Acceleration data of each test
                %figure;
                %subplot 121; title('35EE'); hold on;
                %plot(X_acc_raw_35EE,'b'); plot(Y_acc_raw_35EE,'r'); plot(Z_acc_raw_35EE,'k');
                %subplot 122; title('36F9'); hold on;
                %plot(X_acc_raw_36F9,'b'); plot(Y_acc_raw_36F9,'r'); plot(Z_acc_raw_36F9,'k');
                
                % Plot Depth and Skeleton data of each test
                %figure;
                %subplot 131;
                %imagesc(M); title('depth frame');
                %subplot 132;  hold on;
                %plot3(jMatSkl(:,1,1),jMatSkl(:,3,1),jMatSkl(:,2,1),'.r','markersize',20); view(0,0); axis equal;
                %title('skeleton in skeleton space');
                %subplot 133;
                %plot3(jMatDep(:,1,1),jMatDep(:,3,1),jMatDep(:,2,1),'.b','markersize',20); view(0,0); axis equal; set(gca,'ZDir','Reverse');
                %title('skeleton in depth space');
                % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
            end
        end
    end
end

end
function PckVal = loadPackets(device,path)
[SLASH, ~] = OS_VARS();
n = 22; % No. of columns of T
fid = fopen(strcat(path,SLASH,'Shimmer',SLASH,'Packets',device,'.bin'),'r');
B = fread(fid,'uint8');
fclose(fid);
BB = reshape(B, n,[]);
PckVal = permute(BB,[2,1]);
end