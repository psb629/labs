function FreqIndexTable = tf_ini_Dis_FreqIndex(path_FreqIndex,ended_RUN,rand_nFreqPairsXnblocks)
global Ns FreqPairs

load(path_FreqIndex,'FreqIndex');
cFidx = Ns.SampleRate*0.5 + 1;
FreqIndex(cFidx).OrderOfFreqPair = nan;
FreqIndex(cFidx).CountCalled = nan;
FreqIndex(cFidx).ISI = nan;
for iter = 1:Ns.SampleRate
    if (iter ~= cFidx)
        FreqIndex(iter).CountCalled = [0,0];
    end
end

FreqPair = FreqPairs.Low;
f_mid = FreqPairs.Low(1,1);
f_min = FreqPairs.Low(1,2);
f_max = FreqPairs.Low(end,2);

needRun = true;
if ended_RUN == 1
    blocks_already = 1:4;
elseif ended_RUN == 2
    blocks_already = 1:7;
elseif ended_RUN == 3
    blocks_already = 1:10;
else
    needRun = false;
end

if needRun
    for a = blocks_already
        for b = 1:ntrials
            row = rand_nFreqPairsXnblocks(b,a);
            cFidx = (FreqPair(row,1) + FreqPair(row,2) - f_mid - f_min)/freq_interval + 1;
            col1=FreqIndex(cFidx).OrderOfFreqPair(a,1); %col2=FreqIndex(idx).OrderOfFreqPair(a,2);
            FreqIndex(cFidx).CountCalled(col1) = FreqIndex(cFidx).CountCalled(col1) + 1;
        end
    end
end
FreqIndexTable = FreqIndex;
end