function [fup,fdn, fnt, htr] = rrtmg_lw_htr_allsky(cflag,atmprofile,nlev)
! rm -rf TAPE5,TAPE6,OUTPUT_RRTM
  rrtmg_tape5_writer_htr_lw_allsky(cflag,atmprofile,nlev);
%! rrtmg_lw
!/home/yantingc/projects/rrg-yihuang-ad/yantingc/rrtmg/rrtmg_lw_v4.85_linux_intel
  [fup, fdn, fnt, htr1] = rrtmg_lw_output_read('OUTPUT_RRTM',nlev);
  htr = htr1(2:nlev);
