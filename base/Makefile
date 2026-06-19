#!/usr/bin/make -f
# Minimal XEM6010 base build: clocks + Badger Ethernet/lbus only.
# Builds in a few minutes (no servo/IIR/ADC/DAC/DDR2). Reusable scaffold for
# fast component bring-up: bolt a module onto base_top.v and rebuild quickly.

SHELL := /bin/bash
PART = xc6slx150-fgg484-2

# Build variant is selectable so the same Badger scaffold can host a component
# under test. Defaults build the bare base design; override to bolt a module on:
#   make PROJECT=flash TOP=flash_top UCF=xem6010_flash.ucf EXTRA_SOURCES=../flash_spi.v
PROJECT ?= base
TOP ?= base_top
UCF ?= xem6010_base.ucf
EXTRA_SOURCES ?=

ROOT = ..
BADGER = $(ROOT)/Bedrock/badger
BEDROCK = $(ROOT)/Bedrock

VERILOG_SOURCES = \
	$(TOP).v \
	timescale.v \
	$(EXTRA_SOURCES) \
	$(ROOT)/ethernet_clkgen_s6.v \
	$(ROOT)/rmii_iob.v \
	$(ROOT)/rmii_gmii.v \
	$(ROOT)/rtefi_blob.v \
	$(ROOT)/rtefi_center.v \
	$(ROOT)/construct_tx_table.v \
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

.PHONY: all clean program help

all: $(BIT)

help:
	@echo "Targets:"
	@echo "  all        Build bitfile (default)"
	@echo "  program    Program FPGA via JTAG (xc3sprog)"
	@echo "  clean      Remove all build artifacts"

$(PROJECT).prj: $(VERILOG_SOURCES)
	@rm -f $@
	@for f in $(VERILOG_SOURCES); do echo "verilog work $$f" >> $@; done

$(PROJECT).xst: $(PROJECT).prj
	@echo "set -tmpdir xst/projnav.tmp" > $@
	@echo "set -xsthdpdir xst" >> $@
	@echo "run" >> $@
	@echo "-ifn $(PROJECT).prj" >> $@
	@echo "-ofn $(PROJECT).ngc" >> $@
	@echo "-ofmt NGC" >> $@
	@echo "-p $(PART)" >> $@
	@echo "-top $(TOP)" >> $@
	@echo "-opt_mode Speed" >> $@
	@echo "-opt_level 1" >> $@
	@echo "-keep_hierarchy No" >> $@
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
		-uc $(UCF) -p $(PART) $(NGC) $(NGD)

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
