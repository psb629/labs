%   Setting parameters for discrimination task
%   20. March . 2020 by Sungbeen Park
%%  Default setting
global TM_dir Discrimination_dir
TM_Set;
%%  Addpath the Dis_dir
Discrimination_dir = [TM_dir '/main_Discrimination_task'];
if exist(Discrimination_dir,'dir')
    addpath(Discrimination_dir);
end
%%  Experimental parameters
global Ns times sizes
Ns(1).block = 10;
Ns(1).trial = Ns.SampleRate;
sizes(1).cross = 175;
sizes(1).coin = [0 0 300 300];       %%% Show the coins within the size
%%	Inter-stimulus interval
times = struct([]);
times(1).decision = 1.5;
times(1).show_coin = 0.5;
%%  Make the frequency-pairs table with trial-by-trial: (Randomly)
FreqPairs(1).LowPairs = make_pairs(FreqPairs.Low);
FreqPairs(1).HighPairs = make_pairs(FreqPairs.High);
%%  Set ISIs
% (Session#1: 682s), (Session#2: 535s), (Session#3: 533s),
%%  Time structure to record each event timing
Timing=struct([]);
for iter = 1:(Ns.block*Ns.SampleRate)
    Timing(iter).Vibration = NaN(1,2);
    Timing(iter).Yellow = NaN;
    Timing(iter).Decision = NaN;
    Timing(iter).Coin100 = NaN;
    Timing(iter).Coin0 = NaN;
    Timing(iter).ISI = NaN(1,3);
end
%%  Save variables
save([Discrimination_dir '/Dis_variables.mat'],'FreqPairs','times');
%%  Internal functions
function result = make_pairs(FreqPairs)
global Ns times Discrimination_dir
table = repmat((1:Ns.SampleRate)',1,Ns.block); table = Shuffle(table);
FreqIndex = tf_ini_Dis_FreqIndex([Discrimination_dir '/FreqIndex.mat'],0,table);
f_mid = FreqPairs(1,1);
f_min = FreqPairs(1,2);
f_max = FreqPairs(end,2);
freq_interval = FreqPairs(2,2) - FreqPairs(1,2);
time_RUN01 = 0; time_RUN02 = 0; time_RUN03 = 0;
for a = 1:Ns.block
    for b = 1:Ns.trial
        idx = Ns.trial*(a-1) + b;
        row = table(b,a);
        Fidx = (FreqPairs(row,1) + FreqPairs(row,2) - f_mid - f_min)/freq_interval + 1;
        col1=FreqIndex(Fidx).OrderOfFreqPair(a,1); col2=FreqIndex(Fidx).OrderOfFreqPair(a,2);
        FreqIndex(Fidx).CountCalled(col1) = FreqIndex(Fidx).CountCalled(col1) + 1;
        rowISI = FreqIndex(Fidx).CountCalled(col1);
        ISI_1 = 1.5 + FreqIndex(Fidx).ISI(rowISI,col1);
        ISI_2 = 8 - FreqIndex(Fidx).ISI(rowISI,col1);
        ISI_3 = FreqIndex(Fidx).ISI(rowISI,col1);
        F_before(idx,1)=FreqPairs(row,col1); F_after(idx,1)=FreqPairs(row,col2);
        if a <= 4
            time_RUN01 = time_RUN01 + 1 + ISI_1 + 1 + ISI_2 + times.decision + times.show_coin + ISI_3;
        elseif a <= 7
            time_RUN02 = time_RUN02 + 1 + ISI_1 + 1 + ISI_2 + times.decision + times.show_coin + ISI_3;
        else
            time_RUN03 = time_RUN03 + 1 + ISI_1 + 1 + ISI_2 + times.decision + times.show_coin + ISI_3;
        end
        times.ISIs(idx).ISI1 = ISI_1;
        times.ISIs(idx).ISI2 = ISI_2;
        times.ISIs(idx).ISI3 = ISI_3;
    end
end
fprintf('Running time = %d + %d + %d = %d\n',time_RUN01,time_RUN02,time_RUN03,time_RUN01+time_RUN02+time_RUN03);
result(:,1) = F_before;
result(:,2) = F_after;
FreqIndex = tf_ini_Dis_FreqIndex([Discrimination_dir '/FreqIndex.mat'],0,table);
end