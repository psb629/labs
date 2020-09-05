clear all; clc;

subj_list = {'GD07','GD11','GD30','GD02','GD29',...
    'GD32','GD23','GD01','GD31','GD33',...
    'GD44','GD26'};
runs = 1:7;
sequences=1:8;

nsubj = size(subj_list,2);
nrun = size(runs,2);
nsequence = size(sequences,2);
max_score = 60*5*12; %% 60Hz*5s*12trials = frames

rew = zeros(nrun,nsequence);
cnt = 0;
for temp = subj_list
    subj = char(temp);
    rew_bin=calc_rew_reg(subj,1,'OFF');
    for r = runs
        for i = sequences
            sequence_i = 60*i-56:60*i+5;
            rew(r,i)=sum(rew_bin(r,sequence_i))/max_score;
        end
        subplot(nsubj,nrun,nrun*cnt+r);
        plot(sequences,rew(r,:),'-');
        title(sprintf('%s, RUN%02d',subj,r));
        grid on;
        axis([1 8 0 1]);
        xlabel('sequence #');
        ylabel('Reward Rate');
    end
    cnt = cnt + 1;
end