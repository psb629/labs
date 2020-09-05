%%
KbName('UnifyKeyNames');
readyKey = KbName('r'); startKey = KbName('s'); pauseKey = KbName('p');
leftKey = KbName('LeftArrow'); rightKey = KbName('RightArrow');
spaceKey = KbName('space'); escKey = KbName('ESCAPE');
%%
ratioX2Y = 29.656/21;   % movement ratio X : Y = 29.656/21 : 16/16
%%
screenNum = max(Screen('Screens'));
before_button = 0;
PP = 600*ones(1,4);
while 1
    clc;
    [P(1),P(2),buttons] = GetMouse(screenNum); %%% buttons = [left, wheel, right]
    if buttons(1)
        if P(1) < PP(1)
            PP(1) = P(1);
        elseif P(1) > PP(2)
            PP(2) = P(1);
        elseif P(2) < PP(3)
            PP(3) = P(2);
        elseif P(2) > PP(4)
            PP(4) = P(2);
        end
    end
	[keyIsDown,~,keyCode] = KbCheck;
    if keyIsDown
        if keyCode(escKey)
            break
        end
        keyIsDown=0; keyCode=0;
    end
    if (buttons(1) - before_button)	%%% is the button clicked now?
        vec_r0(1) = P(1); vec_r0(2) = P(2);
    elseif buttons(1)               %%% is clicking
        vec_r(1) = P(1); vec_r(2) = P(2);
        P(3) = norm(vec_r-vec_r0);
    end
    %disp(PP);
    %P = tf_adjust_TabletVector(P,[16,9]);
    disp(P);
    before_button = buttons(1);
    WaitSecs(0.0167);   %%% 60 fps
end