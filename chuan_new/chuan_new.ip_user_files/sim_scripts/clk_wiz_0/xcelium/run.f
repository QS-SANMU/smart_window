-makelib xcelium_lib/xil_defaultlib -sv \
  "D:/Vivado/2018.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "D:/Vivado/2018.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "D:/Vivado/2018.2/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../chuan_new.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_clk_wiz.v" \
  "../../../../chuan_new.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

