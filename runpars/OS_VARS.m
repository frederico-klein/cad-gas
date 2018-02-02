function [SLASH, pathtodata] = OS_VARS()
exthdname = 'Elements';
if ispc
    SLASH = '\\'; % windows
    list_dir = {'d', 'e', 'f', 'g', 'h'};
    list_ind = 1;
    while (~exist([list_dir{list_ind} ':\fall_detection_datasets\TST Fall detection database ver. 2\'],'dir'))
        list_ind = list_ind +1;
        if list_ind > length(list_dir)
            error('Could not find suitable save directory')
        end
    end
    pathtodata = [list_dir{list_ind} ':\\fall_detection_datasets\TST Fall detection database ver. 2\'];
elseif ismac
    pathtodata = ['/Volumes/' exthdname '/fall_detection_datasets/TST Fall detection database ver. 2/'];
    SLASH = '/'; %
elseif isunix
    [~,cmdout] = system('echo $USER');
    %pathtodata = '/media/Elements/fall_detection_datasets/TST Fall detection database ver. 2/';
    pathtodata = ['/media/' cmdout(1:end-1) '/' exthdname '/fall_detection_datasets/TST Fall detection database ver. 2/'];
    SLASH = '/'; %
else
    error('Cant determine OS')
end


end