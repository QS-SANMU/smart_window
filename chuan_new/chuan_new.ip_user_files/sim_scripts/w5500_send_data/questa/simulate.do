onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib w5500_send_data_opt

do {wave.do}

view wave
view structure
view signals

do {w5500_send_data.udo}

run -all

quit -force
