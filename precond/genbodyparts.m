function bodyparts = genbodyparts(lenlen)
bodyparts = struct();
switch lenlen
    case {150,75,25}
        bodyparts.SpineBase = 1;
        bodyparts.SpineMid = 2;
        bodyparts.Neck = 3;
        bodyparts.Head = 4;
        bodyparts.ShoulderLeft = 5;
        bodyparts.ElbowLeft = 6;
        bodyparts.WristLeft = 7;
        bodyparts.HandLeft = 8;
        bodyparts.ShoulderRight = 9;
        bodyparts.ElbowRight = 10;
        bodyparts.WristRight = 11;
        bodyparts.HandRight = 12;
        bodyparts.HipLeft = 13;
        bodyparts.KneeLeft = 14;
        bodyparts.AnkleLeft = 15;
        bodyparts.FootLeft = 16;
        bodyparts.HipRight = 17;
        bodyparts.KneeRight = 18;
        bodyparts.AnkleRight = 19;
        bodyparts.FootRight = 20;
        bodyparts.SpineShoulder = 21;
        bodyparts.HandTipLeft = 22;
        bodyparts.ThumbLeft = 23;
        bodyparts.HandTipRight = 24;
        bodyparts.ThumbRight = 25;
        %%% synonyms
        bodyparts.hip_center = bodyparts.SpineBase;
        bodyparts.NECK = bodyparts.Neck;
        bodyparts.RIGHT_HIP = bodyparts.HipRight;
        bodyparts.LEFT_HIP = bodyparts.HipLeft;        
        bodyparts.LEFT_SHOULDER = bodyparts.ShoulderLeft;
        bodyparts.RIGHT_SHOULDER = bodyparts.ShoulderRight;        
        bodyparts.LEFT_ELBOW = bodyparts.WristRight;
        bodyparts.RIGHT_ELBOW = bodyparts.WristLeft;
        bodyparts.LEFT_KNEE =  bodyparts.KneeLeft;
        bodyparts.RIGHT_KNEE = bodyparts.KneeRight;        
        bodyparts.RIGHT_FOOT =  [bodyparts.AnkleRight,	 bodyparts.FootRight];
        bodyparts.LEFT_FOOT =  [bodyparts.AnkleLeft,	 bodyparts.FootLeft];
        bodyparts.HEAD	=	 bodyparts.Head;
        bodyparts.TORSO = bodyparts.SpineShoulder;
        bodyparts.RIGHT_HAND = [bodyparts.HandTipRight bodyparts.ThumbRight];
        bodyparts.LEFT_HAND = [bodyparts.HandTipLeft bodyparts.ThumbLeft];        
    case {120,60,20}
        bodyparts.hip_center = 1;
        bodyparts.spine = 2;
        bodyparts.shoulder_center = 3;
        bodyparts.head = 4;
        bodyparts.shoulder_left = 5;
        bodyparts.elbow_left = 6;
        bodyparts.wrist_left = 7;
        bodyparts.hand_left = 8;
        bodyparts.shoulder_right = 9;
        bodyparts.elbow_right = 10;
        bodyparts.wrist_right = 11;
        bodyparts.hand_right = 12;
        bodyparts.hip_left = 13;
        bodyparts.knee_left = 14;
        bodyparts.ankle_left = 15;
        bodyparts.foot_left = 16;
        bodyparts.hip_right = 17;
        bodyparts.knee_right = 18;
        bodyparts.ankle_right = 19;
        bodyparts.foot_right = 20;
        %%% synonyms        
        bodyparts.HEAD	=	 bodyparts.head;
        bodyparts.NECK = bodyparts.spine;
        bodyparts.TORSO = bodyparts.shoulder_center;
        bodyparts.LEFT_SHOULDER = bodyparts.shoulder_left;
        bodyparts.LEFT_ELBOW = bodyparts.elbow_left;
        bodyparts.RIGHT_SHOULDER = bodyparts.shoulder_right;        
        bodyparts.RIGHT_ELBOW = bodyparts.elbow_right;
        bodyparts.LEFT_HIP = bodyparts.hip_left;
        bodyparts.LEFT_KNEE = bodyparts.knee_left;
        bodyparts.RIGHT_HIP = bodyparts.hip_right;
        bodyparts.RIGHT_KNEE = bodyparts.knee_right;       
        bodyparts.LEFT_HAND = [bodyparts.wrist_left, bodyparts.hand_left];
        bodyparts.RIGHT_HAND = [bodyparts.wrist_right, bodyparts.hand_right]; 
        bodyparts.LEFT_FOOT =  [bodyparts.ankle_left,	 bodyparts.foot_left];
        bodyparts.RIGHT_FOOT =  [bodyparts.ankle_right,	 bodyparts.foot_right];
    case {90,45,15}
        bodyparts.HEAD = 1;
        bodyparts.NECK = 2;
        bodyparts.TORSO = 3;
        bodyparts.LEFT_SHOULDER = 4;
        bodyparts.LEFT_ELBOW = 5;
        bodyparts.RIGHT_SHOULDER = 6;
        bodyparts.RIGHT_ELBOW = 7;
        bodyparts.LEFT_HIP = 8;
        bodyparts.LEFT_KNEE = 9;
        bodyparts.RIGHT_HIP = 10;
        bodyparts.RIGHT_KNEE = 11;
        bodyparts.LEFT_HAND = 12;
        bodyparts.RIGHT_HAND = 13;
        bodyparts.LEFT_FOOT = 14;
        bodyparts.RIGHT_FOOT = 15;
        %%%
        bodyparts.hip_center = [];    
    otherwise
        dbgmsg('No idea from this size from what type of skeleton this is. I will assume it is a randomstick.')
        bodyparts.HEAD = [];
        bodyparts.NECK = [];
        bodyparts.TORSO = [];
        bodyparts.LEFT_SHOULDER = [];
        bodyparts.LEFT_ELBOW = [];
        bodyparts.RIGHT_SHOULDER = [];
        bodyparts.RIGHT_ELBOW = [];
        bodyparts.LEFT_HIP = [];
        bodyparts.LEFT_KNEE = [];
        bodyparts.RIGHT_HIP = [];
        bodyparts.RIGHT_KNEE = [];
        bodyparts.LEFT_HAND = [];
        bodyparts.RIGHT_HAND = [];
        bodyparts.LEFT_FOOT = [];
        bodyparts.RIGHT_FOOT = [];
        %%%
        bodyparts.hip_center = [];    
        return
end
end