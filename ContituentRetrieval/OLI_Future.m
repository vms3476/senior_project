%%%%% Program to find the constituent concentrations based on reflectance
%%%%% values
%
% Created on 07/31/2011
%

clear all;
format long;

%% READ IN LUT/SAMPLES/OLI RESPONSE FUNCTION
SpectralLUT=load('ReformedLUT.txt'); % rows are wavelength, what are cols?
%plot_things(SpectralLUT,'SpectralLUT');

SpectralSamples=load('ReformedSamples.txt'); 
%plot_things(SpectralSamples, 'SpectralSamples');
% THIS SHOULD BE input spectra, TETRACAM imagery
% this code has LUT (spectral curves), samples, spectral response of
% cameras (read in as soon as we calibrate, multiply by the SpectralLUT). 
% Won't have to use SpectralSamples because it's already spectrally sampled. 
% Read in image data. 


SpectralResponseAll=load('OLI_VNIRwExtraBands_Response.txt');
%plot_things(SpectralResponseAll, 'SpectralResponseAll');

% Swap out different bands in model

% THIS IS WHERE I PUT TETRACAM spectral sensitivities after characterizatin
% of camera. 
% Then use it to sample water signatures

% 680
SpectralResponse=cat(2,SpectralResponseAll(:,1:5),SpectralResponseAll(:,6),SpectralResponseAll(:,11));
StepSize=[0.000135498 0.000141846 0.000132813 0.000112793 0.0001101   0.0000686035];                             % W/m^2/ster/nm
 SNR=[420 525 315 220 103 198];

% % 708
% SpectralResponse=cat(2,SpectralResponseAll(:,1:5),SpectralResponseAll(:,7),SpectralResponseAll(:,11));
% StepSize=[0.000135498 0.000141846 0.000132813 0.000112793 0.000100118 0.0000686035];                             % W/m^2/ster/nm
% % SNR=[1 57.76 41.23 18.08 95 12.25];
% % SNR=[130 130 100 90 95 90];
% % SNR=[178.75 237.5 192.5 155.25 95 144];
% % SNR=[227.5 344.5 285 220.5 95 198];
%  SNR=[420 525 315 220.5 95 198];

% % 753
% SpectralResponse=cat(2,SpectralResponseAll(:,1:5),SpectralResponseAll(:,8),SpectralResponseAll(:,11));
% StepSize=[0.000135498 0.000141846 0.000132813 0.000112793 0.0001375   0.0000686035];                             % W/m^2/ster/nm
%  SNR=[420 525 315 220 65 198];
 
% % 761
% SpectralResponse=cat(2,SpectralResponseAll(:,1:5),SpectralResponseAll(:,9),SpectralResponseAll(:,11));
% StepSize=[0.000135498 0.000141846 0.000132813 0.000112793 0.000140806 0.0000686035];                             % W/m^2/ster/nm
%  SNR=[420 525 315 220 39 198];

% % 778
% SpectralResponse=cat(2,SpectralResponseAll(:,1:5),SpectralResponseAll(:,10),SpectralResponseAll(:,11));
% StepSize=[0.000135498 0.000141846 0.000132813 0.000112793 5.76465E-05 0.0000686035];                             % W/m^2/ster/nm
%  SNR=[420 525 315 220 77 198];

%% DEFINE CONSTITUENT CONCENTRATIONS
LUT_Conc=(load('ReformedLUTConc.txt'))';
Samples_Conc=(load('ReformedSamplesConc.txt'))';

% What are these? How were they generated? Javier? 

%% INTERPOLATE AND SPECTRALLY SAMPLE LUT, SAMPLE DATA, AND ATMOSPHERE
% PROPAGATE SIGNALS TO TOA

% Read in MODTRAN file 
Atmosphere=load('MostRecentTape7Urban.txt');
Atmosphere(:,3)=Atmosphere(:,3)/100.0; % Why normalize 3rd col?

% Why are there two atmosphere? Why is the first one "actual"? 
AtmosphereUsedForRetrieval=load('MostRecentTape7Urban.txt');
AtmosphereUsedForRetrieval(:,3)=AtmosphereUsedForRetrieval(:,3)/100.0;

% Interpolate the Spectral LUT to match the spectral resolution of the system
% spectral response functions 
InterpolatedSpectralLUT=interp1(SpectralLUT(:,1),SpectralLUT(:,2:1001),SpectralResponse(:,1));
InterpolatedSpectralLUT(find(isnan(InterpolatedSpectralLUT)))=0;            %  THIS DEALS WITH NaNs IN THE DATA

InterpolatedAtmosphere=interp1(AtmosphereUsedForRetrieval(:,1),AtmosphereUsedForRetrieval(:,2:3),SpectralResponse(:,1));
InterpolatedAtmosphere(find(isnan(InterpolatedAtmosphere)))=0;            %  THIS DEALS WITH NaNs IN THE DATA

InterpolatedActualAtmosphere=interp1(Atmosphere(:,1),Atmosphere(:,2:3),SpectralResponse(:,1));
InterpolatedActualAtmosphere(find(isnan(InterpolatedActualAtmosphere)))=0;            %  THIS DEALS WITH NaNs IN THE DATA


% Multiply by the 2nd column of Atm, add 3rd column
TOA_Samples=SpectralSamples(:,2:2001).*repmat(Atmosphere(:,2),1,2000)+repmat(Atmosphere(:,3),1,2000);


InterpolatedSpectralSamples=interp1(SpectralSamples(1:120,1),TOA_Samples,SpectralResponse(:,1));
InterpolatedSpectralSamples(find(isnan(InterpolatedSpectralSamples)))=0;    %  THIS DEALS WITH NaNs IN THE DATA

% SPECTRALLY SAMPLE
% ... the constituent curves using the system filter curves 
for n = 2:7
    SpecSampledLUT(:,n-1) = (sum(InterpolatedSpectralLUT.*repmat(SpectralResponse(:,n),1,1000),1)./sum(repmat(SpectralResponse(:,n),1,1000),1));
    SpecSampledData(:,n-1) = (sum(InterpolatedSpectralSamples.*repmat(SpectralResponse(:,n),1,2000),1)./sum(repmat(SpectralResponse(:,n),1,2000),1));
    SpecSampledAtmosphere(:,n-1) = (sum(InterpolatedAtmosphere.*repmat(SpectralResponse(:,n),1,2),1)./sum(repmat(SpectralResponse(:,n),1,2),1));
    SpecSampledActualAtmosphere(:,n-1) = (sum(InterpolatedActualAtmosphere.*repmat(SpectralResponse(:,n),1,2),1)./sum(repmat(SpectralResponse(:,n),1,2),1));
end

RetrievedSS_Data=(SpecSampledData-repmat(SpecSampledAtmosphere(2,:),2000,1))./repmat(SpecSampledAtmosphere(1,:),2000,1);

%% ADD QUANTIZATION
% StepSize=[412         442         490         510        560         620         665         681       708         753       761         778         865         885         900]
% StepSize=[0.000150358 0.000168268 0.000183833 0.00016989 0.000148049 0.000129938 0.000108673 0.0001101 0.000100118 0.0001375 0.000140806 5.76465E-05 5.64043E-05 9.68608E-05 8.61782E-05];                             % W/m^2/ster/nm

StepSizeArray=repmat(StepSize,2000,1);
QuantizedData = round(SpecSampledData./StepSizeArray).*StepSizeArray;
RetrievedQuantized_Data=(QuantizedData-repmat(SpecSampledAtmosphere(2,:),2000,1))./repmat(SpecSampledAtmosphere(1,:),2000,1);

%% ADD NOISE
% StepSize=[412         442  490         510        560         620         665         681     708       753       761         778         865         885         900]
% SNR=[368.8111667 318.8385 269.385 254.8418333 183.73815 128.6870667 114.0404667 102.9846833 94.78085 64.88645 39.28176667 76.63836667 57.19593333 40.03741667 38.66223333];
ROI=1;
for n = 1:2000
    test=repmat(SpecSampledData(n,:),ROI,1);
    Noise=test./repmat(SNR,ROI,1);                                %  SNR=S/N   -->  N=S/SNR
    RandomNumbers=randn(ROI,6);
    NoiseData(n,:)=mean((test+Noise.*RandomNumbers),1);
end
NoiseQuantizedData = round(NoiseData./StepSizeArray).*StepSizeArray;
RetrievedNoiseActualData=(NoiseQuantizedData-repmat(SpecSampledActualAtmosphere(2,:),2000,1))./repmat(SpecSampledActualAtmosphere(1,:),2000,1);
RetrievedNoise_Data=(NoiseQuantizedData-repmat(SpecSampledAtmosphere(2,:),2000,1))./repmat(SpecSampledAtmosphere(1,:),2000,1);



%% OPTIMIZATION STUFF

% STRAIGHT TO HERE after camera response and reading imagery

% [CDOM, SM, CHL]
[f2,f1,f3] = ndgrid([0.25 0.50 0.75 1.0 2.0 4.0 7.0 10.0 12.0 14.0],[0.25 0.50 1.0 2.0 4.0 8.0 10.0 14.0 20.0 24.0],[0.25 0.50 1.0 3.0 5.0 7.0 12.0 24.0 46.0 68.0]);
%options = optimset('Display','on');%,'LevenbergMarquardt','on');
options = optimoptions(@lsqnonlin,'Algorithm','levenberg-marquardt','MaxFunEvals',2000);
options.TolFun =[0.0000000001];

RetrievedSamples=Samples_Conc;
SampleData=RetrievedNoise_Data;
n=100
for i = 1:n%size(RetrievedSamples,1)
%     f = myfun_mod(x0,X1,X2,X3,Ys,Yn)
%     plot(Samples_Data(i,:), 'Color', 'red')
%     hold on
    a=sum((SpecSampledLUT-repmat(SampleData(i,:),1000,1)).^2,2);
    index=find(a==min(a));
    x0=LUT_Conc(index,:);
    if x0(1)==68, x0(1)=46; end
    if x0(2)==24, x0(2)=20; end
    if x0(3)==14, x0(3)=12; end
    RetrievedSamples(i,:) = lsqnonlin(@myfun_mod,x0,[0.25;0.25;0.25],[68.0;24.0;14.0],options,f1,f2,f3,SpecSampledLUT(:,2:6),SampleData(i,2:6));
    i
end
%% ERROR REPRESENTATION
figure(1)
plot(RetrievedSamples(1:n,1), Samples_Conc(1:n,1), 'ro')
hold on;

figure(2)
plot(RetrievedSamples(1:n,2), Samples_Conc(1:n,2), 'go')
hold on;

figure(3)
plot(RetrievedSamples(1:n,3), Samples_Conc(1:n,3), 'bo')
hold on;

RetrievalErrors=mean(abs(RetrievedSamples(1:n,:)-Samples_Conc(1:n,:)))
Samples_Conc(find((Samples_Conc==0)))=0.0001;

AbsoluteRetrievalErrors=mean((abs(RetrievedSamples(1:n,:)-Samples_Conc(1:n,:)))./Samples_Conc(1:n,:))
PercentRetrievalErrors=[RetrievalErrors(:,1)/68.0,RetrievalErrors(:,2)/24.0,RetrievalErrors(:,3)/14.0]*100.00

