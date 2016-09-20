
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name Connection -dir "/home/shimizu/openflow1.3/Connection/planAhead_run_3" -part xc7k325tffg676-1
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "/home/shimizu/openflow1.3/Connection/topmodule.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {/home/shimizu/openflow1.3/Connection} {ipcore_dir} }
add_files [list {ipcore_dir/Ethernet.ncf}] -fileset [get_property constrset [current_run]]
set_property target_constrs_file "topmodule.ucf" [current_fileset -constrset]
add_files [list {topmodule.ucf}] -fileset [get_property constrset [current_run]]
link_design
