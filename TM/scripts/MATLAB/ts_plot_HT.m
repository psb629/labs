%%
clear all; clc;
root_dir = pwd;
model_analysis_data = [root_dir '/Model/model1/Subjs.mat'];
load(model_analysis_data,'Subjs');
%%
GammaSet = 0:.2:4;
TempSet = .8:.2:4;
%%
prompt = {'Subject ID','Policy'};
defaults = {'TM',''};
answer = inputdlg(prompt, 'Plot the actions of HT',[1,30], defaults);
[Subj,Policy] = deal(answer{:}); % all input variables are strings
Subj = char(Subj); Policy = char(Policy);
%%
FieldArray_Subj = @(y) arrayfun(@(x) x.Subj,y,'UniformOutput',false);
FieldArray_Policy = @(y) arrayfun(@(x) x.Policy,y,'UniformOutput',false);
Parameter2Index = @(x,x1,dx) round((x-x1)/dx + 1);
%%
subj_num = find(contains(FieldArray_Subj(Subjs),Subj));
policy_num = find(contains(FieldArray_Policy(Subjs(subj_num).Policies),Policy));
%%
gamma = Subjs(subj_num).Policies(policy_num).GammaMax;
temp = Subjs(subj_num).Policies(policy_num).TempMax;
gamma_num = Parameter2Index(gamma,GammaSet(1),GammaSet(2)-GammaSet(1));
temp_num = Parameter2Index(temp,TempSet(1),TempSet(2)-TempSet(1));
%%
subj_behav_dir = [root_dir '/behav_data/' Subj];
load([subj_behav_dir '/' Subj '_model1.mat'],'Targets');
load([subj_behav_dir '/Profile.mat'],'Profile');
age=floor((str2double(datestr(now,'yyyymmdd')) - str2double(Profile{1,3}))/1.e4);
Subjinfo=insertBefore(Subj,"_PILOT","\");
sgt=[sprintf('%s / %s / %d',Subjinfo,char(Profile(4)),age)];
%%
for target_num = 1:2
    figure;
    sgtitle(sgt);
    target = Targets(target_num).Target;
    for trial = 1:15
        actAction = Targets(target_num).actual_actions(trial);
        action = Targets(target_num).Gammas(gamma_num).Trials(trial).Actions;
        if ~isstruct(action)
            continue;
        end
        prior(:,1) = Targets(target_num).Gammas(gamma_num).Priors(:,trial);
        QBA(:,1) = Targets(target_num).Gammas(gamma_num).QBAs(:,trial);
        gain(:,1) = Targets(target_num).Gammas(gamma_num).Gains(:,trial);
        switch Policy
            case 'Greedy'
                simAction = Targets(target_num).Gammas(gamma_num).Trials(trial).Actions.Greedy;
                Qw(:,1) = QBA/sum(QBA);
                Gw(:,1) = 0;
            case 'MIG'
                simAction = Targets(target_num).Gammas(gamma_num).Trials(trial).Actions.MIG;
                Qw(:,1) = QBA/sum(QBA);
                Gw(:,1) = gain/sum(gain);
            case 'SMF'
                simAction = Targets(target_num).Gammas(gamma_num).Trials(trial).Actions.temps(temp_num).SMF;
                maxQBA = max(QBA); Qw(:,1) = exp((QBA-maxQBA)./temp); Qw = Qw./sum(Qw);
                Gw(:,1) = 0;
            case 'SML'
                simAction = Targets(target_num).Gammas(gamma_num).Trials(trial).Actions.temps(temp_num).SML;
                maxQBA = max(QBA); Qw(:,1) = exp((QBA-maxQBA).*trial./temp); Qw = Qw./sum(Qw);
                Gw(:,1) = 0;
        end
        subplot(3,5,trial);
        plot([target,target],[-100,100],'-k');
        axis([0 180 0 .02]);
        xticks([0 30 60 90 120 150 180]);
        grid on;
        hold on;
        plot(0:.5:180,prior,'-','color',[0 0.4470 0.7410]);
        plot(0:.5:180,Qw,'-','color',[0.9290 0.6940 0.1250]);
        plot(0:.5:180,Gw,'-','color',[0.4940 0.1840 0.5560]);
        text(actAction,0,'\uparrow','Color','green','FontSize',15,'HorizontalAlignment','center');
        text(simAction,0,'\uparrow','Color','red','FontSize',15,'HorizontalAlignment','center');
        hold off;
    end
end