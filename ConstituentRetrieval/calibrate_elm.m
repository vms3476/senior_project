function [ im_refl ] = calibrate_elm( x_in, y_out, im_cv )

%{ 

ELM Calibration method
Using 1D LUT per channel (as described by the x_in and y_out parameters),
converts input 16bit image code values (im_cv) to reflectance (im_refl) [0-100%] 

%}

% determine number of pixels in input image
N = numel(im_cv(:,:,1));

% create empty array to fill 
im_refl = zeros(6,N); 

% loop through bands since each has different LUT 
% perform linear interpolation using each channel's LUT to convert CV to
% reflectance
for w = 1:6 
    im_refl(w,:) = interp1(x_in, y_out(w,:),reshape(double(im_cv(:,:,w)),1,N));  
end 

im_refl = reshape(im_refl,size(im_cv));

end

