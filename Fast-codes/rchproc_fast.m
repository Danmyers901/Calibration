function rchproc_fast(iVars,nsubs,calibration_outlets,start_year,n_years)
global VarName

% This program modified by DM 8/27/20 to be faster, by creating sim_monthly.dat or 
% sim_daily.dat files all at once. Commands can be chosen to use monthly or
% daily outputs, as well as default or minimized output positioning.

% ***Commands (change these)***
% Are the outputs monthly (0) or daily (1)?
MonthOrDay = 1;

% What position is the FLOW_OUTcms output after area in output.rch?
    % Minimized (1)
    % Default (2)
FLOW_OUTposition = 2;


%% (TEMPORARY)
% iVars = 1;
% nsubs = 64;
% calibration_outlets = [1];
% start_year = 1950;
% n_years = 50;

%% Create vectors of months (or days) and years

% Make list of years
% tic
years_list = start_year:(start_year + n_years - 1);

% Monthly outputs
if MonthOrDay == 0
    
    % Run the loop
    month_num = 1;
    no_months = 13;
    for yr_now = years_list

        % Append to Months column
        Months(month_num:(month_num + no_months-1)) = 1:no_months;

        % Append Years column
        Years(month_num:(month_num + no_months-1)) = repmat(yr_now, 1, no_months);

        % Move through the months
        month_num = month_num + no_months;
    end
    
% Daily outputs
elseif MonthOrDay == 1
        
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
end

% Output time
% time = num2str(toc);
% disp(['calculating days took ' time ' seconds'])

%% Set import options and read output file to memory

% Memory before reading file
% tic
% disp('Memory before reading file:')
% memory
    
% Initialize variables.
filename = 'output.rch';
startRow = 7;

% Format for each line of text (depending on FLOW_OUTcms position):
% (Spec's generated by importing them as a numeric matrix RCH & FLOW_OUTcms lines 7-end)
if FLOW_OUTposition == 2
    formatSpec = '%*5s%5f%*9*s%*6*s%*12*s%*12f%12f%[^\n\r]';
elseif FLOW_OUTposition == 1
    formatSpec = '%*5s%6f%*9*s%*6*s%*12f%f%[^\n\r]';
end    
    
% Open the text file.
fileID = fopen(filename,'r');

% Read columns of data according to the format.
textscan(fileID, '%[^\n\r]', startRow-1, 'WhiteSpace', '', 'ReturnOnError', false, 'EndOfLine', '\r\n');
dataArray = textscan(fileID, formatSpec, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string', 'EmptyValue', NaN, 'ReturnOnError', false);

% Close the text file.
fclose(fileID);

% Create output variable
OUTPUTFILE = [dataArray{1:end-1}];

% Clear temporary variables
clearvars filename startRow formatSpec fileID dataArray ans;

% Memory after reading file
% disp('Memory after reading file:')
% memory

% Output time
% time = num2str(toc);
% disp(['reading output file to memory took ' time ' seconds'])

%% Write output file

% Create loop (one cycle for each outlet)
% tic

% Monthly outputs
if MonthOrDay == 0
    for outlet = calibration_outlets

        % Find what rows the reach belongs to
        rch_rows = find(OUTPUTFILE(:,1) == outlet);
        rch_rows = rch_rows(1:end-1,:); % Remove that last summary row

        % Name the sim_daily.dat file
        sim_file=['sim_monthly' num2str(outlet) '.dat'];

        % Create a table
        sim_monthly = table(Years', Months', OUTPUTFILE(rch_rows,2));
        sim_monthly.Properties.VariableNames = {'Year' 'Month' 'Flow'};

        % Write it to the file
        writetable(sim_monthly, sim_file, 'Delimiter', '\t');
    end
    
% Daily outputs
elseif MonthOrDay == 1
    for outlet = calibration_outlets
    
        % Find what rows the reach belongs to
        rch_rows = find(OUTPUTFILE(:,1) == outlet);

        % Name the sim_daily.dat file
        sim_file=['sim_daily' num2str(outlet) '.dat'];

        % Create a table
        sim_daily = table(Years', Days', OUTPUTFILE(rch_rows,2));
        sim_daily.Properties.VariableNames = {'Year' 'Day' 'Flow'};

        % Write it to the file
        writetable(sim_daily, sim_file, 'Delimiter', '\t');
    end
end

% Output time
% x = num2str(length(calibration_outlets));
% time = num2str(toc);
% disp(['writing ' x ' sim files took ' time ' seconds'])
