%% This code creates obs_daily_SWE files from Mote 2018 NetCDF.
% Dan Myers, 7/11/2020
clear

%% Input the subbasin, latitude of snow depth grid point, and longitude of SWE grid point.
% (can do a bunch of them at once inside [])

%%%%%(Edit these)%%%%%
% sub_no = [1121 820]; % Subbasin numbers
% lat_input = [44.5 45.5]; % Latitudes of snowfall points
% lon_input = [-84.5 -84.5]; % Longitudes of snowfall points

% Import these from a csv.
sub_lat_lon = csvread('StJoe_subbasin_lat_lon.csv',1,0);
sub_no = sub_lat_lon(:,1);
lat_input = sub_lat_lon(:,2);
lon_input = sub_lat_lon(:,3);

%% Read NC files
file1 = 'G10021-noram-stp-1959-2009.v01r00.nc';
%ncdisp(file1);

lat = ncread(file1, 'latitude');
lon = ncread(file1, 'longitude');
snowfall_m = ncread(file1, 'snowfall');
snow_depth_m = ncread(file1, 'snow_depth');
SWE_mm = ncread(file1, 'SnowWaterEquivalent_mm');

%days_since_1959_08_31 = ncread(file1, 'time');

%% Import time step in correct format (e.g. 19590901)
time_step = num2str(csvread('TimeStep_1959-2009.csv')); % Place this .csv in the same folder.

%% Start a loop that creates an obs_daily_SWE file for each subbasin
for i = 1:length(sub_no)
    
    %% Clear old data
    clear monthly_data fid month month_check year day sub_data
    
    %% Extract the daily SWE time series for the subbasin.
    lat_position = find(lat == lat_input(i));
    lon_position = find(lon == lon_input(i));
    temporary = SWE_mm(lon_position,lat_position,:);
    sub_data = temporary(:);

    %% Extract daily data with year, month, day, SWE format
    for t = 1:length(time_step);
        year(t,:)=str2num(time_step(t,1:4));
        month(t,:)=str2num(time_step(t,5:6));
        day(t,:)=str2num(time_step(t,7:8));
    end

    daily_data = [year month day sub_data]; % collects all daily data 

    %% Convert daily to monthly average
%     monthly_data = [];
%     for m = min(daily_data(:,1)):max(daily_data(:,1))
%         year = daily_data( daily_data(:,1) == m , : );
%         for n = 1:12;
%             month_check = (year(year(:, 2) == n, :));
%             if size(month_check,1) == 1
%                 monthly_data = [monthly_data; month_check];
%             elseif size(month_check,1)> 1
%                 month = nanmean(year(year(:, 2) == n, :));
%                 month(4) = nanmean(year(year(:,2)== n, 4)); % Added to average the monthly SWE data in mm
%                 monthly_data = [monthly_data; month];
%             end
%         end
%     end

    %% Write to obs_daily_SWE file, in units of mm 
    %monthly_data(:,3) = 1; %changes all day values to 1
    daily_data(any(isnan(daily_data),2),:)=[]; % removes all NaN values if present

    outfile=sprintf('obs_daily_OF3_%g.csv',sub_no(i));%name of CSV file
    fid=fopen(outfile,'wt');
    fprintf(fid, 'Year, Month, Day, SWE_mm\n');%#write CSV header
    fprintf(fid,'%g,%g,%g,%g\n',transpose([daily_data(:,1),daily_data(:,2),daily_data(:,3),daily_data(:,4)])); %write the data
    fclose(fid);
    
end
