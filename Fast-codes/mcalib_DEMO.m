 function [OF1,OF2,POSITION] = mcalib(iRun,X, Extra) % Modified by DM 9/23/20
global n_sub file_id

% This file has been modified to work with the new quick rchproc_fast.m and hruproc_fast.m.
% It has also been modified by DM 9/23/20 to output orderly row position.

POSITION = iRun; % Added by DM 9/23/20

n_sub=Extra.nsub; % Number of subwatersheds in the project setup.
%outlet = Extra.outlet1;
start_year = Extra.start_year;
n_years = Extra.nyear;
%-----calibration dates ------%
CalStartDate = Extra.CalStartDate;
CalEndDate=Extra.CalEndDate;

sampleData=X;
path_sim=iRun;
if (exist([Extra.SimulationDir],'dir')==0)
    mkdir ([Extra.SimulationDir])
end
if (exist([Extra.SimulationDir '/sim' num2str(iRun)],'dir')==0)
    mkdir ([Extra.SimulationDir '/sim' num2str(iRun)])

    %THIS MIGHT NEED TO BE ADAPTED
copyfile('../sensin/*.sep*',[Extra.SimulationDir '/sim' num2str(path_sim)]);
copyfile('../sensin/*.gw*',[Extra.SimulationDir '/sim' num2str(path_sim)]);
copyfile('../sensin/*.ATM*',[Extra.SimulationDir '/sim' num2str(path_sim)]);
copyfile('../sensin/*.bsn*',[Extra.SimulationDir '/sim' num2str(path_sim)]);
copyfile('../sensin/*.chm*',[Extra.SimulationDir '/sim' num2str(path_sim)]);
copyfile('../sensin/*.cio*',[Extra.SimulationDir '/sim' num2str(path_sim)]);
copyfile('../sensin/*.cst*',[Extra.SimulationDir '/sim' num2str(path_sim)]);
copyfile('../sensin/*.dat*',[Extra.SimulationDir '/sim' num2str(path_sim)]);
copyfile('../sensin/*.deg*',[Extra.SimulationDir '/sim' num2str(path_sim)]);
copyfile('../sensin/*.fig*',[Extra.SimulationDir '/sim' num2str(path_sim)]);
copyfile('../sensin/*.fin*',[Extra.SimulationDir '/sim' num2str(path_sim)]);
copyfile('../sensin/*.hru*',[Extra.SimulationDir '/sim' num2str(path_sim)]);
copyfile('../sensin/*.mgt*',[Extra.SimulationDir '/sim' num2str(path_sim)]);
copyfile('../sensin/*.out*',[Extra.SimulationDir '/sim' num2str(path_sim)]);
copyfile('../sensin/*.pcp*',[Extra.SimulationDir '/sim' num2str(path_sim)]);
copyfile('../sensin/*.pnd*',[Extra.SimulationDir '/sim' num2str(path_sim)]);
copyfile('../sensin/*.pst*',[Extra.SimulationDir '/sim' num2str(path_sim)]);
copyfile('../sensin/*.qst*',[Extra.SimulationDir '/sim' num2str(path_sim)]);
copyfile('../sensin/*.rch*',[Extra.SimulationDir '/sim' num2str(path_sim)]);
copyfile('../sensin/*.rsv*',[Extra.SimulationDir '/sim' num2str(path_sim)]);
copyfile('../sensin/*.rte*',[Extra.SimulationDir '/sim' num2str(path_sim)]);
copyfile('../sensin/*.sdr*',[Extra.SimulationDir '/sim' num2str(path_sim)]);
copyfile('../sensin/*.sed*',[Extra.SimulationDir '/sim' num2str(path_sim)]);
copyfile('../sensin/*.sol*',[Extra.SimulationDir '/sim' num2str(path_sim)]);
copyfile('../sensin/*.std*',[Extra.SimulationDir '/sim' num2str(path_sim)]);
copyfile('../sensin/*.sub*',[Extra.SimulationDir '/sim' num2str(path_sim)]);
copyfile('../sensin/*.swq*',[Extra.SimulationDir '/sim' num2str(path_sim)]);
copyfile('../sensin/*.wgn*',[Extra.SimulationDir '/sim' num2str(path_sim)]);
copyfile('../sensin/*.wus*',[Extra.SimulationDir '/sim' num2str(path_sim)]);
copyfile('../sensin/*.wwq*',[Extra.SimulationDir '/sim' num2str(path_sim)]);
 
    %copyfile('../sensin/*.*',[Extra.SimulationDir '/sim' num2str(path_sim)]);
    copyfile('../Mfiles/*.*',[Extra.SimulationDir '/sim' num2str(path_sim)]);
    copyfile('../user_inputs/*.*',[Extra.SimulationDir '/sim' num2str(path_sim)]);
    cd([Extra.SimulationDir '/sim' num2str(path_sim)])
else

%    disp('after else condition, directory is')
%    disp(pwd)

    cd(Extra.SimulationDir) % Added by DM 7/13/20 because otherwise it isn't working for some reason.
    copyfile('../user_inputs/*.*',[Extra.SimulationDir '/sim' num2str(path_sim)]);

    copyfile('../Mfiles/*.*',[Extra.SimulationDir '/sim' num2str(path_sim)]);
    cd([Extra.SimulationDir '/sim' num2str(path_sim)])
end
%
disp('copying input files completed')

VarName = {'Flow(cms)';'Org N(kg)';'NO3N(kg)';'NH4N(kg)';'NO2N(kg)';...
    'TN(kg)';'Org P(kg)';'Min P(kg)';'TP(kg)';'Sediment(tons)';...
    'Sol. Pst.(mg/L)';'Sor. Pst.(mg/L)';'Pesticide(mg/L)'};
iVars = [1];

file_id = id_func(n_sub);
par_alter(Extra,sampleData)

unix_command = 'chmod 777 swat_rev681_ROS_06_30_2020';
unix(unix_command);

!./swat_rev681_ROS_06_30_2020
 %hruprocess(iRun)
 
 %%%%%%%%%%%%%%%%%%CHANGE THESE%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%VALUES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % cal stats done in a loop

% These are the calibration outlets for streamflow
calibration_outlets = [75 148 153 161 165 176 178 191 247 267 408 447 465 466 486 503 502 547 578 604 611 736 757 761 778 801 923 1034 1069 1084 1115 1143 1169 1215 1240 1257 1277 1278 1287 1346 1384 1390 1398 1402 1423 1445 1456 1463 1472 1475 1478 1493 1506 1521 1527 1529 1555 1562 1569 1583 1587 1581 1597 1601 1613 1620 1628 1629 1654 1677 1690 1696 1705 1710 1717 1765 1773 1781 1803 1811 1865 1867 1876 1881 1883 1890 1896 1912 1914 1919 1921 1932 1947 1966 1969 1989 2016 2022 2028];
%calibration_outlets = [75];

% These are the calibration outlets for OF2 SWE (DM 6/7/2020)
calibration_outlets_OF2 = [11 73 85 86 96 98 219 237 243 340 343 520 529 538 540 548 579 590 598 606 608 617 623 783 820 823 835 936 971 987 1029 1092 1095 1102 1109 1121 1308 1362 1393 1410 1430 1452 1626 1665 1749 1757 1775 1886 1916 1924];

% *** Process the sim_daily files the fast way. ***
rchproc_fast(iVars,n_sub,calibration_outlets,start_year,n_years);
hruproc_fast(iVars,n_sub,calibration_outlets_OF2,start_year,n_years);

% OF1 (streamflow)
for i = 1:length(calibration_outlets);
  calibration_outlets(i);
  % *** Notice no rchproc() here. ***
  outstats = calstats(calibration_outlets(i),CalStartDate,CalEndDate);
  %%%%%%%%%%%%%%%%%%CHANGE STAT TO WHATEVER YOU WANT THE OF TO
  %%%%%%%%%%%%%%%%%%BE%%%%%%%%%%%%
  OF_sub(:,i) = -1*outstats.R2NSflow; %the -1 represents that the OF needs to be minimized
  obs_mean(:,i) =outstats.obsmean;
  obs_data_length(:,i) = outstats.obsdatalength;
  percent_data_available(:,i) = outstats.percentofsimdata;
end


%%%%MEAN OF OF values -- comment out if not used
% OF1=mean([OF_sub]); % This had default been a sum() function but I changed it to mean() (DM 6/8/2020).

%%%%WEIGHTED MEAN BASED ON DATA LENGTH -- comment out if not used
percent_data_sum = sum( percent_data_available);
for i = 1:length(calibration_outlets);
    OF1_step(:,i) =   (percent_data_available(:,i)/percent_data_sum) * OF_sub(:,i);
end
OF1=sum([OF1_step]); 

for i = 1:length(calibration_outlets);
    %weights(:,i)= (obs_mean(:,i)/obs_mean_sum); % streamflow weights
    weights(:,i) = (percent_data_available(:,i)/percent_data_sum); %data availability weights
end

% OF2 (SWE)
for i = 1:length(calibration_outlets_OF2);
  calibration_outlets_OF2(i);
  % *** Notice no rchproc() here. ***
  outstats_OF2 = calstats_FallWinterSpring(calibration_outlets_OF2(i),CalStartDate,CalEndDate);
  %%%%%%%%%%%%%%%%%%CHANGE STAT TO WHATEVER YOU WANT THE OF TO
  %%%%%%%%%%%%%%%%%%BE%%%%%%%%%%%%
  OF_sub_OF2(:,i) = -1*outstats_OF2.mae; %the -1 represents that the OF needs to be minimized
  obs_mean_OF2(:,i) =outstats_OF2.obsmean;
  obs_data_length_OF2(:,i) = outstats_OF2.obsdatalength;
  percent_data_available_OF2(:,i) = outstats_OF2.percentofsimdata;
end


%%%%MEAN OF OF values -- comment out if not used
 OF2=mean([OF_sub_OF2]); % Note I changed this to OF2
 
!rm output*
!rm sim*

cd ([Extra.InputDir '/Mfiles/'])
