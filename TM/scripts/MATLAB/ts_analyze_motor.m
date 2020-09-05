%%  clear
clc; clear all;
%%  prompt information
prompt = {'Subject ID'};
defaults = {'TM'};
answer = inputdlg(prompt, 'Discrimination Task',[1,30], defaults);
[Subj] = deal(answer{:}); % all input variables are strings
%%  classify test type.
SubjDir = ['./behav_data/' Subj];
behav_data = [SubjDir '/behav_data_Motor.dat'];
load([SubjDir '/Profile.mat']);
age=floor((str2double(datestr(now,'yyyymmdd')) - str2double(Profile{1,3}))/1.e4);
Subjinfo=insertBefore(Subj,"_PILOT","\");
sgt=[Subjinfo sprintf(' / %s / %d',char(Profile(4)),age)];
%%  load data file
Table_data = readtable(behav_data,'Format','%f%d%f%f%f%d');
var1='Target';
var2='Trial';
var3='Estimation';
var4='Decision Time';
var5='ErrorAngle';
var6='ITI';
Table_data.Properties.VariableNames={var1,var2,var3,var4,var5,var6};
clear var1 var2 var3 var4 var5 var6
%%  make a table for a motor distribution
theta_min = min(Table_data{:,'Target'});
theta_max = max(Table_data{:,'Target'});
nTargets = (theta_max-theta_min)/(2*theta_min) + 1;
nTrials = height(Table_data) / nTargets;
theta_count = zeros(1,nTargets);
motor_distribuion = zeros(nTrials,nTargets);
motor_gaussian = zeros(3,nTargets);
for iter = 1 : (nTargets*nTrials)
    column = (Table_data{iter,'Target'}-theta_min) / (2*theta_min) + 1;
    theta_count(column) = theta_count(column) + 1;
    row = theta_count(column);
    motor_distribuion(row,column)=Table_data{iter,'Estimation'};  
end
delta_theta = (theta_max - theta_min) / (nTargets-1);
for iter = 1 : nTargets
    nn(iter) = sum(~isnan(motor_distribuion(:,iter)));   % number of none-NaN valuse
    motor_gaussian(1,iter) = theta_min + delta_theta*(iter-1);
    motor_gaussian(2,iter) = mean(motor_distribuion(:,iter),'omitnan');        % 'omitnan' : ignore NaN values
    motor_gaussian(3,iter) = std(motor_distribuion(:,iter),'omitnan');
end
%%  plot #1
nrow=4;
ncol=nTargets/nrow;
figure;
sig_m = mean(motor_gaussian(3,:));
mu_m = mean(abs(motor_gaussian(2,:)-motor_gaussian(1,:)));
sgt = [sgt ' / <\sigma>=' sprintf('%.3f',sig_m) ' / <\Delta\mu>=' sprintf('%.3f',mu_m)];
sgtitle(sgt);
for iter = 1 : nTargets
    X=linspace(0,180);
    Y=gaussian(X,motor_gaussian(2,iter),motor_gaussian(3,iter));
    hold on;
    subplot(nrow,ncol,iter);
    plot(X,Y,'black-',[motor_gaussian(1,iter) motor_gaussian(1,iter)],[0 1],'red--');
    title(['n=' sprintf('%d',nn(iter)) ', \sigma=' sprintf('%.3f',motor_gaussian(3,iter)) ', \Delta\mu=' sprintf('%.3f',abs(motor_gaussian(2,iter)-motor_gaussian(1,iter)))]);
    xticks([0 30 60 90 120 150 180]);
    %xticks(motor_gaussian(1,iter)); xticklabels(sprintf('%.3f',motor_gaussian(1,iter)));
    axis([0 180 0 max(Y)]);
    grid on;
    hold off;
end