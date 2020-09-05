function tf_make_sound(Freq)
%This function will make a sound whose duriation is 1 sec in given frequency.
%tf_make_sound(Freq)
timeStart=GetSecs;
A = 10.;                % amplitude
fs = 44100;             % sampling rate
dur = 1.;               % duration time
n = fs * dur;           % total # of data
t = (0:n) / fs;         % time vector(x-axis)

w = 2 * pi * Freq;      % angular frequency in radians

Y = A * sin(w*t);       % sinusoidal signal(y-axis), amplitude = A
sound(Y,fs);            % play the signal
while GetSecs-timeStart < dur
end