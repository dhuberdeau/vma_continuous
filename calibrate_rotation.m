% Use this script at the beginning of each experiment to calibrate any
% potential rotation of the camera lens relative to the participant's
% workspace.

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE
AssertOpenGL;
%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE
screen_dims = [1920, 1080];
res1 = 1920;
res2 = 1080;
ind1 = repmat((1:res2)', 1, res1);
ind2 = repmat((1:res1), res2, 1);

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
% RMIN = [30, -1, -1];
% RMAX = [90, 20, 20];
% GMIN = [70, 80, -1];
% GMAX = [130, 120, 20];
% OMIN = [240, 40, -1];
% OMAX = [260, 90, 20];

RMIN = [-.05, .9, .4];
RMAX = [.05, 1.1, .75];
GMIN = [.1, .9, .3];
GMAX = [.3, 1.1, .7];
OMIN = [0, .9, .95];
OMAX = [.3, 1.1, 1.1];
%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE

x_mean = nan(3, 10);
y_mean = nan(3, 10);

for i_pic = 1:size(x_mean,2)
    [tex, pts, nrdropped, imtext] = Screen('GetCapturedImage', win, grabber, 1, [], 2);

    img_ = permute(imtext([3,2,1], :,:), [3,2,1]);
    img = undistortImage(img_, camera_params);
    b = rgb2hsv(img);

    % im_r = inRange(b, [RMAX 1 1], [RMIN 0.5 0.5]);
%     im_r_ = inRange(img, RMAX, RMIN);
%     im_g_ = inRange(img, GMAX, GMIN);
%     im_o_ = inRange(img, OMAX, OMIN);

    im_r_ = inRange(b, RMAX, RMIN);
    im_g_ = inRange(b, GMAX, GMIN);
    im_o_ = inRange(b, OMAX, OMIN);

    windw = 75;

    trk_y_r_ = (median(ind1(im_r_)));
    trk_x_r_ = (median(ind2(im_r_)));
    im_r_(ind1(:,1) > (trk_y_r_ + windw) | ind1(:,1) < (trk_y_r_ - windw),...
        ind2(1,:) > (trk_x_r_ + windw) | ind2(1,:) < (trk_x_r_ - windw)) = 0;

    trk_y_o_ = (median(ind1(im_o_)));
    trk_x_o_ = (median(ind2(im_o_)));
    im_o_(ind1(:,1) > (trk_y_o_ + windw) | ind1(:,1) < (trk_y_o_ - windw),...
        ind2(1,:) > (trk_x_o_ + windw) | ind2(1,:) < (trk_x_o_ - windw)) = 0;

    trk_y_g_ = (median(ind1(im_g_)));
    trk_x_g_ = (median(ind2(im_g_)));
    im_g_(ind1(:,1) > (trk_y_g_ + windw) | ind1(:,1) < (trk_y_g_ - windw),...
        ind2(1,:) > (trk_x_g_ + windw) | ind2(1,:) < (trk_x_g_ - windw)) = 0;
    
    stat_r = regionprops(im_r_, 'BoundingBox');
    stat_o = regionprops(im_o_, 'BoundingBox');
    stat_g = regionprops(im_g_, 'BoundingBox');
    
    boxs_r = nan(4,length(stat_r));
    box_size_r = nan(1, length(stat_r));
    for i_r = 1:length(stat_r)
        boxs_r(:, i_r) = stat_r(i_r).BoundingBox';
        box_size_r(i_r) = norm([boxs_r(3,i_r); boxs_r(4, i_r)]);
    end
    boxs_o = nan(4,length(stat_o));
    box_size_o = nan(1, length(stat_o));
    for i_r = 1:length(stat_o)
        boxs_o(:, i_r) = stat_o(i_r).BoundingBox';
        box_size_o(i_r) = norm([boxs_o(3,i_r); boxs_o(4, i_r)]);
    end
    boxs_g = nan(4,length(stat_g));
    box_size_g = nan(1, length(stat_g));
    for i_r = 1:length(stat_g)
        boxs_g(:, i_r) = stat_g(i_r).BoundingBox';
        box_size_g(i_r) = norm([boxs_g(3,i_r); boxs_g(4, i_r)]);
    end

    [~, k_box_r] = max(box_size_r);
    [~, k_box_o] = max(box_size_o);
    [~, k_box_g] = max(box_size_g);
    
    trk_x_r = boxs_r(1, k_box_r) + .5*boxs_r(3, k_box_r);
    trk_y_r = boxs_r(2, k_box_r) + .5*boxs_r(4, k_box_r);
    
    trk_x_o = boxs_o(1, k_box_o) + .5*boxs_o(3, k_box_o);
    trk_y_o = boxs_o(2, k_box_o) + .5*boxs_o(4, k_box_o);
    
    trk_x_g = boxs_g(1, k_box_g) + .5*boxs_g(3, k_box_g);
    trk_y_g = boxs_g(2, k_box_g) + .5*boxs_g(4, k_box_g);
    
%     trk_y_r = (mean(ind1(im_r_)));
%     trk_x_r = (mean(ind2(im_r_)));
% 
%     trk_y_o = (mean(ind1(im_o_)));
%     trk_x_o = (mean(ind2(im_o_)));
% 
%     trk_y_g = (mean(ind1(im_g_)));
%     trk_x_g = (mean(ind2(im_g_)));
    
    x_mean(1, i_pic) = trk_x_r;
    x_mean(2, i_pic) = trk_x_o; 
    x_mean(3, i_pic) = trk_x_g;
    y_mean(1, i_pic) = trk_y_r; 
    y_mean(2, i_pic) = trk_y_o;
    y_mean(3, i_pic) = trk_y_g;
end
%%
tex_ = Screen('MakeTexture', win, img);
Screen('DrawTexture', win, tex_);
% Screen('FillOval', win, [200;200;0], [trk_x_r trk_y_r trk_x_r trk_y_r]' + cursor_dims);
% Screen('FillOval', win, [200;0;0], [trk_x_o trk_y_o trk_x_o trk_y_o]' + cursor_dims);
% Screen('FillOval', win, [0;200;0], [trk_x_g trk_y_g trk_x_g trk_y_g]' + cursor_dims);
Screen('FillOval', win, [200;200;0], mean([x_mean(1,:)', y_mean(1,:)', x_mean(1,:)', y_mean(1,:)'])' + cursor_dims);
Screen('FillOval', win, [200;0;0], mean([x_mean(2,:)', y_mean(2,:)', x_mean(2,:)', y_mean(2,:)'])' + cursor_dims);
Screen('FillOval', win, [0;200;0], mean([x_mean(3,:)', y_mean(3,:)', x_mean(3,:)', y_mean(3,:)'])' + cursor_dims);
Screen('Flip', win)
Screen('Close', tex);

Screen('StopVideoCapture', grabber);
Screen('CloseVideoCapture', grabber);
%%
keyIsDown = 0;
while(~keyIsDown)
    [keyIsDown, keyTime, keyCode ] = KbCheck; 
    pause(.1);
end

v_r = mean([x_mean(1,:)', y_mean(1,:)'])';
v_o = mean([x_mean(2,:)', y_mean(2,:)'])';
v_g = mean([x_mean(3,:)', y_mean(3,:)'])';

sca

%% 
x = v_r - v_o;
y = v_g - v_o;

figure;
imshow(img); hold on;
plot(v_o(1) + [0 y(1)], v_o(2) + [0 y(2)], 'g-')
plot(v_o(1) + [0 x(1)], v_o(2) + [0 x(2)], 'k-')
for i_ = 1:length(stat_r)
    plot(stat_r(i_).BoundingBox(1)+[0, stat_r(i_).BoundingBox(3)], stat_r(i_).BoundingBox(2) + [0, stat_r(i_).BoundingBox(4)], 'w-'); 
end
for i_ = 1:length(stat_o)
    plot(stat_o(i_).BoundingBox(1)+[0, stat_o(i_).BoundingBox(3)], stat_o(i_).BoundingBox(2) + [0, stat_o(i_).BoundingBox(4)], 'w-'); 
end
for i_ = 1:length(stat_g)
    plot(stat_g(i_).BoundingBox(1)+[0, stat_g(i_).BoundingBox(3)], stat_g(i_).BoundingBox(2) + [0, stat_g(i_).BoundingBox(4)], 'w-'); 
end

angle_error_x = atan2d(x(2), x(1));
angle_error_y = (90 + atan2d(y(2), y(1)));

angle_error = mean([angle_error_x, angle_error_y]);

calib_angle_error = atan2d(norm(cross([y(1), y(2), 0]', [x(1), x(2), 0]')), dot([y(1), y(2)]', [x(1) x(2)]'));

save camera_angle_calibration angle_error calib_angle_error