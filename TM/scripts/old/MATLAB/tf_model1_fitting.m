function tf_model1_fitting(Subj,GammaSubSet)
% tf_model1_fitting(Subj,GammaSubSet)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% output
% prior: Target -> Gamma -> nStates x nTrials
% QBA: Target -> Gamma -> nStates x nTrials
% Gain: Target -> Gamma -> nStates x nTrials
% simAction: Target -> Gamma -> nTrials x policies(softmaxFixed, ..., MIG)
% logLK: Target -> Gamma x Properties in each policy
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Root directory
global TM_dir nCells nTrials_HT
root_dir = [TM_dir '/scripts/MATLAB/Model/model1'];  % MATLAB in Labtap
addpath(root_dir);
%%  Parameters
TargetSet = 1:nCells;
GammaSet = 0:.2:4;
TempSet = .8:.2:4;

ThetaBias = 0;

Subj_dir = [TM_dir '/behav_data/' Subj];
Subj_data = [Subj_dir '/behav_data_HT.dat'];
FreqType = Subj(3);
%% Internal Function(Macro)
global Parameter2Index
Parameter2Index = @(x,x1,dx) round((x-x1)/dx + 1);      %% 0.0 : 0.2 : 4.0
%FieldArrayOfStr = @(y) arrayfun(@(x) x.Sum5,y);
%% Defining Variables
[Targets] = DefineOutputVars(TargetSet,GammaSet,TempSet,nTrials_HT);
%%  Model 1
%% Run the model
for target_num = TargetSet
    target_num
    [Targets(target_num).Target,Targets(target_num).actual_actions,Targets(target_num).actual_rewards]...
        = LoadBehavData(Subj_data,target_num);
   for Gamma = GammaSubSet
       Gidx = Parameter2Index(Gamma,GammaSet(1),GammaSet(2)-GammaSet(1));
       [Targets(target_num).Gammas(Gidx).Priors,Targets(target_num).Gammas(Gidx).QBAs,Targets(target_num).Gammas(Gidx).Gains,Targets(target_num).Gammas(Gidx).Trials]...
           =model1(FreqType,Targets(target_num).Target,ThetaBias,Gamma,TempSet,Targets(target_num).actual_actions);
   end
end
save([Subj_dir '/' Subj '_model1.mat'],'Targets');
%%	Calcuating Log likelihood from each policy
for target_num = TargetSet
    for Gamma = GammaSubSet
        Gidx = Parameter2Index(Gamma,GammaSet(1),GammaSet(2)-GammaSet(1));
        logLks = zeros(nTrials_HT,(2+2*length(TempSet)));   %%% logLks = nTrials x policies(GRD,MIG,SMFs,SMLs)
        for a = 1:nTrials_HT
            act_act = Targets(target_num).actual_actions(a);
            if isnan(act_act)
                Targets(target_num).Gammas(Gidx).Trials(a).Actions = nan;
                Targets(target_num).Gammas(Gidx).Trials(a).logLks = nan;
            else
                for temp = TempSet
                    Tidx = Parameter2Index(temp,TempSet(1),TempSet(2)-TempSet(1));
                    Targets(target_num).Gammas(Gidx).Trials(a).logLks(1).temps(Tidx).temp = temp;
                    Targets(target_num).Gammas(Gidx).Trials(a).logLks(1).temps(Tidx).SMF = Calc_loglk_smf(act_act,Targets(target_num).Gammas(Gidx).QBAs(:,a),temp);
                    Targets(target_num).Gammas(Gidx).Trials(a).logLks(1).temps(Tidx).SML = Calc_loglk_sml(act_act,Targets(target_num).Gammas(Gidx).QBAs(:,a),temp,a);
                    logLks(a,2+Tidx) = Targets(target_num).Gammas(Gidx).Trials(a).logLks(1).temps(Tidx).SMF;
                    logLks(a,2+length(TempSet)+Tidx) = Targets(target_num).Gammas(Gidx).Trials(a).logLks(1).temps(Tidx).SML;
                end
                Targets(target_num).Gammas(Gidx).Trials(a).logLks(1).Greedy = Calc_loglk_grd(act_act,Targets(target_num).Gammas(Gidx).QBAs(:,a));
                Targets(target_num).Gammas(Gidx).Trials(a).logLks(1).MIG = Calc_loglk_mig(act_act,Targets(target_num).Gammas(Gidx).Gains(:,a));
                logLks(a,1) = Targets(target_num).Gammas(Gidx).Trials(a).logLks(1).Greedy;
                logLks(a,2) = Targets(target_num).Gammas(Gidx).Trials(a).logLks(1).MIG;
                %logLK(target_num).Target(sim).Sim(Gidx).Sum5 = sum(loammas(Gidx).Trials(a).logLks(1).MIG;
                %logLK(target_num).Target(sim).Sim(Gidx).SumOmitInf = gGg(find(~isnan(logGg),5)));
            end
        end
        Targets(target_num).Gammas(Gidx).sum_logLks(1).Greedy = sum(logLks(:,1),'omitnan');
        Targets(target_num).Gammas(Gidx).sum_logLks(1).MIG = sum(logLks(:,2),'omitnan');
        for temp = TempSet
            Tidx = Parameter2Index(temp,TempSet(1),TempSet(2)-TempSet(1));
            Targets(target_num).Gammas(Gidx).sum_logLks(1).temps(Tidx).SMF = sum(logLks(:,2+Tidx),'omitnan');
            Targets(target_num).Gammas(Gidx).sum_logLks(1).temps(Tidx).SML = sum(logLks(:,2+length(TempSet)+Tidx),'omitnan');
        end
    end
end
%% Aftertreatment
save([Subj_dir '/' Subj '_model1.mat'],'Targets');
end
%% Internal Function
function [Targets] = DefineOutputVars(TargetSet,GammaSet,TempSet,nTrials)
global Parameter2Index
Targets = struct([]);
for a = TargetSet
    Targets(a).Target = NaN;
    Targets(a).actual_actions = NaN;
    Targets(a).actual_rewards = NaN;
    for gamma = GammaSet
        b = Parameter2Index(gamma,GammaSet(1),GammaSet(2)-GammaSet(1));
        Targets(a).Gammas(b).Gamma = gamma;
        Targets(a).Gammas(b).Priors = NaN;
        Targets(a).Gammas(b).QBAs = NaN;
        Targets(a).Gammas(b).Gains = NaN;
        for c = 1:nTrials
            Targets(a).Gammas(b).Trials(c).Trial = c;
            for temp = TempSet
                d = Parameter2Index(temp,TempSet(1),TempSet(2)-TempSet(1));
                Targets(a).Gammas(b).Trials(c).Actions(1).temps(d).temp = temp;
                Targets(a).Gammas(b).Trials(c).Actions(1).temps(d).SMF = nan;
                Targets(a).Gammas(b).Trials(c).Actions(1).temps(d).SML = nan;
                Targets(a).Gammas(b).Trials(c).logLks(1).temps(d).temps = temp;
                Targets(a).Gammas(b).Trials(c).logLks(1).temps(d).SMF = nan;
                Targets(a).Gammas(b).Trials(c).logLks(1).temps(d).SML = nan;
            end
            Targets(a).Gammas(b).Trials(c).Actions(1).Greedy = nan;
            Targets(a).Gammas(b).Trials(c).Actions(1).MIG = nan;
            Targets(a).Gammas(b).Trials(c).logLks(1).Greedy = nan;
            Targets(a).Gammas(b).Trials(c).logLks(1).MIG = nan;
        end
        for temp = TempSet
            d = Parameter2Index(temp,TempSet(1),TempSet(2)-TempSet(1));
            Targets(a).Gammas(b).sum_logLks(1).temps(d).temp = temp;
            Targets(a).Gammas(b).sum_logLks(1).temps(d).SMF = nan;
            Targets(a).Gammas(b).sum_logLks(1).temps(d).SML = nan;
        end
        Targets(a).Gammas(b).sum_logLks(1).Greedy = nan;
        Targets(a).Gammas(b).sum_logLks(1).MIG = nan;
    end
end
end
function [target,actual_actions,actual_rewards] = LoadBehavData(Subj_data,target_num)
Table_data = readtable(Subj_data,'Format','%f%d%f%f%f%d%f');
var1='Block';
var2='Trial';
var3='Estimation';
var4='Decision_Time';
var5='ErrorAngle';
var6='ISI';
var7='Reward';
Table_data.Properties.VariableNames={var1,var2,var3,var4,var5,var6,var7};

target_data_range = ((target_num-1)*15+1):((target_num-1)*15+15);
target = Table_data{target_data_range,'Block'}(1);
actual_rewards = Table_data{target_data_range,'Reward'};
actual_actions = Table_data{target_data_range,'Estimation'};
end
function [loglk_smf] = Calc_loglk_smf(act_act,QBa,temp)
QBa_max = max(QBa);
w(:,1) = exp((QBa-QBa_max)./temp);
w = w./sum(w);
idx = round(act_act*2) + 1;
loglk_smf = log(w(idx));
end
function [loglk_sml] = Calc_loglk_sml(act_act,QBa,temp,trial)
QBa_max = max(QBa);
w(:,1) = exp((QBa-QBa_max).*trial./temp);
w = w./sum(w);
idx = round(act_act*2) + 1;
loglk_sml = log(w(idx));
end
function [loglk_grd] = Calc_loglk_grd(act_act,QBa)
w(:,1) = QBa - min(QBa);
w = w./sum(w);
idx = round(act_act*2) + 1;
loglk_grd = log(w(idx));
end
function [loglk_mig] = Calc_loglk_mig(act_act,Gain)
w(:,1) = Gain - min(Gain);
w = w./sum(w);
idx = round(act_act*2) + 1;
loglk_mig = log(w(idx));
end