%%
clear all; clc;
%% GA
subj_list_GA = ['GA01';'GA02';'GA05';'GA07';'GA08';'GA11';'GA12';'GA13';'GA14';'GA15';'GA18';
  'GA19';'GA20';'GA21';'GA23';'GA26';'GA27';'GA28';'GA29';'GA30';'GA31';'GA32';'GA33';'GA34';'GA35';
  'GA36';'GA37';'GA38';'GA42';'GA44'];
load('./mrew_errR_30_run4to6_20190626.mat');
data_unprac = mrew_run4to6;
load('./mrew_errR_30_run1to3_20190626.mat');
for i=1:size(subj_list_GA,1)
  data_prac(i,:) = eval(sprintf([subj_list_GA(i,:) '_mrew_all']));
end
%% GD
subj_list_GD = [
    "GD07","GD11","GD30","GD02","GD29",...
    "GD32","GD23","GD01","GD31","GD33",...
    "GD20","GD44"];
trials = 1:12;
blocks = 1:8;
runs = 1:7;

nsubj = size(subj_list_GD,2);
ntrial = size(trials,2);
nblock = size(blocks,2);
nrun = size(runs,2);
max_score = 60*5*ntrial; %% 60Hz*5s*12trials = frames

rew = zeros(nsubj,nblock*nrun);
cnt = 0;
for subj = subj_list_GD
    cnt = cnt+1;
    temp = calc_rew_reg(char(subj),1,'OFF');
    rew_bin = temp(:,6:end)';   % cut the 1st 5s off. then, transpose it
    temp = rew_bin(:)';     % reshape it to 1D array
    for b = 1:(nblock*nrun)
        rew(cnt,b) = sum(temp(5*ntrial*(b-1)+1:5*ntrial*b))/max_score;
    end
end
%% plot
figure; hold on;
xt = 24*(0:8);
plot([xt;xt],[0;1],'k');
ylabel('success rate');
names = {'fMRI1','behav1','behav2','behav3','behav4','behav5','fMRI2','fMRI3'};
set(gca,'xtick',xt+12,'xticklabel',names)
plot(mean(data_prac));
plot([1:24 24*6+1:24*7],mean(data_unprac),'g');
temp = mean(rew,1);
plot(24*7+(1:24),temp(1:24),'b');
plot(24*7+(1:24),temp(24+(1:24)),'r');