% Victoria Scholl - Tetracam Imagery - Team Water
% 11/9/15

% This script reads in 16bit TIF tetracam image data

%% declare font size variable for plot labels
fs = 14;

% declare list of filter center wavelengths
filterCenters = [490 550 680 720 800 900];

%% image directory
imDir = '../ConesusLake20151023_b/';

% get filenames of all images in directory
imFilenames = dir([imDir '*.TIF']);

% determine the number of images with specified extension
numberOfImages = size(imFilenames,1);

% read in 16-bit tif. 6 bands. order: B G R NIR1 NIR2 NIR3
im = imread([imDir imFilenames.name]);

% declare subset
i = im(:,:,2);

% display 8-bit scaled version
imScaled = uint8(round(double(i)./double(max((max(max(i)))))*255));
imshow(imScaled)

%% read in and display image containing calibration targets

figure;
set(gcf, 'Name', 'Frame with Calibration Targets')

% read in image containing cal targets 
calDir = [imDir 'cal_target_images/'];
calFilename = 'TTC03570_16.TIF';
calIm = imread([calDir calFilename]);

% isolate a single band
i = calIm(:,:,1:3);

% display 8-bit scaled version
imScaled = uint8(round(double(i)./double(max((max(max(i)))))*255));
imScaled = uint8(round(double(calIm)./double(max((max(max(calIm)))))*255));

rScaled = imScaled(:,:,3);
gScaled = imScaled(:,:,2);
bScaled = imScaled(:,:,1);
rgbScaled = cat(3,rScaled,gScaled,bScaled);
imshow(rgbScaled);

%% User manually selects ROI's for each target (in Digital Counts)

% Uses roipoly function to obtain the approximate upper left and lower 
% right corner coordinates. the rectangle to which this diagonal line
% belongs is used to sample the calibration target image. 

figure; set(gcf, 'Name', 'Click in upper left corner of GRAY panel. Next, click lower right to create a diagonal line. Then double click either point to continue.');
[lightTargetMask xGray yGray] = roipoly(rgbScaled);
close(gcf);

figure; set(gcf, 'Name', 'Click in upper left corner of BLACK panel. Next, click lower right to create a diagonal line. Then double click either point to continue.');
[darkTargetMask xBlack yBlack] = roipoly(rgbScaled);
close(gcf);

%% round decimal values to be integers representing pixel indices
%  for two panel subsets based on the ROI's 

xGray = round(xGray);
yGray = round(yGray);
xBlack = round(xBlack);
yBlack = round(yBlack);

% scaled image used to display the subset
figure;
set(gcf, 'Name', 'Calibration Target Subsets from Image')

subplot(2,2,1);
grayPanelSubset = rgbScaled(yGray(1):yGray(2),xGray(1):xGray(2));
imshow(grayPanelSubset) 
title('Gray Calibration Target Selected Area','FontSize',fs)

subplot(2,2,2);
blackPanelSubset = rgbScaled(yBlack(1):yBlack(2),xBlack(1):xBlack(2));
imshow(blackPanelSubset) 
title('Black Calibration Target Selected Area','FontSize',fs)

% index into the calibration target image and take the average
% to yield a 6-point spectra for each target

grayPanel_6 = calIm(yGray(1):yGray(2),xGray(1):xGray(2),:);
blackPanel_6 = calIm(yBlack(1):yBlack(2),xBlack(1):xBlack(2),:);

subplot(2,2,3);
grayDCAvgSpectra = reshape(mean(mean(grayPanel_6)),1,6);
plot(filterCenters,grayDCAvgSpectra)
ylim([0,2^16])
xlabel('Wavelength [nm]','FontSize',fs')
ylabel('16bit CV','FontSize',fs')

subplot(2,2,4);
blackDCAvgSpectra = reshape(mean(mean(blackPanel_6)),1,6);
plot(filterCenters,blackDCAvgSpectra)
ylim([0,2^16])
xlabel('Wavelength [nm]','FontSize',fs')
ylabel('16bit CV','FontSize',fs')


%% read in 4 SVC reflectance spectra per panel, average
run('../calibration/read_gray_svc_csv.m')
run('../calibration/read_black_svc_csv.m')

% to then plot versus HYDROLIGHT or SVC WATER SPECTRA. 
figure; hold on;
plot(blackWavelengths,blackSpectraSVC,'--k')
plot(grayWavelengths,graySpectraSVC,'k')
title('SVC Reflectance Spectra for Water Calibration Targets','FontSize',fs)
ylabel('Reflectance [%]','FontSize',fs)
xlabel('Wavelength [nm]','FontSize',fs)
xlim([400 1000])

% plot vertical lines indicating where each filter center lies
plot([filterCenters(1) filterCenters(1)],[0 20],'b')
plot([filterCenters(2) filterCenters(2)],[0 20],'g')
plot([filterCenters(3) filterCenters(3)],[0 20],'r')
plot([filterCenters(4) filterCenters(4)],[0 20],'c')
plot([filterCenters(5) filterCenters(5)],[0 20],'m')
plot([filterCenters(6) filterCenters(6)],[0 20],'y')


% label each curve as a panel or filter 
legend('Target: Black ~0%', 'Target: Gray ~16%','Filter: 490',...
       'Filter: 550','Filter: 680', 'Filter: 720','Filter: 800', 'Filter: 900')
   
%% ELM 

% sample the panel reflectance curves to the filter center values
blackSpectraSVCSampled = zeros(1,6);
graySpectraSVCSampled = zeros(1,6);
for w = 1:6
    [x b_index] = min(abs(round(blackWavelengths)-filterCenters(w)))
    blackSpectraSVCSampled(1,w) = blackSpectraSVC(b_index);
    
    [x g_index] = min(abs(round(grayWavelengths)-filterCenters(w)))
    graySpectraSVCSampled(1,w) = graySpectraSVC(g_index);
end

figure; hold on;
scatter(filterCenters, blackSpectraSVCSampled)
scatter(filterCenters, graySpectraSVCSampled)
title('Sampled Panel Reflectances to Filter Centers','FontSize',fs)
xlabel('Wavelength [nm]','FontSize',fs)
ylabel('Reflectance [%]','FontSize',fs)


%% Interpolate to create 1D LUT for each channel? 

% Create 1D LUT for each filter 
% input is 16bit CV 
x_in = 1:1:2^16;
y_out = zeros(6,2^16);

slopes = zeros(1,6);
y_intercepts = zeros(1,6);

figure; hold on;
colors = ['r' 'g' 'b' 'k' 'm' 'c'];
for w = 1:6
x1 = blackDCAvgSpectra(w);
x2 = grayDCAvgSpectra(w);
y1 = blackSpectraSVCSampled(w);
y2 = graySpectraSVCSampled(w);
slopes(w) = (y2-y1)/(x2-x1);
y_intercepts(w) = y1 - m*x1;
y_out(w,:) = x_in * slopes(w) - y_intercepts(1);

% apply equation to all possible 16bit CV to yield reflectance LUT
plot(x_in, y_out(w,:),colors(w))
end
legend('Filter: 490','Filter: 550','Filter: 680', 'Filter: 720','Filter: 800', 'Filter: 900')


%% Using GPS information, be able to select 2 adjacent images 

[filenames, lat, long, alt] = textread([imDir 'gps.txt'], '%s %f %f %f','delimiter', ',');
figure; hold on;
scatter(lat,long,'r.')
title('Camera Center Locations','FontSize',fs)
xlabel('Latitude','FontSize',fs)
ylabel('Longitude','FontSize',fs)


%% constituent retrieval 

% gather spectral readings and cosntituent levels
% Ryan create LUT? 
% never sampled at Conesus before.
% long pond LUT should be the same. same watershed for years. been
% measuring IOPs of water
% for long pond, set a threshold to ignore the glint pixels before doing
% constituent analysis
% when creating constituent maps, leave glint pixels as zero. 
% glint avoidance in the future - minimize through TOD choice. 
% nothing we can do about glint and mosaic right now. Need to purchase IMU.
% Mosaic - since we may end up down-sampling resolution for comparison to
% Landsat, it might be ok to do a rough projection 

