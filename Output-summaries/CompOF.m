function [newOF,newCg,POSITION, outputs_snowmelt, outputs_groundwater, outputs_water_yield] = CompOF(x,AMALGAMPar,Extra) % Modified by DM 9/23/20
% This function computes the objective function for each x value
% It has been modified for multivariable calibration.

% This program has been modified by DM 9/23/20 to output the orderly row position.

t0=clock;


OF1(1:AMALGAMPar.N)=0;
if AMALGAMPar.nobj>1
    OF2(1:AMALGAMPar.N)=0;
end
newOF(1:AMALGAMPar.N,1:AMALGAMPar.nobj>1)=0;

% Initialize summaries
outputs_groundwater = [];
outputs_snowmelt = [];
outputs_water_yield = [];

parfor iRun=1:AMALGAMPar.N

    [OF1(iRun), OF2(iRun),POSITION(iRun)] = mcalib(iRun,x(iRun,:),Extra); % Modified by DM 9/23/20
    
    % Summarize outputs
    [outputs_snowmelt_append, outputs_gw_append, outputs_water_yield_append] = Summary_making_code_daily(iRun, x(iRun,:),Extra);

    outputs_groundwater = [outputs_groundwater; outputs_gw_append];
    outputs_snowmelt = [outputs_snowmelt; outputs_snowmelt_append];
    outputs_water_yield = [outputs_water_yield; outputs_water_yield_append];

end

newOF(:,1)=OF1;
if AMALGAMPar.nobj>1
    newOF(:,2)=OF2;
end

runtime1=fix(etime(clock,t0)/60);
runtime2=round((etime(clock,t0)/60-fix(etime(clock,t0)/60))*60);
disp(['runtime: ' num2str(runtime1) ' min     ' num2str(runtime2) ' sec']);

newCg(1:AMALGAMPar.N,1) = 0;
POSITION = POSITION'; % Modified by DM 9/23/20

fid = fopen ('../outputs/simTime_SubCalib21516.dat','a');
fprintf(fid,'%d\t%.3f\t%d\n',1,runtime1,runtime2);
fclose(fid);
