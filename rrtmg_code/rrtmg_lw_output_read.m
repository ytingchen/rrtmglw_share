function [fup, fdn, fnt, htr] = rrtmg_lw_output_read(filename,nlev)

  fdn = NaN(1,nlev);
  fup = NaN(1,nlev);
  fnt = NaN(1,nlev);
  htr = NaN(1,nlev);

  fi  = fopen(filename,'r');

  for j = 1:3;
     tmp1 = fgetl(fi); 
  end % read through the header info

  for j =1:nlev
    tmp1 = fgetl(fi);
    tmp2 = sscanf(tmp1,'%g',[6 1]);
    fup(j) = tmp2(3);
    fdn(j) = tmp2(4);
    fnt(j) = tmp2(5);
    htr(j) = tmp2(6);
  end

  fclose(fi);
