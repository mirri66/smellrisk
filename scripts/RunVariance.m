% pre - running:
% 1)make sure pVAS is started up, ensure computer is on same
% LAN as pVAS computer
% 2) baseline G has to have been collected for the subj you're running. See
% baseline folder


% issues:
% check if all important data is recorded...
% scanner timing sync - check if Alex's hack works.
% check out scanner sync?
% how to sync odor delivery with TR? or should 'event' be breathing?
% ratings: 1-9 scale seems more common?
% make sure instructions include something about scents and chair and all
% that
% change number of trials to the right number

function theData = RunVariance(thePath,subNumber,subjgender,scanner)

RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock))); %seed rand



noScents = 6; % change this according to number of scents, including control (non-scented air);

% % *** scanner stuff ***
TR = 2;


% *** mini-VAS stuff ***
% minivass.class is automatically in the classpath now
%javaaddpath('C:\Documents and Settings\DNL\My Documents\Dropbox\room 530 -
%sharing\CAP\CAP\scripts'); %minivas.class must be in the java path
v = minivas(); % connect miniVAS
v.allChannelsOff(); % make sure all channels off at start of session

%enable only channels that you will use: 1 = enable, 0 = disable, 30
%channels
% v.setChannelsEnabled([ones(1,noScents) zeros(1,(30-noScents))]);
v.setChannelsEnabled([ones(1,15+noScents) zeros(1,(30-noScents-15))]); % left olfacto-arm is broken :(

cd lists
load('variance.mat');
%[y.num, y.txt]=xlsread('variance.xls');
cd ..
% task 2 -var
y.IDCol=1;
y.chosenValue = 2;
y.winCol = 3;
y.ITICol = 4;
y.ISICol=5; % ITI
y.choicePresCol=6; % time options presented
y.choiceMadeCol=7; % time choice is made
y.odorOnCol=8;
y.odorOffCol=9;
y.keyCol=10;
y.RTCol=11;
y.tallyCol = 12;
y.scentCol = 13;



s.odorOnsetCol = 1; % onset of odor
s.odorScentCol = 2;

flowrate = 10;

%graphics stuff
screenNumber = max(Screen('Screens')); % 0 = main display
% screen / coordinates
if max(Screen('Screens'))>0 %dual screen
    c.dual = get(0,'MonitorPositions');
    c.scrsz = [0,0,(c.dual(2,3)-c.dual(2,1)),(c.dual(2,4)-c.dual(2,2))];
elseif max(Screen('Screens'))==0 % one screen
    c.scrsz = get(0,'ScreenSize') ;
end

[c.Window, Rect] = Screen('OpenWindow',screenNumber, 0);
Window=c.Window;

% Set fonts
% Screen('TextFont',Window,'Times');
Screen('TextFont',Window,'Arial');
Screen('TextSize',Window,24);
Screen('FillRect', Window, 0);  % 0 = black background
c.leftcolor = [];
c.rightcolor = [];
c.textColor = 255;
c.textColor2 = [255 255 50]; % yellow for hihglighting choices

c.DIAM = c.scrsz(4)/5; % diameter of pie chart


c.vPosPie=c.scrsz(4)/2; % Y coord of midpoint of pie charts
c.hPosLPie=c.scrsz(3)/2 - c.scrsz(3)/5; % X pos of left pie
c.hPosRPie=c.scrsz(3)/2 + c.scrsz(3)/5; % X pos of right pie

c.hPosL=c.hPosLPie+c.DIAM/2-20; % to display the values
c.hPosR=c.hPosRPie+c.DIAM/2-20;

% c.instr_X = c.scrsz(3)/4; % pc
c.instr_X = c.scrsz(3)/3; % horizontal (X) coord for displaying instructions



%% variance task graphics

c.hPosL1 = c.scrsz(3)/3;
c.hPosR1 = 2*c.scrsz(3)/3;
c.vPos1=c.scrsz(4)/2;

%slider bar stuff
c.linestart=c.scrsz(3)/8;
c.lineend=(c.scrsz(3)*7)/8;
c.linelength=(c.lineend-c.linestart);

% choose rects
c.rect = [c.hPosL1-20 c.hPosR1-20;c.vPos1-10 c.vPos1-10;c.hPosL1+120 c.hPosR1+120;c.vPos1+50 c.vPos1+50]; % rows = left, top, right, bottom, each column = new rect

% cursor + keyboard control
ListenChar(2) %Ctrl-c to enable Matlab keyboard interaction.
HideCursor; % Remember to type ShowCursor or sca later


%% the study::

% Print a loading screen
DrawFormattedText(Window, 'Loading -- the experiment will begin shortly','center','center',255);
Screen('Flip',Window);


%when experiment is loaded, start the task

DrawFormattedText(Window, 'Welcome! \n\n Press ''g'' to begin the experiment.','center','center',255,100);
Screen('Flip',Window);
GetKey('g',[],[],-3);


% % hunger rating:
% hunger=hungerLikert(c,Window);

sessionTime=clock;
%
% % Instructions
% DrawFormattedText(Window, ['In this session, you will be asked to inhale various scents. For the duration of the experiment, please place your chin on the chin rest and breathe normally. ' ...
%     'You might want to adjust the height of your chair now so that you can comfortably hold this position throughout the session. \n'...
%     'When a scent is about to be delivered, you will be asked to indicate when you are ready by pressing ''g''. The word ''inhale'' will then appear and the scent will be delivered. Please breathe normally during this time. \n\n ' ...
%     'Press ''g'' to continue.'],'center','center',255,100,[],[],2);
% Screen('Flip',Window);
% GetKey('g',[],[],-3);
%

cd(thePath.main);

%% Variability task

datamat1=[];
odormat1 = []; % record odor timing and scent info
cnt= 1;

sessionTime1=clock;
clear startTime

DrawFormattedText(Window, ['In this task you will be asked to decide between two payment options. \n\n'...
    'You will be given $10.00 at the beginning of the experiment, and whatever amount you possess at the end of the task will be paid to you in full.\n\n'...
    'Press ''g'' to continue.'],'center','center',255,100,[],[],2);
Screen('Flip',Window);
GetKey('g',[],[],-3);

DrawFormattedText(Window, ['In each trial, you will chose between two options:\n\n' ...
    'Option A:  +$0.10 or -$0.10\n\n' ...
    'Option B:  +$1.00 or -$1.00\n\n'...
    'For each option, you have a 50% chance of winning money and a 50% chance of losing money.\n'...
    'Press ''g'' to continue.'],'center','center',255,100,[],[],2);
Screen('Flip',Window);
GetKey('g',[],[],-3);

DrawFormattedText(Window, ['The options will appear on either side of the screen. \n\n For the Left option, please press ''f''.\n\n' ...
    'For the Right option, please press ''j''.\n\n'...
    'If you have any questions, please ask the experimenter now. Otherwise, press ''g'' to begin the task.'],'center','center',255,100,[],[],2);
Screen('Flip',Window);
GetKey('g',[],[],-3);

% start the task

tally = 10; % starting value

noVarTrials = size(y.num,1); % length of xls file % DEBUG
%noVarTrials =3; %debug



if scanner == 1
    % scanner trigger %%%
    
    while 1
        AG1getKey('3#',S.kbNum);
        [status, startTime] = AG1startScan; % startTime corresponds to getSecs in startScan
        fprintf('Status = %d\n',status);
        if status == 0  % successful trigger otherwise try again
            break
        else
            Screen(S.Window,'DrawTexture',blank);
            message = 'Trigger failed, "3" to retry';
            DrawFormattedText(S.Window,message,'center','center',S.textColor);
            Screen(S.Window,'Flip');
        end
    end
elseif scanner == 0
    startTime = GetSecs;
end

drift = 0;

    %lead in
    Screen('TextSize',Window,40);
    
    DrawFormattedText(Window, '+','center','center',255,100);
    Screen('Flip',Window);
    WaitSecs(3*TR);
%WaitSecs(0) % debug

for n=1:noVarTrials
    
    % scentType = y.num(n,12);
    scentType = y.num{n,11};
    
    
    %black screen - ITI
    Screen('TextSize',Window,40);
    %ITI=y.num(n,3)/1000-drift; % DEBUG: 8-12??
    ITI=y.num{n,2}/1000-drift; % DEBUG: 8-12??
    
    % ITI = 0.0; %debug
    DrawFormattedText(Window, '+','center','center',255,100);
    Screen('Flip',Window);
    WaitSecs(ITI);
    
%     % prompt user to self-deliver odor % DEBUG: not subject-initiated...
%     % get ready screen - exhale inhale cues
%     DrawFormattedText(Window, 'Press ''g'' when you''re ready to inhale the next scent.','center','center',255,100);
%     Screen('Flip',Window);
%     GetKey('g',[],[],-3); % rmb to put GetKey.m in scripts folder!

Screen('TextSize',Window,40);

DrawFormattedText(Window, 'INHALE','center','center',255,100);
Screen('Flip',Window);

    Screen('TextSize',Window,40);
    
    % present odor
    [odor] = presentOdor(v,scentType,startTime, flowrate);
    fprintf('scent: %g, flowrate: %g\n', scentType, flowrate);
    
    %black screen - ISI = length of odor exposure % DEBUG : 6 seconds exposure
    ISI=1.5;
    %ISI = 0; % debug
    DrawFormattedText(Window, '+','center','center',255,100);
    Screen('Flip',Window);
    WaitSecs(ISI);
    
    
    % Choose screen
    Screen('TextSize',Window,30);
Screen('DrawText', Window, 'Choose', c.scrsz(3)/2-20, c.vPos1-100, c.textColor);
% Screen('FrameRect', windowPtr [,color] [,rect] [,penWidth]);
Screen('FrameRect', Window, [255 255 255], c.rect ,1);
Screen('Flip',Window);
WaitSecs(TR); % wait one TR
% WaitSecs(0); % debug
    
    % present risk choice
    [data, tally, testTrials]=varTrials(c, n, subNumber, startTime, tally, y, v);
    %[data, tally, testTrials]=varTrials(c, n, subNumber, startTime, tally, y);
    
    
    
    % record info for trial
    datamat1(cnt,y.IDCol)=data(y.IDCol);
    datamat1(cnt,y.chosenValue) = data(y.chosenValue);
    datamat1(cnt,y.winCol) = data(y.winCol);
    % FILL IN MORE FIELDS HERE
    datamat1(cnt,y.ITICol)=ITI;
    datamat1(cnt,y.ISICol)=ISI;
    datamat1(cnt,y.keyCol)=testTrials.key(1);
    datamat1(cnt,y.RTCol)=testTrials.RT;
    datamat1(cnt,y.choicePresCol)=data(y.choicePresCol);
    datamat1(cnt,y.choiceMadeCol)=data(y.choiceMadeCol);
    datamat1(cnt,y.odorOnCol)=odor.onset;
    datamat1(cnt,y.odorOffCol)=data(y.odorOffCol);
    datamat1(cnt,y.tallyCol)=data(y.tallyCol);
    datamat1(cnt,y.scentCol)=scentType;
    
    odormat1(cnt,s.odorOnsetCol)=odor.onset;
    odormat1(cnt,s.odorScentCol)=odor.scent;
    
    cnt = cnt+1;
    
    v.allChannelsOff();
    
    %adjusting for drift
    endTrial=GetSecs;
    drift = mod((endTrial-startTime),TR);
    fprintf('drift: %g\n', drift);
end

 Screen('TextSize',Window,24);


DrawFormattedText(Window, 'You are done with the task. Press ''g'' to continue.','center','center',255,100);
Screen('Flip',Window);
GetKey('g',[],[],-3);

%%
% Interim save for the variability task
d1.data=datamat1;
d1.odorData=odormat1;
d1.subjno=subNumber;
d1.subjgender=subjgender;
d1.sessiontime=sessionTime1;
% d1.hunger=hunger;
theData.d1 = d1;

cd(thePath.data);
savename = ['variance_' num2str(subNumber) '.mat'];
save(savename,'d1');

savename = ['vardata_' num2str(subNumber) '.mat'];
save(savename);

cd(thePath.main);


% Print a goodbye screen
DrawFormattedText(Window, 'Please let the experimenter know that you are done with this part of the session.','center',200,255); % 255=white
Screen('Flip',Window);

GetKey({},[],[],-3); % wait for a keypress to close the screen.


% Print a save confirm screen
DrawFormattedText(Window, 'Save finished. Hit any key to exit.','center',200,255); % 255=white
Screen('Flip',Window);

GetKey({},[],[],-3); % wait for a keypress to close the screen.

ListenChar(0)
sca %Closes screen, shows cursor.

% a shortcut for turning all channels off...
v.allChannelsOff();

% when you are finished, you need to disconnect from pVAS.
v.disconnect();

end


function [data, tally, testTrials]=varTrials(c, trialNo, subNumber, startTime, tally, y, v)
%function [data, tally, testTrials]=varTrials(c, trialNo, subNumber, startTime, tally ,y)
Window = c.Window;

TR=2;
data = []; % temp placeholder for this subfunction, will be transferred to datamat

data(y.IDCol)=subNumber;

%randomize which side they see $1.00 r $0.10

% leftVal = y.num(trialNo,9);
% rightVal = y.num(trialNo,10);
leftVal = y.num{trialNo,8};
rightVal = y.num{trialNo,9};

% risk pref

% record choice presentation onset time
ons_start = GetSecs;
nChoicePres = GetSecs - startTime;

% draw the values
Screen('TextSize',Window,30);
Screen('DrawText', Window, 'Choose', c.scrsz(3)/2-20, c.vPos1-100, c.textColor);
Screen('DrawText', Window, ['$' num2str(leftVal,'%#4.2f')], c.hPosL1, c.vPos1, c.textColor);
Screen('DrawText', Window, ['$' num2str(rightVal,'%#4.2f')], c.hPosR1, c.vPos1, c.textColor);
Screen('FrameRect', Window, [255 255 255], c.rect ,1);
Screen('TextSize',Window,24);
Screen('DrawText', Window, 'Press ''f'' for the option on the left, ''j'' for the option on the right.', c.instr_X ,c.vPosPie+c.DIAM+c.scrsz(3)/10, c.textColor);
Screen('Flip',Window);
% Now collect a keypress from the user.
[testTrials.key testTrials.RT] = GetKey({'f','j'},4,[],-3);


nChoiceMade = GetSecs - startTime;  %records when subj makes choice.

% record choice
if strcmp(testTrials.key,'f') && leftVal == 0.1 || strcmp(testTrials.key,'j') && rightVal == 0.1
    data(y.chosenValue)=0.1;
elseif strcmp(testTrials.key,'f') && leftVal == 1 || strcmp(testTrials.key,'j') && rightVal == 1
    data(y.chosenValue)=1;
end

% highlight choice
if strcmp(testTrials.key,'f')
    c.leftcolor = c.textColor2;
    c.rightcolor = c.textColor;
elseif strcmp(testTrials.key,'j')
    c.leftcolor = c.textColor;
    c.rightcolor = c.textColor2;
end

Screen('TextSize',Window,30);
Screen('DrawText', Window, 'Choose', c.scrsz(3)/2-20, c.vPos1-100, c.textColor);
Screen('DrawText', Window, ['$' num2str(leftVal,'%#4.2f')], c.hPosL1, c.vPos1, c.leftcolor);
Screen('DrawText', Window, ['$' num2str(rightVal,'%#4.2f')], c.hPosR1, c.vPos1, c.rightcolor);
Screen('FrameRect', Window, [255 255 255], c.rect ,1);
Screen('TextSize',Window,24);
Screen('DrawText', Window, 'Press ''f'' for the option on the left, ''j'' for the option on the right.', c.instr_X ,c.vPosPie+c.DIAM+c.scrsz(3)/10, c.textColor);
Screen('Flip',Window);
WaitSecs(4-testTrials.RT);
%WaitSecs(0) % debug

v.allChannelsOff();

%record offset of odor
ons_start = GetSecs;
nOffset = ons_start - startTime;
data(y.odorOffCol)=nOffset;


data(y.choicePresCol)=nChoicePres;
data(y.choiceMadeCol)=nChoiceMade;



% win or lose?
wincode = NaN;
winsign = '';
%win = y.txt{trialNo+1, 8};
win = y.num(trialNo,7);
if strcmp(win, 'win')
    tally = tally + data(y.chosenValue);
    wincode = 1;
    winsign = '+';
elseif strcmp(win, 'loss')
    tally = tally - data(y.chosenValue);
    wincode = -1;
    winsign = '-';
end

data(y.tallyCol) = tally;
data(y.winCol) = (wincode+1)/2; %1 if win, 0 if lose

% feedback
Screen('TextSize',Window,40);
Screen('DrawText', Window, [ winsign '$' num2str(data(y.chosenValue), '%#4.2f')], c.scrsz(3)/2 ,c.scrsz(4)/2-50, c.textColor);
Screen('DrawText', Window, [' '], c.scrsz(3)/2+40 ,c.scrsz(4)/2, c.textColor);
Screen('DrawText', Window, ['Total: $' num2str(tally, '%#4.2f')], c.scrsz(3)/2 - 20 ,c.scrsz(4)/2+50, c.textColor);
Screen('Flip',Window);
WaitSecs(TR);
%WaitSecs(0); %debug

Screen('TextSize',Window,40);
DrawFormattedText(c.Window, '+','center','center',255,100);
Screen('Flip',c.Window);

end


function [odor]=presentOdor(v,scentType, startTime, flowrate)

v.setChannel( 15 + scentType, flowrate);

%record onset of odor
ons_start = GetSecs;
nOnset = ons_start - startTime;
odor.onset=nOnset;

% use this for a short presentation of odor
WaitSecs(4.5); % in reality, scent is presented longer than this - add ISI 
%WaitSecs(0); % debug
% %for RCAP the odor is not turned off until after the trial
% v.allChannelsOff();
% %record offset of odor
% ons_start = GetSecs;
% nOffset = ons_start - startTime;
% odor.offset=nOffset;

odor.scent = scentType; % record scent


end


