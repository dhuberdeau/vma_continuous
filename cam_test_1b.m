%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE
AssertOpenGL;
%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE

load('camera_params');
load('mm_per_pix');

screens=Screen('Screens');
screenNumber=max(screens);
[win, rect] = Screen('OpenWindow', screenNumber);%, [0 0 800 450]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE
dev_list = Screen('VideoCaptureDevices');
for i_dev = 1%:length(dev_list)
    try
        grabber = Screen('OpenVideoCapture', win, dev_list(i_dev).DeviceIndex);
    catch
        warning(['dev ', num2str(i_dev), ' failed.'])
    end
end
Screen('StartVideoCapture', grabber, 60, 1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE
keyIsDown = 0;

while(~keyIsDown)
    [ keyIsDown, keyTime, keyCode ] = KbCheck; 
    [tex, pts, nrdropped, imtext] = Screen('GetCapturedImage', win, grabber, 1, [], 2);
    permim = permute(imtext([3,2,1], :,:), [3,2,1]);
    calib_img = undistortImage(permim, camera_params);
    calib_tex = Screen('MakeTexture', win, calib_img);
    Screen('DrawTexture', win, calib_tex);
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