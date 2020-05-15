% created March 7, 2020 by Yan-Ting Chen
clear;clc;
tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This is for *clear-sky* calculation with skin temperature for land %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  loc      = '/lustre03/project/6003571/yantingc/';
  locdata  = [loc,'data/'];
  addpath([loc,'co2_forcing_seasonal/script/rrtmg_code']);
% parameters
  
  co2      = 380*2; % ppmv
  time     = '20120202';

  dir      = [loc,'co2_forcing_seasonal/'];
  datadir  = [locdata,'ERA5/'];
  outdir   = [loc,'co2_forcing_seasonal/output/'];

  outfile  = [outdir,'output_lw_era5emis_land_',time,'_2xco2.nc'];
  
  cflag    = 0; 	%for clear sky

  % read data
  lon_coor = ncread([locdata,'ERA5/T/hourly/',time,'.nc'],'longitude');	% longitude coordinate
  lat_coor = ncread([locdata,'ERA5/T/hourly/',time,'.nc'],'latitude');	% latitude coordinate
  t_era5   = ncread([locdata,'ERA5/T/hourly/',time,'.nc'],'time'); 
  pmid_tmp = ncread([locdata,'ERA5/T/hourly/',time,'.nc'],'level'); 
  load([locdata,'ERA5-land/land_ind_2.5x2.5_1hr.mat']);  % load land index land_ind
  load([locdata,'ERA5/emis/hourly/',time,'.mat']);	% load emissivity emis

  % Create struct for output data
  dim_output = [length(lon_coor),length(lat_coor),length(pmid_tmp)+1];  % add one more level for surface layer
toc

for tind = 1:24

  tind
  
% Create struct for output data
  output_fup_lw(:,:,:,tind) = NaN([dim_output 1]);
  output_fdn_lw(:,:,:,tind) = NaN([dim_output 1]);
  output_fnt_lw(:,:,:,tind) = NaN([dim_output 1]);
  output_htr_lw(:,:,:,tind) = NaN([dim_output 1]);
  
  sfc_ind(:,:,tind)    = NaN([dim_output(1) dim_output(2) 1]);
  sfc_fup_lw(:,:,tind) = NaN([dim_output(1) dim_output(2) 1]);
  sfc_fdn_lw(:,:,tind) = NaN([dim_output(1) dim_output(2) 1]);
  sfc_fnt_lw(:,:,tind) = NaN([dim_output(1) dim_output(2) 1]);
  sfc_htr_lw(:,:,tind) = NaN([dim_output(1) dim_output(2) 1]);
               
  tmid_tmp = ncread([locdata,'ERA5/T/hourly/',time,'.nc'],'t',[1 1 1 tind],[Inf Inf Inf 1]);
  h2o_raw  = ncread([locdata,'ERA5/spec_humidity/hourly/',time,'.nc'],'q',[1 1 1 tind],[Inf Inf Inf 1]);
  o3_raw   = ncread([locdata,'ERA5/ozone/hourly/',time,'.nc'],'o3',[1 1 1 tind],[Inf Inf Inf 1]);
  psfc_raw = ncread([locdata,'ERA5/Psfc/hourly/',time,'.nc'],'sp',[1 1 tind],[Inf Inf 1]) ./ 100. ;	% surface pressure  % convert to hPa
  tsfc_raw = ncread([locdata,'ERA5/Tskin/hourly/',time,'.nc'],'skt',[1 1 tind],[Inf Inf 1]);	% skin temperature
  psfc_land= ncread([locdata,'ERA5-land/Psfc/hourly/',time,'.nc'],'sp',[1 1 tind],[Inf Inf 1]) ./ 100.;
  tsfc_land= ncread([locdata,'ERA5-land/Tskin/hourly/',time,'.nc'],'skt',[1 1 tind],[Inf Inf 1]);
%
  % replace surface pressure and skin temperatere over land. Not necessary.
  tsfc_raw(land_ind) = tsfc_land(land_ind);
  psfc_raw(land_ind) = psfc_land(land_ind);

  emis_tmp = squeeze(emis(:,:,tind));
 
  h2o_raw(h2o_raw < 0) = missing;               % avoid negative h2o
  o3_raw(o3_raw < 0)   = missing;

% for loop for each gridbox.

  for i = 1: 1: length(lon_coor)
    lon = lon_coor(i);
  
    for j = 1: 1: length(lat_coor)
      lat = lat_coor(j);

      if any(ismissing(h2o_raw(i,j,:))|ismissing(o3_raw(i,j,:))) % half part only for derived emis | any(ismissing(emis_tmp((i-1)/8+1,(j-1)/8+1)))
        continue
      else

        % profile
        psfc = psfc_raw(i,j);
        tsfc = tsfc_raw(i,j);
        
        [nlev, pmid, pint, tmid, tint, h2o, o3, n2o, co, ch4, o2] = read_profile(i,j,pmid_tmp,tmid_tmp,psfc,tsfc,h2o_raw,o3_raw);
        
        atmprofile.pmid = pmid;
        atmprofile.pint = pint;
        atmprofile.tmid = tmid;
        atmprofile.tint = tint;
        atmprofile.h2o  = h2o;
        atmprofile.o3   = o3;
        atmprofile.n2o  = n2o;
        atmprofile.co   = co;
        atmprofile.ch4  = ch4;
        atmprofile.o2   = o2;
        atmprofile.co2  = co2.*ones(size(atmprofile.h2o)) * 1e-6;
        atmprofile.wbroadl = broad(atmprofile,nlev);  
        atmprofile.semiss  = emis_tmp(i,j);        

        % calculate longwave 
        [fup_lw, fdn_lw, fnt_lw, htr_lw] = rrtmg_lw_htr(atmprofile, nlev);
        
        % Output data        
        output_fup_lw(i,j,1:nlev,tind) = fup_lw;
        output_fdn_lw(i,j,1:nlev,tind) = fdn_lw;
        output_fnt_lw(i,j,1:nlev,tind) = fnt_lw;
        output_htr_lw(i,j,1:nlev,tind) = [0 htr_lw];
        
        sfc_ind(i,j,tind)    = nlev;
        sfc_fup_lw(i,j,tind) = fup_lw(nlev);
        sfc_fdn_lw(i,j,tind) = fdn_lw(nlev);
        sfc_fnt_lw(i,j,tind) = fnt_lw(nlev);
        sfc_htr_lw(i,j,tind) = htr_lw(nlev-1);
             
      end 
    end
  end

  clear tmid_tmp h2o_raw o3_raw psfc_raw tsfc_raw psfc_land tsfc_land emis_tmp

end  

  time = 1:tind;
  
  ! rm -rf outfile.nc
  
  % --------------------------- DEFINE THE FILE ----------------------------
  ncid = netcdf.create(outfile,'CLOBBER');
  %ncid = netcdf.open('olr_nc_test.nc','WRITE');
  %nccreate('olr_nc_test.nc','bdps_olr');
  
  %-----------------------------DEFINE DIMENSION----------------------------
  dimidx = netcdf.defDim(ncid,'lon',length(lon_coor));    
  dimidy = netcdf.defDim(ncid,'lat',length(lat_coor));
  dimidz = netcdf.defDim(ncid,'level',length(pmid_tmp)+1);    % add surface layer
  dimidt = netcdf.defDim(ncid,'time',tind);  
  atm_dz = netcdf.defDim(ncid,'atm_level',length(pmid_tmp));
  
  %----------------------------DEFINE NEW VARIABLES-------------------------
  lonvarid  = netcdf.defVar(ncid,'longitude','NC_FLOAT',[dimidx]);
  latvarid  = netcdf.defVar(ncid,'latitude','NC_FLOAT',[dimidy]);
  levvarid  = netcdf.defVar(ncid,'atm_level','NC_INT',[atm_dz]);
  timevarid = netcdf.defVar(ncid,'time','NC_INT',[dimidt]);
  varid1 = netcdf.defVar(ncid,'fup_lw','NC_FLOAT',[dimidx dimidy dimidz dimidt]);
  varid2 = netcdf.defVar(ncid,'fdn_lw','NC_FLOAT',[dimidx dimidy dimidz dimidt]);
  varid3 = netcdf.defVar(ncid,'fnt_lw','NC_FLOAT',[dimidx dimidy dimidz dimidt]);
  varid4 = netcdf.defVar(ncid,'htr_lw','NC_FLOAT',[dimidx dimidy dimidz dimidt]);
  toaid1 = netcdf.defVar(ncid,'toa_lw','NC_FLOAT',[dimidx dimidy dimidt]);
  sfcid1 = netcdf.defVar(ncid,'sfc_fup_lw','NC_FLOAT',[dimidx dimidy dimidt]);
  sfcid2 = netcdf.defVar(ncid,'sfc_fdn_lw','NC_FLOAT',[dimidx dimidy dimidt]);
  sfcid3 = netcdf.defVar(ncid,'sfc_fnt_lw','NC_FLOAT',[dimidx dimidy dimidt]);
  sfcid4 = netcdf.defVar(ncid,'sfc_htr_lw','NC_FLOAT',[dimidx dimidy dimidt]);
  sfcid5 = netcdf.defVar(ncid,'sfc_ind','NC_FLOAT',[dimidx dimidy dimidt]);
 
  %------------------------------DEFINE ATTRIBUTE---------------------------
  netcdf.putAtt(ncid,lonvarid,'units','degrees_east');
  netcdf.putAtt(ncid,latvarid,'units','degrees_north');
  netcdf.putAtt(ncid,levvarid,'units','millibars. Surface pressure not included.');
  netcdf.putAtt(ncid,timevarid,'units','hour');
  netcdf.putAtt(ncid,varid1,'units','W/m2. Upward positive');
  netcdf.putAtt(ncid,varid2,'units','W/m2. Downward positive');
  netcdf.putAtt(ncid,varid3,'units','W/m2. Upward positive');
  netcdf.putAtt(ncid,varid4,'units','degree/day.');
  netcdf.putAtt(ncid,toaid1,'units','W/m2. Upward positive');
  netcdf.putAtt(ncid,sfcid1,'units','W/m2. Upward positive');
  netcdf.putAtt(ncid,sfcid2,'units','W/m2. Downward positive');
  netcdf.putAtt(ncid,sfcid3,'units','W/m2. Upward positive');
  netcdf.putAtt(ncid,sfcid4,'units','degree/day.');
  netcdf.putAtt(ncid,sfcid5,'units','Effective atmospheric layers above surface. Count from TOA');
   
   %---------------------------GIVE VALUES TO VARIABLES-----------------------
  netcdf.endDef(ncid)
   
  netcdf.putVar(ncid,lonvarid,lon_coor);
  netcdf.putVar(ncid,latvarid,lat_coor);
  netcdf.putVar(ncid,levvarid,pmid_tmp);
  netcdf.putVar(ncid,timevarid,t_era5);
  netcdf.putVar(ncid,varid1,output_fup_lw);
  netcdf.putVar(ncid,varid2,output_fdn_lw);
  netcdf.putVar(ncid,varid3,output_fnt_lw);
  netcdf.putVar(ncid,varid4,output_htr_lw);
  netcdf.putVar(ncid,toaid1,squeeze(output_fnt_lw(:,:,1,:)));
  netcdf.putVar(ncid,sfcid1,sfc_fup_lw);
  netcdf.putVar(ncid,sfcid2,sfc_fdn_lw);
  netcdf.putVar(ncid,sfcid3,sfc_fnt_lw);
  netcdf.putVar(ncid,sfcid4,sfc_htr_lw);
  netcdf.putVar(ncid,sfcid5,sfc_ind);

  netcdf.close(ncid);

toc

