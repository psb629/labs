tdfread('~/Desktop/GA/behavior_data/aspect_ratio/main_task/AL_maintask_all_averaged_new-idx2.tsv');
practice = [1:24,49:192];
unpractice = [24:48,193:216];
unpractice = [25:48,193:216];
persubj=length(practice)+length(unpractice);
N = 30;
temp = zeros(N,length(practice));
for i = 1:N; temp(i,:) = AR(practice+persubj*(i-1))'; end
result = mean(temp,1);
SE = std(temp,1)/sqrt(N);
errorbar(1:length(practice),result,SE);
xlim([0,length(practice)]);