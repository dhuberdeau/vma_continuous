%presentation script for the fmri version: present images of subcategories
%with "manmade object" cover task

% changes from previous catstats versions:
% - get rid of math distractor task,
% - allow for multiple blocks (the pre and post scans too)
% - add jittering

function theData = presentation_script_fmri(thePath,theList,S,theData,sNum,block,fmri,TRlength)
% block: 1 = pre (random order); 2 = presentation (with stats); 3 = post
% (random order)

dbstop if error

%STUDY
rand('state', sum(100*clock));
%timing variables
studyTime = 1; %1s stim appears

picList = theList.seqIms(block,:);
itiTime = theList.ITIs(block,:);
trigNs = nan(1,length(itiTime));

trigNs(itiTime == 2) = 2;
trigNs(itiTime == 3.5) = 3;
trigNs(itiTime == 5) = 4;

listLength = length(picList);
% listLength = 5;

%initialize all the response variables
%randomize the response mappings for each subject 
if strcmp(theList.respCode,'yes_j_no_k')
    scenePrompt = sprintf('Is there manmade object? \n\n Yes (index) or No (middle)?');
    theData.responseCode = 'yes_j_no_k';
    scenePrompt1 = 'Yes (index) / No (middle)';
else
    scenePrompt = sprintf('Is there manmade object? \n\n No (index) or Yes (middle)?');
    theData.responseCode = 'no_j_yes_k';
    scenePrompt1 = 'No (index) / Yes (middle)';
end

fprintf(scenePrompt);

respSet = [11 12];
respSet_key = ['1' '2' 'n'];

trigSet = [15];
trigSet_key = ['5'];


% respSet = [45 46];
% respSet_key = ['j','k'];

%set up the practice
if block == 1
    stimOrder = {'prac1.jpg','prac6.jpg','prac4.jpg','prac2.jpg','prac5.jpg','prac3.jpg'};
    cd(thePath.stim)
    for p = 1:6
        picname = stimOrder{p};
        [picLoad, map, alpha] = imread(picname);
        [heightP(p) widthP(p) crapP(p)] = size(picLoad);
        picPtrsP(p) = Screen('MakeTexture',S.Window,picLoad);
        clear picLoad;
    end

    cd(thePath.start);

    %draw the get ready screen
    message = scenePrompt;
    DrawFormattedText(S.Window,message,'center','center',S.textColor);
    Screen(S.Window,'Flip');

    %get cursor out of the way
    SetMouse(0,S.myRect(4));
    
    fprintf('\n Practice trials loaded. Press g to begin \n')

    %Start practice phase
    getKey('g',S.kbNum); 
    

    %fixation
    DrawFormattedText(S.Window,'+','center','center',S.textColor);
    Screen(S.Window,'Flip');
    WaitSecs(itiTime(p)); %just use the first 6 itis from block 1

    %display the images with the prompt
    for p = 1:6
         destRect = [S.xcenter-widthP(p)/2 S.ycenter-heightP(p)/2 S.xcenter+widthP(p)/2 S.ycenter+heightP(p)/2];
         Screen('DrawTexture',S.Window,picPtrsP(p),[],destRect);

         %also present the prompt until they respond
         DrawFormattedText(S.Window,scenePrompt1,'center',S.ycenter-heightP(p)*5/8,S.textColor);


        %flip
        t = Screen(S.Window,'Flip');

        while GetSecs - t < studyTime
                [keyIsDown, secs, keyCode] = KbCheck();

                keyPressed = find(keyCode);

                if keyIsDown == 1 && ismember(keyPressed(1),respSet) %keyPressed(1): only take first keypress; in case they press two buttons at the same time
                    respTime = secs;
                    keyInd = find(respSet==keyPressed(1));
                    destRect = [S.xcenter-widthP(p)/2 S.ycenter-heightP(p)/2 S.xcenter+widthP(p)/2 S.ycenter+heightP(p)/2];
                    Screen('DrawTexture',S.Window,picPtrsP(p),[],destRect);
                    Screen(S.Window,'Flip');
                    WaitSecs(studyTime - respTime);
                end


        end

        clear respTime;

        %iti fixation
        DrawFormattedText(S.Window,'+','center','center',S.textColor);
        Screen(S.Window,'Flip');
        WaitSecs(itiTime(p+1));
    end
end

%now get the actual experiment started
%load scene stims
cd(thePath.stim)

%load in the block's trial-unique images that are going to be presented
for p = 1:listLength
    
    %display 'loading'
    message = sprintf('Loading Images \n\n  %s %%  \n\nPlease wait.',num2str(round(p/(listLength)*100)));
    DrawFormattedText(S.Window,message,'center','center',S.textColor);
    Screen(S.Window,'Flip');
    
    picname = picList{p};
    [picLoad, map, alpha] = imread(picname);
    [height(p) width(p) crap(p)] = size(picLoad);
    picPtrs(p) = Screen('MakeTexture',S.Window,picLoad);
    clear picLoad;
    
end 


cd(thePath.start);

%draw the get ready screen
message = scenePrompt;
DrawFormattedText(S.Window,message,'center','center',S.textColor);
Screen(S.Window,'Flip');

fprintf('\n Images loaded. Press g before turning the scanner on!\n')


%get cursor out of the way
SetMouse(0,S.myRect(4));

%Start study phase
getKey('g',S.kbNum); %first wait for a g-- that will help in case we need to calibrate headphones between runs (which will send triggers)
fprintf('g registered. Waiting for scanner to turn on \n');
getKey('5',S.kbNum); %wait for first trigger to come in before starting -- this is the 0th trigger
theData.startTime(block,:) = clock;
expStart = tic;

KbQueueCreate(S.kbNum);
KbQueueStart(S.kbNum);

burnInCount = 0; 

%fixation
DrawFormattedText(S.Window,'+','center','center',S.textColor);
Screen(S.Window,'Flip');

while burnInCount < 5
    [keyIsDown,keyCode] = KbQueueCheck(S.kbNum);
     keyPressed = find(keyCode);
        

        if keyIsDown == 1 && ismember(keyPressed,trigSet)
            burnInCount = burnInCount + 1;
        end
    
     clear keyIsDown; clear keyCode; clear keyPressed;
end

fprintf('Burn in time complete. Starting experiment. \n')
    

for Trial = 1:listLength
    
    trigCount = 0;
    
    %present the scene
     destRect = [S.xcenter-width(Trial)/2 S.ycenter-height(Trial)/2 S.xcenter+width(Trial)/2 S.ycenter+height(Trial)/2];
     Screen('DrawTexture',S.Window,picPtrs(Trial),[],destRect);
     
    %flip
    t = Screen(S.Window,'Flip');
    imstart = tic;
    theData.relImOn(block,Trial) = toc(expStart);
    theData.relImOn_trig(block,Trial) = round(theData.relImOn(block,Trial)/TRlength);
    
    % wait for response
    while GetSecs - t < studyTime
            [keyIsDown,keyCode] = KbQueueCheck(S.kbNum);


                keyPressed = find(keyCode);
                
                if ~exist('respTime')
                    if keyIsDown == 1 && ismember(keyPressed,respSet) 
                    respTime = keyCode(keyPressed(1))-t;
                    keyInd = find(respSet==keyPressed);
                    
                    % if they press both at the same time, just make it a
                    % nan
                    if length(keyInd) > 1
                        keyInd = 3;
                    end
                    
                    destRect = [S.xcenter-width(Trial)/2 S.ycenter-height(Trial)/2 S.xcenter+width(Trial)/2 S.ycenter+height(Trial)/2];
                    Screen('DrawTexture',S.Window,picPtrs(Trial),[],destRect);
                    Screen(S.Window,'Flip');
                    WaitSecs(studyTime - keyCode(keyPressed(1)));
                    end
                end

    end
    
    clear keyIsDown; clear keyCode; clear keyPressed;
    
    theData.imPresTime(block,Trial) = toc(imstart);
    
     DrawFormattedText(S.Window,'+','center','center',S.textColor);
     Screen(S.Window,'Flip');
     itiStart = tic;
    
    while trigCount < trigNs(Trial)
        
        
        [keyIsDown,keyCode] = KbQueueCheck(S.kbNum);
        keyPressed = find(keyCode);
        

        if keyIsDown == 1
            if ismember(keyPressed,trigSet)
                trigCount = trigCount + 1;
            end
            
            if ~exist('respTime2') && ismember(keyPressed,respSet)
                respTime2 = keyCode(keyPressed(1))-t;
                keyInd2 = find(respSet == keyPressed);
                
                if length(keyInd2) > 1
                    keyInd2 = 3;
                end
            end
        end
        
        clear keyIsDown; clear keyCode; clear keyPressed;
    
        
    end
    theData.itiTime(block,Trial) = toc(itiStart);
    
    if exist('respTime') %now check again to save out resp and RT
            theData.judgmentResp(block,Trial) = (respSet_key(keyInd));
            theData.judgmentRespRT(block,Trial) = respTime;
    elseif exist('respTime2')
            theData.judgmentResp(block,Trial) = (respSet_key(keyInd2));
            theData.judgmentRespRT(block,Trial) = respTime2;
    else
            theData.judgmentResp(block,Trial) = 'n';
            theData.judgmentRespRT(block,Trial) = nan;
    end
    
             
    clear respTime;
    clear respTime2;
    
    %print out the resp and RT on every trial so we can see what's
    %happening
    [str2double(theData.judgmentResp(block,Trial)) theData.judgmentRespRT(block,Trial)]
    

        %save out after every trial - in backup
        saveName = ['catStats.sub' num2str(sNum) '_block' num2str(block)];
        cd(thePath.backup);
        matname = [saveName '_' date '.mat'];
        cmd = ['save ' matname];
        eval(cmd);
        
        cd(thePath.start);

end

fprintf('Experiment ended. Waiting 10 TRs now for burnout \n')

%fixation
DrawFormattedText(S.Window,'+','center','center',S.textColor);
Screen(S.Window,'Flip');
%burn out time to capture representation of last item
burnOutCount = 0;
while burnOutCount < 10
    [keyIsDown,keyCode] = KbQueueCheck(S.kbNum);
     keyPressed = find(keyCode);
        

        if keyIsDown == 1 && ismember(keyPressed,trigSet)
            burnOutCount = burnOutCount + 1;
        end
    
     clear keyIsDown; clear keyCode; clear keyPressed;
end

%End study phase
theData.endTime(block,:) = clock;

theData.totTrigN(block) = theData.relImOn_trig(block,listLength)+burnOutCount;

fprintf(['\n Run completed. Total number of triggers:', num2str(theData.totTrigN(block))]);

message = sprintf(['Done with Part ' num2str(block) '!']);

DrawFormattedText(S.Window,message,'center','center',S.textColor);
Screen(S.Window,'Flip');
WaitSecs(10);

end

