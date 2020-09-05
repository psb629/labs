%  clear
clc; clear all;
%%  prompt information
prompt = {'Subject ID'};
defaults = {'TM'};
answer = inputdlg(prompt, 'Discrimination Task',[1,30], defaults);
[Subj] = deal(answer{:}); % all input variables are strings
%%  classify test type.
SubjDir = ['./behav_data/' Subj];
behav_data = [SubjDir '/behav_data_Dis.dat'];
load([SubjDir '/Profile.mat']);
age=floor((str2double(datestr(now,'yyyymmdd')) - str2double(Profile{1,3}))/1.e4);
Subjinfo=insertBefore(Subj,"_PILOT","\");
sgt=[Subjinfo sprintf(' / %s / %d',char(Profile(4)),age)];
%%  load data file
Table_data = readtable(behav_data,'Format','%d%f%f%f%d%s%d%f%d');
var1='TrialNumber';
var2='Fbefore';
var3='ISI_1';
var4='Fafter';
var5='ISI_2';
var6='Choice';
var7='Accuracy';
var8='ReactionTime';
var9='ISI_3';
Table_data.Properties.VariableNames={var1,var2,var3,var4,var5,var6,var7,var8,var9};
%%  set the basic parameters that refer to frequency
nblocks=double(max(Table_data{:,'TrialNumber'}/1.e4));
SampleRate=double(max(mod(Table_data{:,'TrialNumber'},1.e4))+1);
f_start=double(min([Table_data{1:SampleRate-1,'Fbefore'},Table_data{1:SampleRate-1,'Fafter'}],[],'All'));
f_end=double(max([Table_data{1:SampleRate-1,'Fbefore'},Table_data{1:SampleRate-1,'Fafter'}],[],'All'));
freq_interval=(f_end-f_start) / (SampleRate-1);
sum = 0;
for i=1:SampleRate-1
   sum = sum + Table_data{i,'Fbefore'} + Table_data{i,'Fafter'};
end
f_center = 0.5 * sum / (SampleRate-1);
%%  make the formations of the 1st column that relects the range of data frequency
probability = zeros(2,SampleRate); probability(1,:) = linspace(f_start,f_end,SampleRate);
%%  count the number of correctness
for a = 1:height(Table_data)
    if Table_data{a,'Accuracy'}==1
        b = abs(Table_data{a,'Fbefore'}-Table_data{a,'Fafter'})/freq_interval;
        if Table_data{a,'Fbefore'} >= f_center && Table_data{a,'Fafter'} >= f_center
            i = abs(max(Table_data{a,'Fbefore'},Table_data{a,'Fafter'})-f_start)/freq_interval+1;
            probability(2,i) = probability(2,i)+1;
        end
    else
        if Table_data{a,'Fbefore'} <= f_center && Table_data{a,'Fafter'} <= f_center
            i = abs(min(Table_data{a,'Fbefore'},Table_data{a,'Fafter'})-f_start)/freq_interval+1;
            probability(2,i) = probability(2,i)+1;
        end
    end
end
divider = height(Table_data)/(SampleRate-1);
probability(2,round(SampleRate/2)) = 0.5*divider;
Y = probability(2,:)/divider;
cdata = probability(1,:);
%%  deviation
figure;
n = f_center;
xstart = 4*rand;
myfitoption = fitoptions('Method','NonlinearLeastSquares','Lower',0,'Upper',Inf,'Start',xstart);
myfittype = fittype('0.5*(1+erf((x-n)/(sqrt(2)*s)))','problem','n','option',myfitoption);
[curve,gof] = fit(cdata',Y',myfittype,'problem',n);
tic;
for i = 1 : 3.e2
    xstart = 4*rand;
    myfitoption = fitoptions('Method','NonlinearLeastSquares','Lower',0,'Upper',Inf,'Start',xstart);
    myfittype = fittype('0.5*(1+erf((x-n)/(sqrt(2)*s)))','problem','n','option',myfitoption);
    [curvedummy,gofdummy] = fit(cdata',Y',myfittype,'problem',n);
    if gof.rsquare < gofdummy.rsquare
        gof=gofdummy;
        curve=curvedummy;
    end	
end
toc;
ErfCoeff=coeffvalues(curve);    % percetual noise(=sigma_p) in Hz
ErfGof=gof;
x=linspace(f_start,f_end,100);
y=0.5*(1+erf((x-n)/(sqrt(2)*ErfCoeff)));
JND=erfinv(0.5)*(sqrt(2)*ErfCoeff);     % JND for 75%
plot(curve,'r-',cdata,Y,'ro');
axis([f_start f_end 0 1]);
xlabel('Freq.');
ylabel('Prob. judged higher');
legendInfo=['\sigma=' sprintf('%.3fHz',ErfCoeff) sprintf('\nJND=%.3fHz',JND)];
dummyh=line(nan,nan,'Linestyle','none','Marker','none','Color','none');
legend(dummyh,legendInfo,'Location','northwest','Box','off');
sgtitle(sgt);
grid on;
%%  custumize fitting function #1
%{
d_prime='0.5*(1+erf( k/(a*k^r)^(0.5) * (x^b-n^b)/sqrt(x^(b*r)+n^(b*r)) ))';
n = f_center;
startpoint1 = 4*rand(1,4);
fo1 = fitoptions('Method','NonlinearLeastSquares','Lower',[0,0,0,0],'Upper',[Inf,Inf,Inf,Inf],'Start',startpoint1);
f1 = fittype(d_prime,'problem','n','options',fo1);
[curve,gof] = fit(cdata',Y',f1,'problem',n);
time_start=GetSecs; count=0;
for i = 1 : 2.e2
    startpoint1 = 3*rand(1,4);
    fo1 = fitoptions('Method','NonlinearLeastSquares','Lower',[0,0,0,0],'Upper',[Inf,Inf,Inf,Inf],'Start',startpoint1);
    f1 = fittype(d_prime,'problem','n','options',fo1);
    [curvedummy,gofdummy] = fit(cdata',Y',f1,'problem',n);
    if gof.rsquare < gofdummy.rsquare
        gof=gofdummy;
        curve=curvedummy;
        count=count+1;
    end
end
time_end=GetSecs-time_start;
fprintf('time = %.3f\ncount = %d\n',time_end,count);
global MyCoeffs MyGOF
MyCoeffs=coeffvalues(curve);    % #1=a, #2=b, #3=k, #4=r
MyGOF=gof;
%% plotting #1
subplot(2,2,[1,2]);
plot(curve,'r-',cdata,Y,'ro');  % '-': line, 'o': dot shaped o
grid on;
xlabel('F_{comparison}');
ylabel('F_{comp.} jurged higher');
legendInfo=sprintf('fiting curve, r^2=%.4f',MyGOF.rsquare);
legend('data',legendInfo,'Location','northwest','Color','none');

subplot(2,2,3);
x=cdata;
y=MyCoeffs(3)*x.^MyCoeffs(2);
axis([0 f_end 0 Inf]);
plot(x,y,'g-o');
xlabel('Freqency');
ylabel('R');
legendInfo=sprintf('k=%.1e\n¥â=%.1f',MyCoeffs(3),MyCoeffs(2));
dummyh=line(nan,nan,'Linestyle','none','Marker','none','Color','none');
legend(dummyh,legendInfo,'Location','northwest','Box','off');
grid on;

subplot(2,2,4);
x=MyCoeffs(3)*x.^MyCoeffs(2);
y=MyCoeffs(1)*x.^MyCoeffs(4);
axis([0 f_end 0 Inf])
plot(x,y,'b-o');
xlabel('R');
ylabel('\sigma^{2}');
legendInfo=sprintf('¥á=%.1e\n¥ã=%.1f',MyCoeffs(1),MyCoeffs(4));
dummyh=line(nan,nan,'Linestyle','none','Marker','none','Color','none');
legend(dummyh,legendInfo,'Location','northwest','Box','off');
grid on;
%set(gca,'Fontsize',20);
set(findall(gcf,'-property','FontSize'),'FontSize',20);
%}
%%  custumize fitting function & plot #2
%{
startpoint2 = [f_center,rand()];
fo2 = fitoptions('Method','NonlinearLeastSquares','Lower',[0,0],'Upper',[Inf,max(cdata)],'Start',startpoint2);
f2 = fittype('1-exp(-((x-n)/a)^b)','problem','n','options',fo2);
n = 0;  % n is always 0
[curve,gof] = fit(cdata',Y',f2,'problem',n);
plot(curve,cdata,Y,'-o');  % '-': line, 'o': dot shaped o
xlabel('F_{comparison}');
ylabel('F_{comparison} jurged higher');
legend('Location','southeast');
grid on;
%}
%%  custumize fitting function & plot #3
%{
startpoint3 = [f_center,rand()];
fo3 = fitoptions('Method','NonlinearLeastSquares','Lower',[0,0],'Upper',[Inf,max(cdata)],'Start',startpoint3);
f3 = fittype('a*(x-n)^b','problem','n','options',fo3);	exclude3 = cdata < f_center;
n = f_center;
[curve,gof] = fit(cdata',Y',f3,'problem',n,'exclude',exclude3);
plot(curve,cdata,Y,'-o',exclude3);  % '-': line, 'o': dot shaped o
xlabel('F_{comparison}');
ylabel('F_{comparison} jurged higher');
legend('Location','southeast');
grid on;
%}
%%  custumize fitting function & plot #4
%{
cdata = responses(1,:);
Y = (responses(2,:)-nblocks);
[curve,gof] = fit(cdata',Y','a*x^b','Start',[rand(),rand()],'Lower',[0,0],'Upper',[100,100]);
plot(curve,cdata,Y,'-o');  % '-': line, 'o': dot shaped o
xlabel('\DeltaFrequency');
ylabel('Responses');
legend('Location','southeast');
grid on;
%}