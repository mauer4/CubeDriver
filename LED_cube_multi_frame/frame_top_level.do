onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /single_frame_tb/DUT/CLOCK_50
add wave -noupdate -divider GPIOs
add wave -noupdate /single_frame_tb/DUT/Layers
add wave -noupdate /single_frame_tb/DUT/Latches
add wave -noupdate /single_frame_tb/DUT/Data
add wave -noupdate -divider {Top Level}
add wave -noupdate /single_frame_tb/DUT/state
add wave -noupdate /single_frame_tb/DUT/start_layer_latcher_cond
add wave -noupdate /single_frame_tb/DUT/start_layer_latcher
add wave -noupdate /single_frame_tb/DUT/start_layer_driver_cond
add wave -noupdate /single_frame_tb/DUT/start_layer_driver
add wave -noupdate /single_frame_tb/DUT/start
add wave -noupdate /single_frame_tb/DUT/layer_latcher_done
add wave -noupdate /single_frame_tb/DUT/layer_driver_done
add wave -noupdate -divider Layer_i/Latch_i
add wave -noupdate /single_frame_tb/DUT/layer_i
add wave -noupdate /single_frame_tb/DUT/latch_i
add wave -noupdate /single_frame_tb/DUT/data_to_latch
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 165
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {976 ps}
