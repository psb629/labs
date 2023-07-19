%% this code is used to pre-caculate the likelihood table

%In our model, the states, actions and observations are all discrete 
%(441 states, 441 actions and 51 observations). 
%The joint distribution of S and O given an action, p(O|S,A), was 
% estimated (directly) by sampling. 


%The likelihood function p(O|S,A) given the uncertainty 
%(from Gamma and Motor Noise) can be estimated by the following. 

%For each of the state and action pair, 
%we generated 60000 observations (points between 0 to 50)%
% given the Gamma (plus Motor Noise if for the reaching task). 
% Then p(O|S,A) can be directly estimated as the frequency that 
% each of the observations (51 of them) was encountered (within 
%fthese 10000 samples)?.


% For the decision making task, the likelihood function is 
% dependent on the Gamma

% For the MO task, the likelihood function is 
% dependent on both motor noise and Gamma

clear;clc;close all;
Table_dir='./likelihoodTableDM';
if ~exist(Table_dir,'dir')
    mkdir(Table_dir);
end

ObsMin=100; ObsMax=ObsMin+12;       % range(score)=12, min(score)>>1 for a round function
thetaRange=0:0.5:180;               % direction
GammaRange=0.0:0.2:4.0;             % variance related to compregension of the model

% Find all possible combination of alpha and beta 
Theta=thetaRange;

nActions=size(Theta,2);
nStates=nActions;
nObs=nStates;

for Gamma=GammaRange
    Gamma
    tic;
    L=struct([]); % the likelihood table
    for iAction=1:nActions

        %table = zeros(nStates,nObs);   % Finite Gaussian distribution
        table = ones(nStates,nObs);     % It is necessary that some kind of distribution in low uncertainty
        plannedtheta = Theta(iAction);
        for iState=1:nStates
            nReps=60000; % you could change this setting. Ideally, the higher the better, but it takes long time.
            targettheta = Theta(iState);
            score = ObsMax - (ObsMax - ObsMin)*abs(targettheta-plannedtheta)/180;   % f_max - |dtheta|/180 * df
            for i=1:nReps
                needRep=1;
                while needRep
                    noiseScore = Gamma*randn;
                    scorePlusNoise = score + noiseScore;
                    indexObsMax = nObs;
                    indexObsMin = 1;
                    indexObsK = (scorePlusNoise-ObsMin)*(nObs-1)/(ObsMax-ObsMin) + 1;
                    indexObsK = round(indexObsK);
                    if (indexObsMax-indexObsK)*(indexObsMin-indexObsK)<=0    % Min <= K <= Max
                        needRep = 0;
                    end
                end
                table(iState,indexObsK) = table(iState,indexObsK) + 1;
            end
        end
        L(iAction).table=table;
    end
    save([Table_dir '/likelihood_Gamma' num2str(sprintf('%.1f',Gamma)) '.mat']);
    toc;
end
