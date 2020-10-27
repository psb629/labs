function ppi_reg = calc_binary_reg(pid, onsTarget, TR)
% CALC_BINARY_REG : Generate a binary regressor (1, -1) for PPI analysis
% 1s correspond to TR for condition of interest
% -1s correspond to TR for condition of non-interest
% This function generates single concatenated regressors for all runs
%
% USAGE: modules =calc_binary_reg(pid, onsTarget, TR);
%
%           Inputs: pid, onsTarget, TR
%           pid: trial number for the condition of interest
%           onsTarget: onsets of all stimuli
%           TR: Number of TR for runs, should have r element (r= number of
%           runs)
%   Sep, 16, 2019
%   calc_binary_reg Written by Sungshin Kim
%

npid = setdiff([1:length(onsTarget)],pid);
tarP = onsTarget(pid);
ntarP = onsTarget(npid);

tem = [0 find(diff(tarP)<0) length(tarP)];
ntem = [0 find(diff(ntarP)<0) length(ntarP)];
tarP2 = []; ntarP2 = [];
for i=1:length(tem)-1
    tarP2 = [tarP2 round(tarP([tem(i)+1:tem(i+1)])/2)];
end
for i=1:length(ntem)-1
    ntarP2 = [ntarP2 round(ntarP([ntem(i)+1:ntem(i+1)])/2)];
end
%tem = find(diff(tarP)<0);
temp = [];ntemp = [];
for i=1:length(tem)-1
    if i==1
        temp = [temp tarP2(tem(i)+1:tem(i+1))];
    else
        temp = [temp tarP2(tem(i)+1:tem(i+1))+sum(TR(1:i-1))];
    end
end

for i=1:length(ntem)-1
    if i==1
        ntemp = [ntemp ntarP2(ntem(i)+1:ntem(i+1))];
    else
        ntemp = [ntemp ntarP2(ntem(i)+1:ntem(i+1))+sum(TR(1:i-1))];
    end
end


tridx = ismember(sort([temp ntemp]),temp);
ppi_reg(1) = 2*(temp(1)<ntemp(1))-1;

for i=2:sum(TR)
    if ppi_reg(i-1)==1
        if ~ismember(i,ntemp)
            ppi_reg(i) = 1;
        else
            ppi_reg(i) = -1;
        end
    else
        if ~ismember(i,temp)
            ppi_reg(i)= -1;
        else
            ppi_reg(i) = 1;
        end
    end
end

fprintf('Processed\n');
    
