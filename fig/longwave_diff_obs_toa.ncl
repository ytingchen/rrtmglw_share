begin

  dir      = "/home/yanting/co2_forcing_seasonal/"
  datadir  = "/home/yanting/co2_forcing_seasonal/data_beluga/"
  outdir   = "/home/yanting/co2_forcing_seasonal/figure/"
  filetime = "2012"
  filename_toa = filetime + "_toa_lw.nc"
  filerrtm_toa = filetime + "_ctrl_clear_era5emis.nc"; + filename + ".nc"

  title    = filename_toa
  figname  = "LW_toa_obs_diff_emis_era5_land_" + filetime + "_clear"
  figtype  = "pdf"
  
  panel_string = (/"ERA5","RRTM","RRTM - ERA5"/)
  
; add file
  f1 = addfile(datadir + filename_toa,"r")
  f2 = addfile(datadir + filerrtm_toa,"r")

  dlongrid = 1
  dlatgrid = 1

  fnt_obs   = f1->ttrc(:,::dlatgrid,::dlongrid)
  fnt_obs_flt = dim_avg_n_Wrap(dble2flt(fnt_obs),0)/3600.
  fnt_1xco2 = f2->toa_lw(:,::dlatgrid,::dlongrid)*(-1.)    ; note that the level coordinate is TOA to surface

  ; manually replace NaN with _FillValue
  if (any(isnan_ieee(fnt_1xco2))) then
    if(.not.isatt(fnt_1xco2,"_FillValue")) then
      fnt_1xco2@_FillValue = default_fillvalue(typeof(fnt_1xco2))
    end if
    replace_ieeenan (fnt_1xco2, fnt_1xco2@_FillValue, 0)
  end if

  fnt_1xco2:= dim_avg_n_Wrap(dble2flt(fnt_1xco2),0)
;  fnt_lw_2xco2 = f3->fnt_lw(:,::10,::10) ;- f3->fnt_lw(0,::10,::10)

  lon = f1->longitude(::dlongrid)
  lat = f1->latitude(::dlatgrid)

  diff_fnt  = fnt_1xco2 - fnt_obs_flt
printMinMax(diff_fnt,1)
  copy_VarCoords(fnt_obs(0,:,:),fnt_obs_flt) 
  copy_VarCoords(fnt_obs_flt,fnt_1xco2) 
  copy_VarCoords(fnt_obs_flt,diff_fnt)  

; calculate global mean
  re             = 6.37122e06		; earth radius [m]
  rad		 = 4.0*atan(1.0)/180.0		; get radiance
  clat           = cos(lat*rad)		; cosine of latitude

  dlon           = (lon(2) - lon(1))	; assume dlon is constant
  dlat		 = (lat(2) - lat(1))	; assume dlat is constant

  dx 		 = dlon*clat    	; dx at each latitude
  dy 		 = dlat*re*rad		; dy is costant
  area		 = dy*dx		; area(nlat)

  opt_wgt        = 0	;0-calculate non-missing data

  fnt_obs_avg    = wgt_areaave(fnt_obs_flt,area,1.0,opt_wgt)    ;wgt_areaave(var,wgty,wgtx,opt)
  fnt_1xco2_avg  = wgt_areaave(fnt_1xco2,area,1.0,opt_wgt)
  diff_fnt_avg   = wgt_areaave(diff_fnt,area,1.0,opt_wgt)

  global_mean = new(3,float)
  global_mean(0) = fnt_obs_avg
  global_mean(1) = fnt_1xco2_avg
  global_mean(2) = diff_fnt_avg

  global_mean = decimalPlaces(global_mean,1,True)    	;True-> round number to 1 decimal place

  global_var = variance(diff_fnt)

  global_var = decimalPlaces(global_var,1,True)    	;True-> round number to 1 decimal place

; set res
  
  res = True
  res@gsnDraw  = False
  res@gsnFrame = False
  
  res@cnFillOn = True
  res@cnLinesOn = False
  res@gsnLeftStringFontHeightF  = 19
  res@gsnRightStringFontHeightF = res@gsnLeftStringFontHeightF 

  ;res@cnFillPalette =  
;  res@cnLevelSelectionMode = "ManualLevels"
;  res@cnMinLevelValF       = -5.6
;  res@cnMaxLevelValF       =  5.6
;  res@cnLevelSpacingF      =   .4

  cmap = read_colormap_file("NCV_jaisnd")
  cmap(119:135,:) = 1.
  cmap2 = read_colormap_file("ViBlGrWhYeOrRe");("BlueWhiteOrangeRed")

  res@cnFillMode    = "RasterFill"
  res@cnFillPalette = cmap;"ViBlGrWhYeOrRe" 
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = -340.
  res@cnMaxLevelValF       = -120.
  res@cnLevelSpacingF      =  20.

; plot

  wks = gsn_open_wks(figtype,outdir+figname)
  
  plot = new(3,graphic)
  
  res0 = res
  res0@gsnLeftString = panel_string(0)
  res0@gsnRightString = global_mean(0) + " W/m2"

  res1 = res
  res1@gsnLeftString = panel_string(1)
  res1@gsnRightString = global_mean(1) + " W/m2"
  
  res2 = res
  res2@gsnLeftString = panel_string(2)
  res2@gsnRightString = global_mean(2) + " W/m2; variance = " + global_var + " W2/m4"
  delete(res2@cnFillPalette)
  res2@cnFillPalette = "ViBlGrWhYeOrRe";BlueWhiteOrangeRed"
  res2@cnLevelSelectionMode = "ManualLevels"
  res2@cnMinLevelValF       = -10.
  res2@cnMaxLevelValF       =  10.
  res2@cnLevelSpacingF      =  1.
 
  plot(0) = gsn_csm_contour_map(wks,fnt_obs_flt,res0)
  plot(1) = gsn_csm_contour_map(wks,fnt_1xco2,res1)
  plot(2) = gsn_csm_contour_map(wks,diff_fnt,res2)

; create panel
 
  resP                    = True                 ; modify the panel plot
  resP@gsnFrame           = False                ; don't advance panel plot
  resP@gsnMaximize        = True
;  resP@gsnPanelLabelBar   = True                 ; add common colorbar
;  resP@gsnPanelBottom     = 0.05
;  resP@gsnPanelMainString = "A common title"     ; set main title

  gsn_panel(wks,plot,(/3,1/),resP)               ; now draw as one plot

  frame(wks)

end
