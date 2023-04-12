
% =========================================================================
% Face Hallucination via Locality-constrained Representation
% Example code
%
% Reference
% [1] Junjun Jiang, Ruimin Hu, Zhen Han, Tao Lu, Kebin Huang, ¡°Position-Patch Based 
% Face Hallucination via Locality-constrained Representation,¡± in the International 
% Conference on Multimedia and Expo (ICME 2012), Melbourne, Australia, pp. 212-217, Jul 2012.
%
% [2]Junjun Jiang, Ruimin Hu, Zhongyuan Wang, and Zhen Han, "Noise Robust Face 
% Hallucination via Locality-constrained Representation," TMM, 2014
%
% For any questions, email me by jiangjunjun@whu.edu.cn
%=========================================================================



clc;close all;
clear all;
addpath('utilities');

% set parameters
nrow        = 360;        % rows of HR face image
ncol        = 260;        % cols of HR face image
nTraining   = 360;        % number of training sample
nTesting    = 40;         % number of ptest sample
upscale     = 16;          % upscaling factor 
BlurWindow  = 4;          % size of an averaging filter 
tau         = 0.04;       % locality regularization
patch_size  = 48;         % image patch size
overlap     = 4;          % the overlap between neighborhood patches

YH_Red      = zeros(nrow,ncol,nTraining); 
YL_Red      = zeros(nrow,ncol,nTraining);
YH_Green    = zeros(nrow,ncol,nTraining); 
YL_Green    = zeros(nrow,ncol,nTraining);
YH_Blue     = zeros(nrow,ncol,nTraining); 
YL_Blue     = zeros(nrow,ncol,nTraining);

bb_psnr    = zeros(1,nTesting);
sr_psnr    = zeros(1,nTesting);
bb_ssim    = zeros(1,nTesting);
sr_ssim    = zeros(1,nTesting);


% generate the training and testing samples from the FEI Face Database
% FEIDBResize(nrow,ncol,nTraining);% we have genetaed the  training and testing samples from 
% FEI Face Database, and you can download it from 'http://fei.edu.br/~cet/facedatabase.html' also.

% TRAINING
% construct the HR and LR training pairs from the FEI face database
[YH_Red, YL_Red, YH_Green, YL_Green, YH_Blue, YL_Blue] = Training_LH(upscale,BlurWindow,nTraining);

fprintf('\nface hallucinating for %d input test images\n', nTesting);

for TestImgIndex = 1:nTesting

    fprintf('\nProcessing  %d/%d LR image\n', TestImgIndex,nTesting);

    % read ground truth of one test face image
    strh    = strcat('testFaces/ (',num2str(TestImgIndex),').jpg');
    im_h    = imread(strh);

    redChannel = im_h(:,:,1); % Red channel
    greenChannel = im_h(:,:,2); % Green channel
    blueChannel = im_h(:,:,3); % Blue channel

    [im_Channel_Red, im_L_Red, Diff_Red, im_b_R] = SuperResolution(redChannel,upscale,BlurWindow,YH_Red,YL_Red,patch_size,overlap,tau,nrow,ncol);
    [im_Channel_Blue, im_L_Blue, Diff_Blue, im_b_B] = SuperResolution(blueChannel,upscale,BlurWindow,YH_Blue,YL_Blue,patch_size,overlap,tau,nrow,ncol);
    [im_Channel_Green, im_L_Green, Diff_Green, im_b_G] = SuperResolution(greenChannel,upscale,BlurWindow,YH_Green,YL_Green,patch_size,overlap,tau,nrow,ncol);
    
    im_SR = cat(3, im_Channel_Red, im_Channel_Green, im_Channel_Blue);
    im_bb = cat(3, im_b_R, im_b_G, im_b_B);

    YCBCR_H = rgb2ycbcr(im_h);
    YCBCR_SR = rgb2ycbcr(im_SR);
    YCBCR_BB = rgb2ycbcr(im_bb);

    luma_H = YCBCR_H(:,:,1);
    luma_SR = YCBCR_SR(:,:,1);
    luma_BB = YCBCR_BB(:,:,1);

    % compute PSNR and SSIM for Bicubic and our method
    bb_psnr(TestImgIndex) = psnr(luma_BB,luma_H);
    bb_ssim(TestImgIndex) = ssim(luma_BB,luma_H);
    
    sr_psnr(TestImgIndex) = psnr(luma_SR,luma_H);
    sr_ssim(TestImgIndex) = ssim(luma_SR,luma_H);

    % display the objective results (PSNR and SSIM)
    fprintf('PSNR for Bicubic Interpolation: %f dB\n', bb_psnr(TestImgIndex));
    fprintf('PSNR for LcR Recovery: %f dB\n', sr_psnr(TestImgIndex));
    fprintf('SSIM for Bicubic Interpolation: %f dB\n', bb_ssim(TestImgIndex));
    fprintf('SSIM for LcR Recovery: %f dB\n', sr_ssim(TestImgIndex));

    strw = strcat('results/',num2str(TestImgIndex),'_SR.bmp');
    imwrite(uint8(im_SR),strw,'bmp');

    im_L = cat(3, im_L_Red, im_L_Green, im_L_Blue);
    strL = strcat('results/',num2str(TestImgIndex),'_l.jpg');
    imwrite(uint8(im_L),strL,'jpg');

    im_Diff = cat(3, Diff_Red, Diff_Green, Diff_Blue);
    strL = strcat('results/',num2str(TestImgIndex),'_Diff.jpg');
    imwrite(uint8(im_Diff),strL,'jpg');
end


fprintf('===============================================\n');
fprintf('Average PSNR of Bicubic Interpolation: %f\n', sum(bb_psnr)/nTesting);
fprintf('Average PSNR of LcR method: %f\n', sum(sr_psnr)/nTesting);
fprintf('Average SSIM of Bicubic Interpolation: %f\n', sum(bb_ssim)/nTesting);
fprintf('Average SSIM of LcR method: %f\n', sum(sr_ssim)/nTesting);
fprintf('===============================================\n');

