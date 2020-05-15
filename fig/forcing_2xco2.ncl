begin

  dir      = "/storage/ytchen/co2_forcing_seasonal/"
  datadir  = "/storage/ytchen/data/ERA5/"
  outdir   = "/storage/ytchen/co2_forcing_seasonal/figure/"
  filetime = "201207"
  filename = "radflx_lw_clear/" + filetime + ".nc"
  filerrtm = "output_lw_emis_merra2_"+filetime+"01.nc"; + filename + ".nc"
  file2co2 = "output_lw_emis_merra2_land_2xco2_"+filetime+"01.nc"; + filename + ".nc"
  title    = filename
  figname  = "forcing_LW_emis_merra2_land_" + filetime
  figtype  = "x11"
  
  panel_string = (/"TOA_2xco2-ctl","SFC_2xco2-ctl","CONVERCE_2xco2-ctl"/)
  
; add file
  f1 = addfile(dir + filerrtm,"r")
  f2 = addfile(dir + "2xco2/" + file2co2,"r") 
  f3 = addfile(datadir + filename,"r")

  dlongrid = 1
  dlatgrid = 1

  lon = f1->longitude(::dlongrid)
  lat = f1->latitude(::dlatgrid)

olr_tmp = f3->ttrc(0,::dlatgrid,::dlongrid)	;load for coordinate

  flux_1xco2 = new((/3,24,73,144/),float)
  flux_1xco2(0,:,:,:) = f1->fnt_lw(0:23,0,::dlatgrid,::dlongrid)
  flux_1xco2(1,:,:,:) = f1->sfc_fnt_lw(0:23,::dlatgrid,::dlongrid)
  
  flux_2xco2 = new(dimsizes(flux_1xco2),float)
  flux_2xco2(0,:,:,:) = f2->fnt_lw(0:23,0,::dlatgrid,::dlongrid)
  flux_2xco2(1,:,:,:) = f2->sfc_fnt_lw(0:23,::dlatgrid,::dlongrid)
  
  ; manually replace NaN with _FillValue
  if (any(isnan_ieee(flux_1xco2))) then
    if(.not.isatt(flux_1xco2,"_FillValue")) then
      flux_1xco2@_FillValue = default_fillvalue(typeof(flux_1xco2))
    end if
    replace_ieeenan (flux_1xco2, flux_1xco2@_FillValue, 0)
  end if

  ; manually replace NaN with _FillValue
  if (any(isnan_ieee(flux_2xco2))) then
    if(.not.isatt(flux_2xco2,"_FillValue")) then
      flux_2xco2@_FillValue = default_fillvalue(typeof(flux_2xco2))
    end if
    replace_ieeenan (flux_2xco2, flux_2xco2@_FillValue, 0)
  end if


  flux_1xco2 := dim_avg_n_Wrap(flux_1xco2,1)
  flux_2xco2 := dim_avg_n_Wrap(flux_2xco2,1)

  forcing_2xco2 = flux_2xco2 - flux_1xco2
  forcing_2xco2 = forcing_2xco2*(-1.)	;flip sign to make downward positive
  forcing_2xco2(2,:,:) = forcing_2xco2(0,:,:) - forcing_2xco2(1,:,:)

;  fnt_obs   = f1->ttrc(0:23,::dlatgrid,::dlongrid)
;;printVarSummary(fnt_obs)
;  fnt_obs_flt = dim_avg_n_Wrap(short2flt(fnt_obs),0)/3600.
;printVarSummary(fnt_obs_flt)
;;  fnt_obs_flt = short2flt(fnt_obs)/3600.
;  fnt_1xco2 = f2->fnt_lw(0:23,0,::dlatgrid,::dlongrid)*(-1.)    ; note that the level coordinate is TOA to surface
;  fnt_1xco2:= dim_avg_n_Wrap(fnt_1xco2,0)
;;  fnt_lw_2xco2 = f3->fnt_lw(:,::10,::10) ;- f3->fnt_lw(0,::10,::10)



;  diff_fnt  = fnt_1xco2 - fnt_obs_flt
printMinMax(forcing_2xco2(0,:,:),1)
printMinMax(forcing_2xco2(1,:,:),1)
printMinMax(forcing_2xco2(2,:,:),1)
  copy_VarCoords(olr_tmp,forcing_2xco2(0,:,:)) 
  copy_VarCoords(olr_tmp,forcing_2xco2(1,:,:)) 
  copy_VarCoords(olr_tmp,forcing_2xco2(2,:,:)) 
;  copy_VarCoords(fnt_obs_flt,fnt_1xco2) 
;  copy_VarCoords(fnt_obs_flt,diff_fnt)  

; give attributes
;  fnt_obs

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

  fnt_obs_avg    = wgt_areaave(forcing_2xco2(0,:,:),area,1.0,opt_wgt)    ;wgt_areaave(var,wgty,wgtx,opt)
  fnt_1xco2_avg  = wgt_areaave(forcing_2xco2(1,:,:),area,1.0,opt_wgt)
  diff_fnt_avg   = wgt_areaave(forcing_2xco2(2,:,:),area,1.0,opt_wgt)

  global_mean = new(3,float)
  global_mean(0) = fnt_obs_avg
  global_mean(1) = fnt_1xco2_avg
  global_mean(2) = diff_fnt_avg

  global_mean = decimalPlaces(global_mean,1,True)    	;True-> round number to 1 decimal place

  global_var = new(3,float)
  global_var(0) = variance(forcing_2xco2(0,:,:)) 
  global_var(1) = variance(forcing_2xco2(1,:,:)) 
  global_var(2) = variance(forcing_2xco2(2,:,:)) 

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
  res@cnMinLevelValF       = -6.
  res@cnMaxLevelValF       =  6.
  res@cnLevelSpacingF      =  0.25

; plot

  wks = gsn_open_wks(figtype,outdir+figname)
  
  plot = new(3,graphic)
  
  res0 = res
  res0@gsnLeftString = panel_string(0)
  res0@gsnRightString = global_mean(0) + " W/m2; variance = " + global_var(0) + " W2/m4"

  res1 = res
  res1@gsnLeftString = panel_string(1)
  res1@gsnRightString = global_mean(1) + " W/m2; variance = " + global_var(1) + " W2/m4"
  
  res2 = res
  res2@gsnLeftString = panel_string(2)
  res2@gsnRightString = global_mean(2) + " W/m2; variance = " + global_var(2) + " W2/m4"
  delete(res2@cnFillPalette)
  res2@cnFillPalette = "ViBlGrWhYeOrRe";BlueWhiteOrangeRed"
  res2@cnLevelSelectionMode = "ManualLevels"
  res2@cnMinLevelValF       = -2.5
  res2@cnMaxLevelValF       =  2.5
  res2@cnLevelSpacingF      =  0.25
 
  plot(0) = gsn_csm_contour_map(wks,forcing_2xco2(0,:,:),res0) 
  plot(1) = gsn_csm_contour_map(wks,forcing_2xco2(1,:,:),res1) 
  plot(2) = gsn_csm_contour_map(wks,forcing_2xco2(2,:,:),res2) 

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
