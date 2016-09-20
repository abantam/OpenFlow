#!/bin/sh
mkdir work

echo "Compiling Core Simulation Models"
ncvlog -work work ../../../Ethernet.v

echo "Compiling Example Design"
ncvlog -work work \
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
../../example_design/Ethernet_example_design.v

echo "Compiling Test Bench"
ncvlog -work work ../stimulus_tb.v ../demo_tb.v

echo "Elaborating design"
ncelab -access +rw work.demo_tb glbl

echo "Starting simulation"
ncsim -gui work.demo_tb -input @"simvision -input wave_ncsim.sv"
