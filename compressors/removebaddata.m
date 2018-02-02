function icli = removebaddata(inp, idxx,rev, qp) 
%%%% THIS FUNCTION IS A MESS. It was really difficult to write, it is slow
%%%% (I have implemented a considerable speedup, but then it lost
%%%% generality!) and perhaps even inaccurate. BUT, to make this better it
%%%% would probably require to not use cells anymore, but a structure with
%%%% variable number of fields and go through them in order. 

if isstruct(rev)    
    aaaa = fieldnames(rev);
else
    aaaa = []; %%% this is already a warning and the warning below should be an error, but I have little time and would need more help with this to do it the right way
    if ~isempty(rev)
        warning('wrong initialization for rev variable! please debug.')
    end
end
something_to_remove = false;
for i = 1:length(aaaa)
    if ~isempty(rev.(aaaa{i}))
        something_to_remove = true;
    end
end
if ~something_to_remove
    icli = inp;
    return
end

q = qp(1);
switch length(qp)
    case 1
        p = 0;
        r = 1;
    case 2
        p = qp(2);
        r = 1;
    case 3
        p = qp(2);
        r = qp(3);
end
allitems = 1:size(inp,2);
eliminate = [];
B = [];
for i = 1:length(aaaa)
    for j = 1:length(rev.(aaaa{i}))
        if i >1
            error('set debug on!')
        end
        [~, B ] = find(idxx == rev.(aaaa{i})(j));        
    end
    eliminate = [B, eliminate];
end
icli = inp(:,setdiff(allitems, eliminate));
dbgmsg('Removed ', num2str(length(unique(eliminate))),0)

%     warning('I am removing some points!')
%     
%     % I will make this a basic implementation. The cells should have
%     % appropriate multi-layer data points to remove, so it will likely not be
%     % that hard to debug once the error occurs when there are different
%     % concatenation levels to remove here in this place.
%     
%     %[idxx{1}{1}{:}] is the first element of 3 that makes the my 9 element
%     %supervector
%     
%     %[rev{1,1}{:}] is the first element I want to check it against. if they are
%     %the same, then it is out
%     
%     allitems = 1:size(inp,2);
%     eliminate = [];
%     imax = size(rev,2);
%     jmax = size(idxx,2);
%     for i = 1:imax
%         try %actually I may have solved a problem with the turtles thing, but I think I havent. this fix is a hAck, hope it doesnt break too often, sorry
%             currrev = [rev{1,i}{:}];
%         catch
%             currrev = rev{i};
%         end
%         try
%             jlower = max([1 fix((currrev(1)*.7)/(q*(p+1)*r))-1 ]); % I think indexes will be always ordered, so I THINK this will always work...
%             jhigher = min([jmax ceil((currrev(end))/(q*(p+1)*r))+1]); % multiply by 10 if it doesnt work %%% there is some irregularity here because of actions that dont end where they should, so each ending action can cause you to drift additionally q*(p+1)*r-1 data samples      
%         catch %% in strange concatenations my speedup will fail. I cannot think of everything...
%             try %% maybe it is still a cell then?
%                 jlower = max([1 fix((currrev{1}*.9)/(q*(p+1)*r))-1 ]); 
%                 jhigher = min([jmax ceil((currrev{end})/(q*(p+1)*r))+1]);
%             catch
%                 dbgmsg('You better debug this function because using these long indexes will take forever!!!!!',1)
%                 jlower = 1;
%                 jhigher = jmax;
%             end                       
%         end
%         for j = jlower:jhigher         %1:jmax %%% I will try to improve this by limiting the data that I look up based on q!
%             kmax = size(idxx{j},2);
%             for k = 1:kmax                
%                 curridxx = [idxx{j}{k}{:}];
% %                 maxcurrpoint = max(turtlesallthewaydown(curridxx));
% %                 mincurrpoint = min(turtlesallthewaydown(curridxx));
%                 if isequal(currrev,curridxx) %maybe I can try this, if it fails do a catch opening it once more. it will be the world's slowest function, but...
%                     if iscell(currrev)
%                         eliminate = cat(2, eliminate, [currrev{:}]);
%                     else
%                         eliminate = cat(2, eliminate, j);
%                     end
%                     %I have to also unwrap curridx to check if any of its
%                     %elements is equals to currrev
%                 elseif (iscell(curridxx)&&length(curridxx)>length(currrev))
%                     arryofcurridx = curridxx;
%                     while (iscell(arryofcurridx)&&length(arryofcurridx)>length(currrev))
%                         arryofcurridx = [curridxx{:}];
%                         for mm = 1:length(arryofcurridx);
%                             if isequal(currrev,arryofcurridx(mm))
%                                 eliminate = cat(2, eliminate, j);
%                             end
%                         end
%                     end
% %                 elseif j==jlower&&currrev(1)<curridxx(end) %% I could not
% %                 make my error check work for cells of cells of cells of cells, since the count of label was different than the content. I will have to make due without it...
% %                     %dbgmsg('Out of bounds with current indexing scheme!',1)
% %                     error('Out of bounds with current indexing scheme!')
%                 end
%             end
%         end
%     end
%     whattoget = setdiff(allitems, eliminate);
%     icli = inp(:,whattoget);
%     if size(rev,2)<size(unique(eliminate),2)
%         disp('point removal is weird!, please debug')
%     end
%     dbgmsg('I removed', num2str(size(unique(eliminate),2)), ' out of ', num2str(size(inp,2)), ' points!',1)
% else
%     icli = inp;
% end
% 
% %ok, inputends is a problem!!!
% % ecli = inpe;
% % if ~isempty(rev)
% %     absolends = cumsum(inpe);
% %     for i =1:size(rev,2)
% %         
% %         if rev(i)<absolends(1)
% %             ecli(1) = ecli(1)-1;
% %         else
% %             for j =2:size(inpe,2)
% %                 if (absolends(j)>=rev(i))&&(rev(i)>absolends(j-1))
% %                     ecli(j) = ecli(j)-1;
% %                 end
% %             end
% %         end
% %     end
% % end
% % ycli = y(:,whattoget);

end