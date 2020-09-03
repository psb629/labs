function [prior,QBA,Gain,Trials]=model1(FreqType,target,MotorBias,Gamma,tempSet,actual_actions)
%% INPUT
% task: 1---decision-making task; 2---reaching task
% targetTheta: target's position
% ThetaNoise: direction noise. For the decision making task, this is set to 0
% Gamma: the likelihood uncertainty parameters
% action0: the first action(movement) of the real subject
% nSim: the number of simuations
% likelihoodTable: the likelihood function is pre-generated.
% temp: describe how the temperature changes along the number of attempt;
%                   please read the associated text with Equation 12
% policy: the policy for action slection. E.g.,epsilon-greedy or softmax.
% See actionSelection function below for more information.
        %--'softmaxLinear': linear decreasing temperature
        %--'softmaxFixed': fixed temperature
        %--'greedy': choose the best action so far withour exploration

%% output
% prior: (nState) x (nTrial) matrix
% QBA: (nState) x (nTrial) matrix
% Gain: (nState) x (nTrial) matrix
% Trials: (nTrials) x (4 policies) structure
%%
global TM_dir Freqs
global Obsmin ObsMax nObs
global L
global Parameter2Index

tolerence = 1.e-10;
% experimental parameters
switch FreqType
    case 'L'
        Obsmin=Freqs(1).Low; ObsMax=Freqs(3).Low;
    case 'H'
        Obsmin=Freqs(1).High; ObsMax=Freqs(3).High;
end

Gamma

% load likelihood function L = p(Oi|S,Ai)
load([TM_dir '/scripts/MATLAB/Model/model1/likelihoodCalc/likelihoodTableDM/likelihood_Gamma' sprintf('%.1f',Gamma) '.mat'],'L');

% all the targets and actions
theta = 0:0.5:180; % direction

nStates = length(theta);
nActions = nStates;
nObs = nActions;
% As in the experiment, the model is allowed 25 attempts to find each target
nAttempts = 15;

% calculate the score for all state-action pairs
trueScores = zeros(nStates,nActions);
for i=1:nStates     % target's state
    % all actions for each target
    S = theta(i); A = theta;
    % trueScores = (all target's states x all actions) matrix
    trueScores(i,:) = Action2Obs(S,A);
end

% make Qsa = [Q11 Q12 ... Q1a; Q21 ...; ...; Qs1 Qs2 ... Qsa; ...] which is the value matrix (S-by-A)
A = repmat(theta,nStates,1);
S = repmat(theta,nActions,1)';
% A = repmat(theta,nStates,1)+MotorNoise*randn(nStates,nActions);
% S = repmat(theta,nActions,1)'+MotorNoise*randn(nStates,nActions);
% A = min(180,max(0,A));
% S = min(180,max(0,S));
QSA = Action2Obs(S,A);

% Initializing
prior0 = ones(nStates,1)./nStates;
prior(:,1) = prior0;
QBA = nan(nStates,nAttempts);
Gain = nan(nStates,nAttempts);
iAttempt = 0;
% for each target search, it would terminate either when it finds the target or when it reachs maximal steps.

while iAttempt < nAttempts
    iAttempt = iAttempt+1;
    Trials(iAttempt).Trial = iAttempt;
    
    % Equation 7 in the paper. QBA = [QB1 QB2 ... QBa ...] is an array which evaluates each state
    QBA(:,iAttempt) = prior(:,iAttempt)'*QSA;
    %QBA(iSim).Sim(:,iAttempt) = prior(iSim).Sim(:,iAttempt)';
    
    % Calculating information gain
    Gain(:,iAttempt) = Prior2Gain(prior(:,iAttempt));
    
    % if the subject didn't reach to the arc
    if isnan(actual_actions(iAttempt))
        prior(:,iAttempt+1) = prior(:,iAttempt);
        continue
    end
    
    % choose an action based on QBA (Equation 12);
    first_trial_reaching = find(~isnan(actual_actions),1);    % first time reaching
    if iAttempt > first_trial_reaching
        [actionChosen] = actionSelection(QBA(:,iAttempt),nActions,iAttempt,tempSet,prior(:,iAttempt));
        thetaPlanned = theta(actionChosen);
    end
    act_act = actual_actions(iAttempt);
    % execute the action chosen (+ Motor Noise)
    if iAttempt > first_trial_reaching
        actionExe = thetaPlanned + MotorBias;
        actionExe = min(180,max(0,actionExe));  % upper limit = 180, lower limit = 0
    elseif iAttempt == first_trial_reaching
        actionExe = act_act * ones(length(tempSet),4);
    end
    % observe a score given the action selection
    obs = Action2Obs(target,act_act);
    % record the simulation results
    for t = tempSet
        Tidx = Parameter2Index(t,tempSet(1),tempSet(2)-tempSet(1));
        Trials(iAttempt).Actions(1).temps(Tidx).temp = t;
        Trials(iAttempt).Actions(1).temps(Tidx).SMF = actionExe(Tidx,1);
        Trials(iAttempt).Actions(1).temps(Tidx).SML = actionExe(Tidx,2);
    end
    Trials(iAttempt).Actions(1).Greedy = actionExe(1,3);
    Trials(iAttempt).Actions(1).MIG = actionExe(1,4);
    
    % the likelihoodTable is precalculated.
    indexObsK = Obs2index(obs);
    
    table=L(Action2index(act_act)).table;
    counts=table(:,indexObsK);
    likelihood=counts./sum(counts);
    
    % posterior(state) = likelihood(state) * prior(state)
    actual_posterior = likelihood.*prior(:,iAttempt);
    
    % normalization
    actual_posterior = actual_posterior./sum(actual_posterior);
    
    % update the belief
    pp = actual_posterior;
    pp(pp<tolerence)=0;
    pp = smoothdata(pp,'gaussian');
    prior(:,iAttempt+1) = pp/sum(pp);

end
%fprintf('mean=%.1f\tdiv=%.1f\n',mean(simActions(nAttempts,:)),std(simActions(nAttempts,:)));
end

%% Calculator
function indexObsK = Obs2index(Obs)
global ObsMax Obsmin nObs
indexObsK = (Obs-Obsmin)*(nObs-1)/(ObsMax-Obsmin) + 1;
indexObsK = round(indexObsK);
end
function indexActionK = Action2index(Action)
indexActionK = round(Action*2 + 1);
end
function Obs = Action2Obs(Target,Action)
global ObsMax Obsmin
Obs = ObsMax - abs(Target-Action)*(ObsMax-Obsmin)/180;
end
function GainMeans = Prior2Gain(P_prior)
global L
theta = 0:0.5:180;
n_states = length(theta);
n_actions = n_states;
GainMeans = nan(1,n_actions);
pp = P_prior(P_prior>0);
entropy_before = -pp'*log2(pp);
EstimTarget = randsample(theta,1,true,P_prior);
for a = 1:n_actions
    if std(P_prior) > 1.e-5
        Obs = Action2Obs(EstimTarget,theta(a));
        table = L(a).table;
        counts = table(:,Obs2index(Obs));
        likelihood = counts./sum(counts);
        P_post = likelihood.*P_prior;
        P_post = P_post./sum(P_post);
        pp = P_post(P_post>0);
        entropy_after = -pp'*log2(pp);
        GainMeans(a) = entropy_before - entropy_after;
    else        %% initial condition of the belief b
        g = zeros(1,n_states);
        for s = 1:n_states
            Obs = Action2Obs(theta(s),theta(a));
            table = L(a).table;
            counts = table(:,Obs2index(Obs));
            likelihood = counts./sum(counts);
            P_post = likelihood.*P_prior;
            P_post = P_post./sum(P_post);
            pp = P_post(P_post>0);
            entropy_after = -pp'*log2(pp);
            g(s) = entropy_before - entropy_after;
        end
        GainMeans(a) = mean(g);
    end
end
GainMeans=smoothdata(GainMeans,'gaussian');
end

%% Policies (Maximum A Posterior)
function [actionChosen]=actionSelection(Qmap,n_actions,t,tempSet,prior)
actionChosen = ones(length(tempSet),4);     %% 1 <= actionSelection <= 361
global Parameter2Index
for temp = tempSet
    Tidx = Parameter2Index(temp,tempSet(1),tempSet(2)-tempSet(1));
    %%% softmaxFixed
	Qmap_Max = max(Qmap);		%%% to prevent overflow
    w=exp((Qmap-Qmap_Max)./temp);
    w=w/sum(w);
    actionChosen(Tidx,1)=randsample(1:n_actions,1,true,w);
    %%% softmaxLinear
    w=exp(((Qmap-Qmap_Max).*t)./temp);
    w=w/sum(w);
    actionChosen(Tidx,2)=randsample(1:n_actions,1,true,w);
end
%%% Greedy
c=find(Qmap==max(Qmap));
if length(c)>1  % if there the index of maximum Qmap is many, choose one randomly within c
    actionChosen(1,3)=c(randi(length(c)));
else
    actionChosen(1,3)=c;
end
%%% MIG
gain = Prior2Gain(prior);
c=find(gain==max(gain));
if length(c)>1
    actionChosen(1,4)=c(randi(length(c)));
else
    actionChosen(1,4)=c;
end
end
