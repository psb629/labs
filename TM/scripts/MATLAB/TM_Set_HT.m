%   Setting parameters for hidden target task
%   19. Jan . 2020 by Sungbeen Park
%%  Default setting
TM_Set;
global TM_dir
%%  Addpath the DisDir
addpath([TM_dir '/behav_data']);
%% Define global variables
global rad2deg deg2rad min2sec sec2min
global Tolerance
%%  Numerical constants
rad2deg = 180/pi; deg2rad = pi/180;
min2sec = 60; sec2min = 1/60;
Tolerance = 1e0;
%%  Experimental parameters
global nCells nBlocks_HT nTrials_HT
nCells = 16;        % # of cells which include targets
nBlocks_HT = nCells;
nTrials_HT = 15;
TimeOutLimit = 1.5;
WarningTime = 0.8;
show_blocks=2.0;
show_Target=2.0;
DotSize = 20;
%%	Inter-stimulus interval
% 2(x39),4(x25),6(x15),8(x9),10(x5),12(x3). mean=4.438s
%ISI_HT=[ones(39,1)*2;ones(25,1)*4;ones(15,1)*6;ones(9,1)*8;ones(5,1)*10;ones(3,1)*12];
dummy_ISI=[2;3;4;5;6];
%%  Set the ISIs (Randomly)
ISI = vertcat(Shuffle(dummy_ISI),Shuffle(dummy_ISI),Shuffle(dummy_ISI));
for iter = 1:nBlocks_HT-1
    ISI = horzcat(ISI,vertcat(Shuffle(dummy_ISI),Shuffle(dummy_ISI),Shuffle(dummy_ISI)));
end     % ISI_1(nTrials_HT,nCells)
clear dummy_ISI
%%  Time structure to record each event timing
Timing=struct([]);
for iter = 1 : (nBlocks_HT*nTrials_HT)
    Timing(iter).RedCursor=NaN; Timing(iter).Decision=NaN; Timing(iter).Vibration=NaN;
    Timing(iter).Target=NaN; Timing(iter).ISI=NaN;
end
%%  Trace of a mouse cursor
Trace=struct([]);
for iter = 1 : (nBlocks_HT*nTrials_HT)
    Trace(iter).Trace=NaN(1,3);
    Trace(iter).Reach=0;
end
function v=Shuffle(v)
	v=v(randperm(length(v)));
end