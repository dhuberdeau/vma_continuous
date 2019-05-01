base_file_name = 'test_pos_';         
try
    win = Screen('OpenWindow', 0, [], [0 0 600 300]);

    grab = Screen('OpenVideoCapture', win, 0);
    Screen('StartVideoCapture', grab, 60, 1);
    for i = 1:6
        [tex, pts, nrdropped, imtext]=Screen('GetCapturedImage', win, grab, 1, [], 2);
        img = permute(imtext([3,2,1], :,:), [3,2,1]);
        imwrite(img, [base_file_name, num2str(i), '.jpg']);
        pause
    end
    Screen('StopVideoCapture', grab);
    Screen('CloseVideoCapture', grab);
catch err
   sca
   rethrow(err)
   Screen('StopVideoCapture', grab);
   Screen('CloseVideoCapture', grab);
end