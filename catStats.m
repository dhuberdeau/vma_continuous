function theData = catStats

% Screen('Preference','SkipSyncTests',1);

rand('state', sum(100*clock)); %reset random number generator

%path loader
pwd
thePath.start = pwd;
[pathstr,curr_dir,ext] = fileparts(pwd);
if ~strcmp(curr_dir,'catStats')
    error(['You must start the experiment from the catStats directory. Go there and try again.\n']);
else
    thePath.script = fullfile(thePath.start, 'scripts');
    thePath.data = fullfile(thePath.start, 'data');
    thePath.backup = fullfile(thePath.data, 'backup');
    thePath.list = fullfile(thePath.start, 'lists');
    thePath.stim = fullfile(thePath.start,'stims/resized');

    % add more dirs above

    % Add relevant paths for this experiment
    names = fieldnames(thePath);
    for f = 1:length(names)
        eval(['addpath(thePath.' names{f} ')']);
        fprintf(['added ' names{f} '\n']);
    end
    
    cd(thePath.start);
end

% Load practice list
% cd(thePath.script);
% load('PracticeList_pv2.mat'); %contains structure theList

%get identifier info
sNum = input('Enter subject number: ');
fmri = input('fMRI? '); %0 - no, 1 - yes

listName=['sub' num2str(sNum) 'list.mat'];

% Load subject list
cd(thePath.list);
load(listName); %contains structure theList

%define the TR duration
TRlength = 1.5;

% Screen commands
S.boxNum = 1;

if fmri == 0
    S.screenNumber = 1;
    DEVICENAME = 'Apple Inc. Magic Keyboard';
elseif fmri == 1
    S.screenNumber = 1;
    DEVICENAME = 'Current Designs, Inc. 932';
end
        
[index devName] = GetKeyboardIndices;
for device = 1:length(index)
    if strcmp(devName(device),DEVICENAME)
        S.kbNum = index(device);
    end
end

[S.Window, S.myRect] = Screen(S.screenNumber, 'OpenWindow');
%make it a square to mimic testing room computers sitch
% [S.Window, S.myRect] = Screen(S.screenNumber, 'OpenWindow',[],[0 0 900 900]);
S.white = WhiteIndex(S.Window); % pixel value for white
black = BlackIndex(S.Window); % pixel value for black
lightGray = S.white * .6;
S.screenColor = lightGray; 
S.textColor = black;
Screen('TextSize', S.Window, 24);
S.on = 1;  % Screen now on
Screen(S.Window, 'FillRect', lightGray);
S.cuetextColor=[255 0 0];

%get center and box points
S.xcenter = S.myRect(3)/2;
S.ycenter = S.myRect(4)/2;
S.blankRect = [S.myRect(3)/4 S.myRect(4)/4 S.myRect(3)*3/4 S.myRect(4)*3/4];

theData.blank=[];

%suppress keyboard inputs
ListenChar(2);

% first run the presentation phases - pre, then learning, then post
for block = 1:5
    theData = presentation_script_fmri(thePath,theList,S,theData,sNum,block,fmri,TRlength);
    
    %if it's between blocks 1 & 2, run the math distractor task
    if block == 1
        theData = mathPresentation(thePath,theList,S,theData,sNum);
    end
    
end

%and then run the recognition test
theData = recognition_test(thePath,theList,S,theData,sNum);

%save out the data
cd(thePath.data);
save(['catStats.sub' num2str(sNum) '.mat'], 'theData');
cd(thePath.start);

% no longer suppress keypresses
ListenChar(1);

DrawFormattedText(S.Window,'You are done with the experiment!','center','center',S.textColor);
Screen(S.Window,'Flip');

%wait until a g comes in before closing the screen
getKey('g');


%all done!      
Screen('CloseAll'); clear all

end
