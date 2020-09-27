 function [OF1,OF2,OF3,OF4,POSITION] = mcalib(iRun,X, Extra) % DM 9/23/20 change made here.
global n_sub file_id

% This code was modified by DM 9/23/20 to create the POSITION variable which helps create the ordered parameter set OrdSet.

POSITION = iRun; % 9/23/20 DM added this.

n_sub=Extra.nsub; % Number of subwatersheds in the project setup.
%outlet = Extra.outlet1;
start_year = Extra.start_year;
n_years = Extra.nyear;
%-----calibration dates ------%
CalStartDate = Extra.CalStartDate;
CalEndDate=Extra.CalEndDate;

%disp('before copying files, directory is')
%disp(pwd)

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

%disp('after copying files, directory is')
%disp(pwd)

VarName = {'Flow(cms)';'Org N(kg)';'NO3N(kg)';'NH4N(kg)';'NO2N(kg)';...
    'TN(kg)';'Org P(kg)';'Min P(kg)';'TP(kg)';'Sediment(tons)';...
    'Sol. Pst.(mg/L)';'Sor. Pst.(mg/L)';'Pesticide(mg/L)'};
iVars = [1];

file_id = id_func(n_sub);
par_alter(Extra,sampleData)

% unix_command = 'chmod 777 swat2012_627';
% unix(unix_command);

%unix_command = 'chmod 777 swat2012_ficklin_KARST';
%unix_command = 'chmod 777 swat2012_linux_ficklin_2017-05-05';
%unix_command = 'chmod 777 swat2012_ficklin_Linux_2017-04-07';
unix_command = 'chmod 777 swat_rev681_ROS_06_30_2020';
unix(unix_command);

%!./swat2012_627
%!./swat2012_ficklin_KARST
%!./swat2012_linux_ficklin_2017-05-05
%!./swat2012_ficklin_Linux_2017-04-07
!./swat_rev681_ROS_06_30_2020
 %hruprocess(iRun)
 
 %%%%%%%%%%%%%%%%%%CHANGE THESE%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%VALUES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % cal stats done in a loop

% These are the calibration outlets for streamflow
%calibration_outlets = [75 148 153 161 165 176 178 191 247 267 408 447 465 466 486 503 502 547 578 604 611 736 757 761 778 801 923 1034 1069 1084 1115 1143 1169 1215 1240 1257 1277 1278 1287 1346 1384 1390 1398 1402 1423 1445 1456 1463 1472 1475 1478 1493 1506 1521 1527 1529 1555 1562 1569 1583 1587 1581 1597 1601 1613 1620 1628 1629 1654 1677 1690 1696 1705 1710 1717 1765 1773 1781 1803 1811 1865 1867 1876 1881 1883 1890 1896 1912 1914 1919 1921 1932 1947 1966 1969 1989 2016 2022 2028];
% calibration_outlets = [1 2 3 4 6 10 12 26 27 30 35 36 37 38 43 46 48 54 57 58];
calibration_outlets = [36];

% These are the calibration outlets for OF3 (DM 6/7/2020)
% calibration_outlets_OF3 = [1 2 3 4 6 10 12 26 27 30 35 36 37 38 43 46 48 54 57 58];
calibration_outlets_OF3 = [1];

% These are the calibration outlets for OF5 (DM 6/11/2020)
%calibration_outlets_OF5 = [11 73 85];

for i = 1:length(calibration_outlets);
  calibration_outlets(i);
  rchproc(iVars,n_sub,calibration_outlets(i),start_year,n_years);
  outstats = calstats(calibration_outlets(i),CalStartDate,CalEndDate);
  %%%%%%%%%%%%%%%%%%CHANGE STAT TO WHATEVER YOU WANT THE OF TO
  %%%%%%%%%%%%%%%%%%BE%%%%%%%%%%%%
  OF_sub(:,i) = -1*outstats.R2NSflow; %the -1 represents that the OF needs to be minimized
  obs_mean(:,i) =outstats.obsmean;
  obs_data_length(:,i) = outstats.obsdatalength;
  percent_data_available(:,i) = outstats.percentofsimdata;
end

%%%%MEAN OF OF values -- comment out if not used
 OF1=mean([OF_sub]); % This had default been a sum() function but I changed it to mean() (DM 6/8/2020).

%%%%WEIGHTED MEAN BASED ON streamflow -- comment out if not used
% obs_mean_sum = sum(obs_mean);
% for i = 1:length(calibration_outlets);
% OF1_step(:,i) =   (obs_mean(:,i)/obs_mean_sum) * OF_sub(:,i);
% %OF1=mean([OF_sub]); 
% end
% OF1=sum([OF1_step]); 

%%%%WEIGHTED MEAN BASED ON DATA LENGTH -- comment out if not used
% percent_data_sum = sum( percent_data_available);
% for i = 1:length(calibration_outlets);
%     OF1_step(:,i) =   (percent_data_available(:,i)/percent_data_sum) * OF_sub(:,i);
% end
% OF1=sum([OF1_step]); 
% 
% for i = 1:length(calibration_outlets);
%     %weights(:,i)= (obs_mean(:,i)/obs_mean_sum); % streamflow weights
%     weights(:,i) = (percent_data_available(:,i)/percent_data_sum); %data availability weights
% end

%%%%%OF2%%%%%%%%%%%%%%%%%%%%%
if Extra.outlet2>0; 
    %OF2=std(OF_sub,weights); % weighted standard deviation
    OF2=std([OF_sub]);%  standard deviation
else
    OF2=0;
end

% if Extra.outlet2>0; 
%     outlet=Extra.outlet2;
%     rchproc(iVars,n_sub,outlet,start_year,n_years);
%     outstats = calstats(outlet,datenum(2002,1,1),CalEndDate);
%     OF2=-1*outstats.R2NSflow;
% else
%     OF2=0;
% end

%%%%%OF3%%%%%%%%%%%%%%%%%%%%%
% OF3 has been added for multivariable calibration (DM 6/7/2020)
for i = 1:length(calibration_outlets_OF3);
  calibration_outlets_OF3(i);
  hruproc_OF3(iVars,n_sub,calibration_outlets_OF3(i),start_year,n_years);
  outstats_OF3 = calstats_OF3(calibration_outlets_OF3(i),CalStartDate,CalEndDate);
  %%%%%%%%%%%%%%%%%%CHANGE STAT TO WHATEVER YOU WANT THE OF TO
  %%%%%%%%%%%%%%%%%%BE%%%%%%%%%%%%
  OF_sub_OF3(:,i) = -1*outstats_OF3.R2NSflow; %the -1 represents that the OF needs to be minimized
  obs_mean_OF3(:,i) =outstats_OF3.obsmean;
  obs_data_length_OF3(:,i) = outstats_OF3.obsdatalength;
  percent_data_available_OF3(:,i) = outstats_OF3.percentofsimdata;
end

%%%%MEAN OF OF values -- comment out if not used
 OF3=mean([OF_sub_OF3]);
 
%%%%%OF4%%%%%%%%%%%%%%%%%%%%%
% OF4 is the standard deviation of OF3 (DM 6/8/2020)
if Extra.outlet2>0; 
    %OF4=std(OF_sub_OF3,weights); % weighted standard deviation
    OF4=std([OF_sub_OF3]);%  standard deviation
else
    OF4=0;
end

%%%%%OF5%%%%%%%%%%%%%%%%%%%%%
% OF5 has been added for multivariable calibration (DM 6/11/2020)
%for i = 1:length(calibration_outlets_OF5);
 % calibration_outlets_OF5(i);
 % rchproc_OF5(iVars,n_sub,calibration_outlets_OF5(i),start_year,n_years);
 % outstats_OF5 = calstats_OF5(calibration_outlets_OF5(i),CalStartDate,CalEndDate);
  %%%%%%%%%%%%%%%%%%CHANGE STAT TO WHATEVER YOU WANT THE OF TO
  %%%%%%%%%%%%%%%%%%BE%%%%%%%%%%%%
 % OF_sub_OF5(:,i) = -1*outstats_OF5.R2NSflow; %the -1 represents that the OF needs to be minimized
 % obs_mean_OF5(:,i) =outstats_OF5.obsmean;
 % obs_data_length_OF5(:,i) = outstats_OF5.obsdatalength;
 % percent_data_available_OF5(:,i) = outstats_OF5.percentofsimdata;
%end

%%%%MEAN OF OF values -- comment out if not used
 %OF5=mean([OF_sub_OF5]);

%%%%%OF6%%%%%%%%%%%%%%%%%%%%%
% OF6 is the standard deviation of OF5 (DM 6/11/2020)
%if Extra.outlet2>0; 
    %OF6=std(OF_sub_OF5,weights); % weighted standard deviation
%    OF6=std([OF_sub_OF5]);%  standard deviation
%else
%    OF6=0;
%end

!rm output*
!rm sim*

cd ([Extra.InputDir '/Mfiles/'])
