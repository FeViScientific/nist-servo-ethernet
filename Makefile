#!/usr/bin/make -f
# Incremental Ethernet build with servo loop

SHELL := /bin/bash
PROJECT = SuperLaserLand_Ethernet_Bare
PART = xc6slx150-fgg484-2
UCF = xem6010_ethernet_bare.ucf
BADGER = Bedrock/badger
BEDROCK = Bedrock

XST_DEFINES =
ifdef BYPASS_IIR
XST_DEFINES = {BYPASS_IIR=1}
endif

HIERARCHY = No
ifdef KEEP_HIERARCHY
HIERARCHY = Yes
endif

VERILOG_SOURCES = \
	SuperLaserLand_Ethernet_Bare.v \
	timescale.v \
	ethernet_clkgen_s6.v \
	rmii_iob.v \
	rmii_gmii.v \
	rtefi_blob.v \
	rtefi_center.v \
	construct_tx_table.v \
	FractionalDAC.v \
	LTC2195.v \
	AD9783.v \
	AD5791.v \
	AD8251x2.v \
	SPI.v \
	flash_spi.v \
	net_config_loader.v \
	IIRfilter1stOrder.v \
	IIRfilter2ndOrderSlowAntiWindup.v \
	IIRfilter1stOrderAntiWindup.v \
	Limit.v \
	Sweep.v \
	Relock.v \
	DigitalDelay.v \
	IIRfilter2ndOrderSlow.v \
	LockIn.v \
	LPfilter.v \
	PhaseDetector.v \
	TransferFunction.v \
	ipcore_dir/multiplier35x35.v \
	ipcore_dir/arctan.v \
	ipcore_dir/dds_LUT_pw24_ow16.v \
	ipcore_dir/dds_LUT_pw24_ow24.v \
	ipcore_dir/dds_PG_pw24.v \
	ipcore_dir/dds_pw32_ow16.v \
	ipcore_dir/dds_pw32_ow24.v \
	ipcore_dir/fifo_w256_128_r64_512.v \
	stream_tx.v \
	stream_tx_header.v \
	DDR2Logger.v \
	ddr2_controller.v \
	mig/memc3_infrastructure.v \
	mig/memc3_wrapper.v \
	mig/mcb_raw_wrapper.v \
	mig/mcb_soft_calibration.v \
	mig/mcb_soft_calibration_top.v \
	mig/iodrp_controller.v \
	mig/iodrp_mcb_controller.v \
	$(BADGER)/scanner.v \
	$(BADGER)/precog.v \
	$(BADGER)/construct.v \
	$(BADGER)/base_rx_mac.v \
	$(BADGER)/mac_subset.v \
	$(BADGER)/pbuf_writer.v \
	$(BADGER)/test_tx_mac.v \
	$(BADGER)/packet_categorize.v \
	$(BADGER)/ones_chksum.v \
	$(BADGER)/crc8e_guts.v \
	$(BADGER)/ethernet_crc_add.v \
	$(BADGER)/udp_port_cam.v \
	$(BADGER)/hack_icmp_cksum.v \
	$(BADGER)/xformer.v \
	$(BADGER)/hello.v \
	$(BADGER)/speed_test.v \
	$(BADGER)/mem_gateway.v \
	$(BEDROCK)/dsp/reg_tech_cdc.v \
	$(BEDROCK)/dsp/reg_delay.v

NGC = $(PROJECT).ngc
NGD = $(PROJECT).ngd
NCD = $(PROJECT).ncd
MAP_NCD = $(PROJECT)_map.ncd
PCF = $(PROJECT).pcf
BIT = $(PROJECT).bit

.PHONY: all clean program help utilization

all: $(BIT)

help:
	@echo "Targets:"
	@echo "  all             Build bitfile (default)"
	@echo "  program         Program FPGA via JTAG (xc3sprog)"
	@echo "  utilization     Build with hierarchy kept, print per-module utilization"
	@echo "  clean           Remove all build artifacts"
	@echo "  help            Show this help"
	@echo ""
	@echo "Options:"
	@echo "  BYPASS_IIR=1    Remove all IIR filters (faster builds during development)"
	@echo "  KEEP_HIERARCHY=1  Keep module hierarchy in synthesis (for utilization reports)"
	@echo ""
	@echo "Examples:"
	@echo "  make                       Full build"
	@echo "  make BYPASS_IIR=1          Build without IIR filters"
	@echo "  make utilization           Per-module resource usage report"

utilization: KEEP_HIERARCHY=1
utilization: $(NGC) $(NGD)
	@echo "[3/3] MAP (with -detail for hierarchy report)..."
	@map -intstyle silent -p $(PART) -w -logic_opt off -ol high \
		-t 1 -xt 0 -register_duplication off -r 4 -global_opt off \
		-mt off -ir off -pr off -lc off -power off -detail \
		-o $(MAP_NCD) $(NGD) $(PCF)
	@echo ""
	@echo "=== Per-Module Utilization ==="
	@sed -n '/^Section 13/,/^Section [0-9]/p' $(PROJECT)_map.mrp | head -n -1

$(PROJECT).prj: $(VERILOG_SOURCES)
	@rm -f $@
	@for f in $(VERILOG_SOURCES); do echo "verilog work $$f" >> $@; done

# Depend on the Makefile so a change to XST_DEFINES (e.g. BYPASS_IIR) forces the
# .xst to be regenerated instead of silently reusing a stale one.
$(PROJECT).xst: $(PROJECT).prj Makefile
	@echo "set -tmpdir xst/projnav.tmp" > $@
	@echo "set -xsthdpdir xst" >> $@
	@echo "run" >> $@
	@echo "-ifn $(PROJECT).prj" >> $@
	@echo "-ofn $(PROJECT).ngc" >> $@
	@echo "-ofmt NGC" >> $@
	@echo "-p $(PART)" >> $@
	@echo "-top SuperLaserLand_Ethernet_Bare" >> $@
	@if [ -n "$(XST_DEFINES)" ]; then echo "-define $(XST_DEFINES)" >> $@; fi
	@echo "-opt_mode Speed" >> $@
	@echo "-opt_level 1" >> $@
	@echo "-iuc NO" >> $@
	@echo "-keep_hierarchy $(HIERARCHY)" >> $@
	@echo "-netlist_hierarchy As_Optimized" >> $@
	@echo "-rtlview Yes" >> $@
	@echo "-glob_opt AllClockNets" >> $@
	@echo "-read_cores YES" >> $@
	@echo "-write_timing_constraints NO" >> $@
	@echo "-cross_clock_analysis NO" >> $@
	@echo "-hierarchy_separator /" >> $@
	@echo "-bus_delimiter <>" >> $@
	@echo "-case Maintain" >> $@
	@echo "-slice_utilization_ratio 100" >> $@
	@echo "-bram_utilization_ratio 100" >> $@
	@echo "-dsp_utilization_ratio 100" >> $@
	@echo "-fsm_extract YES -fsm_encoding Auto" >> $@
	@echo "-safe_implementation No" >> $@
	@echo "-fsm_style LUT" >> $@
	@echo "-ram_extract Yes" >> $@
	@echo "-ram_style Auto" >> $@
	@echo "-rom_extract Yes" >> $@
	@echo "-rom_style Auto" >> $@
	@echo "-auto_bram_packing NO" >> $@
	@echo "-resource_sharing YES" >> $@
	@echo "-async_to_sync NO" >> $@
	@echo "-mult_style Auto" >> $@
	@echo "-iobuf YES" >> $@
	@echo "-max_fanout 500" >> $@
	@echo "-bufg 16" >> $@
	@echo "-register_duplication YES" >> $@
	@echo "-equivalent_register_removal YES" >> $@
	@echo "-register_balancing No" >> $@
	@echo "-optimize_primitives NO" >> $@
	@echo "-use_clock_enable Yes" >> $@
	@echo "-use_sync_set Yes" >> $@
	@echo "-use_sync_reset Yes" >> $@
	@echo "-iob Auto" >> $@
	@echo "-slice_utilization_ratio_maxmargin 5" >> $@

$(NGC): $(PROJECT).xst $(VERILOG_SOURCES)
	@echo "[1/5] Synthesis..."
	@mkdir -p xst/projnav.tmp
	@xst -intstyle silent -ifn $(PROJECT).xst -ofn $(PROJECT).syr

$(NGD): $(NGC) $(UCF)
	@echo "[2/5] NGDBuild..."
	@ngdbuild -intstyle silent -dd _ngo -nt timestamp \
		-sd ipcore_dir -uc $(UCF) -p $(PART) $(NGC) $(NGD)

$(MAP_NCD): $(NGD)
	@echo "[3/5] MAP..."
	@map -intstyle silent -p $(PART) -w -logic_opt off -ol high \
		-t 1 -xt 0 -register_duplication off -r 4 -global_opt off \
		-mt off -ir off -pr off -lc off -power off \
		-o $(MAP_NCD) $(NGD) $(PCF)

$(NCD): $(MAP_NCD)
	@echo "[4/5] PAR..."
	@par -w -intstyle silent -ol high -mt 4 \
		$(MAP_NCD) $(NCD) $(PCF)

$(BIT): $(NCD)
	@echo "[5/5] Bitgen..."
	@bitgen -intstyle silent -w -g Binary:yes -g Compress -g CRC:Enable \
		-g UnusedPin:PullDown $(NCD) $(BIT) $(PCF)
	@echo "Build complete!"
	@ls -lh $(BIT)
	@grep "Timing Score" $(PROJECT).par

program:
	sudo xc3sprog -c jtaghs2 $(BIT)

clean:
	@rm -f $(PROJECT).{ngc,ngd,ncd,bit,bin,prj,xst,lso,syr,bld,bgn}
	@rm -f $(PROJECT).{drc,pad,par,ptwx,twr,twx,unroutes,xpi,ngr}
	@rm -f $(PROJECT).ngc_xst.xrpt
	@rm -f $(PROJECT)_map.{map,mrp,ncd,ngm,xrpt}
	@rm -f $(PROJECT)_ngdbuild.xrpt $(PROJECT)_pad.{csv,txt} $(PROJECT)_par.xrpt
	@rm -f $(PROJECT)_{summary,usage}.xml $(PROJECT)_bitgen.xwbt
	@rm -f $(PROJECT)_unconstrained.{twr,twx}
	@rm -f par_usage_statistics.html usage_statistics_webtalk.html webtalk.log
	@rm -rf _ngo _xmsgs xst xlnx_auto_0_xdb
