function [rew_bin] = calc_rew_reg(subjID,W,option)
% W: timebin size
%% For the second fMRi session
behav_dir = pwd;
dst_dir = fullfile(behav_dir);
cd(dst_dir);
nS = 300; %% Number of sample(=frame) of 1 trial for run 2~7
nR = 7;
cd(dst_dir);
if exist(sprintf([subjID '-refmri.mat']))
    load(sprintf([subjID '-refmri']));
else
    return;
end
% if subjID == 'GA29' targetID = targetID(1:582); nR = 6; end
startTime = LearnTrialStartTime(1:97:end);

for i=1:length(targetID)
    pos = boxSize*convert_ID(targetID(i));
    xy = allXY(:,nS*(i-1)+1:nS*i);
    err = xy - repmat(pos,1,nS);
    cnt_hit_all(i,:) = abs(err(1,:))<=boxSize/2 & abs(err(2,:))<=boxSize/2;
end

if sum(abs(sum(cnt_hit_all,2)'-cnt_hit))~=0 error('Something wrong'); else fprintf('Matched...\n');end
clear tpos XY;
nbin = W*60; %% number of frame per a second. aka, the 'bin' means a frame.
for r=1:nR
    tem = reshape(cnt_hit_all(97*(r-1)+1:97*r,:)',300*97,1);
    for i=1:300*97/nbin
        rew_bin(r,i) = sum(tem(nbin*(i-1)+1:nbin*i));
    end
end
% subjID(2) = 'C';
%% Making regressors for fMRI analysis
dst_dir = fullfile(behav_dir,'regressors',subjID);
if ~exist(dst_dir,'dir')
    mkdir(dst_dir);
end
if strcmp(option,'ON')
    for r=1:nR
        fidr = fopen(fullfile(dst_dir,sprintf([subjID '.r0%drew%d.GAM.1D'],r,1000*W)),'w');
        % for q=1:7
        % if q==r
        for k=1:length(rew_bin)
            % fprintf(fidr2, '%4.2f*%2.3f:0.46 ',startTime(r)/1000+(k-1)*W,rew_bin(r,k));
            fprintf(fidr, '%4.2f*%2.3f ',startTime(r)/1000+(k-1)*W+0.5,rew_bin(r,k)/(60*W));
            if k==length(rew_bin)
                fprintf(fidr,'\n');
            end
        end
    end
elseif strcmp(option,'OFF')
    for r=1:nR
        fidr = fopen(fullfile(dst_dir,sprintf([subjID '.r0%drew%d.GAM.1D'],r,1000*W)),'w');
        for k=1:length(rew_bin)
            % fprintf(fidr2, '%4.2f*%2.3f:%1.1f ',startTime(r)/1000+(k-1)*W+W/2,rew_bin(r,k),W);
            fprintf(fidr, '%4.2f*%1.3f ',startTime(r)/1000+(k-1)*W+0.5,rew_bin(r,k)/(60*W));
            if k==length(rew_bin)
                fprintf(fidr,'\n');
            end
        end
    end
end
fclose(fidr);