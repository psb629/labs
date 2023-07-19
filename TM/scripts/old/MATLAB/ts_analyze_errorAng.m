%%  clear
clc; clear all;
%%  prompt information
prompt = {'Subject ID'};
defaults = {'TM'};
answer = inputdlg(prompt, 'Discrimination Task',[1,30], defaults);
[Subj] = deal(answer{:}); % all input variables are strings
%%  classify test type.
SubjDir = ['./behav_data/' Subj];
behav_data = [SubjDir '/behav_data_HT.dat'];
load([SubjDir '/Profile.mat']);
age=floor((str2double(datestr(now,'yyyymmdd')) - str2double(Profile{1,3}))/1.e4);
Subjinfo=insertBefore(Subj,"_PILOT","\");
sgt=[Subjinfo sprintf(' / %s / %d',char(Profile(4)),age)];
fmin = 10;
fmax = 20;
%%  load data file
Table_data = readtable(behav_data,'Format','%f%d%f%f%f%d%f');
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
%sigma = std(Y(10,:));
nRow=4;     % show nRow lines in one subplot
if mod(nBlocks_HT/nRow,1)~=0    % is nRow a divisor of nBlocks_HT ?
    error('Error. nRow has to be a divisor of nBlock_HT');
end
nCol=nBlocks_HT/nRow;
%%  plot #1 : reward
X=1:nTrials_HT; Y=zeros(nTrials_HT,nBlocks_HT);
for a = 1:nBlocks_HT
    for b = 1:nTrials_HT
        Y(b,a) = Table_data{b+nTrials_HT*(a-1),'Reward'};
    end
end
figure;
for a = 1:nBlocks_HT
    subplot(nRow,nCol,a);
    %hold on;
    plot(X,Y(:,a),'-o');
    axis([1 nTrials_HT 0 180]);
    xlabel('Trial');
    ylabel('Reward');
    axis([1 nTrials_HT fmin fmax]);
    grid on;
    %hold off;
end
sgtitle(sgt);
%%  plot #2 : target tracking
figure;
X=1:nTrials_HT;  Y=zeros(nTrials_HT,nBlocks_HT);
for a = 1:nBlocks_HT
    for b = 1:nTrials_HT
        Y(b,a) = Table_data{b+nTrials_HT*(a-1),'Estimation'};
    end
    %Y(:,a) = Y(:,a) / max(Y(:,a));     % scaling by each maximum value
end
for a = 1:nBlocks_HT
    subplot(nRow,nCol,a);
	hold on
    graphInfo=sprintf('%.3f',Table_data{nTrials_HT+(a-1)*nTrials_HT,'ErrorAngle'});
    title(['\Delta\theta=' graphInfo]);
    TargetPosition=Table_data{nTrials_HT+(a-1)*nTrials_HT,'Block'};
    text(nTrials_HT,TargetPosition,'\leftarrow Target','Color','red','FontSize',6)
	plot(X,Y(:,a),'-o');
    axis([1 nTrials_HT 0 180]);
    yticks([0 30 60 90 120 150 180]);
    xlabel('Trial');
    ylabel('\theta');
	grid on
    hold off
end
sgtitle(sgt);
%%  plot #3 : error
figure;
X=1:nTrials_HT;  Y=zeros(nTrials_HT,nBlocks_HT);
Errors=1:nBlocks_HT;
for a = 1:nBlocks_HT
    for b = 1:nTrials_HT
        Y(b,a) = Table_data{b+nTrials_HT*(a-1),'ErrorAngle'};
    end
    %Y(:,a) = Y(:,a) / max(Y(:,a));     % scaling by each maximum value
end
for a = 1:nBlocks_HT
    subplot(nRow,nCol,a);
	hold on
	legendInfo=sprintf('¥è_{target}=%.3f\n¥è_{Error}=%.3f',Table_data{nTrials_HT+(a-1)*nTrials_HT,'Block'},Table_data{nTrials_HT+(a-1)*nTrials_HT,'ErrorAngle'});
    Errors(a)=Table_data{nTrials_HT+(a-1)*nTrials_HT,'ErrorAngle'};
	%fprintf(legendInfo);
	plot(X,Y(:,a),'-o','DisplayName',legendInfo);
    axis([1 nTrials_HT 0 180]);
    yticks([0 30 60 90 120 150 180]);
    xlabel('Trial');
    ylabel('\theta_{Error}');
	grid on
	legendline=line(nan,nan,'Linestyle','none','Marker','none','Color','none');
    legend(legendline,legendInfo,'Location','northeast','Box','off')
    hold off
end
sgt=[sgt ' / ' sprintf('N(%.1f,%.1f©÷)',mean(Errors,'omitnan'),std(Errors,'omitnan'))];
sgtitle(sgt);
%%  the size of font up
%set(findall(gcf,'-property','FontSize'),'FontSize',10);