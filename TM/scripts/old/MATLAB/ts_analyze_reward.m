%%  clear
clc; clear all;
%%  prompt information
prompt = {'Subject ID','Name','Day'};
defaults = {'0','HGD','1'};
answer = inputdlg(prompt, 'Hidden Target Task',[1,30], defaults);
[SUBID,SUBNAME,NDAY] = deal(answer{:}); % all input variables are strings
%%  classify test type.
subid = str2double(SUBID);  % convert string to number for subsequent reference
nday = str2double(NDAY);	% convert string to number for subsequent reference
testType = mod(subid + nday,2);    % the result is odd or even #
LogDir = ['Log_HT_' SUBID SUBNAME];
switch testType
    case 0     % Normal Learning Session 1 : Low Frequency
        FreqType = '/LowFreq'; f_start=14; f_end=26;
    case 1     % Normal Learning Session 2 : High Frequency
        FreqType = '/HighFreq'; f_start=34; f_end=46;
end
PathLog = [LogDir FreqType '/HiddenTarget_Freq.dat'];
load([LogDir '/Profile.mat']);
age=floor((str2double(datestr(now,'yyyymmdd')) - str2double(Profile{1,5}))/1.e4);
sgt=sprintf('%s %d',char(Profile(6)),age);
%%  load data file
Table_data = readtable(PathLog,'Format','%f%d%f%f%f%d%f');
var1='Block';
var2='Trial';
var3='Estimation';
var4='Decision Time';
var5='ErrorAngle';
var6='ISI';
var7='Reward';
Table_data.Properties.VariableNames={var1,var2,var3,var4,var5,var6,var7};
%%  set x, y, and deviation
nTrials_HT=double(max(Table_data{:,'Trial'}));
nBlocks_HT=height(Table_data)/nTrials_HT;
X=1:nTrials_HT;  Y=zeros(nTrials_HT,nBlocks_HT);
for a = 1:nBlocks_HT
    for b = 1:nTrials_HT
        Y(b,a) = Table_data{b+nTrials_HT*(a-1),'ErrorAngle'};
    end
end
sigma = sqrt(var(Y(10,:)));
nRow=4;     % show nRow lines in one subplot
if mod(nBlocks_HT/nRow,1)~=0    % is nRow a divisor of nBlocks_HT ?
    error('Error. nRow has to be a divisor of nBlock_HT');
end
nCol=nBlocks_HT/nRow;
%%  plot #1 : Reward
figure;
X=1:nTrials_HT;  Y=zeros(nTrials_HT,nBlocks_HT);
Reward=zeros(1,nTrials_HT);
err=zeros(1,nTrials_HT);
for b = 1:nTrials_HT
    for a = 1:nBlocks_HT
        rw=Table_data{b+nTrials_HT*(a-1),'Reward'};
        if rw<f_start || rw>f_end
            Y(b,a) = NaN;
        else
            Y(b,a) = rw;
        end
    end
    Reward(b)=mean(Y(b,:),'omitnan');
    err(b)=sqrt(var(Y(b,:),'omitnan'));
    %Y(:,a) = Y(:,a) / max(Y(:,a));     % scaling by each maximum value
end
errorbar(X,Reward,err);
axis([1 nTrials_HT f_start-2 f_end+2]);
xlabel('Trial');
xticks(1:nTrials_HT);
ylabel('Reward');
grid on;
sgt=[sgt ' / ' sprintf('N(%.1f,%.1f©÷)',mean(Reward),std(Reward))];
sgtitle(sgt);
%%  the size of font up
%set(findall(gcf,'-property','FontSize'),'FontSize',10);