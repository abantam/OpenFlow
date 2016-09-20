
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name Connection -dir "/home/shimizu/openflow1.3/Connection/planAhead_run_2" -part xc7k325tffg676-1
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "topmodule.ucf" [current_fileset -constrset]
add_files [list {ipcore_dir/Ethernet.ngc}]
set hdlfile [add_files [list {ipcore_dir/Ethernet.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {topmodule.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set_property top topmodule $srcset
add_files [list {topmodule.ucf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/Ethernet.ncf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc7k325tffg676-1
