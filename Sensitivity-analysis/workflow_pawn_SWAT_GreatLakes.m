% This workflow scripts demonstrates the approximation strategy 
% of PAWN indices from generic input-output dataset
% by application to the SWAT model, 
% as described in Section 3.2 of:
%
% Pianosi, F. and Wagener, T. (2018), Distribution-based sensitivity 
% analysis from a generic input-output sample, Env. Mod. & Soft.
%
% The code works together with the SAFE Toolbox. More information and
% dowload at: www.bris.ac.uk/cabot/resources/safe-toolbox/
%
% This code developed by Francesca Pianosi, University of Bristol
% email: francesca.pianosi@bristol.ac.uk

%%%%%%%%%%%%%%%%%%%%% SET PATH %%%%%%%%%%%%%%%%%%%%%

% Set the path to the SAFE Toolbox directory
% (where you must have also copied the additional functions/data 
% for applying PAWN to generic datasets)

my_dir = pwd ; % use the 'pwd' command if you have already setup the Matlab
% current directory to the SAFE directory. Otherwise, you may define
% 'my_dir' manually by giving the path to the SAFE directory, e.g.:
% my_dir = '/Users/francescapianosi/Documents/safe_R1.1';

addpath(genpath(my_dir))

%%%%%%%%%%%%%%%%%%%%% LOAD DATA %%%%%%%%%%%%%%%%%%%%%

%% THIS SECTION IS MODIFIED FOR GREAT LAKES BASIN (DM 7/22/2020)
% Load the parameters and NSEs data
load('SWAT_samples_GLB_SAs_2020_09_08')

% Assign parameter labels
X_Labels_swat={'SFTMP', 'SURLAG', 'ALPHA\_BF', 'GW\_DELAY', 'GW\_REVAP', 'GWQMN', 'ESCO.hru', 'OV\_N (r)', 'RSDIN', 'SLOPE (r)',...
        'SLSUBBSN (r)', 'CN\_F (r)', 'CHKII', 'CHNII', 'CHSII (r)', 'SOL\_AWC (r)', 'SOL\_K (r)', 'CH\_KI (r)', 'CH\_NI', 'CH\_SI (r)',...
        'REVAPMN', 'EPCO.hru', 'ESCO.bsn', 'EPCO.bsn', 'CANMX (r)', 'ALPHA\_BNK', 'LAT\_TTIME', 'SOL\_BD (r)', 'RCHRG\_DP',...
        'SMFMN', 'SMFMX', 'SMTMP', 'SNO50COV', 'SNOCOVMX', 'TIMP'};

% Calculate how many parameters there are
[N,M] = size(Xrsa_ext_GLB) ;

% Calculate how many OFs there are
[N,P] = size(Y_ext_GLB_NSE_NSEsd)    ;
X = Xrsa_ext_GLB   ; % Model parameters
Y = Y_ext_GLB_NSE_NSEsd(:,1) ; % NSE for streamflow (used in convergence paper)

% Size of reduced sample for approximation of PAWN indices.
% These values must be less than the number of SWAT runs (e.g. <1008)
N_red = [3500 4000 4500 5000 ] ; % size of reduced sample for approximation of PAWN indices

% n must be less than or equal to the lowest N_red (e.g. 250) divided by nboot (e.g.
% 50); e.g. n would be <=5.
n = 10;

% N_sel must be less than the total number of SWAT runs (e.g. <1008)
N_sel = 5000 ; % sample size

% The max of nn must be equal to or less than n/2 (e.g. if n is 10, nn
% can't be more than 5...the reason is the split sample approach)
nn = [1:1:5] ; % values of 'n' to be tested

%% THIS ENDS THE GREAT LAKES BASIN MODIFICATION. THE REST OF THE CODE IS UNMODIFIED PAWN STUFF
%% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute PAWN sensitivity indices for different choices of N
% and different aggregation statistics
% (this will take some computing time!!!)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% n = 10 ;
% N_red = [ 1000 5000 7500 10000 ] ; % size of reduced sample for approximation of PAWN indices

nboot = 50  ;
alfa  = 0.05 ;

PAWN_median   = nan(length(N_red),M); PAWN_median_lb = PAWN_median; PAWN_median_ub = PAWN_median;
PAWN_mean     = nan(length(N_red),M); PAWN_mean_lb = PAWN_mean; PAWN_mean_ub = PAWN_mean;
PAWN_max      = nan(length(N_red),M); PAWN_max_lb = PAWN_max; PAWN_max_ub = PAWN_max;
KS_dummy_mean = nan(1,length(N_red));

for r=1:length(N_red) % WARNING: running this for loop may take some time!
    
    idx = randperm(N,N_red(r)) ;
    [KS_median,KS_mean,KS_max,KS_dummy] = pawn_indices_givendata(X(idx,:),Y(idx),n,nboot) ;
    
    % Take statistics across bootstrap resamples:
    PAWN_median(r,:) = mean(KS_median) ;
    median_lb = sort(KS_median) ; median_lb = median_lb(max(1,round(nboot*alfa/2)),:);
    median_ub = sort(KS_median) ; median_ub = median_ub(round(nboot*(1-alfa/2)),:);
    PAWN_median_lb(r,:) = median_lb ;
    PAWN_median_ub(r,:) = median_ub ;
    %
    PAWN_mean(r,:)   = mean(KS_mean)  ;
    mean_lb = sort(KS_mean) ; mean_lb = mean_lb(max(1,round(nboot*alfa/2)),:);
    mean_ub = sort(KS_mean) ; mean_ub = mean_ub(round(nboot*(1-alfa/2)),:);
    PAWN_mean_lb(r,:) = mean_lb ;
    PAWN_mean_ub(r,:) = mean_ub ;
    %
    PAWN_max(r,:)   = mean(KS_max)  ;
    max_lb = sort(KS_max) ; max_lb = max_lb(max(1,round(nboot*alfa/2)),:);
    max_ub = sort(KS_max) ; max_ub = max_ub(round(nboot*(1-alfa/2)),:);
    PAWN_max_lb(r,:) = max_lb ;
    PAWN_max_ub(r,:) = max_ub ;
    %
    KS_dummy_mean(r) = mean(KS_dummy)  ;
    %
    fprintf('iteration %d (N_red=%d) of %d completed \n',r,N_red(r),length(N_red))

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure 4: Bar plot of PAWN indices for given (N,n) [using stat=median] 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[tmp,ranking] = sort(-PAWN_median(end,:));
X_Labels_swat_ranked=X_Labels_swat(ranking);

hfig= figure; 
fs = 24 ;
b = bar(PAWN_median(end,ranking)) ;
set(b,'FaceColor',[126 126 126]/256)
axis([0,M+1,0,0.5])
hold on
plot([1:M],ones(1,M)*KS_dummy_mean(end),'r','LineWidth',2)
text(3,0.2,['N = ' int2str(N_red(end)) ', n = ' num2str(n) ],'FontSize',fs)
% set(gca,'YLim',[0,0.3],'FontSize',fs)
set(gca,'YLim',[0,0.25],'FontSize',fs) % I adjusted this DM 7/22/2020
for i=1:M; Xlab{i}=num2str(ranking(i)); end
% set(gca,'XTick',[1:M],'XTickLabel',Xlab,'YTick',[0,0.2,0.4],'FontSize',16)
set(gca,'XTick',[1:M],'XTickLabel',X_Labels_swat_ranked,'YTick',[0,0.1,0.2,0.3,0.4,1.0],'FontSize',16) % I adjusted this DM 7/22/2020
xtickangle(90) % Added by DM 7/22/20
%for i=1:M; text(i-0.5,PAWN_median_ub(end,ranking(i))+0.02,num2str(ranking(i)),'FontSize',20); end
ylabel('median(KS)','FontSize',fs)
xlabel('input factors','FontSize',fs)
for i = 1:M % connect upper and lower bound with a line
    plot([i i],[PAWN_median_lb(end,ranking(i)) PAWN_median_ub(end,ranking(i))],'k','LineWidth',1.5)
end
set(hfig, 'Position', [0 0 1200 300])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure 6: Bar plots of PAWN indices for given n and varying N
% [using stat=median or mean or max ]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hfig= figure; fs = 24 ;
stat = 1 ; % median (creates Fig. 6)
%stat = 2 ; % mean (creates Fig. 8)
%stat = 3 ; % max (creates Fig. 9)

for r=1:length(N_red)
    
    %subaxis(length(N_red),1,r, 'SpacingVert', 0.01,'SpacingHoriz',0.01,'MarginRight',0.01,'MarginTop',0.01,'MarginBottom',0.05);
    subplot(length(N_red),1,r)
    
    if stat==1; b = bar(PAWN_median(r,ranking)) ; ylabel('median(KS)','FontSize',fs); end
    if stat==2; b = bar(PAWN_mean(r,ranking))   ; ylabel('mean(KS)','FontSize',fs)  ; end
    if stat==3; b = bar(PAWN_max(r,ranking))    ; ylabel('max(KS)','FontSize',fs)   ; end
    set(b,'FaceColor',[126 126 126]/256)
    axis([0,M+1,0,0.5])
    hold on
    plot([1:M],ones(1,M)*KS_dummy_mean(r),'r','LineWidth',2)
    text(3,0.2,['N = ' int2str(N_red(r)) ', n = ' num2str(n) ],'FontSize',fs)
    
    % add axis ticks and label
    for i=1:M; Xlab{i}=num2str(ranking(i)); end 
    % for i=1:M; Xlab{i}=X_Labels_swat_ranked(i); end % changed by DM 9/8/20
    set(gca,'FontSize',fs,'YTick',[0,0.1,0.2,0.3], 'YLim', [0,0.25])% Edited by DM 9/8/20
    if r<length(N_red); 
        set(gca,'XTick',[1:M],'XTickLabel',{}); 
    else
        set(gca,'XTick',[1:M],'XTickLabel',X_Labels_swat_ranked,'FontSize',16)
        xlabel('input factors','FontSize',fs); 
        xtickangle(90) % Added by DM 9/8/2020
    end
    
    for i = 1:M % connect upper and lower bound with a line
        if stat==1; plot([i i],[PAWN_median_lb(r,ranking(i)) PAWN_median_ub(r,ranking(i))],'k','LineWidth',1.5); end
        if stat==2; plot([i i],[PAWN_mean_lb(r,ranking(i)) PAWN_mean_ub(r,ranking(i))],'k','LineWidth',1.5);     end
        if stat==3; plot([i i],[PAWN_max_lb(r,ranking(i)) PAWN_max_ub(r,ranking(i))],'k','LineWidth',1.5);       end        
    end
    
end
set(hfig, 'Position', [0 0 1200 1100])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure 7: Colourmap of PAWN indices to analyse impact of chosen 'n':
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% nn = [6:2:20] ; % values of 'n' to be tested

PAWN_median2   = nan(length(nn),M); PAWN_median_lb2 = PAWN_median2; PAWN_median_ub2 = PAWN_median2;
PAWN_mean2     = nan(length(nn),M); PAWN_mean_lb2 = PAWN_mean2; PAWN_mean_ub2 = PAWN_mean2;
PAWN_max2      = nan(length(nn),M); PAWN_max_lb2 = PAWN_max2; PAWN_max_ub2 = PAWN_max2;
KS_dummy_mean2 = nan(1,length(nn));

% N_sel = 5000 ; % sample size
nboot = 50   ; % number of bootstrap resamples
alfa  = 0.05 ; % confidence level to derive intervals via bootstrapping

% compute PAWN indices for different values of 'n'
% (this may take some computing time!):
idx2 = randperm(N,N_sel) ;
for r=1:length(nn) % WARNING: running this for loop may take some time!
    
    [KS_median2,KS_mean2,KS_max2,KS_dummy2] = pawn_indices_givendata(X(idx2,:),Y(idx2),nn(r),nboot) ;
    
    fprintf('%d iteration of %d completed \n',r,length(nn))
    % Take statistics across bootstrap resamples:
    PAWN_median2(r,:) = mean(KS_median2) ;
    median_lb2 = sort(KS_median2) ; median_lb2 = median_lb2(max(1,round(nboot*alfa/2)),:);
    median_ub2 = sort(KS_median2) ; median_ub2 = median_ub2(round(nboot*(1-alfa/2)),:);
    PAWN_median_lb2(r,:) = median_lb2 ;
    PAWN_median_ub2(r,:) = median_ub2 ;
    %
    PAWN_mean2(r,:)   = mean(KS_mean2)  ;
    mean_lb2 = sort(KS_mean2) ; mean_lb2 = mean_lb2(max(1,round(nboot*alfa/2)),:);
    mean_ub2 = sort(KS_mean2) ; mean_ub2 = mean_ub2(round(nboot*(1-alfa/2)),:);
    PAWN_mean_lb2(r,:) = mean_lb2 ;
    PAWN_mean_ub2(r,:) = mean_ub2 ;
    %
    PAWN_max2(r,:)   = mean(KS_max2)  ;
    max_lb2 = sort(KS_max2) ; max_lb2 = max_lb2(max(1,round(nboot*alfa/2)),:);
    max_ub2 = sort(KS_max2) ; max_ub2 = max_ub2(round(nboot*(1-alfa/2)),:);
    PAWN_max_lb2(r,:) = max_lb2 ;
    PAWN_max_ub2(r,:) = max_ub2 ;
    %
    KS_dummy_mean2(r) = mean(KS_dummy2)  ;
       
end

% rank inputs according to mean PAWN indices over different 'n':
[tmp,ranking2] = sort(-mean(PAWN_median2)); 

% create figure:
fs   = 20 ;
hfig = figure;
clrs = gray  ;
clrs = clrs(end:-1:1,:);
colormap(clrs) ; hold on
for r=1:length(nn); Lab_n{r}= num2str(nn(r)); end
for i=1:M;     Lab_i{i}=num2str(ranking2(i)); end
% Compute logical: if 1, then PAWN sensitivity is too close to dummy_KS 
% to be considered 'credible'
idx_ = nan(length(nn),M) ;
for r=1:length(nn)
    idx_(r,:) = max(PAWN_median2(r,ranking2)-KS_dummy_mean2(r),0)<=0.02; 
end
% plot colourmap (inputs on the vertical axis and 'n' on the horizontal)
imagesc4pdf( PAWN_median2(:,ranking2)' )
set(gca,'XTick',[1:length(nn)],'XTickLabel',Lab_n,'FontSize',fs)
set(gca,'YTick',[1:M],'YTickLabel',Lab_i,'FontSize',16)
ylabel('input factors','FontSize',fs)
xlabel('n','FontSize',fs)
for r=1:length(nn)
    plot(idx_(r,:)*r,1:M,'xr'); hold on
end
box on
hcb=colorbar('location','NorthOutside','FontSize',16);
title(hcb,'median(KS)','FontSize',fs)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure 10: Scatter plots and KS plots for selected inputs 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% idx  = randperm(N,5000) ; 
idx  = randperm(N,N_sel) ; % Modified this DM 7/22/2020 
X_ = X(idx,:) ; 
Y_ = Y(idx)   ;
i_sel  = [1,8,15,22]    ; % index of inputs to be further analysed
i_sel2 = ranking(i_sel) ;

nboot = 10 ;

hfig = figure; fs = 24;
col=gray(n+1); % Color for colormap, (n+1) so that the last line is not white
map = colormap(col(1:n,:));% Remove white color

for ii = 1:length(i_sel2)
    
    %subaxis(2,length(i_sel2),ii, 'SpacingVert', 0.01,'SpacingHoriz',0.01,'MarginRight',0.01,'MarginTop',0.01,'MarginBottom',0.15); hold on
    subplot(2,length(i_sel2),ii); hold on
    
    % scatter plots:
    plot(X_(:,i_sel2(ii)),Y_,'xk');
    set(gca,'YLim',[min(Y_) max(Y_)],'XLim',[min(X_(:,i_sel2(ii))),max(X_(:,i_sel2(ii)))],'XTickLabel',{},'YTickLabel',{},'FontSize',fs);
    if ii==1; ylabel('y'); end
    
    % KS plots:
    for temp = 1:nboot
        
        %[KS,KS_dummy,YF,Fu,Fc,YY,xc] = pawn_ks_givendata(X_,Y_,n) ;
        [KS,KS_dummy,YF,Fu,Fc,YY,xc] = pawn_ks_givendata(X_,Y_,round(n/2)) ; % Modified by DM 7/22/20
        
        %subaxis(2,length(i_sel2),ii+length(i_sel2), 'SpacingVert', 0.01,'SpacingHoriz',0.01,'MarginRight',0.01,'MarginTop',0.01,'MarginBottom',0.15);
        subplot(2,length(i_sel2),ii+length(i_sel2));
        %for kk=1:n
        for kk=1:round(n/2) % Modified by DM 7/22/20
            plot(xc{i_sel2(ii)}(kk),KS(kk,i_sel2(ii)),'ok','MarkerFaceColor',map(kk,:),'MarkerSize',8); hold on
        end
        
        % plot KS_dummy:
        plot([ xc{i_sel2(ii)}(1) xc{i_sel2(ii)}(end) ],[mean(KS_dummy) mean(KS_dummy)],'--r','LineWidth',2); hold on
    
    end
    set(gca,'YLim',[0 1],'XLim',[min(X_(:,i_sel2(ii))),max(X_(:,i_sel2(ii)))],'YTickLabel',{},'FontSize',fs)
    xlabel(['input ' num2str(i_sel2(ii)) ' (' X_Labels_swat{i_sel2(ii)} ')'],'FontSize',fs);
    if ii==1; ylabel('KS'); end

end
set(hfig, 'Position', [0 0 1200 600])


