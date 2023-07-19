%% Regressor extractor.
%
%%  clear
clc; clear all;
%%  set the root directory
Root_dir = pwd;        % MATLAB Drive in Laptop
cd(Root_dir);
%%  Input Subjects
prompt = {'Subject ID'};
defaults = {'TM'};
answer = inputdlg(prompt, 'Discrimination Task',[1,30], defaults);
[Subj] = deal(answer{:}); % all input variables are strings
%%  set the directories
SubjDir = [Root_dir '/behav_data/' Subj];
DisTimingLog = [SubjDir '/behav_data_Dis_OnsetTime.mat'];
HdfTimingLog = [SubjDir '/behav_data_HT_OnsetTime.mat'];   % 'H'i'd'den Target 'f'req. Timing Log
DisBehaviorLog = [SubjDir '/behav_data_Dis.dat'];
RegDir = [Root_dir '/regression'];
if ~exist(RegDir,'dir')
    mkdir(RegDir);
end
SubjRegDir = [RegDir '/' Subj];
if ~exist(SubjRegDir,'dir')
    mkdir(SubjRegDir);
end
addpath(RegDir);
%RegFilePrefix = ['/Reg_' Subj];
%%  Execute subscripts  %%
%%  Discrimination Task
Run01 = 40;
Run02 = 30;
Run03 = 30;
delay_Run01=0;
delay_Run02=0;
delay_Run03=0;

%Reg1_vibration_vs_decision;
%Reg2_vibration_vs_coin;
%Reg3_FullModel;

onset_ISI1;
onset_ISI2;
duration_ISI1;
duration_ISI2;
onset_vibration;
onset_yellow;
onset_coin;
%%  Hidden Target Task (Frequency)
Run04 = 120;
Run05 = 120;
%%  Hidden Target Task (Score)
Run06 = 120;
Run07 = 120;
%%  Finish
fprintf('Extracting regressors are successful!\n');