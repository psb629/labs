%   Setting parameters for hidden target task
%   19. Jan . 2020 by Sungbeen Park
%%  Default setting
global TM_dir HiddenTarget_dir
TM_Set;
%%  Addpath the HT_dir
HiddenTarget_dir = [TM_dir '/main_HiddenTarget'];
if exist(HiddenTarget_dir,'dir')
    addpath(HiddenTarget_dir);
end
%% Colors
global colors
colors(1).start = colors.green * 0.1;
%%  Numerical constants
global rad2deg deg2rad min2sec sec2min
global Tolerance
rad2deg = 180/pi; deg2rad = pi/180;
min2sec = 60; sec2min = 1/60;
Tolerance = 1.e1;
%%  Experimental parameters
global Ns times sizes
Ns(1).cell = 16;        % # of cells which include targets
Ns(1).trial = 15;
times(1).TimeOutLimit = 1.5;
times(1).WarningTime = 0.8;
times(1).show_block=2.0;
times(1).show_Target=2.0;
sizes(1).dot = 20;
%%	Inter-stimulus interval
% 2(x39),4(x25),6(x15),8(x9),10(x5),12(x3). mean=4.438s
%ISI_HT=[ones(39,1)*2;ones(25,1)*4;ones(15,1)*6;ones(9,1)*8;ones(5,1)*10;ones(3,1)*12];
dummy_ISI=[2;3;4;5;6];
%%  Set the ISIs (Randomly)
ISI = vertcat(Shuffle(dummy_ISI),Shuffle(dummy_ISI),Shuffle(dummy_ISI));
for iter = 1:(Ns.cell-1)
    ISI = horzcat(ISI,vertcat(Shuffle(dummy_ISI),Shuffle(dummy_ISI),Shuffle(dummy_ISI)));
end     % ISI_1(nTrials_HT,nCells)
times(1).ISIs = ISI;
%%  Time structure to record each event timing
Timing=struct([]);
for iter = 1 : (Ns.cell*Ns.trial)
    Timing(iter).RedCursor=NaN; Timing(iter).Decision=NaN; Timing(iter).Vibration=NaN;
    Timing(iter).Target=NaN; Timing(iter).ISI=NaN;
end
%%  Trace of a mouse cursor
Trace=struct([]);
for iter = 1 : (Ns.cell*Ns.trial)
    Trace(iter).Trace=NaN(1,3);
    Trace(iter).Reach=0;
end
%%  Execute main task
%main_HiddenTarget_Freq;