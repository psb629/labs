% clear all; clc;
GA_behav_dir = '~/Desktop/GA/behavior_data/';
%%
% subj_list = {'GD01','GD02','GD07','GD11','GD20','GD23','GD29','GD30','GD31','GD32','GD33','GD44'};
subj_list = {'GA01','GA02','GA05','GA07','GA08',...
    'GA11','GA12','GA13','GA14','GA15',...
    'GA18','GA19','GA20','GA21','GA23',...
    'GA26','GA27','GA28','GA29','GA30',...
    'GA31','GA32','GA33','GA34','GA35',...
    'GA36','GA37','GA38','GA42','GA44'};
subj_list = {'GA01'}; %GA
row = 0;
for subj = subj_list
    row = row + 1;
    %% load datum
%     fname = [char(subj) '-refmri.mat'];
    fname = [GA_behav_dir char(subj) '/' char(subj) '-fmri.mat']; %GA
%     fname = [GA_behav_dir char(subj) '/' char(subj) '-1-behav.mat']; %GA
%     fname = [GA_behav_dir char(subj) '/' char(subj) '-2-behav.mat']; %GA
%     fname = [GA_behav_dir char(subj) '/' char(subj) '-3-behav.mat']; %GA
%     fname = [GA_behav_dir char(subj) '/' char(subj) '-4-behav.mat']; %GA
%     fname = [GA_behav_dir char(subj) '/' char(subj) '-5-behav.mat']; %GA
%     fname = [GA_behav_dir char(subj) '/' char(subj) '-refmri.mat']; %GA
    load(fname);
    targetID = targetID(9:end); %-fmri
    %% XYs
    s = struct([]);
    XY = struct([]);
    s(1).run = [1:300*97];
    s(1).trial = [1:300];
    for run = 1:3
        for trial = 1:97
            temp = allXY(:,length(s.run)*(run-1)+s.run);
            XY(run).run(trial).trial = temp(:,length(s.trial)*(trial-1)+s.trial);
            id = targetID((run-1)*97+trial);
            XY(run).run(trial).targetID = id;
            XY(run).run(trial).targetPos = convert_ID(id)*boxSize;
        end
    end
    %% plot #1
    % run = 3;
    % hold on
    % frame = [-300 300]; %[-240 240];
    % xlim(frame);
    % ylim(frame);
    % xticks(boxSize*([-6:5]+0.5));
    % yticks(boxSize*([-6:5]+0.5));
    % for trial = 2:3
    %     temp = XY(run).run(trial).trial;
    %     plot(temp(1,:),temp(2,:));
    % end
    % grid on
    %% Aspect Ratio
    set_run = 1:3;
    set_trial = 2:97;
    AR = nan(length(set_run),length(set_trial));
    count = 0;
    for run = set_run
        count = count + 1;
        for trial = set_trial
            path = trial - 1;
            Origin = XY(run).run(trial-1).targetPos;
            vec_T2T = XY(run).run(trial).targetPos - Origin;
            vec_P = XY(run).run(trial).trial - Origin;
            temp = vec_T2T(1)*vec_P(2,:) - vec_T2T(2)*vec_P(1,:);
%             ratio(path,:) = abs(temp)/(vec_T2T'*vec_T2T);
            AR(count,path) = max( abs(temp)/(vec_T2T'*vec_T2T) );
        end
    end
    temp = nan(1,length(set_run)*length(set_trial));
    temp(:) = AR(:,:)';
    aspect_ratio(row,:) = temp;
end
block = 1:12;
temp = zeros(24,1);
%clearvars -except aspect_ratio
for i = 1:24
    %disp(block+12*(i-1));
    temp(i) = mean(aspect_ratio(block+12*(i-1)),2);
end
%temp = aspect_ratio;
%% plot #2
% plot([1:96*3],temp);
% xticks(96*[0:3]);
% xlim(24*[0,12]);
plot([1:24],temp);
xticks([0:24]);
xlim(24*[0,1]);
%xticks(24*[0:12]);
ylim([0,1.4]);