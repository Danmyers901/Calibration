function stats = calstats_OF3(sub,StartDate,EndDate)

% This function was modified by DM 8/31/20 to select only fall, winter, and
% spring daily data for snow studies.

%% TEMPORARY
% sub = 1;
% StartDate = datenum(1950,1,1); % Calibration start date
% EndDate = datenum(1999,12,31);   % Calibration end date

%% READ DATA
obsdata_all = textread(['obs_daily_OF3_' num2str(sub) '.csv'],'',...
    'delimiter',',','headerlines',1);
simdata_all = textread(['sim_daily_OF3_' num2str(sub) '.dat'],'','headerlines',1);

%% DEAL WITH DATA THAT HAS MISSING VALUES

% Check data
obs_check = datenum(obsdata_all(:,1),obsdata_all(:,2),obsdata_all(:,3));
sim_check = datenum(simdata_all(:,1),repmat(0,length(simdata_all(:,1)),1),simdata_all(:,2));

% Intersect the checks
[samesies rows_to_extract ] = intersect(obs_check,sim_check,'rows');
corr(obs_check(rows_to_extract,:),sim_check(rows_to_extract,:));

% initialize array with missing values to nan
obsnew=nan(size(sim_check));

% put non-missing values where they should go
for i=1:length(samesies)
    inonmiss=find(sim_check==samesies(i));
    obsnew(inonmiss)=obsdata_all(i,4);
end
one_rep = repmat([1],length(simdata_all),1);
obsdata_all = [simdata_all(:,1:2) one_rep obsnew];


%% SPLIT DATA?
data_split = 1; %do you want to split data for calibration and validation? 
    % If so, put 1. If not, put 0;

%% CHOOSE PERCENTAGES FOR DATA SPLIT
calibration_split = 50; % percent of observed data used for calibration 
%the calibration and validation split must add up to 100;
validation_split = 50; % percent of observed data used for validation

%% FORMAT DATA AND REMOVE NaNs
obsdata = obsdata_all(:,:);           
simdata = simdata_all(:,:);
obs_data_count = length(obsdata) - sum(isnan(obsdata(:,4)));

if data_split == 1 && obs_data_count> 60; % obs_data_count asks what are the
% data availability constraints of your calibration.
% I put 60 months here
simnan = isnan(simdata(:,3));
simnan_row = find(simnan == 1);
obsdata(simnan_row,:) = [];
simdata(simnan_row,:) = [];

obsnan = isnan(obsdata(:,4));
obsnan_row = find(obsnan == 1);
obsdata(obsnan_row,:) = [];
simdata(obsnan_row,:) = [];

%% SPLIT THE DATA
obsdata_calib_split = ceil(length(obsdata) * (calibration_split/100));
obsdata = obsdata(1:obsdata_calib_split,:);
simdata = simdata(1:obsdata_calib_split,:);

elseif data_split == 0;
findnan = isnan(simdata(:,3));
removenan = find(findnan == 1);
obsdata(removenan,:)=[];
simdata(removenan,:)=[];

findnan = isnan(obsdata(:,4));
removenan = find(findnan == 1);
obsdata(removenan,:)=[];
simdata(removenan,:)=[];
end

%% CHOOSE FALL, WINTER, AND SPRING MONTHS ONLY
summer_rows = find(obsdata(:,2) > 170 & obsdata(:,2) < 265);
obsdata(summer_rows,:) = [];
simdata(summer_rows,:) = [];


%% CALCULATE THE STATS  

stats.obsmean=nanmean(obsdata(:,4));
stats.simmean=nanmean(simdata(:,3));
stats.obsdatalength = sum(~isnan(obsdata(:,4)));
stats.simsdatalength = numel(simdata(:,3));
stats.percentofsimdata = (sum(~isnan(obsdata(:,4)))./numel(simdata(:,3)))*100;

%R2
stats.R2flow = min(min((nancorrcoef(simdata(:,3),obsdata(:,4))).^2));

%NS
stats.R2NSflow = 1 - nansum((obsdata(:,4) - simdata(:,3)).^2)/nansum((obsdata(:,4) - nanmean(obsdata(:,4))).^2);

%Kling_gupta
sdmodelled=nanstd(simdata(:,3));
sdobserved=nanstd(obsdata(:,4));
mmodelled=nanmean(simdata(:,3));
mobserved=nanmean(obsdata(:,4));
kg_r = nancorrcoef(simdata(:,3),obsdata(:,4));
kg_relvar=sdmodelled/sdobserved;
kg_bias=mmodelled/mobserved;

stats.kling_gupta = 1-  sqrt( ((kg_r(1,2)-1)^2) + ((kg_relvar-1)^2)  + ((kg_bias-1)^2) );

%dr
c =2 ;
first=nansum(abs(simdata(:,3)-obsdata(:,4)));
second=c*nansum(abs(obsdata(:,4)-nanmean(obsdata(:,4))));

if first <= second
    stats.dr =1-first/second;
else
    stats.dr =second/first - 1;
end

% MAE
find_if_nan = length(obsdata(:,3)) - sum(isnan(obsdata(:,4))); % This line fixed with Alejandra's findings.
stats.mae = -1*(1./find_if_nan).*nansum(abs(simdata(:,3)-obsdata(:,4)));% the -1 is there for minimization problem
