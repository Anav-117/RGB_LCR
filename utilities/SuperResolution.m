function [im_Channel, im_l, im_Diff, im_b] = SuperResolution(im_h,upscale,BlurWindow,YH,YL,patch_size,overlap,tau,nrow,ncol)

% generate the input LR face image by smooth and down-sampleing
w       = fspecial('average',[BlurWindow BlurWindow]);
im_s    = imgaussfilt(im_h); % imfilter(im_h,w);
im_l    = imresize(im_s,1/upscale,'bicubic');
im_l    = double(im_l);
%     figure,imshow(im_l);title('input LR face');

% face hallucination via LcR
[im_Channel] = LcRSR(im_l,YH,YL,upscale,patch_size,overlap,tau);
[im_Channel] = uint8(im_Channel);

% bicubic interpolation for reference
im_b = imresize(im_l, [nrow, ncol], 'bicubic');

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