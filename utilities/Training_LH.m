function [YH_Red,YL_Red,YH_Green,YL_Green,YH_Blue,YL_Blue] = Training_LH(upscale,BlurWindow,nTraining)
%%% construct the HR and LR training pairs from the FEI face database
disp('Constructing the HR-LR training set...');
for i=1:nTraining
    %%% read the HR face images from the HR training set
    strh = strcat('trainingFaces/ (',num2str(i),').jpg');    
    HI = double(imread(strh)); 
    redChannel = HI(:,:,1); % Red channel
    greenChannel = HI(:,:,2); % Green channel
    blueChannel = HI(:,:,3); % Blue channel
    YH_Red(:,:,i) = redChannel;
    YH_Green(:,:,i) = greenChannel;
    YH_Blue(:,:,i) = blueChannel;
    
    %%% generate the LR face image by smooth and down-sampling
    w=fspecial('average',[BlurWindow BlurWindow]);
    SI_R = imfilter(redChannel,w);
    SI_G = imfilter(greenChannel,w);
    SI_B = imfilter(blueChannel,w);
    LI_R = imresize(SI_R,1/upscale,'bicubic');
    LI_G = imresize(SI_G,1/upscale,'bicubic');
    LI_B = imresize(SI_B,1/upscale,'bicubic');
    YL_Red(:,:,i) = LI_R;
    YL_Green(:,:,i) = LI_G;
    YL_Blue(:,:,i) = LI_B;
    LI = cat(3, LI_R, LI_G, LI_B);
    strL = strcat('trainingFaces/ (',num2str(i),')_l.jpg');
    imwrite(uint8(LI),strL,'jpg'); 
end

disp('done.');