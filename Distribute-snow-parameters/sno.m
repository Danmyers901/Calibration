function sno(subid,par_n,par_f,x,Extra)

% This function updates the parameters in .sno files (created by DM 8/12/20).

subid=char(subid);
subid=[subid '.sno'];


SFTMP=x(par_n==78); 
SMTMP=x(par_n==79);
SMFMX=x(par_n==80);
SMFMN=x(par_n==81);
TIMP=x(par_n==82);
delete(subid);

fid1=fopen([Extra.InputDir '/sensin/' subid],'r');
fid2=fopen(subid,'w');

% Format of the .sno file
snoformat = '%8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f\r\n ';

% Option 1: Assign sub sno parameters (comment if not unused)
sub_sftmp = repmat(SFTMP,1,10) ;
sub_smtmp = repmat(SMTMP,1,10) ;
sub_smfmx = repmat(SMFMX,1,10) ;
sub_smfmn =repmat(SMFMN,1,10);
sub_timp = repmat(TIMP,1,10);

% Option 2: Create random sno parameters for testing (comment if not used)
% sub_sftmp = repmat(rand*5,1,10) ;
% sub_smtmp = repmat(rand*5,1,10) ;
% sub_smfmx = repmat(rand*10,1,10) ;
% sub_smfmn =repmat(rand*10,1,10);
% sub_timp = repmat(rand*1,1,10);

% Merge sno parameters
allsnow = [sub_sftmp;sub_smtmp;sub_smfmx; sub_smfmn; sub_timp];

% Write parameters to sno files
fprintf(fid2, snoformat,allsnow');
fclose(fid1);
fclose(fid2);

return;
