while getopts ":f:" opt; do
  case $opt in
     f) 
        echo "${OPTARG}"
        iverilog -o ../runs/${OPTARG}_tb.vvp ../sim/${OPTARG}_tb.v
        vvp ../runs/${OPTARG}_tb.vvp
        gtkwave ../runs/${OPTARG}_tb.vcd
       ;;
     *)
       echo "invalid command"
       ;;
  esac
done

# iverilog -o ../runs/uart_top_tb.vvp ../sim/uart_top_tb.v
# #iverilog -o ../runs/top_tb.vvp ../sim/top_tb.v
# vvp ../runs/uart_top_tb.vvp # -lxt2 uarttb
# gtkwave ../runs/uart_top_tb.vcd