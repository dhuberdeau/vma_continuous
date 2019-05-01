%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE
AssertOpenGL;
%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE
screen_dims = [1920, 1080];
res1 = 1920;%1280;%1920;
res2 = 1080;%1024;%1080;
ind1 = repmat((1:res2)', 1, res1);
ind2 = repmat((1:res1), res2, 1);
DISC_SIZE = 1;
REFL_TH = .9;

ind1_d = repmat((1:DISC_SIZE:res2)', 1, res1/DISC_SIZE);
ind2_d = repmat((1:DISC_SIZE:res1), res2/DISC_SIZE, 1);
% SUBWIN_SIZE = 75;
% ind1 = repmat((1:res2)', 1, res1);
% ind2 = repmat((1:res1), res2, 1);

x = nan(1, 10000);
y = nan(1, 10000);
tim = nan(1, 10000);
cursor_dims = [-10 -10 10 10]';

screens=Screen('Screens');
screenNumber=max(screens);
[win, rect] = Screen('OpenWindow', screenNumber, 0); %, [0 0 800 450]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE
dev_list = Screen('VideoCaptureDevices');
grabber = Screen('OpenVideoCapture', win, dev_list(5).DeviceIndex);
Screen('StartVideoCapture', grabber, 60, 1);
RMIN = 0;
RMAX = .025;
%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE
keyIsDown = 0;

while(~keyIsDown)
    [ keyIsDown, keyTime, keyCode ] = KbCheck; 
    [tex, pts, nrdropped, imtext] = Screen('GetCapturedImage', win, grabber, 1, [], 2);
    
    img_ = imtext(:, 1:DISC_SIZE:end, 1:DISC_SIZE:end);
    img = permute(img_([3,2,1], :,:), [3,2,1]);
    b = rgb2hsv(img);

    im_r = inRange(b, [RMAX 1 1], [RMIN 0.5 0.5]);

    trk_y_rd = (median(ind1_d(im_r)));
    trk_x_rd = (median(ind2_d(im_r)));

    trk_x_r = trk_x_rd*screen_dims(1)/res1; % for psych room setup
    trk_y_r = trk_y_rd*screen_dims(2)/res2;
%     trk_x_r = (res1 - trk_x_rd)*screen_dims(1)/res1; % for scanner setup
    % trk_y_r = trk_y_rd*screen_dims(2)/res2;

    Screen('DrawTexture', win, tex);
    Screen('FillOval', win, [200;200;0], [trk_x_r trk_y_r trk_x_r trk_y_r]' + cursor_dims);
    Screen('Flip', win)
    Screen('Close', tex);
    pause(.017);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE

 
%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE
if exist('grabber')
    Screen('StopVideoCapture', grabber);
    Screen('CloseVideoCapture', grabber);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE
