sqr_size = 17.5;

% I0 = imread('checkerboard.jpg');
% I1 = imread('checkerboard_1.jpg');
% I2 = imread('checkerboard_2.jpg');
% I3 = imread('checkerboard_3.jpg');
% I4 = imread('checkerboard_4.jpg');
% I5 = imread('checkerboard_5.jpg');
% I6 = imread('checkerboard_6.jpg');
I1 = imread('test_pos_1.jpg');
I2 = imread('test_pos_2.jpg');
I3 = imread('test_pos_3.jpg');
I4 = imread('test_pos_4.jpg');
I5 = imread('test_pos_5.jpg');
I6 = imread('test_pos_6.jpg');
% [im_pts0, board_size] = detectCheckerboardPoints(I1);
[im_pts1, board_size] = detectCheckerboardPoints(I1);
[im_pts2, board_size] = detectCheckerboardPoints(I2);
[im_pts3, board_size] = detectCheckerboardPoints(I3);
[im_pts4, board_size] = detectCheckerboardPoints(I4);
[im_pts5, board_size] = detectCheckerboardPoints(I5);
[im_pts6, board_size] = detectCheckerboardPoints(I6);

% im_pts = cat(3, im_pts0, cat(3, im_pts1, cat(3, im_pts2, im_pts3)));
im_pts0 = cat(3, im_pts1, cat(3, im_pts2, im_pts3));
im_pts1 = cat(3, im_pts4, cat(3, im_pts5, im_pts6));
im_pts = cat(3, im_pts0, im_pts1);

world_pts = generateCheckerboardPoints(board_size, sqr_size);

camera_params = estimateCameraParameters(im_pts, world_pts, 'ImageSize', [size(I1,1), size(I1,2)]);

I_calib = undistortImage(I1, camera_params);

figure;
subplot(1,2,1)
imshow(I1);
subplot(1,2,2)
imshow(I_calib);

%% find world pixel size:

figure; hold on;
imshow(I_calib);

d = detectCheckerboardPoints(I_calib);

dd1 = 17.6;
dd2 = 14.5;
dd3 = 22.5;

x2 = d(91, 1:2);
x1 = d(1, 1:2);
x3 = d(9, 1:2);

pix1_2 = norm(x2 - x1);
mm1_2 = dd1/pix1_2;

pix1_3 = norm(x3 - x1);
mm1_3 = dd2/pix1_3;

pix2_3 = norm(x3 - x2);
mm2_3 = dd3/pix2_3;

mm_pix = mean([mm1_3, mm1_2, mm2_3]);

save mm_per_pix mm_pix
save camera_params camera_params