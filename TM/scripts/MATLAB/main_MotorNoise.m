%   Hidden Target Task
%   29. Dec . 2019 by Sungbeen Park
%%	Login prompt and open file for writing data out
global TM_dir
global Keys colors Ns sizes
prompt = {'Subject ID'};
defaults = {'TM'};
Answer = inputdlg(prompt,'Motor Task',[1,30],defaults);
[SUBID] = deal(Answer{:}); % all input variables are strings

Behav_Dir = [TM_dir '/behav_data']; makeDIR(Behav_Dir);
Subj_Behav_Dir = [Behav_Dir '/' SUBID]; makeDIR(Subj_Behav_Dir);
SUBID = char(SUBID); FreqType = SUBID(3);
makeDIR(Subj_Behav_Dir);
behav_data_Motor = [Subj_Behav_Dir '/behav_data_Motor.dat']; behav_data_Motor = askFILE(behav_data_Motor);
%%	Experimental instructions
screenNum = max(Screen('Screens'));     %%% set screen
if screenNum > 0
    Screen('Preference','SkipSyncTests',1);	%%% To skip the sync error
    [specwin, specscreen] = Screen('OpenWindow',1);
    clear screen
end
Screen('Preference','SkipSyncTests',1);	% To skip the sync error
[mainwin,screenrect] = Screen('OpenWindow',screenNum);
Screen('FillRect',mainwin,colors.black);         % the experiment doesn't proceed without this line
Screen('Flip',mainwin);
Screen('TextSize',mainwin,sizes.text);
%ShowCursor(5);  % 5 means a cross-hair
%%  System variables (Randomly)
Origin = [screenrect(1),screenrect(2)];     % a corrdinate of the O
Origin_prime = [screenrect(3)/2,screenrect(4)-2];     % a corrdinate of O'
sizes(1).radius = Origin_prime(1)-sizes.dot/2;       % a radius of targets' distribution from O' in pixel
if sizes.radius > Origin_prime(2)
    error('The sizes.radius is too long. Please make it shorter.');
end
Theta_Max = 2*asin((screenrect(3))/(2*max(sizes.radius,screenrect(3)/2)));	% Maximum theta in radian
Theta_Max = min(Theta_Max,pi);  % Theta_max is smaller than or equal to 'pi' radian
%%	Set corrdinates of Targets
Theta = zeros(Ns.cell,1);
Cell = zeros(Ns.cell,2);    % initializing corrdinates of center of cells
for i = 1 : Ns.cell
    Theta(i) = Theta_Max*(i-0.5)/Ns.cell;
    Cell(i,1) = sizes.radius*cos(Theta(i))+Origin_prime(1);
    Cell(i,2) = -sizes.radius*sin(Theta(i))+Origin_prime(2);
end
CircleRect = [(Origin_prime - (sizes.radius+0.5*sizes.dot)) (Origin_prime + (sizes.radius+0.5*sizes.dot))]; % [xi yi xf yf]
arcStart = -90;   % 0 = 12 o'clock, + = clockwise, - = counter-clockwise
arcAngle = 180;
%%  Main loop
ISI = 1.5;
out_file = fopen(behav_data_Motor,'w'); % open a file for writing data out
HideCursor;     % in order to the subject would concentrate the tactile feedback, the cursor will be disappear.
tic;     % to count the sequence of each session, and to check the running time.
for trial = 1 : (Ns.trial*Ns.cell)
    
    tmod = mod(trial,Ns.cell) + 1;
    if trial == 1
        DrawFormattedText(mainwin,'Waiting to start','center','center',colors.text);
        Screen('Flip', mainwin);
        inputKeys(Keys.readyKey,Keys.startKey);
    end
    if mod(trial,Ns.cell)==1  % when trial is a multiple of Ns.cell
        RanOrder=Shuffle(1:Ns.cell);
    end
    target = Theta(RanOrder(tmod))*rad2deg;

    timeStart=GetSecs;      %%% tic #1-1
    SessionTimeStart=timeStart;	%% record the start time of each session
    while GetSecs-timeStart < 0.5; [~,~,~] = GetMouse; end
    colors(1).arc = colors.green * 0.2;
    Screen('FrameArc',mainwin,colors.arc,CircleRect,arcStart,arcAngle,sizes.dot);
    Screen('DrawDots',mainwin,Origin_prime,sizes.dot,colors.start,Origin,0);
    Screen('Flip',mainwin);
    while GetSecs-timeStart < 1.5; [~,~,~] = GetMouse; end %%% toc #1-1
    
    timeStart=GetSecs;      %%% tic #2
    fprintf('%d\t%.3f\t',trial,target);
    %%% initializing
    SetMouse(Origin_prime(1),Origin_prime(2),screenNum);
    Screen('FrameArc',mainwin,colors.arc,CircleRect,arcStart,arcAngle,sizes.dot);
    Screen('DrawDots',mainwin,[Cell(RanOrder(tmod),1),Cell(RanOrder(tmod),2)],sizes.dot,colors.khaki,Origin,1);
    Screen('DrawDots',mainwin,Origin_prime,sizes.dot,colors.start,Origin,0);
    Screen('DrawDots',mainwin,Origin_prime,sizes.dot,colors.red,Origin,1);
    Screen('Flip',mainwin);
    SetMouse(Origin_prime(1),Origin_prime(2),screenNum);
    Time_LearnTrial=0; istouched=0; didDecide=0; isGoingOut=1; isWarned=0;
    Traj=[0,0]; theAng=NaN; vec_e=[Origin_prime(1),Origin_prime(2)];
    while (Time_LearnTrial < times.TimeOutLimit)
        [mouseCoord(1),mouseCoord(2),buttons] = GetMouse(screenNum);
        %%% distance between an O' and a current position of a mouse
        if buttons(1)   %%% the mouse1 is being clicked
            if ~istouched
                vec_r0 = mouseCoord;
                Screen('FrameArc',mainwin,colors.arc,CircleRect,arcStart,arcAngle,sizes.dot); % green or khaki arc
                Screen('DrawDots',mainwin,[Cell(RanOrder(tmod),1),Cell(RanOrder(tmod),2)],sizes.dot,colors.khaki,Origin,1);
                Screen('DrawDots',mainwin,Origin_prime,sizes.dot,colors.start,Origin,0);
                Screen('Flip',mainwin);
                istouched = 1;
            end
            vec_r = mouseCoord;
            vec_dr = vec_r - vec_r0;
            vec_dr = tf_adjust_TabletVector(vec_dr,[16,9]);
            vec_a = Origin_prime + vec_dr;
            %%% trace the cursor
            if ~isequal(Traj(end,:),vec_dr)
                Traj=[Traj;vec_dr];
            end
            theR = norm(vec_dr);
            if (sizes.radius - theR <= Tolerance)	%%% is there the cursor within the arc?
                didDecide=1;
                Trace(trial).Reach=didDecide;
                theAng=tf_measure_ArcAngle(vec_a,[Cell(RanOrder(tmod),1),...
                    Cell(RanOrder(tmod),2)],Origin_prime)*rad2deg; % an angle between vec_target and vec_estimation in degree
                vec_r_p = [vec_a(1),min(vec_a(2),Origin_prime(2))] - Origin_prime;
                vec_e_p = sizes.radius * vec_r_p / norm(vec_r_p);
                vec_e = vec_e_p + Origin_prime;     % estimating postion
                break;
            end
        end
        %%% a color of the arc will be changed in the warning time
        if (~isWarned) && (Time_LearnTrial >= times.WarningTime)
            colors(1).arc=colors.khaki*0.2;
            Screen('FrameArc',mainwin,colors.arc,CircleRect,arcStart,arcAngle,sizes.dot); % green or khaki arc
            Screen('DrawDots',mainwin,[Cell(RanOrder(tmod),1),Cell(RanOrder(tmod),2)],sizes.dot,colors.khaki,Origin,1);
            if ~istouched
                Screen('DrawDots',mainwin,Origin_prime,sizes.dot,colors.red,Origin,1);
            end
            Screen('DrawDots',mainwin,Origin_prime,sizes.dot,colors.start,Origin,0);
            Screen('Flip',mainwin);
            isWarned=1;
        end
        Time_LearnTrial = GetSecs - timeStart;
    end
    while ((GetSecs-timeStart) < times.TimeOutLimit); [~,~,~] = GetMouse; end 	%%% toc #2
    
    timeStart=GetSecs;      %%% tic #3
    Screen('FrameArc',mainwin,colors.arc,CircleRect,arcStart,arcAngle,sizes.dot);
    Screen('DrawDots',mainwin,[Cell(RanOrder(tmod),1),Cell(RanOrder(tmod),2)],sizes.dot,colors.khaki,Origin,1);
    Screen('DrawDots',mainwin,Origin_prime,sizes.dot,colors.start,Origin,0);
    if didDecide
        Screen('DrawDots',mainwin,vec_e,sizes.dot,colors.red,Origin,1);
    end
    Screen('Flip',mainwin);
    estimateAng=tf_measure_ArcAngle([screenrect(3),Origin_prime(2)],vec_e,...
        Origin_prime)*rad2deg;    % estimating point's angle position.
    fprintf('%.3f\n',estimateAng);
    % fprintf data
    fprintf(out_file,'%.3f\t%d\t%.3f\t%.3f\t%.3f\t%.3f\n',target,trial,...
        estimateAng,Time_LearnTrial,theAng,ISI);
    Trace(trial).Trace=Traj;
    Trace(trial).Trace(:,3)=sizes.radius-vecnorm(Traj,2,2);
    while ((GetSecs-timeStart) < ISI); [~,~,~] = GetMouse; end         %%% toc #3. generate feedback for 1s
    
end
toc;
%% finish the experiment
fclose(out_file);
save([Subj_Behav_Dir '/behav_data_Motor_Trace.mat'],'Trace');
DrawFormattedText(mainwin,'Processing...\nPlease wait for a while.','center','center',colors.text);
Screen(mainwin, 'Flip');
while 1     % give me 'r'
    [~,~,~] = GetMouse;
	[keyIsDown,~,keyCode] = KbCheck;
    if keyIsDown
        if keyCode(Keys.readyKey)
            break
        end
        keyIsDown=0; keyCode=0;
    end
end
DrawFormattedText(mainwin,'Experiment is finished','center','center',colors.text);
Screen(mainwin, 'Flip');
while 1     % give me 'esckey'
    [~,~,~] = GetMouse;
	[keyIsDown,~,keyCode] = KbCheck;
    if keyIsDown
        if keyCode(Keys.escKey)
            break
        end
        keyIsDown=0; keyCode=0;
    end
end
clear Screen;
%%  Internal functions
function makeDIR(address)
if ~exist(address,'dir') % check the existance of log time directory of the subject
    mkdir(address);
end
end

function inputKeys(Key1,Key2)
while 1
    [~,~,~] = GetMouse;
    [keyIsDown,~,keyCode] = KbCheck;
    if keyIsDown
        if keyCode(Key1)
            break
        end
        keyIsDown=0; keyCode=0;
    end
end
while 1 % give me 's'
    [~,~,~] = GetMouse;
    [keyIsDown,~,keyCode] = KbCheck;
    if keyIsDown
        if keyCode(Key2)
            break
        end
        keyIsDown=0; keyCode=0;
    end
end
end