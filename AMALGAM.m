function [output,ParGen,ObjVals,ParSet,ParSim, OrdSet, outputs_snowmelt, outputs_groundwater, outputs_water_yield] = AMALGAM(AMALGAMPar,ParRange,Extra,Fpareto);

% THIS AMALGAM.M FUNCTION HAS BEEN MODIFIED BY DAN MYERS 7/23/2020 TO GENERATE A NEW LATIN HYPERCUBE
% SAMPLE FOR EACH ITERATION, FOR SENSITIVITY ANALYSIS PURPOSES


% ------------------ The AMALGAM multiobjective optimization algorithm ------------------------ % 
%                                                                                               %
% This general purpose MATLAB code is designed to find a set of parameter values that defines   %
% the Pareto trade-off surface corresponding to a vector of different objective functions. In   %
% principle, each Pareto solution is a different weighting of the objectives used. Therefore,   %
% one could use multiple trials with a single objective optimization algorithms using diferent  %
% values of the weights to find different Pareto solutions. However, various contributions to   %
% the optimization literature have demonstrated that this approach is rather inefficient. The   %
% AMALGAM code developed herein is designed to find an approximation of the Pareto solution set %
% within a single optimization run. The AMALGAM method combines two new concepts,               %
% simultaneous multimethod search, and self-adaptive offspring creation, to ensure a fast,      %
% reliable, and computationally efficient solution to multiobjective optimization problems. 	%
% This method is called a multi-algorithm, genetically adaptive multiobjective, or AMALGAM, 	%
% method, to evoke the image of a procedure that blends the attributes of the best available 	%
% individual optimization algorithms.                                                           %
%                                                                                               %
% This algorithm has been described in:                                                         %
%                                                                                               %
% J.A. Vrugt, and B.A. Robinson, Improved evolutionary optimization from genetically adaptive   %
%    multimethod search, Proceedings of the National Academy of Sciences of the United States   %
%    of America, 104, 708 - 711, doi:10.1073/pnas.0610471104, 2007.                             %
%                                                                                               %
% J.A. Vrugt, B.A. Robinson, and J.M. Hyman, Self-Adaptive MultiMethod Search For Global        %
%    Optimization in Real-Parameter Spaces, IEEE Transactions on Evolutionary Computation,      %
%    1-17, 10.1109/TEVC.2008.924428, In Press, 2009                                             %
%                                                                                               %
% For more information please read:                                                             %
%                                                                                               %
% J.A. Vrugt, H.V. Gupta, L.A. Bastidas, W. Bouten, and S. Sorooshian, Effective and efficient  %
%    algorithm for multi-objective optimization of hydrologic models, Water Resources Research, %
%    39(8), art. No. 1214, doi:10.1029/2002WR001746, 2003.                                      %
%                                                                                               %
% G.H. Schoups, J.W. Hopmans, C.A. Young, J.A. Vrugt, and W.W.Wallender, Multi-objective        %
%    optimization of a regional spatially-distributed subsurface water flow model, Journal      %
%    of Hydrology, 20 - 48, 311(1-4), doi:10.1016/j.jhydrol.2005.01.001, 2005.                  %
%                                                                                               %
% J.A. Vrugt, P.H. Stauffer, T. W?hling, B.A. Robinson, and V.V. Vesselinov, Inverse modeling   %
%    of subsurface flow and transport properties: A review with new developments, Vadose Zone   %
%    Journal, 7(2), 843 - 864, doi:10.2136/vzj2007.0078, 2008.                                  %
%                                                                                               %
% T. W?hling, J.A. Vrugt, and G.F. Barkle, Comparison of three multiobjective optimization      %
%    algorithms for inverse modeling of vadose zone hydraulic properties, Soil Science Society  %
%    of America Journal, 72, 305 - 319, doi:10.2136/sssaj2007.0176, 2008.                       %
%                                                                                               %
% T. W?hling, and J.A. Vrugt, Combining multi-objective optimization and Bayesian model         %
%    averaging to calibrate forecast ensembles of soil hydraulic models, Water Resources        %
%    Research, 44, W12432, doi:10.1029/2008WR007154, 2008.                                      %
%                                                                                               %
%                                                                                               %
% Copyright (c) 2008, Los Alamos National Security, LLC                                         %
%                                                                                               %
% All rights reserved.                                                                          %
%                                                                                               %
% Copyright 2008. Los Alamos National Security, LLC. This software was produced under U.S.      %
% Government contract DE-AC52-06NA25396 for Los Alamos National Laboratory (LANL), which is     %
% operated by Los Alamos National Security, LLC for the U.S. Department of Energy. The U.S.     %
% Government has rights to use, reproduce, and distribute this software.                        %
%                                                                                               %
% NEITHER THE GOVERNMENT NOR LOS ALAMOS NATIONAL SECURITY, LLC MAKES A NY WARRANTY, EXPRESS OR  %
% IMPLIED, OR ASSUMES ANY LIABILITY FOR THE USE OF THIS SOFTWARE. If software is modified to    %
% produce derivative works, such modified software should be clearly marked, so as not to       %
% confuse it with the version available from LANL.                                              %
%                                                                                               %
% Additionally, redistribution and use in source and binary forms, with or without              %
% modification, are permitted provided that the following conditions are met:                   %
% ? Redistributions of source code must retain the above copyright notice, this list of         %
%   conditions and the following disclaimer.                                                    %
% ? Redistributions in binary form must reproduce the above copyright notice, this list of      %
%   conditions and the following disclaimer in the documentation and/or other materials         %
%   provided with the distribution.                                                             %
% ? Neither the name of Los Alamos National Security, LLC, Los Alamos National Laboratory, LANL %
%   the U.S. Government, nor the names of % its contributors may be used to endorse or promote  %
%   products derived from this software without specific prior written permission.              %
%                                                                                               %
% THIS SOFTWARE IS PROVIDED BY LOS ALAMOS NATIONAL SECURITY, LLC AND CONTRIBUTORS "AS IS" AND   %
% ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES      %
% OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL LOS %
% ALAMOS NATIONAL SECURITY, LLC OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, %
% SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF   %
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)        %
% HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT %
% (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,       %
% EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                                            %
%                                                                                               %
%                                                                                               %
% AMALGAM code developed by Jasper A. Vrugt, Center for NonLinear Studies (CNLS), LANL          %
%                                                                                               %
% Written by Jasper A. Vrugt: vrugt@lanl.gov                                                    % 
%                                                                                               %
% Version 0.5:   June 2006                                                                      %
% Version 1.0:   January 2009    Cleaned up source code and implemented 4 test example problems %
%                                                                                               %
% --------------------------------------------------------------------------------------------- %

% Initialize algorithmic variables and other properties
[AMALGAMPar,Extra,output,Bounds,ParSet,V] = InitVariables(AMALGAMPar,Extra);

%Alejandra 9/27/2018
ParSim = zeros(AMALGAMPar.N,AMALGAMPar.n + AMALGAMPar.nobj + 1);

% Sample AMALGAMPar.N points in the parameter space
ParGen = LHSU(ParRange.minn,ParRange.maxn,AMALGAMPar.N);

% Initialize summary matrices
outputs_groundwater = [];
outputs_snowmelt = [];
outputs_water_yield = [];

% Calculate objective function values for each of the AMALGAMPar.N points
[ObjVals,Cg, OrdSet, outputs_snowmelt_append, outputs_gw_append, outputs_water_yield_append] = CompOF(ParGen,AMALGAMPar,Extra);

% Summarize outputs
outputs_groundwater = [outputs_groundwater; outputs_gw_append];
outputs_snowmelt = [outputs_snowmelt; outputs_snowmelt_append];
outputs_water_yield = [outputs_water_yield; outputs_water_yield_append];

% Ranking and CrowdDistance Calculation
[Ranking,CrowdDist] = CalcRank(ObjVals,Bounds,Cg);

% Define the current iteration value
Iter = AMALGAMPar.N;

% Compute convergence diagnostics -- distance to Pareeto optimal front (only values for synthetic problems!)
[Gamma,Delta,Hvol] = CompConv(AMALGAMPar,Fpareto,ObjVals); 

% Store the convergence statistics in output.R
output.R(1,1:4) = [Iter Gamma Delta Hvol];

% Store current population in ParSet
ParSet(1:AMALGAMPar.N,1:AMALGAMPar.n + AMALGAMPar.nobj + 1) = [ParGen Cg ObjVals];

% Define counter
counter = 2;

% Now iterate
while (Iter < AMALGAMPar.ndraw),
    
    % Step 1: Now determine Pbest and Nbest for Particle Swarm Optimization
    [pBest,nBest] = SelBest(Ranking,ParSet(1:Iter,1:end),AMALGAMPar,Extra);
    
    % Step 2: Generate offspring
    [NewGen,V,Itot] = GenChild(ParGen,ObjVals,Ranking,CrowdDist,Cg,V,pBest,nBest,AMALGAMPar,ParRange,Extra);
    
    % Step 2b: Check whether parameters are in bound 
    %[NewGen] = CheckPars(NewGen,ParRange,Extra.BoundHandling);

    % Sample AMALGAMPar.N points in the parameter space 
    %(Added by DM 7/23/2020 so that a new latin hypercube sample is generated each time, not converging, for sensitivity analysis purposes.
    NewGen = LHSU(ParRange.minn,ParRange.maxn,AMALGAMPar.N);


    % Step 3: Compute Objective Function values offspring
    % Modified by DM 8/12/20 for sensitivity analysis purposes
    %[ChildObjVals,ChildCg] = CompOF(NewGen,AMALGAMPar,Extra);
    [ObjVals,Cg, OrdSet, outputs_snowmelt_append, outputs_gw_append, outputs_water_yield_append] = CompOF(NewGen,AMALGAMPar,Extra);

    % Append summaries
    outputs_groundwater = [outputs_groundwater; outputs_gw_append];
    outputs_snowmelt = [outputs_snowmelt; outputs_snowmelt_append];
    outputs_water_yield = [outputs_water_yield; outputs_water_yield_append];

	
	size(NewGen);
	%size(ChildCg);
	%size(ChildObjVals);

    % Step 4: Now merge parent and child populations and generate new one
    % This was modified by DM 8/12/2020 for sensitivity analysis purposes, to not generate a new population based on rank.
    %[ParGen,ObjVals,Ranking,CrowdDist,Iout,Cg] = CreateNewPop(ParGen,NewGen,ObjVals,ChildObjVals,Itot,Cg,ChildCg,ParRange,Bounds);
    
    % Step 5: Determine the new number of offspring points for individual algorithms
    %[AMALGAMPar] = DetN(Iout,AMALGAMPar);
    
    % Step 6: Append the new points to ParSet
    % Modified by DM 8/12/20 for sensitivity analysis purposes.
    %ParSet(Iter+1:Iter+AMALGAMPar.N,1:end) = [ParGen Cg ObjVals];
    ParSet(Iter+1:Iter+AMALGAMPar.N,1:end) = [NewGen Cg ObjVals];
    
    % Step 7: Compute convergence statistics -- this can only be done for synthetic problems
    [Gamma,Delta,Hvol] = CompConv(AMALGAMPar,Fpareto,ObjVals);
    
    % Step 8: Update Iteration
    Iter = Iter + AMALGAMPar.N;
    
    % Step 9a: Save AMALGAMPar.m
    output.algN(counter,1:AMALGAMPar.q + 1) = [Iter AMALGAMPar.m];
    
    % Step 9b: Store the convergence statistics in output.R
    output.R(counter,1:4) = [Iter Gamma Delta Hvol];
    
    % Step 10: Update counter
    counter = counter + 1;
    save ../outputs/Calib2obj.mat ParSet output outputs_snowmelt outputs_groundwater outputs_water_yield
    % Write Iter to screen -- to show progress
    Iter
	
end;

%Alejandra 9/27/2018
NewGen;
%ChildCg;
%ChildObjVals;
size(NewGen);
%size(ChildCg);
%size(ChildObjVals);

% Modified by DM 8/12/20 for sensitivity analysis purposes
%ParSim = [NewGen(1:AMALGAMPar.N,:) ChildCg ChildObjVals];
ParSim = [NewGen(1:AMALGAMPar.N,:) Cg ObjVals];
