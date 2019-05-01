%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE
AssertOpenGL;
%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE
screen_dims = [1920, 1080];
res1 = 1920;
res2 = 1080;
ind1 = repmat((1:res2)', 1, res1);
ind2 = repmat((1:res1), res2, 1);
DISC_SIZE = 30;

ind1_d = repmat((1:DISC_SIZE:res2)', 1, res1/DISC_SIZE);
ind2_d = repmat((1:DISC_SIZE:res1), res2/DISC_SIZE, 1);

x = nan(1, 10000);
y = nan(1, 10000);
tim = nan(1, 10000);
flip_onset_times = nan(1, 10000);
flip_offset_times = nan(1, 10000);
stim_times = nan(1, 10000);
image_capture_time = nan(1, 10000);
cursor_dims = [-10 -10 10 10]';

screens=Screen('Screens');
screenNumber=max(screens);
[win, rect] = Screen('OpenWindow', screenNumber, 0); %, [0 0 800 450]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE
load('camera_params.mat');
load('mm_per_pix.mat');
load('camera_angle_calibration.mat');
% angle_error = -angle_error;
c_rr = cosd(angle_error);
s_rr = sind(angle_error);
ROT_MAT = [c_rr s_rr; -s_rr c_rr];

dev_list = Screen('VideoCaptureDevices');
grabber = Screen('OpenVideoCapture', win, dev_list(5).DeviceIndex);
Screen('StartVideoCapture', grabber, 60, 1);
RMIN = 0;
RMAX = .025;
SUBWIN_SIZE = 75;
%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE

keyIsDown = 0;
k_samp = 1;
% timr = tic;
timr = GetSecs;
while(~keyIsDown)
    [ keyIsDown, keyTime, keyCode ] = KbCheck; 
    [tex, image_cap_time, nrdropped, imtext] = Screen('GetCapturedImage', win, grabber, 1, [], 2);
    image_capture_time(k_samp) = image_cap_time - timr;
    img_ = imtext(:, 1:DISC_SIZE:end, 1:DISC_SIZE:end);
    img = permute(img_([3,2,1], :,:), [3,2,1]);
    b = rgb2hsv(img);

    im_r = inRange(b, [RMAX 1 1], [RMIN 0.5 0.5]);

    trk_y_rd = (median(ind1_d(im_r)));
    trk_x_rd = (median(ind2_d(im_r)));
    if ~isempty(trk_y_rd) && ~isempty(trk_x_rd)
        img_ = imtext(:, max([(trk_x_rd - SUBWIN_SIZE),1]):min([(trk_x_rd + SUBWIN_SIZE), res1]), max([(trk_y_rd - SUBWIN_SIZE),1]):min([(trk_y_rd + SUBWIN_SIZE),res2]));
        img = permute(img_([3 2 1], :, :), [3 2 1]);
        c_r = rgb2hsv(img);
        im_r = inRange(c_r, [RMAX 1 1], [RMIN 0.5 0.5]);
        rel_ind2 = ind2(max([(trk_y_rd - SUBWIN_SIZE),1]):min([(trk_y_rd + SUBWIN_SIZE),res2]),max([(trk_x_rd - SUBWIN_SIZE),1]):min([(trk_x_rd + SUBWIN_SIZE), res1]));
        rel_ind1 = ind1(max([(trk_y_rd - SUBWIN_SIZE),1]):min([(trk_y_rd + SUBWIN_SIZE),res2]),max([(trk_x_rd - SUBWIN_SIZE),1]):min([(trk_x_rd + SUBWIN_SIZE), res1]));
        trk_y_r = median(rel_ind1(im_r))*screen_dims(1)/res1;
        trk_x_r = median(rel_ind2(im_r))*screen_dims(2)/res2;

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
        x(k_samp) = calib_pts(1,1)*mm_pix;
        y(k_samp) = calib_pts(1,2)*mm_pix;
%         tim(k_samp) = toc(timr);
        tim(k_samp) = GetSecs - timr;
        xr = calib_pts(1,1)*screen_dims(1)/res1;
        yr = calib_pts(1,2)*screen_dims(2)/res2;

    %     Screen('DrawTexture', win, tex);
        Screen('FillOval', win, [200;200;0], [xr yr xr yr]' + cursor_dims);
        [t_flip_0, t_stim, t_flip_f] = Screen('Flip', win);
        flip_onset_times(k_samp) = t_flip_0 - timr;
        flip_offset_times(k_samp) = t_flip_f - timr;
        stim_times(k_samp) = t_stim - timr;
        Screen('Close', tex);
        
        k_samp = k_samp + 1;
    else
%         Screen('FillOval', win, [200;0;0], [trk_x_r trk_y_r trk_x_r trk_y_r]' + cursor_dims);
        [t_flip_0, t_stim, t_flip_f] = Screen('Flip', win);
        flip_onset_times(k_samp) = t_flip_0 - timr;
        flip_offset_times(k_samp) = t_flip_f - timr;
        stim_times(k_samp) = t_stim - timr;
        Screen('Close', tex);

        x(k_samp) = nan;
        y(k_samp) = nan;
        tim(k_samp) = GetSecs - timr;
        k_samp = k_samp + 1;
    end
%     pause(.005);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE

 
%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE
if exist('grabber')
    Screen('StopVideoCapture', grabber);
    Screen('CloseVideoCapture', grabber);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE
