%   Setting default parameters
%   20. March . 2020 by Sungbeen Park
%%  Allocate main directory
global TM_dir
TM_dir = pwd;
%%	Define global variables
global Keys colors sizes
global FreqPairs Ns
%%  Numerical constants
KbName('UnifyKeyNames');
Keys(1).readyKey = KbName('r');
Keys(1).startKey = KbName('s');
Keys(1).pauseKey = KbName('p');
Keys(1).escKey = KbName('ESCAPE');

colors = struct([]);
colors(1).gray = [127 127 127];
colors(1).white = [255 255 255];
colors(1).black = [0 0 0];
colors(1).red = [250 128 114];
colors(1).blue = [65 105 225];
colors(1).green = [60 179 113];
colors(1).yellow = [255 255 0];
colors(1).khaki = [240 230 140];
colors(1).backgrond = colors(1).black;
colors(1).text = colors(1).white;

sizes(1).text = 75;
%%  Experimental parameters
Ns = struct([]);
Ns(1).SampleRate = 10;            % frequency sample rate except a central freq.
if mod(Ns.SampleRate,2)~=0     % it accepts only even number
    error('A SampleRate must be an odd number.');
end
l_mid = 15;    h_mid = 30;
Freq_interval = 1;
%%	Frequency arrays
mids = [l_mid, h_mid]; count = 0;
for mid = mids
    count = count + 1;
    min = mid - Freq_interval*Ns.SampleRate*0.5; max = mid + Freq_interval*Ns.SampleRate*0.5;
    pairs(:,count) = linspace(min,max,Ns.SampleRate+1);
end
central_row = round(1+Ns.SampleRate*0.5);
FreqPairs = struct([]);
FreqPairs(1).Low(:,1) = pairs(central_row,1)*ones(Ns.SampleRate,1);
FreqPairs(1).High(:,1) = pairs(central_row,2)*ones(Ns.SampleRate,1);
pairs(central_row,:) = [];
FreqPairs(1).Low(:,2) = pairs(:,1);
FreqPairs(1).High(:,2) = pairs(:,2);
%% clear useless variables
clear central_row count Freq_interval h_mid l_mid max mid mids min pairs 