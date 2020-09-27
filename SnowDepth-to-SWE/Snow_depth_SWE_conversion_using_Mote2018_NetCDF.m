% Convert snow depth to SWE
% Using model from Hill et al. 2018 "Converting snow depth to snow water equivalent using climatological variables"
% and snow data from Mote et al. 2018 "Daily Gridded North American Snow, Temperature, and Precipitation, 1959-2009"

% Dan Myers, 7/8/2020

% If the snow depth is zero, print zero. Otherwise run this equation.


%% Access the NetCDF and time step data
file1 = 'G10021-noram-stp-1959-2009.v01r00.nc'; % Name of .nc file
time_step = num2str(csvread('TimeStep_1959-2009.csv')); % Place this time step .csv in the same folder.
water_year = csvread('water_year_1959-2009.csv'); % Water year (beginning Oct 1, named after ending year)
month = csvread('month_1959-2009.csv'); % Month


%% Set h variable for snow depth (mm)
snow_depth_m = ncread(file1, 'snow_depth');
h = snow_depth_m * 1000; % Convert m to mm
clearvars snow_depth_m

%% Set PPTWT variable for sum of winter precipitation in water year (December + January + February, mm)
precip_m = ncread(file1, 'precipitation');
precip_mm = precip_m * 1000; % Convert m to mm
clearvars precip_m

% Prealocate PPTWT
PPTWT = zeros(size(h,1), size(h,2), size(h,3));

% Then need to sum Dec + Jan + Feb precip_mm for each water year
for yr = 1960:2009
    for lon = 1:size(h,1)
        for lat = 1:size(h,2)
            PPTWT(lon,lat,find(water_year==yr)) = sum(precip_mm(lon,lat,(water_year==yr & (month==12 | month==1 | month==2))));
        end
    end
    'PPTWT finished for ',yr
end

clearvars precip_mm

%% Set TD variable for difference between mean temperature of warmest month and coldes month in water year (C)
Tmax = ncread(file1, 'temperature_max'); % maximum daily temperature
Tmin = ncread(file1, 'temperature_min'); % minimum daily temperature
Tmean = (Tmax + Tmin) / 2; % mean daily temperature
clearvars Tmax Tmin

% Prealocate TD and monthlyT
TD = zeros(size(h,1), size(h,2), size(h,3));
monthlyT = zeros(1,12);

% Convert mean daily temperature to mean monthly temperature, identify the
% warmest and coldest months each water year, and find the difference between
% them.
for yr = 1960:2009
    for lon = 1:size(h,1)
        for lat = 1:size(h,2)
            for mo = 1:12
                monthlyT(mo) = mean(Tmean(lon,lat,(water_year==yr & (month==mo))));
            end
            TD(lon,lat,find(water_year==yr)) = max(monthlyT) - min(monthlyT);
        end
    end
    'TD finished for ',yr
end

clearvars Tmean

%% Set DOY variable for day of water year (beginning Oct 1)
DOY = csvread('Date_of_water_year_1959-2009.csv'); % Number of days since start of water year (October 1 = 1)


%% Equations 7 & 8 (accumulation SWE and ablation SWE)

% These are the fitted coefficients.
A = 0.0533;
a1 = 0.9480;
a2 = 0.1701;
a3 = -0.1314;
a4 = 0.2922;
B = 0.0481;
b1 = 1.0395;
b2 = 0.1699;
b3 = -0.0461;
b4 = 0.1804;

% These are the equations for accumulation and ablation SWE.
% SWEacc: snow water equivalent for accumulation (mm)
% SWEabl: snow water equivalent for ablation (mm)
SWEacc = zeros(size(h,1), size(h,2), size(h,3));
SWEabl = zeros(size(h,1), size(h,2), size(h,3));

for lon = 1:size(h,1);
    for lat = 1:size(h,2);
        for day = 1:length(time_step)
            SWEacc(lon,lat,day) = A * h(lon,lat,day).^a1 * PPTWT(lon,lat,day).^a2 * TD(lon,lat,day).^a3 * DOY(day).^a4;
            SWEabl(lon,lat,day) = B * h(lon,lat,day).^b1 * PPTWT(lon,lat,day).^b2 * TD(lon,lat,day).^b3 * DOY(day).^b4;
        end
    end
    'Completed SWEacc lon ',lon
end
'SWEacc and SWEabl calculated'

%% Equation 5 (2-equation model)

% SWE: snow water equivalent (mm)
SWE = zeros(size(h,1), size(h,2), size(h,3));
DOYstar = 180; % Day of water year that separates accumulation from ablation phases, and should be set to 180.

for lon = 1:size(h,1);
    for lat = 1:size(h,2);
        for day = 1:length(time_step)
            SWE(lon,lat,day) = SWEacc(lon,lat,day) * 1/2 * (1 - tanh(0.01 * (DOY(day) - DOYstar))) +...
                               SWEabl(lon,lat,day) * 1/2 * (1 + tanh(0.01 * (DOY(day) - DOYstar)));
        end
    end
    'Completed SWE lon ',lon
end
'SWE calculated'

%% Save SWE to the NetCDF

% It's in a lon,lat,day grid like the rest of the data.
% nccreate(file1, 'SnowWaterEquivalent_mm', 'Dimensions',{'longitude',114,'latitude',58,'time',18385});
% ncwrite(file1, 'SnowWaterEquivalent_mm',SWE_mm);
% 'SWE data saved to NetCDF'