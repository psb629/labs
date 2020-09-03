%   Setting default parameters
%   16. Jan . 2020 by Sungbeen Park
%%  Allocate main directory
global TM_dir
TM_dir = '/clmnlab/TM';
%%	Define global variables
global SampleRate
global freq_interval
global Freqs LowFreqPair HighFreqPair
%%  Experimental parameters
SampleRate = 11;            % frequency sample rate include a central freq.
if mod(SampleRate,2)~=1     % it accepts only odd number
    error('A SampleRate must be an odd number.');
end
l_mid = 15;    h_mid = 30;
freq_interval = 1;
%%	Frequency arrays
l_min=l_mid-freq_interval*floor(SampleRate/2); l_max=l_mid+freq_interval*floor(SampleRate/2);
l_freq=linspace(l_min,l_max,SampleRate);     % low frequency vector
h_min=h_mid-freq_interval*floor(SampleRate/2); h_max=h_mid+freq_interval*floor(SampleRate/2);
h_freq=linspace(h_min,h_max,SampleRate);    % high frequency vector
%%	Set pairs with standard freq.
LowFreqPair=zeros(SampleRate-1,2);
HighFreqPair=zeros(SampleRate-1,2);
for col1 = 1:(SampleRate-1)
    LowFreqPair(col1,1)=l_mid;   
    if l_freq(col1)<l_mid
        LowFreqPair(col1,2)=l_freq(col1);
    else
        LowFreqPair(col1,2)=l_freq(col1)+freq_interval;
    end
    HighFreqPair(col1,1)=h_mid;
    if h_freq(col1)<h_mid
        HighFreqPair(col1,2)=h_freq(col1);
    else
        HighFreqPair(col1,2)=h_freq(col1)+freq_interval;
    end
end         % Note, the 1st columns of PairOfFreq only have a centeral frequency value.
clear col1 l_freq h_freq
%%  Memorize values of frequency
Freqs=struct([]);
Freqs(1).Low=l_min; Freqs(2).Low=l_mid; Freqs(3).Low=l_max;
Freqs(1).High=h_min; Freqs(2).High=h_mid; Freqs(3).High=h_max;
clear l_min l_mid l_max h_min h_mid h_max
