begin

  filename = "2012.07.01.1200.era5" + ".nc"
  filerrtm = "output_lw_" + filename + ".nc"
  title    = filename
  figname  = "fnet_lw_diff" + filename
  figtype  = "pdf"
  
  panel_string = "2xco2-ctrl_" + (/"TOA","sfc","convergence"/)
  
; add file
  
  f1 = addfile(filename,"r")
  f2 = addfile(filerrtm,"r")
  f3 = addfile("./2xco2/" + filerrtm ,"r")
  
  T = f1->t(0,:,::10,::10)
  fnt_lw_1xco2 = f2->fnt_lw(:,::10,::10) ;- f2->fnt_lw(0,::10,::10)    ; note that the level coordinate is TOA to surface
  fnt_lw_2xco2 = f3->fnt_lw(:,::10,::10) ;- f3->fnt_lw(0,::10,::10)

  diff_fnt_lw  = fnt_lw_2xco2 - fnt_lw_1xco2
  diff_fnt_lw_toa = diff_fnt_lw(0,:,:)*(-1.)
  diff_fnt_lw_sfc = diff_fnt_lw(35,:,:)*(-1.)
  diff_fnt_lw_cov = -1.*diff_fnt_lw_sfc + diff_fnt_lw_toa

;  copy_VarCoords(T,fnt_lw_1xco2)
;  copy_VarCoords(T,fnt_lw_2xco2)
;  copy_VarCoords(T,diff_fnt_lw)

  copy_VarCoords(T(0,:,:),diff_fnt_lw_toa)  
  copy_VarCoords(T(0,:,:),diff_fnt_lw_sfc)  
  copy_VarCoords(T(0,:,:),diff_fnt_lw_cov)  

; set res
  
  res = True
  res@gsnDraw  = False
  res@gsnFrame = False
  
  res@cnFillOn = True
  res@cnLinesOn = False
  ;res@cnFillPalette =  
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = -5.6
  res@cnMaxLevelValF       =  5.6
  res@cnLevelSpacingF      =   .4

  cmap = read_colormap_file("NCV_jaisnd")
  cmap(119:135,:) = 1.

  res@cnFillPalette = cmap;"ViBlGrWhYeOrRe" 

; plot

  wks = gsn_open_wks(figtype,figname)
  
  plot = new(3,graphic)
  
  res0 = res
  res0@gsnLeftString = panel_string(0)
  
  res1 = res
  res1@gsnLeftString = panel_string(1)
  
  res2 = res
  res2@gsnLeftString = panel_string(2)
  delete(res2@cnFillPalette)
  res2@cnFillPalette = "BlueWhiteOrangeRed"
  res2@cnLevelSelectionMode = "ManualLevels"
  res2@cnMinLevelValF       = -3.2
  res2@cnMaxLevelValF       =  3.2
  res2@cnLevelSpacingF      =  0.2
 
  plot(0) = gsn_csm_contour_map(wks,diff_fnt_lw_toa,res0)
  plot(1) = gsn_csm_contour_map(wks,diff_fnt_lw_sfc,res1)
  plot(2) = gsn_csm_contour_map(wks,diff_fnt_lw_cov,res2)

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
