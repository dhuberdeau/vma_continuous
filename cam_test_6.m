% cam_test_5.m Tests the camera setup with a different scheme for capturing
% webcam images, which is to not wait for a newly avaialble frame and
% instead use the old rame if a new one is not available. it turns out that
% this scheme does not substantially change the run time performance
% (sampling rate) at all, so the recommendation will be to revert to the
% standard method, which is to wait for a frame to be available (which
% apparently takes very little time in practice).

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
missed_frames = nan(1, 1000);
cursor_dims = [-10 -10 10 10]';

screens=Screen('Screens');
screenNumber=max(screens);
[win, rect] = Screen('OpenWindow', screenNumber, 0); %, [0 0 800 450]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE
load('camera_params.mat');
load('mm_per_pix.mat');

dev_list = Screen('VideoCaptureDevices');
grabber = Screen('OpenVideoCapture', win, dev_list(5).DeviceIndex);
Screen('StartVideoCapture', grabber, 60, 1);

% Get an initial sample of the camera. use 'Wait for image' = 1 to
% ensure an image and texture are returned.
[tex0, pts, nrdropped, imtext]=Screen('GetCapturedImage', win, grabber, 1, [], 2);

RMIN = 0;
RMAX = .025;
SUBWIN_SIZE = 75;
%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE


timr = tic;
keyIsDown = 0;
k_samp = 1;
k_missed = 1;
while(~keyIsDown)
    [ keyIsDown, keyTime, keyCode ] = KbCheck; 
    % poll for image; if avail. use, if not, use old and note
%     [~, pts, nrdropped, im_sum_int]=Screen('GetCapturedImage', win, grabber, 3, []);
%     if im_sum_int > 0
%         % a new image is available; grab it and use it
% %         Screen('Close', tex);
%         [tex, pts, nrdropped, imtext]=Screen('GetCapturedImage', win, grabber, 0, [], 2);
%     else
%         % a new image is not available; use old one, and note
%         Screen('GetCapturedImage', win, grabber, 4, tex);
%     end
    [tex_, pts, nrdropped, imtext_]=Screen('GetCapturedImage', win, grabber, 0, [], 2);
    if tex_ > 0
        % a new image was pulled
        imtext = imtext_;
        tex = tex_;
        Screen('Close'Screen, tex_);
    else
        % no new image. use old one and note.
        missed_frames(k_missed) = toc(timr);
        k_missed = k_missed + 1;
    end
    
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
                calib_pts = undistortPoints([trk_x_r, trk_y_r], camera_params);
            catch
                calib_pts = nan(1,2);
            end
        else
            calib_pts = nan(1,2);
        end
        x(k_samp) = calib_pts(1,1)*mm_pix;
        y(k_samp) = calib_pts(1,2)*mm_pix;
        tim(k_samp) = toc(timr);
        xr = calib_pts(1,1)*screen_dims(1)/res1;
        yr = calib_pts(1,2)*screen_dims(2)/res2;

    %     Screen('DrawTexture', win, tex);
        Screen('FillOval', win, [200;200;0], [xr yr xr yr]' + cursor_dims);
        Screen('Flip', win);
%         Screen('Close', tex);

        k_samp = k_samp + 1;
    else
%         Screen('FillOval', win, [200;0;0], [trk_x_r trk_y_r trk_x_r trk_y_r]' + cursor_dims);
        Screen('Flip', win);
        Screen('Close', tex);

        x(k_samp) = nan;
        y(k_samp) = nan;
        tim(k_samp) = toc(timr);
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
