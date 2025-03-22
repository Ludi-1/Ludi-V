while getopts ":f:" opt; do
  case $opt in
     f) 
        echo "${OPTARG}"
        mkdir -p runs
        rm -rf obj_dir
        rm waveform.vcd
        verilator --trace --coverage --x-assign unique --x-initial unique -cc rtl/core/*.sv rtl/*.sv --top-module ${OPTARG} --exe sim/tb_${OPTARG}.cpp
        make -C obj_dir -f V${OPTARG}.mk V${OPTARG}
        ./obj_dir/V${OPTARG} +verilator+rand+reset+2
        surfer waveform.vcd
        # iverilog -g2012 -o runs/${OPTARG}_tb.vvp sim/${OPTARG}_tb.sv rtl/core/*.sv rtl/axi_intf.sv
        # vvp runs/${OPTARG}_tb.vvp
        # surfer runs/${OPTARG}_tb.vcd
       ;;
     *)
       echo "invalid command"
       ;;
  esac
done
