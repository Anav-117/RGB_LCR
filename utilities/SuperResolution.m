function [im_Channel, im_l, im_Diff] = SuperResolution(im_h,upscale,BlurWindow,YH,YL,patch_size,overlap,tau,nrow,ncol,TestImgIndex)

% generate the input LR face image by smooth and down-sampleing
w       = fspecial('average',[BlurWindow BlurWindow]);
im_s    = imfilter(im_h,w);
im_l    = imresize(im_s,1/upscale,'bicubic');
im_l    = double(im_l);
%     figure,imshow(im_l);title('input LR face');

% face hallucination via LcR
[im_Channel] = LcRSR(im_l,YH,YL,upscale,patch_size,overlap,tau);
[im_Channel] = uint8(im_Channel);

% bicubic interpolation for reference
im_b = imresize(im_l, [nrow, ncol], 'bicubic');

% compute PSNR and SSIM for Bicubic and our method
% bb_psnr(TestImgIndex) = psnr(im_b,im_h);
% bb_ssim(TestImgIndex) = ssim(im_b,im_h);
% 
% sr_psnr(TestImgIndex) = psnr(im_Channel,im_h);
% sr_ssim(TestImgIndex) = ssim(im_Channel,im_h);
% 
% % display the objective results (PSNR and SSIM)
% fprintf('PSNR for Bicubic Interpolation: %f dB\n', bb_psnr(TestImgIndex));
% fprintf('PSNR for LcR Recovery: %f dB\n', sr_psnr(TestImgIndex));
% fprintf('SSIM for Bicubic Interpolation: %f dB\n', bb_ssim(TestImgIndex));
% fprintf('SSIM for LcR Recovery: %f dB\n', sr_ssim(TestImgIndex));

% show the images
%     figure, imshow(im_b);
%     title('Bicubic Interpolation');
%     figure, imshow(uint8(im_SR));
%     title('LcR Recovery');

% save the result
% strw = strcat('results_channel/',num2str(TestImgIndex),'_SR.bmp');
% imwrite(uint8(im_Channel),strw,'bmp');

im_Channel = uint8(im_Channel);

im_Diff = imsubtract(im_h, im_Channel);