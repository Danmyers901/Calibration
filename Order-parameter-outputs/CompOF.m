function [newOF,newCg,POSITION] = CompOF(x,AMALGAMPar,Extra)
% This function computes the objective function for each x value
% It has been modified for multivariable calibration.

% This code was modified by DM 9/23/20 to create the POSITION variable which helps create the ordered parameter set output OrdSet.

t0=clock;


OF1(1:AMALGAMPar.N)=0;
if AMALGAMPar.nobj>1
    OF2(1:AMALGAMPar.N)=0;
    if AMALGAMPar.nobj>2 % Added this for OF3, so that it can be turned off if needed (DM 6/7/2020)
    	OF3(1:AMALGAMPar.N)=0; % Be sure to update nobj in runAMALGAM.m to the correct number of OFs too (DM 6/7/2020).
        if AMALGAMPar.nobj>3 % Added for OF4 (DM 6/8/2020)
            OF4(1:AMALGAMPar.N)=0;
            if AMALGAMPar.nobj>4 % Added for OF5 (DM 6/11/2020)
                OF5(1:AMALGAMPar.N)=0;
                if AMALGAMPar.nobj>5 % Added for OF6 (DM 6/11/2020)
                    OF6(1:AMALGAMPar.N)=0;
                end
            end
        end   
    end
end
newOF(1:AMALGAMPar.N,1:AMALGAMPar.nobj>1)=0;


parfor iRun=1:AMALGAMPar.N

    [OF1(iRun), OF2(iRun), OF3(iRun), OF4(iRun), POSITION(iRun)] = mcalib(iRun,x(iRun,:),Extra) % Added OF3, OF4 here (DM 6/11/2020). DM 9/23/20 change made here.
end

newOF(:,1)=OF1;
if AMALGAMPar.nobj>1
    newOF(:,2)=OF2;
    if AMALGAMPar.nobj>2 % Added this condition for OF3 (DM 6/7/2020)
        newOF(:,3)=OF3;
        if AMALGAMPar.nobj>3 % Added for OF4 (DM 6/8/2020)
            newOF(:,4)=OF4;
            if AMALGAMPar.nobj>4 % Added for OF5 (DM 6/11/2020)
                newOF(:,5)=OF5;
                if AMALGAMPar.nobj>5 % Added for OF6 (DM 6/11/2020)
                    newOF(:,6)=OF6;
                end
            end
        end
    end
end

runtime1=fix(etime(clock,t0)/60);
runtime2=round((etime(clock,t0)/60-fix(etime(clock,t0)/60))*60);
disp(['runtime: ' num2str(runtime1) ' min     ' num2str(runtime2) ' sec']);

newCg(1:AMALGAMPar.N,1) = 0;
POSITION = POSITION';

fid = fopen ('../outputs/simTime_SubCalib21516.dat','a');
fprintf(fid,'%d\t%.3f\t%d\n',1,runtime1,runtime2);
fclose(fid);
