function perf = genRegressors(subjID,option)
%cd('/Users/sskim/Documents/MATLAB/GL/data');
cd('/Volumes/clmnlab/GL/behavior_data');
load(sprintf([subjID '-fmri']));
% dst_dir = fullfile('/Users/sskim/Documents/Research/AFNI/GL/data',subjID,'regressors');
dst_dir = fullfile('/Volumes/T7SSD1/GL/regressors');
if exist(dst_dir,'dir')==0 mkdir(dst_dir);end
nTrials = [12 145*ones(1,6)];
nS = 240; %% Number of sample of 1 trial for run 2~7
idx1 = find(fb==1);
idx0 = find(fb==0);
fbEndTrial = [idx1(find(diff(idx1)>1)) idx1(end)];
fb0EndTrial = [idx0(find(diff(idx0)>1)) idx0(end)];
fbStartTrial = [13 fb0EndTrial(1:end-1)+1];  %% exclude the first trial
fb0StartTrial = fbEndTrial+1;
LearnTrialStartTime = LearnTrialStartTime/1000;

allData = allData(:,12*nS*nTrials(1)-19:end);
cnt_hit = cnt_hit(nTrials(1)+1:end);
N = length(cnt_hit); 
for k=1:size(allData,2)-K
    temp = sum(allData(1:14,k+1:k+K)'.*weight)'/sumw-mData(1:14);
    filteredData(:,k) = temp/norm(temp);
end



targetID = targetID(13:end);
for i=1:length(targetID)
     pos = boxSize*convert_ID(targetID(i));
     xy = allXY(:,240*(i-1)+1:240*i);
     err = xy - repmat(pos,1,240);
%      cnt_hit_rep(i) = sum(abs(err(1,:))<=boxSize/2 & abs(err(2,:))<=boxSize/2);
     cnt_hit_all(i,:) = abs(err(1,:))<=boxSize/2 & abs(err(2,:))<=boxSize/2;
end

if sum(abs(sum(cnt_hit_all,2)'-cnt_hit))~=0 error('Something wrong'); else fprintf('Matched...\n');end
clear tpos XY;

for r=1:6
    for n=1:N/6          %% 145
        data_chunk_filtered(n,r,:,:) = filteredData(:,nS*N/6*(r-1)+nS*(n-1)+1:nS*N/6*(r-1)+nS*n);
        data_chunk(n,r,:,:) = allData(:,nS*N/6*(r-1)+nS*(n-1)+21:nS*N/6*(r-1)+nS*n+20);
        avcost(n,r,:) = sum(abs(diff(squeeze(data_chunk_filtered(n,r,:,:))')));
        v2cost(n,r,:) = sum((diff(squeeze(data_chunk_filtered(n,r,:,:))').^2));
        tpos(n,r,:) = convert_ID(targetID(N/6*(r-1)+n))*boxSize;
        XY(n,r,:,:) = allXY(:,nS*N/6*(r-1)+nS*(n-1)+1:nS*N/6*(r-1)+nS*n);
        errR(n,r,:) = sqrt(sum((squeeze(XY(n,r,:,:))-repmat(squeeze(tpos(n,r,:)),1,nS)).^2));
        for k=1:14 
            expl(n,r,k) = std(squeeze(data_chunk(n,r,k,:)));
            explTR(2*(n-1)+1,r,k) = std(squeeze(data_chunk(n,r,k,1:120)));
            explTR(2*n,r,k) = std(squeeze(data_chunk(n,r,k,121:nS)));
            idx = find(cnt_hit_all(N/6*(r-1)+n,:)==0);
            idx1 = find(cnt_hit_all(N/6*(r-1)+n,1:120)==0);
            idx2 = find(cnt_hit_all(N/6*(r-1)+n,121:240)==0);
            if length(idx) < 30  idx = find(cnt_hit_all(N/6*(r-1)+n,:)==1); end;
            if length(idx1) < 30  idx1 = find(cnt_hit_all(N/6*(r-1)+n,1:120)==1); end;
            if length(idx2) < 30  idx2 = find(cnt_hit_all(N/6*(r-1)+n,121:240)==1); end;
            expl2(n,r,k) = std(squeeze(data_chunk(n,r,k,idx)));
            explTR2(2*(n-1)+1,r,k) = std(squeeze(data_chunk(n,r,k,idx1)));
            explTR2(2*n,r,k) = std(squeeze(data_chunk(n,r,k,120+idx2)));
        end
    end
end
expl = reshape(expl,N,14)'; explTR = reshape(explTR,N*2,14)';
expl2 = reshape(expl2,N,14)'; explTR2 = reshape(explTR2,N*2,14)';
mexpl = mean(expl); mexplTR = mean(explTR);
mexpl2 = mean(expl2); mexplTR2 = mean(explTR2);
% mdata_chunk = reshape(squeeze(mean(data_chunk,4));
idx = setdiff([1:N],[1:145:N]);
for i=1:length(idx)/nS mrew(i) = mean(cnt_hit(idx(12*(i-1)+1:12*i)))/nS;end
fb = fb(13:end);
idx1 = setdiff(idx,find(fb==0));
idx0 = setdiff(idx,idx1);
for i=1:length(idx)/12 mrew(i) = mean(cnt_hit(idx(12*(i-1)+1:12*i)))/nS; end
for i=1:length(idx1)/12 mrew1(i) = mean(cnt_hit(idx1(12*(i-1)+1:12*i)))/nS; end
for i=1:length(idx0)/12 mrew0(i) = mean(cnt_hit(idx0(12*(i-1)+1:12*i)))/nS; end

perf.expl = expl;
perf.explTR = explTR;
perf.expl2 = expl2;
perf.explTR2 = explTR2;
perf.errR = errR;
perf.XY = XY;
perf.cnt_hit = cnt_hit;
perf.fb = fb;
perf.mrew = mrew;
perf.mrew0 = mrew0;
perf.mrew1 = mrew1;
perf.cnt_hit_all = cnt_hit_all;
perf.targetID = targetID;
perf.gdata = data_chunk;
perf.fgdata = data_chunk_filtered;
perf.avcost = avcost;
perf.v2cost = v2cost;
perf.U = U;
perf.S = S;




%% Making regressors for fMRI analysis
if strcmp(option,'ON')
%     
    for r=1:6
        fid = fopen(fullfile(dst_dir,sprintf([subjID '_onsettime_r0%d.txt'],r)),'w');
        for n=1:145
           fprintf(fid,'%4.2f ',LearnTrialStartTime(n+12+145*(r-1)));
        end
        fprintf(fid,'\n');
    end
    data_chunk_reshaped = reshape(data_chunk,N,14,240);
    cost_reshaped = reshape(avcost,N,14);
%     
%     for k=1:14
%         r = 1; r1 = 1; r2 = 1;
%         if k<10
%             fid = fopen(fullfile(dst_dir,sprintf([subjID '_Cg0%d.txt'],k)),'w');
%             fid1 = fopen(fullfile(dst_dir,sprintf([subjID '_Cg0%dFB.txt'],k)),'w');
%             fid2 = fopen(fullfile(dst_dir,sprintf([subjID '_Cg0%dnFB.txt'],k)),'w');
%         else
%             fid = fopen(fullfile(dst_dir,sprintf([subjID '_Cg%d.txt'],k)),'w');
%             fid1 = fopen(fullfile(dst_dir,sprintf([subjID '_Cg%dFB.txt'],k)),'w');
%             fid2 = fopen(fullfile(dst_dir,sprintf([subjID '_Cg%dnFB.txt'],k)),'w');
%         end            
%         for n=1:length(LearnTrialStartTime)-12
%                 fprintf(fid, '%4.1f*%4.2f ',LearnTrialStartTime(n+12)+2,cost_reshaped(n,k));  %% Beggining of current trial + 1 sec
%             if mod(n,N/6)==0 fprintf(fid,'\n'); end
%         end
%         
%         if k<10
%             fid3 = fopen(fullfile(dst_dir,sprintf([subjID '_Cg0%dr0%dFB.txt'],k,r1+1)),'w');
%             fid4 = fopen(fullfile(dst_dir,sprintf([subjID '_Cg0%dr0%dnFB.txt'],k,r1+1)),'w');
% 
%         else
%             fid3 = fopen(fullfile(dst_dir,sprintf([subjID '_Cg%dr0%dFB.txt'],k,r1+1)),'w');
%             fid4 = fopen(fullfile(dst_dir,sprintf([subjID '_Cg%dr0%dnFB.txt'],k,r1+1)),'w');
%         end                        
% 
%         for n=1:length(idx1)        
%                 fprintf(fid1, '%4.1f*%4.2f ',LearnTrialStartTime(idx1(n)+12)+2,cost_reshaped(idx1(n),k));  %% Beggining of current trial + 1 sec
%                 fprintf(fid3, '%4.1f*%4.2f ',LearnTrialStartTime(idx1(n)+12)+2,cost_reshaped(idx1(n),k));  %% Beggining of current trial + 1 sec
%                 if ismember(n,[72:72:72*4 72*6 length(idx1)]) 
%                     fprintf(fid1,'\n'); 
%                     fprintf(fid3,'\n');
%                     r1 = r1+1; 
%                     if k<10
%                         fid3 = fopen(fullfile(dst_dir,sprintf([subjID '_Cg0%dr0%dFB.txt'],k,r1+1)),'w');
%                     else
%                         fid3 = fopen(fullfile(dst_dir,sprintf([subjID '_Cg%dr0%dFB.txt'],k,r1+1)),'w');
%                     end                        
%                 end
%         end
%         for n=1:length(idx0)        
%                 fprintf(fid2, '%4.1f*%4.2f ',LearnTrialStartTime(idx0(n)+12)+2,cost_reshaped(idx0(n),k));  %% Beggining of current trial + 1 sec
%                 fprintf(fid4, '%4.1f*%4.2f ',LearnTrialStartTime(idx0(n)+12)+2,cost_reshaped(idx0(n),k));  %% Beggining of current trial + 1 sec
%                 if ismember(n,[72:72:72*4]) 
%                     fprintf(fid2,'\n'); 
%                     fprintf(fid4,'\n');
%                     r2 = r2+1; 
%                     if k<10
%                         fid4 = fopen(fullfile(dst_dir,sprintf([subjID '_Cg0%dr0%dnFB.txt'],k,r2+1)),'w');
%                     else
%                         fid4 = fopen(fullfile(dst_dir,sprintf([subjID '_Cg%dr0%dnFB.txt'],k,r2+1)),'w');
%                     end
%                 end
%         end        
%     end
% 
%     for k=1:14
%         for r=1:6
%             if k<10
%                 fid = fopen(fullfile(dst_dir,sprintf([subjID '_Cg0%dr0%d.txt'],k,r+1)),'w');
%             else
%                 fid = fopen(fullfile(dst_dir,sprintf([subjID '_Cg%dr0%d.txt'],k,r+1)),'w');
%             end
%             for n=1:(length(LearnTrialStartTime)-12)/6
%                     fprintf(fid, '%4.1f*%4.2f ',LearnTrialStartTime(145*(r-1)+n+12)+2,cost_reshaped(n,k));  %% Beggining of current trial + 1 sec
%             end
%             fprintf(fid,'\n');
%         end
%     end
%     
%     
%     fid1 = fopen(fullfile(dst_dir,[subjID '_Move.txt']),'w');
%     fid2 = fopen(fullfile(dst_dir,[subjID '_Stop.txt']),'w');
%     for n=1:12 %% 12, run01
%             if n~=12
%                 if mod(n,2)==1
%                     fprintf(fid1, '%4.1f:%4.2f ',LearnTrialStartTime(n),...
%                     LearnTrialStartTime(n+1)-LearnTrialStartTime(n)-2);  %% +4 for the end of current trial      
%                 else
%                     fprintf(fid2, '%4.1f:%4.2f ',LearnTrialStartTime(n),...
%                     LearnTrialStartTime(n+1)-LearnTrialStartTime(n)-2);  %% +4 for the end of current trial
%                 end
%             else    
%                 fprintf(fid2, '%4.1f:%4.2f ',LearnTrialStartTime(n),48);  %% +4 for the end of current trial
%                 fprintf(fid1,'\n');
%                 fprintf(fid2,'\n');
% 
%             end            
%     end
% 
%     fid = fopen(fullfile(dst_dir,[subjID '_Expl.txt']),'w');
%     for n=1:length(LearnTrialStartTime)-12
%             fprintf(fid, '%4.1f*%4.2f ',LearnTrialStartTime(n+12),mexpl(n));  %% Beggining of current trial
%         if mod(n,N/6)==0 fprintf(fid,'\n'); end
%     end
% % 
%     fid = fopen(fullfile(dst_dir,[subjID '_Expl2.txt']),'w');
%     for n=1:length(LearnTrialStartTime)-12
%             fprintf(fid, '%4.1f*%4.2f ',LearnTrialStartTime(n+12),mexpl2(n));  %% Beggining of current trial
%         if mod(n,N/6)==0 fprintf(fid,'\n'); end
%     end
%     
%     fid = fopen(fullfile(dst_dir,[subjID '_ExplTR.txt']),'w');
%     for n=1:length(LearnTrialStartTime)-12
%             fprintf(fid, '%4.1f*%4.2f ',LearnTrialStartTime(n+12),mexplTR(2*(n-1)+1));  %% Beggining of current trial
%             fprintf(fid, '%4.1f*%4.2f ',LearnTrialStartTime(n+12),mexplTR(2*n));  %% Beggining of current trial
%         if mod(n,N/6)==0 fprintf(fid,'\n'); end
%     end
%     
%     fid = fopen(fullfile(dst_dir,[subjID '_ExplTR2.txt']),'w');
%     for n=1:length(LearnTrialStartTime)-12
%             fprintf(fid, '%4.1f*%4.2f ',LearnTrialStartTime(n+12),mexplTR2(2*(n-1)+1));  %% Beggining of current trial
%             fprintf(fid, '%4.1f*%4.2f ',LearnTrialStartTime(n+12),mexplTR2(2*n));  %% Beggining of current trial
%         if mod(n,N/6)==0 fprintf(fid,'\n'); end
%     end
% 
% 

%     fid = fopen(fullfile(dst_dir,[subjID '_Rew.txt']),'w');
%     for n=1:length(LearnTrialStartTime)-12
%             fprintf(fid, '%4.1f*%4.2f ',LearnTrialStartTime(n+12)+4,cnt_hit(n)/nS);  %% +4 for the end of current trial
%         if mod(n,N/6)==0 fprintf(fid,'\n'); end
%     end
% % 
    fid = fopen(fullfile(dst_dir,[subjID '_FB.txt']),'w');
    for n=1:24
        fprintf(fid,'%4.1f:%4.1f ',LearnTrialStartTime(fbStartTrial(n)),...
            LearnTrialStartTime(fb0StartTrial(n))-LearnTrialStartTime(fbStartTrial(n)));
        if mod(n,6)==0 fprintf(fid,'\n'); end
    end

    fid = fopen(fullfile(dst_dir,[subjID '_nFB.txt']),'w');
    for n=1:24
        fprintf(fid,'%4.1f:%4.1f ',LearnTrialStartTime(fb0StartTrial(n)),48)
        if mod(n,6)==0 fprintf(fid,'\n'); end
   end

    idx1_org = find(fb==1);    idx0 = find(fb==0);
    idx2 = [594:605 618:629 642:653 666:677 690:701 714:725 739:750 763:774 787:798 811:822 835:846 859:870]; %% FB with new sequence from r05, r06
    idx1 = find(fb(1:580)==1);
    idx1_1 = idx1(1:length(idx0)+4); %% FB from r01~r04
    
    idx1_2 = setdiff(idx1_org,idx1_1);  %% FB from r05, r06
    
    fid = fopen(fullfile(dst_dir,sprintf([subjID '_RewFB.txt'],r+1)),'w');
    fid2 = fopen(fullfile(dst_dir,sprintf([subjID '_RewnFB.txt'],r+1)),'w');

    for r=1:4
        L = length(idx1_1)/4;
        for n=1:L
            fprintf(fid, '%4.1f*%4.2f ',LearnTrialStartTime(idx1_1(n+(r-1)*L)+12)+4,cnt_hit(idx1_1(n+(r-1)*L))/nS);  %% +4 for the end of current trial
        end
        fprintf(fid,'\n');
        L = length(idx0)/4;
        for n=1:L
            fprintf(fid2, '%4.1f*%4.2f ',LearnTrialStartTime(idx0(n+(r-1)*L)+12)+4,cnt_hit(idx0(n+(r-1)*L))/nS);  %% +4 for the end of current trial
        end    
        fprintf(fid2,'\n');
    end
    
%     for r=1:4
%         fid = fopen(fullfile(dst_dir,sprintf([subjID '_r0%dRewFB.txt'],r+1)),'w');
%         L = length(idx1_1)/4;
%         for n=1:L
%             fprintf(fid, '%4.1f*%4.2f ',LearnTrialStartTime(idx1_1(n+(r-1)*L)+12)+4,cnt_hit(idx1_1(n+(r-1)*L))/nS);  %% +4 for the end of current trial
%         end
%         fid = fopen(fullfile(dst_dir,sprintf([subjID '_r0%dRewnFB.txt'],r+1)),'w');
%         L = length(idx0)/4;
%         for n=1:L
%             fprintf(fid, '%4.1f*%4.2f ',LearnTrialStartTime(idx0(n+(r-1)*L)+12)+4,cnt_hit(idx0(n+(r-1)*L))/nS);  %% +4 for the end of current trial
%         end      
%     end
%     
%     for r=1:2
%         fid = fopen(fullfile(dst_dir,sprintf([subjID '_r0%dRewFB.txt'],r+5)),'w');
%         L = length(idx1_2)/2;
%         for n=1:L
%             fprintf(fid, '%4.1f*%4.2f ',LearnTrialStartTime(idx1_2(n+(r-1)*L)+12)+4,cnt_hit(idx1_2(n+(r-1)*L))/nS);  %% +4 for the end of current trial
%         end
%         fid = fopen(fullfile(dst_dir,sprintf([subjID '_r0%dRewFBNew.txt'],r+5)),'w');
%         L = length(idx2)/2;
%         for n=1:L
%             fprintf(fid, '%4.1f*%4.2f ',LearnTrialStartTime(idx2(n+(r-1)*L)+12)+4,cnt_hit(idx2(n+(r-1)*L))/nS);  %% +4 for the end of current trial
%         end      
%     end

end