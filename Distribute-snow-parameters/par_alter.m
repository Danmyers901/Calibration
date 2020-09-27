function par_alter(Extra,sampleData)
global n_sub file_id

% This function has been modified by DM 8/12/20 to include .sno parameters

par_n=Extra.par_n;
par_f= Extra.par_f;
x = zeros(length(par_n),1);
x(par_f==1)=sampleData;

% Change basin-level parameters 
ibsn=max(par_f(par_n==1)==1 || par_f(par_n==2)==1 || par_f(par_n==3)==1 || ...
         par_f(par_n==4)==1 || par_f(par_n==5)==1 || par_f(par_n==6)==1 || ...
         par_f(par_n==7)==1 || par_f(par_n==8)==1 || par_f(par_n==9)==1 || ...
         par_f(par_n==18)==1|| par_f(par_n==53)==1 || par_f(par_n==54)==1 || ...
         par_f(par_n==63)==1 || par_f(par_n==64)==1 || par_f(par_n==65)==1 || ...
         par_f(par_n==66)==1 || par_f(par_n==67)==1 || par_f(par_n==68)==1 ...
         || par_f(par_n==69)==1 || par_f(par_n==70)==1 || par_f(par_n==71)==1 ...
         || par_f(par_n==72)==1|| par_f(par_n==73)==1 || par_f(par_n==74)==1 ...
         || par_f(par_n==75)==1 || par_f(par_n==76)==1 || par_f(par_n==77)==1); 
       
iwwq=max(par_f(par_n==44)==1 || par_f(par_n==45)==1 || par_f(par_n==46)==1 || ...
         par_f(par_n==47)==1 || par_f(par_n==48)==1 || par_f(par_n==49)==1);

if  ibsn==1; bsn(par_n,par_f,x,Extra); end

if  iwwq==1; wwq(par_n,par_f,x,Extra); end

icrop=par_f(par_n==50)==1;
if  icrop==1; crop(par_n,x,Extra); end

% Change subbasin-level parameters
isub=max(par_f(par_n==33)==1 || par_f(par_n==34)==1 || par_f(par_n==35)==1 || ...
    par_f(par_n==60)==1 || par_f(par_n==61)==1);
irte=max(par_f(par_n==26)==1 || par_f(par_n==27)==1 || par_f(par_n==28)==1 || ...
               par_f(par_n==29)==1 ||  par_f(par_n==57)==1);
iswq=max(par_f(par_n==36)==1 || par_f(par_n==37)==1 || par_f(par_n==38)==1 || ...
         par_f(par_n==39)==1 || par_f(par_n==40)==1 || par_f(par_n==41)==1 || ...
         par_f(par_n==42)==1 || par_f(par_n==43)==1);

% Added by DM 8/12/20 for sno parameters
isno=max(par_f(par_n==78)==1 || par_f(par_n==79)==1 || par_f(par_n==80)==1 || ...
         par_f(par_n==81)==1 || par_f(par_n==82)==1);


if isub==1;
    for sub_no=1:n_sub;  
        subid=file_id(sub_no,9);
        sub(subid,par_n,par_f,x,Extra);
    end
end

if irte==1;
    for sub_no=1:n_sub;  
        subid=file_id(sub_no,9);
        rte(subid,par_n,par_f,x,Extra);
    end
end

if iswq==1;
    for sub_no=1:n_sub;  
        subid=file_id(sub_no,9);
        swq(subid,par_n,par_f,x, Extra);
    end
end

% Added by DM 8/12/20 for .sno parameters
if isno==1;
    for sub_no=1:n_sub;  
        subid=file_id(sub_no,9);
        sno(subid,par_n,par_f,x,Extra);
    end
end


% Change hru-level parameters
imgt= max(par_f(par_n==23)==1 || par_f(par_n==24)==1 || par_f(par_n==25)==1 || par_f(par_n==55)==1);

ihru=max(par_f(par_n==18)==1  || par_f(par_n==19)==1 || par_f(par_n==20)==1 || ...
         par_f(par_n==21)==1  || par_f(par_n==22)==1 || par_f(par_n==58)==1  );
isol=max(par_f(par_n==30)==1  || par_f(par_n==31)==1 || par_f(par_n==32)==1 || par_f(par_n==59)==1);
igw = max(par_f(par_n==14)==1 || par_f(par_n==15)==1 || par_f(par_n==16)==1 || ...
          par_f(par_n==17)==1 || par_f(par_n==62)==1);
ichm=max(par_f(par_n==10)==1 || par_f(par_n==11)==1 || par_f(par_n==12)==1 || ...
         par_f(par_n==13)==1);

n_hru=size(file_id,1);
if imgt==1;
    for hru_no=1:n_hru;                  
        hruid=file_id(hru_no,3); 
        hru_lnd=(file_id{hru_no,6});
        mgt_f(hruid,hru_lnd,par_n,par_f,x,Extra);
    end
end
if ihru==1;
    for hru_no=1:n_hru;         
        hruid=file_id(hru_no,3); 
        hru(hruid,par_n,par_f,x,Extra);
    end
end
if isol==1;
    for hru_no=1:n_hru;          
        hruid=file_id(hru_no,3); 
        sol(hruid,par_n,par_f,x,Extra);
    end
end
if igw==1;
    for hru_no=1:n_hru;          
        hruid=file_id(hru_no,3);         
        gw(hruid,par_n,par_f,x,Extra);
    end
end
if ichm==1;
    for hru_no=1:n_hru;          
        hruid=file_id(hru_no,3); 
        hru_lnd=double(file_id{hru_no,6});
        chm(hruid,hru_lnd,par_n,par_f,x,Extra);
    end
end
return;
