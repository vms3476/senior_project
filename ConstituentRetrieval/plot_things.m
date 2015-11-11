function [  ] = plot_things( thingToPlot, thingTitle)
% This function plots the input spectral variable.
% Assumes first column contains wavelength.

% Set font size for title and axes labels
fs = 14; 

figure; hold on;
colorString = 'kbgrykbgrykbgrkbgrykbgrykbgrkbgrykbgrykbgrkbgrykbg';
x = thingToPlot(:,1);

% Loop through columns, plot each as a different color
for i=2:size(thingToPlot,2)
    if size(thingToPlot,2)>50
        plot(x,thingToPlot(:,i))
   
    else
        plot(x,thingToPlot(:,i),colorString(i))
    end
end
xlabel('Wavelength [nm]','FontSize',fs)
ylabel('Transmission','FontSize',fs)
title(['Specral Response Curves: ' thingTitle],'FontSize',fs)


end

