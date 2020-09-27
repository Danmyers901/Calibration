function hruproc_fast(iVars,nsubs,calibration_outlets,start_year,n_years)
global VarName

% This program modified by DM 8/27/20 to be faster, by creating sim_daily.dat files all at once.

%% (TEMPORARY)
% iVars = 1;
% nsubs = 64;
% calibration_outlets = 1:2;
% start_year = 1950;
% n_years = 50;


%% Create vectors of days and years

% Make list of years
%tic
years_list = start_year:(start_year + n_years - 1);

% Run the loop
day_num = 1;
for yr_now = years_list
    
    % Account for leap years
    if rem(yr_now,4)==0
        no_days = 366;
    else
        no_days = 365;
    end
    
    % Append to Days column
    Days(day_num:(day_num + no_days-1)) = 1:no_days;
    
    % Append Years column
    Years(day_num:(day_num + no_days-1)) = repmat(yr_now, 1, no_days);
    
    % Move through the days
    day_num = day_num + no_days;
end

% Output time
%time = num2str(toc);
%disp(['calculating days took ' time ' seconds'])

%% Set import options and read output file to memory

% Memory before reading file
%tic
%disp('Memory before reading file:')
%memory

% Initialize variables
filename = 'output.hru';
startRow = 7;

% Format for each line of text
formatSpec = '%*4s%5f%*10f%5f%*5*s%*15f%f%[^\n\r]';

% Open the text file.
fileID = fopen(filename,'r');

% Read columns of data according to the format
textscan(fileID, '%[^\n\r]', startRow-1, 'WhiteSpace', '', 'ReturnOnError', false, 'EndOfLine', '\r\n');
dataArray = textscan(fileID, formatSpec, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string', 'EmptyValue', NaN, 'ReturnOnError', false);

% Close the text file.
 fclose(fileID);

% Create output variable
OUTPUTFILE = [dataArray{1:end-1}];

% Clear temporary variables
clearvars filename startRow formatSpec fileID dataArray ans;

% Memory after reading file
%disp('Memory after reading file:')
%memory

% Output time
%time = num2str(toc);
%disp(['reading output file to memory took ' time ' seconds'])


%% Write output file

% Create loop (one cycle for each outlet)
%tic
for outlet = calibration_outlets
    
    % Find what rows the subbasin belongs to and shape it correctly
    sub_rows = find(OUTPUTFILE(:,2) == outlet);
    new_rows = reshape(sub_rows, length(sub_rows)./length(Days), length(Days));
    
    % Choose the first HRU for each subbasin
    first_sub_row = new_rows(1,:);
    
    % Name the sim_daily_snow.dat file
    sim_file=['sim_daily_OF3_' num2str(outlet) '.dat'];
    
    % Create a table
    sim_daily = table(Years', Days', OUTPUTFILE(first_sub_row,3));
    sim_daily.Properties.VariableNames = {'Year' 'Day' 'SNOmm'};
    
    % Write it to the file
    writetable(sim_daily, sim_file, 'Delimiter', '\t');
end

% Output time
%x = num2str(length(calibration_outlets));
%time = num2str(toc);
%disp(['writing ' x ' sim_daily files took ' time ' seconds'])



