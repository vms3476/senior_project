close('all')

% Plotting spectral response curves


% Set font size for title and axes labels
fs = 14; 

% Define the variable to plot. Assumes first column contains wavelength
thingToPlot = SpectralResponse;
thingToPlot = SpectralResponseAll;
thingToPlot = SpectralLUT;

figure; hold on;
colorString = 'kbgrykbgrykbgrkbgrykbgrykbgrkbgrykbgrykbgrkbgrykbgrykbgr';
x = thingToPlot(:,1);

% Loop through columns, plot each as a different color
for i=2:size(thingToPlot,2)
    plot(x,thingToPlot(:,i),colorString(i))
end
xlabel('Wavelength [nm]','FontSize',fs)
ylabel('Transmission','FontSize',fs)
title('Specral Response Curves','FontSize',fs)

