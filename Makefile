################################################################################
#
#  NetFPGA-10G http://www.netfpga.org
#
#  Module:
#          Project Makefile
#
#  Description:
#          make install : Copy Xilinx pcores into NetFPGA-10G library
#
#          For more information about how Xilinx EDK works, please visit
#          http://www.xilinx.com/support/documentation/dt_edk.htm
#             
#  Revision history:
#          2010/12/8 hyzeng: Initial check-in
#
################################################################################

NF10_HW_LIB_DIR = lib/hw/std/pcores/
XILINX_HW_LIB_DIR = $(XILINX_EDK)/hw/XilinxProcessorIPLib/pcores/
HW_LIB_DIR_INSTANCES := $(shell cd $(NF10_HW_LIB_DIR) && find . -maxdepth 1 -type d)
HW_LIB_DIR_INSTANCES := $(basename $(patsubst ./%,%,$(HW_LIB_DIR_INSTANCES)))


install: pcores $(NF10_HW_LIB_DIR)/nf10_10g_interface_v1_00_a/hdl/verilog/xilinx/xgmac.v $(NF10_HW_LIB_DIR)/nf10_10g_interface_v1_00_a/hdl/verilog/xilinx/xaui.v

pcores:   
	@for lib in $(HW_LIB_DIR_INSTANCES) ; do \
		false | cp -ri $(XILINX_HW_LIB_DIR)/$$lib $(NF10_HW_LIB_DIR) > /dev/null 2>&1; \
	done;
	@echo "Xilinx EDK pcores installed.";
	
$(NF10_HW_LIB_DIR)/nf10_10g_interface_v1_00_a/hdl/verilog/xilinx/xaui.v: $(NF10_HW_LIB_DIR)/nf10_10g_interface_v1_00_a/xco/xaui.xco
	@mkdir -p $(NF10_HW_LIB_DIR)/nf10_10g_interface_v1_00_a/hdl/verilog/xilinx
	@mkdir -p $(NF10_HW_LIB_DIR)/nf10_10g_interface_v1_00_a/netlist
	@mkdir -p /tmp/coregen;
	@cd /tmp/coregen && coregen -b $(NF10_HW_LIB_DIR)/nf10_10g_interface_v1_00_a/xco/xaui.xco \
		&& cp xaui.v $(NF10_HW_LIB_DIR)/nf10_10g_interface_v1_00_a/hdl/verilog/xilinx/ \
		&& cp xaui.ngc $(NF10_HW_LIB_DIR)/nf10_10g_interface_v1_00_a/netlist/ \
		&& cp xaui/example_design/tx_sync.v $(NF10_HW_LIB_DIR)/nf10_10g_interface_v1_00_a/hdl/verilog/xilinx/ \
		&& cp xaui/example_design/cc_2b_1skp.v $(NF10_HW_LIB_DIR)/nf10_10g_interface_v1_00_a/hdl/verilog/xilinx/ \
		&& cp xaui/example_design/chanbond_monitor.v $(NF10_HW_LIB_DIR)/nf10_10g_interface_v1_00_a/hdl/verilog/xilinx/;
	@echo "Xilinx XAUI core installed.";
	@rm -rf /tmp/coregen;

$(NF10_HW_LIB_DIR)/nf10_10g_interface_v1_00_a/hdl/verilog/xilinx/xgmac.v: $(NF10_HW_LIB_DIR)/nf10_10g_interface_v1_00_a/xco/xgmac.xco
	@mkdir -p $(NF10_HW_LIB_DIR)/nf10_10g_interface_v1_00_a/hdl/verilog/xilinx;
	@mkdir -p $(NF10_HW_LIB_DIR)/nf10_10g_interface_v1_00_a/netlist;
	@mkdir -p /tmp/coregen;
	@cd /tmp/coregen &&	coregen -b $(NF10_HW_LIB_DIR)/nf10_10g_interface_v1_00_a/xco/xgmac.xco \
		&& cp xgmac.v $(NF10_HW_LIB_DIR)/nf10_10g_interface_v1_00_a/hdl/verilog/xilinx/ \
		&& cp xgmac.ngc $(NF10_HW_LIB_DIR)/nf10_10g_interface_v1_00_a/netlist/ \
	@echo "Xilinx 10G Ethernet MAC core installed.";
	@rm -rf /tmp/coregen;
	