#!/bin/sh

rm -rf simv* csrc DVEfiles AN.DB

echo "Compiling Core Simulation Models"
vlogan +v2k \
../../../Ethernet.v \
../../example_design/Ethernet_sync_block.v \
../../example_design/Ethernet_reset_sync.v \
../../example_design/transceiver/Ethernet_gtwizard_gt.v \
../../example_design/transceiver/Ethernet_gtwizard.v \
../../example_design/transceiver/Ethernet_tx_startup_fsm.v \
../../example_design/transceiver/Ethernet_rx_startup_fsm.v \
../../example_design/transceiver/Ethernet_gtwizard_init.v \
../../example_design/transceiver/Ethernet_transceiver.v \
../../example_design/Ethernet_tx_elastic_buffer.v \
../../example_design/Ethernet_block.v \
../../example_design/Ethernet_example_design.v \
../stimulus_tb.v \
../demo_tb.v

echo "Elaborating design"
vcs +vcs+lic+wait \
    -debug \
    demo_tb glbl

echo "Starting simulation"
./simv -ucli -i ucli_commands.key

dve -vpd vcdplus.vpd -session vcs_session.tcl
