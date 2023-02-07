while getopts ":f:" opt; do
  case $opt in
     f) 
        echo "${OPTARG}"
        mkdir -p runs
        iverilog -o runs/${OPTARG}_tb.vcd sim/${OPTARG}_tb.v
        vvp runs/${OPTARG}_tb.vcd
        gtkwave runs/${OPTARG}_tb.vvp
       ;;
     *)
       echo "invalid command"
       ;;
  esac
done