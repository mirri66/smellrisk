% random trial payment outcome generator
% This script takes one trial from the (baseline survey + in-lab survey)
% and draws a random trial to count for real. Then the outcome of that
% choice is computed.

function [payout, varPayout, skewPayout] = runOutcomeGen(subjNo)

RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));

%% CHANGE THESE
IDCol=1;
choseRiskCol=2; % CHANGE
certCol=3;
riskCol=4;
probCol=5;

cd ..
cd data 
baselinefile=['cert_baseline_' num2str(subjNo) '.mat']; 
basenum=load(baselinefile);


inLabFile=['cert_' num2str(subjNo) '.mat'];

if exist(inLabFile) == 0
fprintf('Did not participate in certainty task..?');
array = basenum.d.data{1}(:,1:5);
elseif exist(inLabFile) >0
r=load(inLabFile);
array = cat(1, basenum.d.data{1}(:,1:5),r.d.data(:,1:5));
end


randTrial=randi(length(array));

choice = array(randTrial,choseRiskCol);

if choice ==1 % if subject picked risky choice for this trial
    
    prob = array(randTrial, probCol);
    win = randsample('01',1,true,[(1-prob), prob]);
    if win=='1';
        payout = array(randTrial,riskCol);
    elseif win =='0'
        payout = 0;
    end
elseif choice ==0 % if subject picked certain choice for this trial
    payout = array(randTrial,certCol);    
end

%% for variance task


varFile=['variance_' num2str(subjNo) '.mat'];
load(varFile);

varPayout = d1.data(length(d1.data),12);

%% skewness

skewFile = [num2str(subjNo) '_skewout.mat'];

if exist(skewFile) == 0
    fprintf('Did not participate in contskew task..?');
    fprintf('Setting contskew outcome to 0 for now.');
    skewPayout = 0;
else
    sfile = load(skewFile);
    skewPayout = sfile.finaloutcome;
end

