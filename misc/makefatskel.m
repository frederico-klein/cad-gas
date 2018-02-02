function [tdskel,hh] = makefatskel(skel)
%%%%%%%%%MESSAGES PART
%%%%%%%%ATTENTION: this function is executed within loops, so running it will
%%%%%%%%messages on will cause unpredictable behaviour
%dbgmsg('Removing displacement based on hip coordinates (1st point on 25x3 skeleton matrix) from every other')
%dbgmsg('This makes the dataset translation invariant')
%%%%%%%%%%%%%%%%%%%%%
hh = size(skel,1)/3;
%howmanyskels = size(skel,2);
newshape = reshape(skel,hh*3,1,[]);
tdskel = reshape(newshape,hh,3,[]);
% if howmanyskels>1
%     tdskel = zeros(hh,3,howmanyskels);
%     %[tdskel,hh] = makefatskel(skel(:,1));
%     for i = 1:howmanyskels
%         [tdskel(:,:,i), ~] = makefatskel(skel(:,i));
%         %[currskel, ~] = makefatskel(skel(:,i));
%         %tdskel = cat(3, tdskel, currskel );
%         %hh = cat(2, hh, currhh); %% hh will not change, it is matrix,
%         %come on...
%     end
%     disp('')
% else
%     
%     
%     %     %%%% reshape skeleton
%     %     if all(size(skel) == [75 1]) % checks if the skeleton is a 75x1
%     %         tdskel = zeros(25,3);
%     %         for i=1:3
%     %             for j=1:25
%     %                 tdskel(j,i) = skel(j+25*(i-1));
%     %             end
%     %         end
%     %     elseif all(size(skel) == [150 1])
%     %         tdskel = reshape(skel,hh,3); %%%%%I think this should work for every skeleton Nx3, but I will not change the function that came before, because (at least I think), it is working
%     %     elseif all(size(skel) == [25 3])
%     %         tdskel = skel;
%     %     else
%     %         %disp('Not sure, but will try just the reshape...')
%     tdskel = reshape(skel,[],3);
    
%end
%end
end