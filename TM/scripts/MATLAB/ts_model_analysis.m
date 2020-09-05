%% Subjects Set
SubjSet = ["TML04_PILOT","TML05_PILOT","TML06_PILOT","TML07_PILOT","TML09_PILOT","TML10_PILOT","TML11_PILOT",...
    "TML12_PILOT","TML13","TML14","TML15","TML16","TML18","TML19","TML20",...
    "TML21","TML22","TML23","TML24","TML25","TML26","TML28","TML29"];
GammaSet = .2:.2:4.;
tempSet = .8:.2:4.;
%% Global Variables
TM_Set_HT;
global Ns
%% Internal Function(Macro)
Parameter2Index = @(x,x1,dx) round((x-x1)/dx + 1);
FieldArrayOfStr = @(s,field) arrayfun(@(x) x.field,s);
fct_AIC = @(k,logL) 2*k - 2*logL;
fct_BIC = @(k,n,logL) log(n)*k - 2*logL;
%%  Plotting
Subjs = struct([]);
X=0:0.5:180; count = 0;
result_file = './Model/model1/Subjs.mat';
result_file = askFILE(result_file);
for Subj = SubjSet
    Subj = char(Subj)
    count = count + 1;
    Subjs(count).Subj = Subj;
    Subjs(count).Policies(1).Policy = 'Greedy';
    Subjs(count).Policies(2).Policy = 'MIG';
    Subjs(count).Policies(3).Policy = 'SMF';
    Subjs(count).Policies(4).Policy = 'SML';
    Subj_data = ['./behav_data/' Subj '/' Subj '_model1.mat'];
    %Subjinfo=insertBefore(Subj,"_PILOT","\");
    load(Subj_data);
    count_noneNaN = 0;
    pm_logL = 0; 
    sum_max = -1.e4 * ones(4,1);
    gamma_max = nan(4,1);
    temp_max = nan(4,1);
    for Gamma = GammaSet
        Gidx_dummy = Parameter2Index(Gamma,GammaSet(1),GammaSet(2)-GammaSet(1));
        sum_dummy = zeros(4,1);
        for target_num = 1:Ns.cell
            sum_dummy(1) = Targets(target_num).Gammas(Gidx_dummy).sum_logLks.Greedy;
            sum_dummy(2) = Targets(target_num).Gammas(Gidx_dummy).sum_logLks.MIG;
            for policy = 1:2
                if sum_dummy(policy) > sum_max(policy)
                    sum_max(policy) = sum_dummy(policy);
                    gamma_max(policy) = Gamma;
                end
            end
            for temp = tempSet
                tidx_dummy = Parameter2Index(temp,tempSet(1),tempSet(2)-tempSet(1));
                sum_dummy(3) = Targets(target_num).Gammas(Gidx_dummy).sum_logLks.temps(tidx_dummy).SMF;
                sum_dummy(4) = Targets(target_num).Gammas(Gidx_dummy).sum_logLks.temps(tidx_dummy).SML;
                for policy = 3:4
                    if sum_dummy(policy) > sum_max(policy)
                        sum_max(policy) = sum_dummy(policy);
                        gamma_max(policy) = Gamma;
                        temp_max(policy) = temp;
                    end
                end
            end
        end
    end
    nn(count) = 0;
    for target_num = 1:Ns.cell
        for trial = 1:Ns.trial
            nn(count) = nn(count) + ~isnan(Targets(target_num).actual_actions(trial));
        end
    end
    Subjs(count).ndata = nn(count);
    for policy = 1:4
        Subjs(count).Policies(policy).SumMax = sum_max(policy);
        Subjs(count).Policies(policy).GammaMax = gamma_max(policy);
        Subjs(count).Policies(policy).TempMax = temp_max(policy);
        if policy <= 2
            k = 1;
        elseif policy > 2
            k = 2;
        end
        Subjs(count).Policies(policy).AIC = fct_AIC(k,sum_max(policy));
        Subjs(count).Policies(policy).BIC = fct_BIC(k,nn(count),sum_max(policy));
    end
%     for target_num = 1:nCells
%         count_noneNaN = count_noneNaN + sum(~isnan(actual_actions(target_num).Target));
%         sim=1;
%         %fieldarrayofstr = FieldArrayOfStr(logLK(target_num).Target(sim).Sim);
%         %summax = max(fieldarrayofstr(fieldarrayofstr<0));
%         %pm_logL = pm_logL + summax;
%         %maxGidx = find(fieldarrayofstr==summax);
%         pm_logL = pm_logL + logLK(target_num).Target(sim).Sim(maxGidx).SumOmitInf;
%         gamma_max = Index2Gamma(maxGidx);
%         SGTinfo = [Subjinfo ' / ' policyinfo ' / \Gamma=' sprintf('%.2f',gamma_max) ' / Target #' sprintf('%d',target_num)];
%         if PlotPrior
%             figure;
%             for iter = 1:nTrials_HT
%                 pp = prior(target_num).Target(maxGidx).Gamma(sim).Sim(:,iter);
%                 QBA(target_num).Target(maxGidx).Gamma(sim).Sim(:,iter) = QBA(target_num).Target(maxGidx).Gamma(sim).Sim(:,iter)/sum(QBA(target_num).Target(maxGidx).Gamma(sim).Sim(:,iter));
%                 sgt = ['trial ' sprintf('%02d',iter)];
%                 subplot(3,5,iter);
%                 plot(X,[pp (QBA(target_num).Target(maxGidx).Gamma(sim).Sim(:,iter))],[targetTheta(target_num) targetTheta(target_num)],[0 1.e2],'-k');
%                 xticks([0 30 60 90 120 150 180]);
%                 axis([0 180 0 0.01]);
%                 text(actual_actions(target_num).Target(iter),0,'\uparrow','Color','green','FontSize',20,'HorizontalAlignment','center');
%                 text(simActions(target_num).Target(maxGidx).Gamma(iter),0,'\uparrow','Color','red','FontSize',20,'HorizontalAlignment','center');
%                 title(sgt);
%                 grid on;
%             end
%             sgtitle(SGTinfo);
%         end
%         if strcmp(Policy,'MIG')
%             if PlotGain
%                 figure;
%                 for iter = 1:nTrials_HT
%                     %gg=smoothdata(Gain(target_num).Target(maxGidx).Gamma(sim).Sim(:,iter),'gaussian');
%                     gg=Gain(target_num).Target(maxGidx).Gamma(sim).Sim(:,iter);
%                     TFM=find(gg==max(gg));
%                     TFm=find(gg==min(gg));
%                     sgt=['trial ' sprintf('%02d',iter)];
%                     subplot(3,5,iter);
%                     plot(X,gg,[targetTheta(target_num) targetTheta(target_num)],[-1.e2 1.e2],'-k',...
%                         X(TFM),gg(TFM),'r*',X(TFm),gg(TFm),'b*');
%                     xticks([0 30 60 90 120 150 180]);
%                     lowestY = -0.2;
%                     biggestY = 1;
%                     if lowestY ~= biggestY
%                         axis([0 180 lowestY biggestY]);
%                     else
%                         axis([0 180 -1 1]);
%                     end
%                     text(actual_actions(target_num).Target(iter),lowestY,'\uparrow','Color','green','FontSize',20,'HorizontalAlignment','center');
%                     text(simActions(target_num).Target(maxGidx).Gamma(iter),lowestY,'\uparrow','Color','red','FontSize',20,'HorizontalAlignment','center');
%                     title(sgt);
%                     grid on;
%                 end
%                 sgtitle(SGTinfo);
%             end
%         end
%     end
%     pm_k = 1;
%     pm_n = count_noneNaN;
%     fct_BIC(pm_k,pm_n,pm_logL)
end
save(result_file,'Subjs');
%% Internal Functions