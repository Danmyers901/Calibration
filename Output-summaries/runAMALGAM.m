% Matlab codes for SWAT calibration using AMALGAM optimization algorithm :
% Can be used for multisite calibration (two sites) with daily streamflow nash sutcliffe efficiency as likelihood
% Formatted and updated by Cibin (06/20/2016)
% Original codes and linking with AMALGAM credits to Mazdak Arabi and Chetan Maringanti
% AMLAGAM code credits Jasper Vrugt (Vrugt and Robinson, 2007. PNAS doi:10.1073/pnas.0610471104) 
% 


%%%%%%%%%%%%%%%%% READ ME %%%%%%%%%%%%%%
% You should have four folders in your home directory 
%           (1) user_inputs (2) Mfiles
%           (3) sensin (4) outputs
%Steps
%       1. Copy TxtInOut folder from ArcSWAT setup to sensin folder
%       2. Define Calibration parameters and their range in par_file.prn in user_inputs folder
%       3. Format observed data similar to sample obs_daily##.csv in user_inputs folder
%       4. Define user iputs below
%       5. Input your calibration outlets on line 85 in the mcalib.m file
%        5. change the values on the line 43-45 in the rchproc.m file
%       5. Run this code for calibration outputs will be saved in outputs folder
%       6. ParSet variable in AMALGAM.mat has the parameter combination and objctive function value     


clc
clear all

%%%%%%%%%%%%%%%%%     USER INPUTS     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% User defined inputs for calibration%% Has to be specified according to
% your calibration settings

Extra.nsub=2029;              % Total number of subbasins in model
Extra.start_year = 1960;    % Start year of simulation after model warmup
AMALGAMPar.nobj = 2;        % Number of objectives
Extra.outlet1 = 36;          % Calibration subbasin number (first station) -- these are dummy variables -- change the actual outlets in mcalib.m
Extra.outlet2 = 36;          % Calibration subbasin number (second station) for one objective function input outlet2 =0
Extra.nyear = 40;            % Number of year of model simulation after model warmup
Extra.CalStartDate = datenum(1960,1,1); % Calibration start date
Extra.CalEndDate=datenum(1999,12,31);   % Calibration end date


Extra.SimulationDir= '/N/project/pfec_hydroclim/IU/Temporary_Carbonate_Jobs/ACTIVE_JOBS_DONT_EDIT/Summaries_daily/Simulations';    %Define the simulation directory
Extra.InputDir= '/N/project/pfec_hydroclim/IU/Temporary_Carbonate_Jobs/ACTIVE_JOBS_DONT_EDIT/Summaries_daily';            %Define the input folder location

%Optimization algorthm parameters
AMALGAMPar.N = 8;                     % Size of the population
AMALGAMPar.ndraw = 504;              % Maximum number of function evaluations
%Population size should be multiple of number of optimization algorithms used in AMALGAM (line 51, runAMALGAM), try with multiples of 4 in this case.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% parpool close force local
%Initiate a matlabpool of 12 processors
delete(gcp('nocreate'))
myCluster = parcluster('local');
myCluster.NumWorkers = 8;  % 'Modified' property now TRUE
saveProfile(myCluster);    % 'local' profile now updated,
                           % 'Modified' property now FALSE   
parpool(8);

% matlabpool open matlabR2010a 35
Extra.Alg = {'GA','PSO','AMS','DE'};
% Define the number of algorithms
AMALGAMPar.q = size(Extra.Alg,2);

fid = fopen('../user_inputs/par_file.prn','r');
ParData = textscan(fid,'%d%s%s%s%f%d%f%f','headerLines',2);
Extra.par_f=ParData{6};
Extra.par_n=ParData{1};
Par_min=ParData{7};
Par_max=ParData{8};
    
AMALGAMPar.n = sum(Extra.par_f);                       % Dimension of the problem
% Give the parameter ranges (minimum and maximum values)
Par_ide=find(Extra.par_f==1);
ParRange.minn = Par_min(Par_ide)';
ParRange.maxn = Par_max(Par_ide)';
Extra.nPars = AMALGAMPar.n;
% Define the boundary handling
Extra.BoundHandling = 'Bound';
% True Pareto front is not available -- real world problem
Fpareto = [];

Extra.m = AMALGAMPar.n;

% Run the AMALGAM code and obtain non-dominated solution set (modified by DM 9/23/20)
[output,ParGen,ObjVals,ParSet,SimRes,OrdSet, outputs_snowmelt, outputs_groundwater, outputs_water_yield] = AMALGAM(AMALGAMPar,ParRange,Extra,Fpareto);
save ../outputs/AMALGAM.mat
%parpool close
delete(gcp('nocreate'))
