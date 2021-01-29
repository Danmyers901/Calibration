function [outputs_snowmelt, outputs_groundwater, outputs_water_yield] = Summary_making_code_daily(iRun,X,Extra)

% Make summaries
% This code makes summaries of SWAT outputs after each iteration for
% monthly mean, basin-averaged.
% Dan Myers, 12/31/2020

% Go to directory
path_sim=iRun;
cd([Extra.SimulationDir '/sim' num2str(path_sim)])

%% Starting variables
nsubs = Extra.nsub; % number of subbasins
years_span = Extra.start_year:(Extra.start_year+Extra.nyear-1);

% Temporary
%nsubs = 64; % number of subbasins
%years_span = 1950:1999; % years of simulation (e.g. 1960:1999)

% Are the outputs monthly (0) or daily (1)?
MonthOrDay = 1; % Note: use companion .m file for monthly...hasn't been integrated with this one yet.


%% Run CMIP5 model extraction
n=nsubs ; % number of subbasins

% Monthly outputs
if MonthOrDay == 0
    
    % Calculate months
    mo=(1:13)'; % months
    r=repmat(mo,1,n)';
    r=r(:);
    Months = repmat(r,length(years_span),1); 

    % Calculate years
    yr = years_span'; %*
    r=repmat(yr,1,n*13)';
    Years =r(:);
    
% Daily outputs
elseif MonthOrDay == 1
    
    % Calculate days
    day_num=0;
    for yr_now = years_span

        % Account for leap years
        if rem(yr_now,4)==0
            no_days = 366;
            month = [repmat(1,1,31), repmat(2,1,29), repmat(3,1,31), repmat(4,1,30), repmat(5,1,31), repmat(6,1,30), repmat(7,1,31), repmat(8,1,31), repmat(9,1,30), repmat(10,1,31), repmat(11,1,30), repmat(12,1,31)];
        else
            no_days = 365;
            month = [repmat(1,1,31), repmat(2,1,28), repmat(3,1,31), repmat(4,1,30), repmat(5,1,31), repmat(6,1,30), repmat(7,1,31), repmat(8,1,31), repmat(9,1,30), repmat(10,1,31), repmat(11,1,30), repmat(12,1,31)];
        end

        % Append to Days column
        Days((day_num*nsubs+1):((day_num + no_days)*nsubs)) = repelem((1:no_days),(nsubs));
        % Append Years column
        Years((day_num*nsubs+1):((day_num + no_days)*nsubs)) = repelem(repmat(yr_now,1,no_days),(nsubs));
        
        Months((day_num*nsubs+1):((day_num + no_days)*nsubs)) = repelem(month,nsubs);
        
        % Move through the days
        day_num = day_num + no_days;
    end
end

%% Calculate rch spec's
rch =(1:n)';
Rch = repmat(rch,(length(Years)/nsubs),1);

% Transpose
Days = Days';
Years = Years';
Months = Months';

formatSpec = '%6s%4f%9f%15f%10f%10f%10f%10f%10f%10f%10f%10f%10f%10f%10f%10f%10f%10f%10f%10f%10f%10f%11f%10f%f%[^\n\r]';
%formatSpec =
%'%6s%5f%9f%15f%10f%10f%10f%10f%10f%10f%10f%10f%10f%10f%10f%10f%10f%10f%10f%10f%10f%10f%11f%10f%f%[^\n\r]';
% (for older SWAT versions)

startRow = 6; 
endRow = length(Days)+5; 
FileList = dir('output.sub');
N = size(FileList,1);

%% Loop through outputs (really just one at this point)
for k = 1:N

    % fix faulty PET values in output.sub file
    fid = fopen('output.sub', 'r');
    f = fread(fid,'*char')';
    fclose(fid);
    f = strrep(f,'**********','       NaN');
    fid = fopen('output.sub','w');
    fprintf(fid,'%s',f);
    fclose(fid);

    % Scan the text
    filename = FileList(k).name;
    disp(filename);
    fileID = fopen(filename,'r');
    textscan(fileID, '%[^\n\r]', startRow-1, 'ReturnOnError', false);
    A{k} = textscan(fileID, formatSpec,endRow-startRow+1, 'Delimiter', '', 'WhiteSpace', '', 'ReturnOnError', false);
    fclose(fileID);
    
    % Extract outputs (may not need all of these)
    snowmelt(:,k) = cell2mat(A{k}(:,6));
    groundwater(:,k) = cell2mat(A{k}(:,12));
    water_yield(:,k) = cell2mat(A{k}(:,13));

end

%% Organize outputs (may not need all of these)
GCMs_all_snowmelt = [Years Months Rch snowmelt Days];
GCMs_all_groundwater = [Years Months Rch groundwater Days];
GCMs_all_water_yield = [Years Months Rch water_yield Days];


%% Run water balance analysis 

% Create historic water balance datasets (may not need all of these)
GCMs_hist_groundwater =GCMs_all_groundwater(find(GCMs_all_groundwater(:,1) >= min(years_span) & GCMs_all_groundwater(:,1) <= max(years_span)),:);
GCMs_hist_snowmelt =GCMs_all_snowmelt(find(GCMs_all_snowmelt(:,1) >= min(years_span) & GCMs_all_snowmelt(:,1) <= max(years_span)),:);
GCMs_hist_water_yield =GCMs_all_water_yield(find(GCMs_all_water_yield(:,1) >= min(years_span) & GCMs_all_water_yield(:,1) <= max(years_span)),:);

%% Calculate means 
for i = 1:n;
   step2 =GCMs_hist_groundwater(find(GCMs_hist_groundwater(:,3) == i),:);
   GCMs_hist_mean_groundwater(i,:) = (nanmean(step2(:,4)));  
   step1 =GCMs_hist_snowmelt(find(GCMs_hist_snowmelt(:,3) == i),:);
   GCMs_hist_mean_snowmelt(i,:) = (nanmean(step1(:,4)));   
   step2 =GCMs_hist_water_yield(find(GCMs_hist_water_yield(:,3) == i),:);
   GCMs_hist_mean_water_yield(i,:) = (nanmean(step2(:,4)));

end

%% Calculate monthly means for snowmelt

% Month number
mo = 1;

for i = 1:n;
    step1 =GCMs_hist_snowmelt(GCMs_hist_snowmelt(:,3) == i,:);
    step2 =step1(step1(:,2) == mo,:);
    GCMs_hist_mean_snowmelt_Jan(i,:) = (nanmean(step2(:,4))*31);
    
    step1 =GCMs_hist_groundwater(GCMs_hist_groundwater(:,3) == i,:);
    step2 =step1(step1(:,2) == mo,:);
    GCMs_hist_mean_groundwater_Jan(i,:) = (nanmean(step2(:,4))*31);
    
    step1 =GCMs_hist_water_yield(GCMs_hist_water_yield(:,3) == i,:);
    step2 =step1(step1(:,2) == mo,:);
    GCMs_hist_mean_water_yield_Jan(i,:) = (nanmean(step2(:,4))*31);
   
end
 
mo = 2;
for i = 1:n;
    step1 =GCMs_hist_snowmelt(GCMs_hist_snowmelt(:,3) == i,:);
    step2 =step1(step1(:,2) == mo,:);
    GCMs_hist_mean_snowmelt_Feb(i,:) = (nanmean(step2(:,4))*sum(GCMs_hist_snowmelt(:,2)==2)/nsubs/length(years_span)); % Average number of days in February. 
    
    step1 =GCMs_hist_groundwater(GCMs_hist_groundwater(:,3) == i,:);
    step2 =step1(step1(:,2) == mo,:);
    GCMs_hist_mean_groundwater_Feb(i,:) = (nanmean(step2(:,4))*sum(GCMs_hist_snowmelt(:,2)==2)/nsubs/length(years_span));
    
    step1 =GCMs_hist_water_yield(GCMs_hist_water_yield(:,3) == i,:);
    step2 =step1(step1(:,2) == mo,:);
    GCMs_hist_mean_water_yield_Feb(i,:) = (nanmean(step2(:,4))*sum(GCMs_hist_snowmelt(:,2)==2)/nsubs/length(years_span));

   
end
 
mo = 3;
for i = 1:n;
    step1 =GCMs_hist_snowmelt(GCMs_hist_snowmelt(:,3) == i,:);
    step2 =step1(step1(:,2) == mo,:);
    GCMs_hist_mean_snowmelt_Mar(i,:) = (nanmean(step2(:,4))*31);
    
    step1 =GCMs_hist_groundwater(GCMs_hist_groundwater(:,3) == i,:);
    step2 =step1(step1(:,2) == mo,:);
    GCMs_hist_mean_groundwater_Mar(i,:) = (nanmean(step2(:,4))*31);
    
    step1 =GCMs_hist_water_yield(GCMs_hist_water_yield(:,3) == i,:);
    step2 =step1(step1(:,2) == mo,:);
    GCMs_hist_mean_water_yield_Mar(i,:) = (nanmean(step2(:,4))*31);

  
end
 
mo = 4;
for i = 1:n;
    step1 =GCMs_hist_snowmelt(GCMs_hist_snowmelt(:,3) == i,:);
    step2 =step1(step1(:,2) == mo,:);
    GCMs_hist_mean_snowmelt_Apr(i,:) = (nanmean(step2(:,4))*30);
    
    step1 =GCMs_hist_groundwater(GCMs_hist_groundwater(:,3) == i,:);
    step2 =step1(step1(:,2) == mo,:);
    GCMs_hist_mean_groundwater_Apr(i,:) = (nanmean(step2(:,4))*30);
    
    step1 =GCMs_hist_water_yield(GCMs_hist_water_yield(:,3) == i,:);
    step2 =step1(step1(:,2) == mo,:);
    GCMs_hist_mean_water_yield_Apr(i,:) = (nanmean(step2(:,4))*30);

    
end
 
mo = 5;
for i = 1:n;
    step1 =GCMs_hist_snowmelt(GCMs_hist_snowmelt(:,3) == i,:);
    step2 =step1(step1(:,2) == mo,:);
    GCMs_hist_mean_snowmelt_May(i,:) = (nanmean(step2(:,4))*31);
    
    step1 =GCMs_hist_groundwater(GCMs_hist_groundwater(:,3) == i,:);
    step2 =step1(step1(:,2) == mo,:);
    GCMs_hist_mean_groundwater_May(i,:) = (nanmean(step2(:,4))*31);
    
    step1 =GCMs_hist_water_yield(GCMs_hist_water_yield(:,3) == i,:);
    step2 =step1(step1(:,2) == mo,:);
    GCMs_hist_mean_water_yield_May(i,:) = (nanmean(step2(:,4))*31);
   
end
 
mo = 6;
for i = 1:n;
    step1 =GCMs_hist_snowmelt(GCMs_hist_snowmelt(:,3) == i,:);
    step2 =step1(step1(:,2) == mo,:);
    GCMs_hist_mean_snowmelt_Jun(i,:) = (nanmean(step2(:,4))*30);
    
    step1 =GCMs_hist_groundwater(GCMs_hist_groundwater(:,3) == i,:);
    step2 =step1(step1(:,2) == mo,:);
    GCMs_hist_mean_groundwater_Jun(i,:) = (nanmean(step2(:,4))*30);
    
    step1 =GCMs_hist_water_yield(GCMs_hist_water_yield(:,3) == i,:);
    step2 =step1(step1(:,2) == mo,:);
    GCMs_hist_mean_water_yield_Jun(i,:) = (nanmean(step2(:,4))*30);

   
end

mo = 7;
for i = 1:n;
    step1 =GCMs_hist_snowmelt(GCMs_hist_snowmelt(:,3) == i,:);
    step2 =step1(step1(:,2) == mo,:);
    GCMs_hist_mean_snowmelt_Jul(i,:) = (nanmean(step2(:,4))*31);
    
    step1 =GCMs_hist_groundwater(GCMs_hist_groundwater(:,3) == i,:);
    step2 =step1(step1(:,2) == mo,:);
    GCMs_hist_mean_groundwater_Jul(i,:) = (nanmean(step2(:,4))*31);
    
    step1 =GCMs_hist_water_yield(GCMs_hist_water_yield(:,3) == i,:);
    step2 =step1(step1(:,2) == mo,:);
    GCMs_hist_mean_water_yield_Jul(i,:) = (nanmean(step2(:,4))*31);

    
end
 
mo = 8;
for i = 1:n;
    step1 =GCMs_hist_snowmelt(GCMs_hist_snowmelt(:,3) == i,:);
    step2 =step1(step1(:,2) == mo,:);
    GCMs_hist_mean_snowmelt_Aug(i,:) = (nanmean(step2(:,4))*31);
    
    step1 =GCMs_hist_groundwater(GCMs_hist_groundwater(:,3) == i,:);
    step2 =step1(step1(:,2) == mo,:);
    GCMs_hist_mean_groundwater_Aug(i,:) = (nanmean(step2(:,4))*31);

    step1 =GCMs_hist_water_yield(GCMs_hist_water_yield(:,3) == i,:);
    step2 =step1(step1(:,2) == mo,:);
    GCMs_hist_mean_water_yield_Aug(i,:) = (nanmean(step2(:,4))*31);
end
 
mo = 9;
for i = 1:n;
    step1 =GCMs_hist_snowmelt(GCMs_hist_snowmelt(:,3) == i,:);
    step2 =step1(step1(:,2) == mo,:);
    GCMs_hist_mean_snowmelt_Sep(i,:) = (nanmean(step2(:,4))*30);
    
    step1 =GCMs_hist_groundwater(GCMs_hist_groundwater(:,3) == i,:);
    step2 =step1(step1(:,2) == mo,:);
    GCMs_hist_mean_groundwater_Sep(i,:) = (nanmean(step2(:,4))*30);
    
    step1 =GCMs_hist_water_yield(GCMs_hist_water_yield(:,3) == i,:);
    step2 =step1(step1(:,2) == mo,:);
    GCMs_hist_mean_water_yield_Sep(i,:) = (nanmean(step2(:,4))*30);

   
end
 
mo = 10;
for i = 1:n;
    step1 =GCMs_hist_snowmelt(GCMs_hist_snowmelt(:,3) == i,:);
    step2 =step1(step1(:,2) == mo,:);
    GCMs_hist_mean_snowmelt_Oct(i,:) = (nanmean(step2(:,4))*31);
    
    step1 =GCMs_hist_groundwater(GCMs_hist_groundwater(:,3) == i,:);
    step2 =step1(step1(:,2) == mo,:);
    GCMs_hist_mean_groundwater_Oct(i,:) = (nanmean(step2(:,4))*31);
    
    step1 =GCMs_hist_water_yield(GCMs_hist_water_yield(:,3) == i,:);
    step2 =step1(step1(:,2) == mo,:);
    GCMs_hist_mean_water_yield_Oct(i,:) = (nanmean(step2(:,4))*31);

end
 
 mo = 11;
for i = 1:n;
    step1 =GCMs_hist_snowmelt(GCMs_hist_snowmelt(:,3) == i,:);
    step2 =step1(step1(:,2) == mo,:);
    GCMs_hist_mean_snowmelt_Nov(i,:) = (nanmean(step2(:,4))*30);
    
    step1 =GCMs_hist_groundwater(GCMs_hist_groundwater(:,3) == i,:);
    step2 =step1(step1(:,2) == mo,:);
    GCMs_hist_mean_groundwater_Nov(i,:) = (nanmean(step2(:,4))*30);
    
    step1 =GCMs_hist_water_yield(GCMs_hist_water_yield(:,3) == i,:);
    step2 =step1(step1(:,2) == mo,:);
    GCMs_hist_mean_water_yield_Nov(i,:) = (nanmean(step2(:,4))*30);

   
end

mo = 12;
 for i = 1:n;
   step1 =GCMs_hist_snowmelt(GCMs_hist_snowmelt(:,3) == i,:);
   step2 =step1(step1(:,2) == mo,:);
   GCMs_hist_mean_snowmelt_Dec(i,:) = (nanmean(step2(:,4))*31);
   
   step1 =GCMs_hist_groundwater(GCMs_hist_groundwater(:,3) == i,:);
   step2 =step1(step1(:,2) == mo,:);
   GCMs_hist_mean_groundwater_Dec(i,:) = (nanmean(step2(:,4))*31);
   
   step1 =GCMs_hist_water_yield(GCMs_hist_water_yield(:,3) == i,:);
   step2 =step1(step1(:,2) == mo,:);
   GCMs_hist_mean_water_yield_Dec(i,:) = (nanmean(step2(:,4))*31);

     
 end
 
%% Calculate monthly means
for i = 1:n;
    GCMs_hist_mean_snowmelt_Jan(i,1) = mean(GCMs_hist_mean_snowmelt_Jan(i,1));
    GCMs_hist_mean_snowmelt_Feb(i,1) = mean(GCMs_hist_mean_snowmelt_Feb(i,1));
    GCMs_hist_mean_snowmelt_Mar(i,1) = mean(GCMs_hist_mean_snowmelt_Mar(i,1));
    GCMs_hist_mean_snowmelt_Apr(i,1) = mean(GCMs_hist_mean_snowmelt_Apr(i,1));
    GCMs_hist_mean_snowmelt_May(i,1) = mean(GCMs_hist_mean_snowmelt_May(i,1));
    GCMs_hist_mean_snowmelt_Jun(i,1) = mean(GCMs_hist_mean_snowmelt_Jun(i,1));
    GCMs_hist_mean_snowmelt_Jul(i,1) = mean(GCMs_hist_mean_snowmelt_Jul(i,1));
    GCMs_hist_mean_snowmelt_Aug(i,1) = mean(GCMs_hist_mean_snowmelt_Aug(i,1));
    GCMs_hist_mean_snowmelt_Sep(i,1) = mean(GCMs_hist_mean_snowmelt_Sep(i,1));
    GCMs_hist_mean_snowmelt_Oct(i,1) = mean(GCMs_hist_mean_snowmelt_Oct(i,1));
    GCMs_hist_mean_snowmelt_Nov(i,1) = mean(GCMs_hist_mean_snowmelt_Nov(i,1));
    GCMs_hist_mean_snowmelt_Dec(i,1) = mean(GCMs_hist_mean_snowmelt_Dec(i,1));
    
    GCMs_hist_mean_groundwater_Jan(i,1) = mean(GCMs_hist_mean_groundwater_Jan(i,1));
    GCMs_hist_mean_groundwater_Feb(i,1) = mean(GCMs_hist_mean_groundwater_Feb(i,1));
    GCMs_hist_mean_groundwater_Mar(i,1) = mean(GCMs_hist_mean_groundwater_Mar(i,1));
    GCMs_hist_mean_groundwater_Apr(i,1) = mean(GCMs_hist_mean_groundwater_Apr(i,1));
    GCMs_hist_mean_groundwater_May(i,1) = mean(GCMs_hist_mean_groundwater_May(i,1));
    GCMs_hist_mean_groundwater_Jun(i,1) = mean(GCMs_hist_mean_groundwater_Jun(i,1));
    GCMs_hist_mean_groundwater_Jul(i,1) = mean(GCMs_hist_mean_groundwater_Jul(i,1));
    GCMs_hist_mean_groundwater_Aug(i,1) = mean(GCMs_hist_mean_groundwater_Aug(i,1));
    GCMs_hist_mean_groundwater_Sep(i,1) = mean(GCMs_hist_mean_groundwater_Sep(i,1));
    GCMs_hist_mean_groundwater_Oct(i,1) = mean(GCMs_hist_mean_groundwater_Oct(i,1));
    GCMs_hist_mean_groundwater_Nov(i,1) = mean(GCMs_hist_mean_groundwater_Nov(i,1));
    GCMs_hist_mean_groundwater_Dec(i,1) = mean(GCMs_hist_mean_groundwater_Dec(i,1));
    
    GCMs_hist_mean_water_yield_Jan(i,1) = mean(GCMs_hist_mean_water_yield_Jan(i,1));
    GCMs_hist_mean_water_yield_Feb(i,1) = mean(GCMs_hist_mean_water_yield_Feb(i,1));
    GCMs_hist_mean_water_yield_Mar(i,1) = mean(GCMs_hist_mean_water_yield_Mar(i,1));
    GCMs_hist_mean_water_yield_Apr(i,1) = mean(GCMs_hist_mean_water_yield_Apr(i,1));
    GCMs_hist_mean_water_yield_May(i,1) = mean(GCMs_hist_mean_water_yield_May(i,1));
    GCMs_hist_mean_water_yield_Jun(i,1) = mean(GCMs_hist_mean_water_yield_Jun(i,1));
    GCMs_hist_mean_water_yield_Jul(i,1) = mean(GCMs_hist_mean_water_yield_Jul(i,1));
    GCMs_hist_mean_water_yield_Aug(i,1) = mean(GCMs_hist_mean_water_yield_Aug(i,1));
    GCMs_hist_mean_water_yield_Sep(i,1) = mean(GCMs_hist_mean_water_yield_Sep(i,1));
    GCMs_hist_mean_water_yield_Oct(i,1) = mean(GCMs_hist_mean_water_yield_Oct(i,1));
    GCMs_hist_mean_water_yield_Nov(i,1) = mean(GCMs_hist_mean_water_yield_Nov(i,1));
    GCMs_hist_mean_water_yield_Dec(i,1) = mean(GCMs_hist_mean_water_yield_Dec(i,1));
    
end


%% Create a water balances table of results
snowmelt_mo(:,1) = 1:nsubs;
snowmelt_mo(:,2) = GCMs_hist_mean_snowmelt_Jan(:,1);
snowmelt_mo(:,3) = GCMs_hist_mean_snowmelt_Feb(:,1);
snowmelt_mo(:,4) = GCMs_hist_mean_snowmelt_Mar(:,1);
snowmelt_mo(:,5) = GCMs_hist_mean_snowmelt_Apr(:,1);
snowmelt_mo(:,6) = GCMs_hist_mean_snowmelt_May(:,1);
snowmelt_mo(:,7) = GCMs_hist_mean_snowmelt_Jun(:,1);
snowmelt_mo(:,8) = GCMs_hist_mean_snowmelt_Jul(:,1);
snowmelt_mo(:,9) = GCMs_hist_mean_snowmelt_Aug(:,1);
snowmelt_mo(:,10) = GCMs_hist_mean_snowmelt_Sep(:,1);
snowmelt_mo(:,11) = GCMs_hist_mean_snowmelt_Oct(:,1);
snowmelt_mo(:,12) = GCMs_hist_mean_snowmelt_Nov(:,1);
snowmelt_mo(:,13) = GCMs_hist_mean_snowmelt_Dec(:,1);

groundwater_mo(:,1) = 1:nsubs;
groundwater_mo(:,2) = GCMs_hist_mean_groundwater_Jan(:,1);
groundwater_mo(:,3) = GCMs_hist_mean_groundwater_Feb(:,1);
groundwater_mo(:,4) = GCMs_hist_mean_groundwater_Mar(:,1);
groundwater_mo(:,5) = GCMs_hist_mean_groundwater_Apr(:,1);
groundwater_mo(:,6) = GCMs_hist_mean_groundwater_May(:,1);
groundwater_mo(:,7) = GCMs_hist_mean_groundwater_Jun(:,1);
groundwater_mo(:,8) = GCMs_hist_mean_groundwater_Jul(:,1);
groundwater_mo(:,9) = GCMs_hist_mean_groundwater_Aug(:,1);
groundwater_mo(:,10) = GCMs_hist_mean_groundwater_Sep(:,1);
groundwater_mo(:,11) = GCMs_hist_mean_groundwater_Oct(:,1);
groundwater_mo(:,12) = GCMs_hist_mean_groundwater_Nov(:,1);
groundwater_mo(:,13) = GCMs_hist_mean_groundwater_Dec(:,1);

water_yield_mo(:,1) = 1:nsubs;
water_yield_mo(:,2) = GCMs_hist_mean_water_yield_Jan(:,1);
water_yield_mo(:,3) = GCMs_hist_mean_water_yield_Feb(:,1);
water_yield_mo(:,4) = GCMs_hist_mean_water_yield_Mar(:,1);
water_yield_mo(:,5) = GCMs_hist_mean_water_yield_Apr(:,1);
water_yield_mo(:,6) = GCMs_hist_mean_water_yield_May(:,1);
water_yield_mo(:,7) = GCMs_hist_mean_water_yield_Jun(:,1);
water_yield_mo(:,8) = GCMs_hist_mean_water_yield_Jul(:,1);
water_yield_mo(:,9) = GCMs_hist_mean_water_yield_Aug(:,1);
water_yield_mo(:,10) = GCMs_hist_mean_water_yield_Sep(:,1);
water_yield_mo(:,11) = GCMs_hist_mean_water_yield_Oct(:,1);
water_yield_mo(:,12) = GCMs_hist_mean_water_yield_Nov(:,1);
water_yield_mo(:,13) = GCMs_hist_mean_water_yield_Dec(:,1);


% Initialize matrices
outputs_groundwater = [];
outputs_snowmelt = [];
outputs_water_yield = [];

%% Append latest outputs
outputs_gw_append = mean(groundwater_mo(:,2:13));
outputs_snowmelt_append = mean(snowmelt_mo(:,2:13));
outputs_water_yield_append = mean(water_yield_mo(:,2:13));

outputs_groundwater = [outputs_groundwater; outputs_gw_append];
outputs_snowmelt = [outputs_snowmelt; outputs_snowmelt_append];
outputs_water_yield = [outputs_water_yield; outputs_water_yield_append];

%% Change back (remove these from the end of mcalib.m)
!rm output*
!rm sim*

cd ([Extra.InputDir '/Mfiles/'])


