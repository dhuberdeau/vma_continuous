function varargout = main_experiment(varargin)
Screen('Preference', 'SkipSyncTests', 1);

%% specify whether to use tracker or just the computer mouse:
USE_TRACKER = 0;

%% Specify trial list
% ultimately replace this section with code to load in a separately
% prepared trial table file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA CAPTURE
AssertOpenGL;
%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA CAPTURE

% screen_dims = [1600, 900];
if USE_TRACKER
    screen_dims = [1920, 1080];
else
    screen_dims = [1920, 1080]./2;
end
TARG_LEN = min(screen_dims)*.4;
home_position = screen_dims/2;

% targ_angles = 15+(0:60:300);
targ_angles = [0:90:300, 45:90:359];
targ_coords_base = TARG_LEN*[cosd(targ_angles)', sind(targ_angles)'] + home_position;

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA CAPTURE

try
    if nargin > 0
        sub_ID = varargin{1};
    else
        rand_id = num2str(round(now*100000000));
        sub_ID = ['sub_', rand_id];
    end
catch
    rand_id = num2str(round(now*100000000));
    sub_ID = ['sub_', rand_id];
end

if USE_TRACKER
    res1 = screen_dims(1);
    res2 = screen_dims(2);
    screen_dim1 = screen_dims(1);
    screen_dim2 = screen_dims(2);
    DISC_SIZE = 40;
else
    res1 = screen_dims(1);
    res2 = screen_dims(2);
    screen_dim1 = res1;
    screen_dim2 = res2;
end

[trial_target_numbers,...
    trial_home_numbers,...
    trial_type,...
    prescribed_PT,...
    trial_stimA_numbers,...
    reward] = ...
    generate_trial_table_vReward(sub_ID); %for E5v1, remove the *_v2 designator
if USE_TRACKER
    load('camera_params');
    load('mm_per_pix');
    load('camera_angle_calibration.mat');
    
    % angle_error = angle_error;
    c_rr = cosd(angle_error);
    s_rr = sind(angle_error);
    ROT_MAT = [c_rr s_rr; -s_rr c_rr];
end
% otherwise, don't load those things


trial_target_numbers_MASTER = trial_target_numbers;
trial_home_numbers_MASTER = trial_home_numbers;
trial_type_MASTER = trial_type; 
prescribed_PT_MASTER = prescribed_PT;
trial_stimA_numbers_MASTER = trial_stimA_numbers;
reward_MASTER = reward;


if USE_TRACKER
    ind1 = repmat((1:res2)', 1, res1);
    ind2 = repmat((1:res1), res2, 1);

    ind1_d = repmat((1:DISC_SIZE:res2)', 1, res1/DISC_SIZE);
    ind2_d = repmat((1:DISC_SIZE:res1), res2/DISC_SIZE, 1);
    SUBWIN_SIZE = 75;
    ind1 = repmat((1:res2)', 1, res1);
    ind2 = repmat((1:res1), res2, 1);

    RMIN = 0;
    RMAX = .025;
    
end

pre_alloc_samps = 36000; %enough for 10 minutes blocks
pre_alloc_trial = 15*60; %enough for 15 second trials
x = nan(1, pre_alloc_samps);
y = nan(1, pre_alloc_samps);
tim = nan(1, pre_alloc_samps); %pre-allocate space for 10-min. of 60-hz recording.


delays = nan(5,pre_alloc_samps);
%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA CAPTUREstate_elapsed_time

%%

im_list = cell(1,4);
im_list{1}= imread('afasa1.jpg');
im_list{2}= imread('afasa2.jpg');
im_list{3}= imread('afasa3.jpg');
im_list{4}= imread('afasa4.jpg');

im_list_A = cell(1, 4);
im_list_A{1} = imread('afasa5.jpg');
im_list_A{2} = imread('afasa6.jpg');
im_list_A{3} = imread('afasa7.jpg');
im_list_A{4} = imread('afasa8.jpg');
im_list_A{5} = imread('afasa9.jpg');
im_list_A{6} = imread('afasa10.jpg');
im_list_A{7} = imread('afasa11.jpg');
im_list_A{8} = imread('afasa12.jpg');

% CUE_TIME = .250; %sec
STIM_A_TIME_DUR = .25; %sec
STIM_B_TIME_DUR = 0;%STIM_A_TIME_DUR;
STIM_ISI_DUR = 0; %this should ultimately get set per trial by exp. params.
STIM_A_ONSET_TIME = 1.9;
% WT_TIME = 2; %this should ultimately get set per trial by exp. params.
RET_TIME = 2; %sec
TR_TIME = 1.1; %sec 
MOV_TIME = 1.9; % (1.1 for targ disp, 1.9 for movement)
MOV_LIMIT_TIME = .75; %time limit from release of home key to press of another key
TR_TOLERANCE = .15;
FB_TIME = .75;
ITI_TIME = 2; %inter-trial interval time
% TEXT_LOC = [600 525];
TEXT_LOC = home_position;
TEXT_SIZE = 40;
SCREEN_COORD_X = screen_dims(1);
SCREEN_COORD_Y = screen_dims(2);
VIA_PT_TH = 25;
SCORE_LOC = [1800 40];

InitializePsychSound
pahandle = PsychPortAudio('Open');

Ts = 1/44100;
sound_dur = .1;
tone_freq1 = 1000;
tone_freq2 = 1700;
time = Ts:Ts:.1;
% tone_signal1 = .1*sin(tone_freq1*time);
% sound_reward = tone_signal1;
sound_reward_ = audioread('coin_flip3.mov');
sound_reward_ = sound_reward_';
tone_signal2 = .1*sin(tone_freq2*time);
sound_neurtral_ = tone_signal2;
sound_neurtral_ = repmat(sound_neurtral_, 2, 1);

% sound_data = [tone_signal1, zeros(1, round(.4/Ts)), tone_signal1, zeros(1, round(.4/Ts)), tone_signal2];
% sound_data2 = repmat(sound_data, 2, 1);
% PsychPortAudio('FillBuffer', pahandle, sound_data2);
% sound_reward_ = repmat(sound_reward, 2, 1);
% sound_neurtral_ = repmat(sound_neutral, 2, 1);

cursor_color = [0 0 0]';
cursor_dims = [-10 -10 10 10]'; %box dimensions defining circle around center
target_circle_dims = [-TARG_LEN, -TARG_LEN, TARG_LEN, TARG_LEN];
target_color = [1 53 53]';
target_dims = [-10 -10 10 10]';
bubble_start_diam = 2;
bubble_end_diam = TARG_LEN;
bubble_expand_rate = 500;

%% full session - ramped pPT
SUB_NUM_ = sub_ID;
%%
% [trial_target_numbers_MASTER, trial_type_MASTER, prescribed_PT_MASTER] = generate_trial_table_E1retention_v5(SUB_NUM_);

screens=Screen('Screens');
screenNumber=min(screens);
if USE_TRACKER
    [win, rect] = Screen('OpenWindow', screenNumber);%, [], [0 0 res1 res2]);
else
    [win, rect] = Screen('OpenWindow', screenNumber, [], [0 0 res1 res2]);
end

for block_num = [1] %[9 7] %[9, 7]%[9,7]  % no cues blocks: [1,2,9], cue blocks: [3,4,5,7], mixed blocks: [6 8]
    switch block_num
        case 1
            this_trials = 1:12;
        case 2
            this_trials = 12+(1:48);
        case 3
            this_trials = 12+48+(1:48);
        case 4
            this_trials = 12+48*2+(1:48);
        case 5
            this_trials = 12+48*3+(1:48);
        case 6
            this_trials = 12+48*5+(1:48);
        case 7
            this_trials = 12+48*6+(1:48);
        case 8
            this_trials = 12+48*7+(1:48);
        case 9
            this_trials = 12+48*8+(1:48);
        otherwise
            error('Not a valid block')
    end
    trial_type = trial_type_MASTER(this_trials);
    trial_target_numbers = trial_target_numbers_MASTER(this_trials);
    trial_home_numbers = trial_home_numbers_MASTER(this_trials);
    trial_stimA_numbers = trial_stimA_numbers_MASTER(this_trials);
    prescribed_PT = prescribed_PT_MASTER(this_trials);
    reward = reward_MASTER(this_trials);
    score = 0;
    
    N_TRS = length(trial_target_numbers);

    %% setup data collection
    Data.MT = nan(N_TRS, 1);
    Data.RT = nan(N_TRS, 1);
    Data.Succ = nan(N_TRS, 1);
    % Data.Key = nan(N_TRS, 1);
    Data.pPT = nan(N_TRS, 1);
    Data.time_targ_disp = nan(N_TRS, 1);
    Data.time_stimA_disp = nan(N_TRS, 1);
    Data.Type = nan(N_TRS, 1);
    Data.ViewTime = nan(N_TRS, 1);
    Data.Kinematics = cell(N_TRS, 1);
    Data.EventTimes = cell(N_TRS, 1);
    Data.Target = nan(N_TRS, 1);
    Data.Home = nan(N_TRS, 1);
    Data.params.trial_type = trial_type;
    Data.params.trial_home_numbers = trial_home_numbers;
    Data.params.trial_target_numbers = trial_target_numbers;
    Data.params.trial_stimA_numbers = trial_stimA_numbers;
    Data.params.prescribed_PT = prescribed_PT;
    Data.Score = nan(N_TRS, 1);
    Data.Reward_assigned = reward;

    %% initialize kinematics
%     kinematics = nan(pre_alloc_samps, 3);
    
    %% wait for subject to begin new block
    Screen('DrawText', win, 'Please press any key to begin the next block.', round(screen_dim1/2), round(screen_dim2/2));
    Screen('Flip', win);
    pause;
    %% run through trial list

    try
        if USE_TRACKER
        %%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA CAPTURE
        grabber = Screen('OpenVideoCapture', win);
        Screen('StartVideoCapture', grabber, 60, 1);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA CAPTURE
        else
            
        end
%         exp_time = tic;
        exp_time = GetSecs;
        for i_tr = 1:N_TRS

            state = 'prestart';
            entrance = 1;
            kinematics = nan(pre_alloc_trial, 3);
            flip_onset_times = nan(1, pre_alloc_trial);
            flip_offset_times = nan(1, pre_alloc_trial);
            stim_times = nan(1, pre_alloc_trial);
            image_capture_time = nan(1, pre_alloc_trial);
            k_samp = 1;
            trial_time = GetSecs; %tic;
            screen_text_buff = {};
            screen_pic_buff = {};
            screen_picDim_buff = cell(2,0);
            screen_oval_buff = nan(4, 0);
            screen_color_buff = nan(3, 0);
            screen_bubble_buff = nan(4, 0);
            draw_text_flag = 0;
            draw_pic_flag = 0;
            draw_bubble_flag = 0;
            draw_red_cursor_flag = 0;
            draw_green_center = 0;
            draw_target_fill = 0;
            k_text_buff = 1;
            k_pic_buff = 1;
            k_oval_buff = 0;
            tone_flag = 1;
            mov_begun = 0;
            mov_ended = 0;
            increment_score = [0 0];
            tone_played = 0;
    
            curr_target = targ_coords_base(trial_home_numbers(i_tr), :);
            trial_home_position = curr_target; %the home position on this target
            trial_target_position = targ_coords_base(trial_target_numbers(i_tr), :);
%             curr_target = home_position;
            
            WT_TIME = STIM_A_ONSET_TIME;
            STIM_ISI_DUR = (RET_TIME + TR_TIME) - WT_TIME - prescribed_PT(i_tr) - STIM_A_TIME_DUR - STIM_B_TIME_DUR;
            while ~isequal(state, 'end_state')

                if USE_TRACKER
                    % record position data and draw all text/pics/objects
                     %%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA CAPTURE
                    k = sum(~isnan(x(1,:)))+1;
                    del_1 = tic;
                    [tex, pts, nrdropped, imtext]=Screen('GetCapturedImage', win, grabber, 1, [], 2);
                    image_capture_time(k_samp) = pts - exp_time;
                    delays(1,k) = toc(del_1);
                    del_1 = tic;
                    img_ = imtext(:, 1:DISC_SIZE:end, 1:DISC_SIZE:end);
                    img = permute(img_([3,2,1], :,:), [3,2,1]);
                    b = rgb2hsv(img);
                    delays(2,k) = toc(del_1);
                    del_1 = tic;
                    im_r = inRange(b, [RMAX 1 1], [RMIN 0.5 0.5]);
                    trk_y_rd = round(median(ind1_d(im_r)));
                    trk_x_rd = round(median(ind2_d(im_r)));
                    delays(3,k) = toc(del_1);
                    del_1 = tic;
                    img_ = imtext(:, max([(trk_x_rd - SUBWIN_SIZE),1]):min([(trk_x_rd + SUBWIN_SIZE), res1]), max([(trk_y_rd - SUBWIN_SIZE),1]):min([(trk_y_rd + SUBWIN_SIZE),res2]));
                    img = permute(img_([3 2 1], :, :), [3 2 1]);
                    c_r = rgb2hsv(img);
                    im_r = inRange(c_r, [.02 1 1], [0 0.5 0.5]);
                    rel_ind2 = ind2(max([(trk_y_rd - SUBWIN_SIZE),1]):min([(trk_y_rd + SUBWIN_SIZE),res2]),max([(trk_x_rd - SUBWIN_SIZE),1]):min([(trk_x_rd + SUBWIN_SIZE), res1]));
                    rel_ind1 = ind1(max([(trk_y_rd - SUBWIN_SIZE),1]):min([(trk_y_rd + SUBWIN_SIZE),res2]),max([(trk_x_rd - SUBWIN_SIZE),1]):min([(trk_x_rd + SUBWIN_SIZE), res1]));
                    trk_y_r = median(rel_ind1(im_r));
                    trk_x_r = median(rel_ind2(im_r));
                    delays(4,:) = toc(del_1);
                    del_1 = tic;
                    if ~isempty(trk_x_r) && ~isempty(trk_y_r)
                        try
                            calib_pts_ = undistortPoints([trk_x_r, trk_y_r], camera_params);
                            calib_pts = (calib_pts_ - [res1, res2]/2)*ROT_MAT + [res1, res2]/2;
                        catch
                            calib_pts = nan(1,2);
                        end
                    else
                        calib_pts = nan(1,2);
                    end
                    x(1,k) = calib_pts(1,1)*mm_pix;
                    y(1,k) = calib_pts(1,2)*mm_pix;
                    tim(k) = GetSecs - exp_time;
                    xr = calib_pts(1,1)*screen_dims(1)/res1;
                    yr = calib_pts(1,2)*screen_dims(2)/res2;
                    Screen('Close', tex);
                    delays(5,k)= toc(del_1);
                     %%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA CAPTURE
                else
                    k = sum(~isnan(x(1,:)))+1;
                    time_1 = GetSecs;
                    [xr, yr, b] = GetMouse(win);
                    image_capture_time(k_samp) = GetSecs - exp_time;
                    delays(5, k) = GetSecs - time_1;
                    x(1,k) = xr;
                    y(1,k) = yr;
                    tim(k) = GetSecs - exp_time;
                end

                % Detail display elements:
                kinematics(k_samp, :) = [GetSecs - exp_time, xr, yr];% translate to screen coordinates
                Screen('FillOval', win, [cursor_color, screen_color_buff],...
                    [[kinematics(k_samp, 2:3), kinematics(k_samp, 2:3)]' + cursor_dims, ...
                    screen_oval_buff]);
                Screen('FrameOval', win, [74, 96, 96]', [home_position home_position]' + target_circle_dims');
                Screen('FillOval', win, [0, 0, 0]', [home_position home_position]' + cursor_dims');
                Screen('DrawText', win, num2str(score), SCORE_LOC(1), SCORE_LOC(2));
                if draw_text_flag == 1
                    for i_text = 1:length(screen_text_buff)
                        Screen('DrawText', win, screen_text_buff{i_text}, TEXT_LOC(1), TEXT_LOC(2) + (i_text - 1)*15);
                    end
                end
                if draw_pic_flag == 1
                    for i_pic = 1:length(screen_pic_buff)
                        Screen('DrawTexture', win, screen_pic_buff{i_pic}, screen_picDim_buff{1, i_pic}, screen_picDim_buff{2, i_pic});
                    end
                end
                if draw_bubble_flag == 1
                    Screen('FrameOval', win, 1, [home_position home_position]' + screen_bubble_buff(:)); 
                    draw_target_fill = 1;
                    if norm(kinematics(k_samp, 2:3) - home_position) < VIA_PT_TH
                        % via point was intersected
                        draw_green_center = 1;
                    end
                end

                if draw_green_center
                    % if the bubble is shrinking and the subject intercepts
                    % the center
                    Screen('FillOval', win, [0, 250, 0]',...
                        [home_position home_position]' + [-VIA_PT_TH -VIA_PT_TH VIA_PT_TH VIA_PT_TH]');
                    if increment_score(1) == 0
                        increment_score(1) = 1;
                    end
                else
                    % all other times
                    Screen('FrameOval', win, [0, 250, 0]',...
                        [home_position home_position]' + [-VIA_PT_TH -VIA_PT_TH VIA_PT_TH VIA_PT_TH]');
                end
                
                % do RT computation:
                %%% RT %%%
                home_dist = norm(trial_home_position - kinematics(k_samp, 2:3));
                if home_dist > 15 && ~mov_begun %&& ~isequal(state, 'prestart')
                    % movement just begun
                    mov_begun = 1;
                    move_start_time = (GetSecs - trial_time); %toc(trial_time);
                end

                targ_dist = norm(trial_target_position - kinematics(k_samp, 2:3));
                % if if the bubble has started shrinking, and the cursor
                % gets to inside the target
                if targ_dist < 25 && draw_target_fill
                    mov_ended = 1;
                    move_end_time = GetSecs - trial_time; %toc(trial_time);
                    % show target:
                    k_oval_buff = k_oval_buff + 1;
                    screen_oval_buff(:, k_oval_buff) = ...
                        [targ_coords_base(trial_target_numbers(i_tr), :), ...
                        targ_coords_base(trial_target_numbers(i_tr), :)]' + cursor_dims;
                    screen_color_buff(:, k_oval_buff) = [0 250 0];
                    if increment_score(2) == 0
                        if reward(i_tr) > 0
                            increment_score(2) = 10;
                        else
                            increment_score(2) = 1;
                        end
                    end
                    if tone_played == 0
                        if reward(i_tr) > 0 
                            %play reward tone:
                            PsychPortAudio('FillBuffer', pahandle, sound_reward_);
                            startTime = PsychPortAudio('Start', pahandle);
                        else
                            %play neutral tone:
                            PsychPortAudio('FillBuffer', pahandle, sound_neurtral_);
                            startTime = PsychPortAudio('Start', pahandle);
                        end
                        tone_played = 1;
                    end
                end
                %%% RT %%%
                
                % THE MAIN EXPERIMENT FLIP (FLIPS SCREEN EVERY SAMPLE):
%                 Screen('Flip', win);
                [t_flip_0, t_stim, t_flip_f] = Screen('Flip', win);
                flip_onset_times(k_samp) = t_flip_0 - exp_time;
                flip_offset_times(k_samp) = t_flip_f - exp_time;
                stim_times(k_samp) = t_stim - exp_time;
                
                switch state
                    case 'prestart'
                        if entrance == 1
                            screen_text_buff{k_text_buff} = 'Go to Home';
                            draw_text_flag = 1;
                            screen_oval_buff(:,1) = [curr_target curr_target]' + target_dims;
                            screen_color_buff(:,1) = target_color;
                            k_oval_buff = k_oval_buff + 1;
                            Data.pPT(i_tr) = prescribed_PT(i_tr);
                            Data.Type(i_tr) = trial_type(i_tr);
                            entrance = 0;
                        else
                            targ_dist = norm(curr_target - kinematics(k_samp, 2:3));
                            if targ_dist <= 15 %pixels
                                % home pos reached: switch to home state
                                entrance = 1;
                                state = 'home';
                                draw_text_flag = 0;
                                draw_pic_flag = 0;
                            else
                                % have not reached home
                            end
                        end
                    case 'home'
                        if entrance == 1
                            % first entrance into home state
                            home_start_time = GetSecs - trial_time; %toc(trial_time);
                            curr_target = targ_coords_base(trial_target_numbers(i_tr),:);
                            entrance = 0;
                            home_sub_state = 'wait';
                            sub_entrance = 1;
                            state_time = GetSecs;
                        else
                            % check if tones need to be started:
                            cur_state_time = GetSecs - state_time;
                            
                            % check state of bubble collapse &/or expand
                            if cur_state_time >= TR_TIME + RET_TIME
                                bubble_rad = (cur_state_time - (TR_TIME + RET_TIME))*bubble_expand_rate;
                                if bubble_rad > TARG_LEN
                                    draw_bubble_flag = 0;
                                else
                                    screen_bubble_buff = [-bubble_rad; -bubble_rad; bubble_rad; bubble_rad];
                                    draw_bubble_flag = 1;
                                end
                            elseif cur_state_time >= (TR_TIME + RET_TIME - (TARG_LEN/bubble_expand_rate))
                                % time to start shrinking the
                                % bubble from the outside in
                                bubble_rad = 1.25*TARG_LEN - (cur_state_time - (TR_TIME + RET_TIME - (TARG_LEN/bubble_expand_rate)))*bubble_expand_rate;
                                if bubble_rad > TARG_LEN*1.25
                                    draw_bubble_flag = 0;
                                else
                                    screen_bubble_buff = [-bubble_rad; -bubble_rad; bubble_rad; bubble_rad];
                                    draw_bubble_flag = 1;
                                end
                            else
                                draw_bubble_flag = 0;
                            end

                            switch home_sub_state
                                case 'wait'
                                    if sub_entrance == 1
                                        sub_entrance = 0;
                                    else
                                        if cur_state_time >= WT_TIME
                                            home_sub_state = 'stimA';
                                            sub_entrance = 1;
                                        else
                                            % do nothing; just wait.
                                        end
                                    end
                                case 'stimA'
                                    if sub_entrance == 1
                                        switch trial_type(i_tr)
                                            case 2
                                                temp_tx = ...
                                                    Screen('MakeTexture', win, im_list_A{trial_stimA_numbers(i_tr)});
                                                tx_size = size(im_list_A{trial_stimA_numbers(i_tr)});
                                                screen_picDim_buff{1, k_pic_buff} = [0; 0; tx_size(2); tx_size(1)];
                                                screen_picDim_buff{2, k_pic_buff} = [TEXT_LOC(1) - TEXT_SIZE; TEXT_LOC(2) - TEXT_SIZE;...
                                                 TEXT_LOC(1) + TEXT_SIZE; TEXT_LOC(2) + TEXT_SIZE];
                                                screen_pic_buff{k_pic_buff} = temp_tx;
                                                draw_pic_flag = 1;
                                                Data.Target(i_tr) = trial_target_numbers(i_tr);
                                                Data.time_stimA_disp(i_tr) = GetSecs - exp_time;
                                                Data.Home(i_tr) = trial_home_numbers(i_tr);
                                            case 1
                                                Data.Target(i_tr) = trial_target_numbers(i_tr);
                                            case 0
                                                %show nothing
                                                Data.Target(i_tr) = trial_target_numbers(i_tr);
                                            otherwise
                                                error('No valid trial type specified.')
                                        end 
                                        sub_entrance = 0;
                                    else
                                        if cur_state_time >= WT_TIME + STIM_A_TIME_DUR
                                            home_sub_state = 'ISI';
                                            sub_entrance = 1;
                                        else
                                            % do nothing
                                        end
                                    end
                                case 'ISI'
                                    if sub_entrance == 1
                                        sub_entrance = 0;
                                        draw_pic_flag = 0;
                                    else
                                        if cur_state_time >= WT_TIME + STIM_A_TIME_DUR + STIM_ISI_DUR
                                            home_sub_state = 'stimB';
                                            sub_entrance = 1;
                                        else
                                            % do nothing
                                        end
                                    end
                                case 'stimB'
                                    if sub_entrance == 1
                                        switch trial_type(i_tr)
                                            case 2
                                                k_oval_buff = k_oval_buff + 1;
                                                screen_oval_buff(:, k_oval_buff) = [targ_coords_base(trial_target_numbers(i_tr),:)'; targ_coords_base(trial_target_numbers(i_tr),:)'] + target_dims;
                                                screen_color_buff(:, k_oval_buff) = [0; 0; 0];
                                                Data.Target(i_tr) = trial_target_numbers(i_tr);
                                                Data.time_targ_disp(i_tr) = GetSecs - exp_time;
                                            case 1
                                                k_oval_buff = k_oval_buff + 1;
                                                screen_oval_buff(:, k_oval_buff) = [targ_coords_base(trial_target_numbers(i_tr),:)'; targ_coords_base(trial_target_numbers(i_tr),:)'] + target_dims;
                                                screen_color_buff(:, k_oval_buff) = [0; 0; 0];
                                                Data.Target(i_tr) = trial_target_numbers(i_tr);
                                                Data.time_targ_disp(i_tr) = GetSecs - exp_time;
                                            case 0
                                                %show nothing
                                                Data.Target(i_tr) = trial_target_numbers(i_tr);
                                            otherwise
                                                error('No valid trial type specified.')
                                        end 
                                        sub_entrance = 0;
                                    else
                                        if cur_state_time >= WT_TIME + STIM_A_TIME_DUR + STIM_B_TIME_DUR + STIM_ISI_DUR
                                            % extinguish cues
                                            draw_text_flag = 0;
                                            draw_pic_flag = 0;
                                            switch trial_type(i_tr)
                                                case 4
                                                case 3
%                                                     k_oval_buff = k_oval_buff - 1;
%                                                     screen_oval_buff = screen_oval_buff(:, 1:k_oval_buff);
%                                                     screen_color_buff = screen_color_buff(:, 1:k_oval_buff);
                                                case 2
                                                case 1
%                                                     k_oval_buff = k_oval_buff - 1;
%                                                     screen_oval_buff = screen_oval_buff(:, 1:k_oval_buff);
%                                                     screen_color_buff = screen_color_buff(:, 1:k_oval_buff);
                                                case 0
                                                otherwise
                                                    error('invalid trial type')
                                            end
                                            sub_entrance = 1;
                                            home_sub_state = 'post_wait';
                                        else
                                            % do nothing
                                        end
                                    end
                                case 'post_wait'
                                    sub_entrance = 0;
                                    
                                    if cur_state_time >= TR_TIME + RET_TIME + MOV_TIME
                                        % finally move to ITI state
                                        state = 'ITI';
                                        entrance = 1;
                                    else
                                        % do nothing just wait
                                    end
                                otherwise
                                    error('No home state substate specified')
                            end
                        end
                    case 'ITI'
                        if entrance == 1
                            ITI_state_time = GetSecs - trial_time; %toc(trial_time);
                            draw_red_cursor_flag = 0;
                            if abs(Data.RT(i_tr)) >= TR_TOLERANCE && Data.RT(i_tr) >= 0
    
                            elseif abs(Data.RT(i_tr)) > TR_TOLERANCE && Data.RT(i_tr) < 0
                                screen_text_buff = {'MOVED TOO SOON!'};
                                draw_text_flag = 1;
                            else
                                % timing was within tolerance.. disp nothng
                            end
                            if Data.MT(i_tr) > MOV_LIMIT_TIME
    %                             screen_text_buff{length(screen_text_buff) + 1} = 'MOVED TOO SLOW!';
    %                             draw_text_flag = 1;
    %                             Screen('DrawText', win, 'MOVED TOO SLOWLY!', 680, 650);
    %                             Screen('Flip', win);
                            else
                                % MT was within tolerance... disp nothing
                            end
                            
                            % extinguish target:
                            % show target:
                            k_oval_buff = k_oval_buff - 1;
                            screen_oval_buff = screen_oval_buff(:, 1:k_oval_buff);
                            screen_color_buff = screen_color_buff(:, 1:k_oval_buff);
                            
                            entrance = 0;
                        else
                            %if (toc(trial_time) - ITI_state_time) > FB_TIME
                            if ((GetSecs - trial_time) - ITI_state_time) > FB_TIME
                                % extinguish feedback
                                draw_text_flag = 0;
                            end
%                             if (toc(trial_time) - ITI_state_time) > (ITI_TIME)
                            if ((GetSecs - trial_time) - ITI_state_time) > (ITI_TIME)
                                % end trial
                                draw_text_flag = 0;
                                Data.Kinematics{i_tr} = kinematics(~isnan(kinematics(:,1)), :);
                                Data.EventTimes{i_tr} = [image_capture_time; ...
                                    flip_onset_times;
                                    stim_times;
                                    flip_offset_times];
                                score = score + sum(increment_score);
                                Data.Score(i_tr) = sum(increment_score);
                                state = 'end_state';
                            end
                        end
                    otherwise
                        error('No state specified');
                end
                k_samp = k_samp + 1;
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA CAPTURE
        if exist('grabber')
                Screen('StopVideoCapture', grabber);
                Screen('CloseVideoCapture', grabber);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA CAPTURE
%         sca;
    catch err_
        try
            warning('An error occured')
%             err_ = lasterror;
            assignin('base', 'err_', err_);
            Data.ViewTime = Data.pPT - Data.RT;
            uniqueness_code = now*10000000000;
            save([SUB_NUM_, num2str(uniqueness_code)], 'Data');
            varargout = {0, lasterror, Data, kinematics, delays};
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA CAPTURE
            Screen('StopVideoCapture', grabber);
            Screen('CloseVideoCapture', grabber);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA CAPTURE
            sca;
            return
        catch
            try
                %%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA CAPTURE
                Screen('StopVideoCapture', grabber);
                Screen('CloseVideoCapture', grabber);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA CAPTURE
                sca
                return
            catch
                sca;
%                 clear all; close all; clc
                return
            end
        end
        sca
        return
    end
    Data.ViewTime = Data.pPT - Data.RT;
    Data.x_track = x; Data.y_track = y; Data.t_track = tim;
    varargout = {1, [], Data, kinematics, delays};
    uniqueness_code = now*10000000000;
    save([SUB_NUM_, num2str(uniqueness_code)], 'Data');
    
    %% between blocks break
    if block_num < 7
        Screen('Flip', win);
        Screen('DrawText', win, 'Starting next block.', round(screen_dim1/2), round(screen_dim2/2));
        pause(2)
        Screen('Flip', win);
        pause(1);
    else
        % exit
    end
end
Screen('Flip', win);
if block_num == 7
    Screen('DrawText', win, 'Part 1 has completed. Please see the experimenter for additional instruction.', round(screen_dim1/2), round(screen_dim2/2));
else
    Screen('DrawText', win, 'This now completes the experiment. Thank you for participating.', round(screen_dim1/2), round(screen_dim2/2));
end
Screen('Flip', win);
pause(1);
sca;