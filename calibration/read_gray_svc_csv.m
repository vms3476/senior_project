%% Import data from text file.
% Script for importing data from the following text file:
%
%    /Users/victoriascholl/Documents/senior_project/calibration/panel_reflectances/gray/gray_svc_spectra.csv
%
% To extend the code to different selected data or a different text file,
% generate a function instead of a script.

% Auto-generated by MATLAB on 2015/11/11 00:20:07

%% Initialize variables.
filename = '/Users/victoriascholl/Documents/senior_project/calibration/panel_reflectances/gray/gray_svc_spectra.csv';
delimiter = ',';
startRow = 26;

%% Format string for each line of text:
%   column1: text (%s)
%	column19: text (%s)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%s%*s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Allocate imported array to column variable names
grayWavelengths = str2double(dataArray{:, 1});
graySpectraSVC = str2double(dataArray{:, 2});

%% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans;