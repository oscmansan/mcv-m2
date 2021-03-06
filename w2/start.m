clearvars;
dst = double(imread('images/lena.png'));
src = double(imread('images/girl.png')); % flipped girl, because of the eyes
[ni,nj, nChannels]=size(dst);

param.hi=1;
param.hj=1;

param.optimize = true;

%Eyes
mask_src=logical(imread('images/mask_src_eyes.png'));
mask_dst=logical(imread('images/mask_dst_eyes.png'));

for nC = 1: nChannels
    
    %TO DO: COMPLETE the ??
    %[drivingGrad_i, drivingGrad_j] = importGradients(src(:,:,nC));
    [drivingGrad_i, drivingGrad_j] = mixGradients(src(:,:,nC), dst(:,:,nC), mask_src, mask_dst);

    driving_on_src = divergence(drivingGrad_i, drivingGrad_j);

    driving_on_dst = zeros(size(src(:,:,1)));
    driving_on_dst(mask_dst(:)) = driving_on_src(mask_src(:));

    param.driving = driving_on_dst;

    dst1(:,:,nC) = sol_Poisson_Equation_Axb(dst(:,:,nC), mask_dst, param);
end

%Mouth
mask_src=logical(imread('images/mask_src_mouth.png'));
mask_dst=logical(imread('images/mask_dst_mouth.png'));

for nC = 1: nChannels
    
    %TO DO: COMPLETE the ??
    %[drivingGrad_i, drivingGrad_j] = importGradients(src(:,:,nC));
    [drivingGrad_i, drivingGrad_j] = mixGradients(src(:,:,nC), dst(:,:,nC), mask_src, mask_dst);

    driving_on_src = divergence(drivingGrad_i, drivingGrad_j);
    
    driving_on_dst = zeros(size(src(:,:,1)));
    driving_on_dst(mask_dst(:)) = driving_on_src(mask_src(:));
    
    param.driving = driving_on_dst;
    dst1(:,:,nC) = sol_Poisson_Equation_Axb(dst1(:,:,nC), mask_dst, param);
end

imshow(dst1/256)
%imwrite(dst1, 'results/lena_girl.png')

%Auxiliary functions
function [drivingGrad_i, drivingGrad_j] = importGradients(src)
    [srcGrad_i, srcGrad_j] = gradient(src);
    drivingGrad_i = srcGrad_i;
    drivingGrad_j = srcGrad_j;
end

function [drivingGrad_i, drivingGrad_j] = mixGradients(src, dst, mask_src, mask_dst)
    %Compute gradients
    [srcGrad_i, srcGrad_j] = gradient(src);
    [dstGrad_i, dstGrad_j] = gradient(dst);
    %Keep only gradients corresponding to the masked regions
    srcGrad_i = srcGrad_i(mask_src(:));
    srcGrad_j = srcGrad_j(mask_src(:));
    dstGrad_i = dstGrad_i(mask_dst(:));
    dstGrad_j = dstGrad_j(mask_dst(:));
    %Keep gradient with larger magnitude
    cond = magnitude(srcGrad_i, srcGrad_j) > magnitude(dstGrad_i, dstGrad_j);
    %Paste gradients onto final position
    drivingGrad_i = zeros(size(src));
    drivingGrad_j = zeros(size(src));
    drivingGrad_i(mask_src(:)) = where(cond, srcGrad_i, dstGrad_i);
    drivingGrad_j(mask_src(:)) = where(cond, srcGrad_j, dstGrad_j);
end

function [result] = magnitude(gx, gy)
    result = sqrt(gx.^2 + gy.^2);
end

function [result] = where(cond, x, y)
    result = zeros(size(cond));
    result(cond) = x(cond);
    result(~cond) = y(~cond);
end
