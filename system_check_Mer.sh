#!/usr/bin/env bash

echo -e "\nProduct name: PVC 600W"
#GPU_Count="8"
while getopts "f:" o; do
        case "${o}" in
                f)  Fail_command=${OPTARG}
                        if [ "$Fail_command" == "Fail" ]; then
                                echo "=========== Error Test ==========="
                                GPU_Count="64"
                        fi
                        #[ "${OPTARG}" == "" ] && GPU_Count="16" # default
                        ;;
                :)  echo "you input *"
                        ;;
                ?)  echo "you input ?";
                        ;;
        esac
done
shift $((OPTIND - 1 ))


function device_check {
        egrep_str=$1
        count=$2
        link_speed=$3
        link_lanes=$4
        device=$5
        upstream_check=$6
        [ "$upstream_check" == "" ] && upstream_check=1000
        #echo $upstream_check
        j=1;
        k=1;
        for i in `echo "$lspci_str" | egrep "$egrep_str" | awk '{print $1}'`; do
                if [ "$(( j % upstream_check ))" != "0" ] ; then
                        echo -e "$k $i \c";
                        str=`lspci -s $i -vvvv | grep LnkSta: | awk -F "," '{print $1 "," $2 }'; `
                        #  LnkSta: Speed 8GT/s, Width x16
                        echo "$str"
                        link_speed_str=`echo $str | awk '{print $3}' | tr -d ','`
                        if [ "$link_speed_str" != "$link_speed""GT/s" ] ; then
                                error_info="Error: $device $i Link speed $link_speed_str doesn't match expected $link_speed""GT/s !"
                                echo "$error_info"
                                error_log="$error_log \n$error_info"
                        fi
                        #link_lanes_str=`echo $str | awk '{print $5}'`
                        link_lanes_str=`echo $str | cut -d , -f 2 | awk '{print $2}'`
                        if [ "$link_lanes_str" != "x$link_lanes" ] ; then
                                error_info="Error: $device $i Link lanes $link_lanes_str doesn't match expected x$link_lanes !"
                                echo "$error_info"
                                error_log="$error_log \n$error_info"
                        fi
                ((k++))
                fi

                ((j++));
                #echo $j
        done
        if [ "$k" -lt "$((count+1))" ]; then
                error_info="Error: $((count+1-k)) $device lost!!"
                echo "$error_info"
                error_log="$error_log \n$error_info"
        fi

}

error_log=""
lspci_str=`lspci`
#echo -e "\nGPU check, 8, 16GT/s, Width x16"
#device_check '3D' 16 8 16 GPU # normal
#device_check '3D' $GPU_Count 8 16 GPU
#device_check '3D' 8 16 16 GPU
#device_check '3D' 20 7 8 GPU # test
#j=1; for i in `echo "$lspci_str" | grep 3D | cut -d : -f1`; do echo -e "$j $i \c"; lspci -s $i: -vvvv | grep LnkSta: | awk -F "," '{print $1 "," $2 }'; ((j++)); done

#echo -e "\nLR10 check, 6, Speed 8GT/s, Width x2"
#j=1; for i in `echo "$lspci_str" | grep "Bridge: NVIDIA" | cut -d : -f1`; do echo -e "$j $i \c"; lspci -s $i: -vvvv | grep LnkSta:  | awk -F "," '{print $1 "," $2 }' ; ((j++)); done
#device_check 'Bridge: NVIDIA' 6 8 2 LR10

#echo -e "\nIB check, 10, 16GT/s, Width x16"
#j=1; for i in `echo "$lspci_str" | grep Mel | grep ':00.0' | cut -d : -f1`; do echo -e "$j $i \c"; lspci -s $i: -vvvv | grep LnkSta: | awk -F "," '{print $1 "," $2 }'; ((j++)); done
#device_check 'Mel' 10 16 16 IB_card

echo -e "\nM.2 SSD check, 4, 16GT/s, Width x4"
#j=1; for i in `echo "$lspci_str" | grep "Non-V" | cut -d : -f1`; do echo -e "$j $i \c"; lspci -s $i: -vvvv | grep LnkSta: | awk -F "," '{print $1 "," $2 }'; ((j++)); done
device_check  'KIOXIA' 4 16 4 NVME_M.2

#echo -e "\nU.2 NVME SSD check, 8, 16GT/s, Width x4"
#j=1; for i in `echo "$lspci_str" | grep "Non-V" | cut -d : -f1`; do echo -e "$j $i \c"; lspci -s $i: -vvvv | grep LnkSta: | awk -F "," '{print $1 "," $2 }'; ((j++)); done
#device_check 'a824|KIOXIA|PM173X' 8 16 4 NVME_U.2

#echo -e "\n10G x540 check, 1, 5GT/s, Width x8"
#j=1; for i in `lspci | grep "540" | grep ':00.0' | cut -d : -f1`; do echo -e "$j $i \c"; lspci -s $i: -vvvv | grep LnkSta: | awk -F "," '{print $1 "," $2 }'; ((j++)); done
#device_check '540'


#PCIe_switch_bus_id_all=$(lspci -tv | grep -v '\\-' | grep '\----' | grep '\--+-' | sed 's/--+-.*//' | grep -v '|            ' | cut -f2 -d"[" | cut -f1 -d"-")
#for i in $PCIe_switch_bus_id_all;do
#	id="$i.00.0"
#        PCIe_switch_bus_id=`echo "$PCIe_switch_bus_id|$id"`

#done

#PCIe_switch_bus_id=${PCIe_switch_bus_id:1}


#echo -e "\nPCIe LSI switch check(Upstream), 4, 16GT/s, Width x16"
#lspci | grep 9797 | grep ':00.0' | nl
#j=1; k=1; for i in `echo "$lspci_str" | egrep '9797|9781' | grep ':00.0' | cut -d : -f1`; do [ "$((j%2))" == "1" ] && echo -e "$k $i \c" && ((k++)) && lspci -s $i:00.0 -vvvv | grep LnkSta: | awk -F "," '{print $1 "," $2 }'; ((j++)); done
#echo "~~~~~~~~~~~~~~~~~~~~~~~~~"
#device_check "$PCIe_switch_bus_id" 4 32 16 LSI_switch
echo -e "\nPCIe_LSI_switch, check, 4, 32GT/s, Width x16"
device_check '0000:6a:00.0|0000:94:00.0|0001:16:00.0|0001:94:00.0' 4 32 16 LSI_switch

echo -e "\nPVC  check, 8, 32GT/s, Width x16"
device_check '0bdd' 8 32 16 PVC


#echo -e "Add_on_card check, 4, 16GT/s, Width x16"
#a=`lspci | grep c010  | awk 'NR==1' |cut -d " " -f 1`
#b=`lspci | grep c010 | grep "Mass storage controller: Broadcom / LSI Device c010 (rev b0)" -A1 | grep "PCI bridge" | cut -d " " -f 1 | awk 'NR==1' `
#c=`lspci | grep c010 | grep "Mass storage controller: Broadcom / LSI Device c010 (rev b0)" -A1 | grep "PCI bridge" | cut -d " " -f 1 | awk 'NR==2' `
#d=`lspci | grep c010 | grep "Mass storage controller: Broadcom / LSI Device c010 (rev b0)" -A1 | grep "PCI bridge" | cut -d " " -f 1 | awk 'NR==3' `

#device_check "$a|$b|$c|$d" 4 16 16 c010

#device_check '0270' 1 16 16 PCIE_brige

#echo -e "\nPCIE Bridge check, 1, 16GT/s, Width x16"
#device_check '027[1-2]' 1 2.5 1 PCIE_brige
#echo -e "\nPCIe switch 8725 check, 1, 8GT/s, Width x4"
#k=1; for i in `lspci | grep 8725 | grep ':00.0' | cut -d : -f1`; do  echo -e "$k $i \c" && ((k++)) && lspci -s $i:00.0 -vvvv | grep LnkSta: | awk -F "," '{print $1 "," $2 }'; ((j++)); done
#device_check '8725' 1 8 4 PLX_8725



#echo -e "\nPCIe bridge, 4, 16GT/s, width x16"

#device_check '148a' 8 16 16 148a 
#device_check '01:00|21:00|81:00|a1:00' 4 16 16 PCIe_bridge
#echo "Notice :01,21,81,a1"

#echo -e "\nCPU check, 2 socket"
#output=`lscpu`
#echo "$output" | egrep 'Model name|Architecture|CPU op-mode\(s\)|CPU\(s\)|Socket\(s\)|CPU max MHz:|CPU min MHz:|Virtualization:|Flags:'
#cpu_count=`echo "$output" | grep Socket | cut -d ":" -f2 | tr -d " "`
#if [ "$cpu_count" != "2" ] ; then
#        error_info="Error: CPU quantity $cpu_count doesn't match expected 2 !"
#        echo "$error_info"
#        error_log="$error_log \n$error_info"
#fi

#lscpu

#echo -e "\nMemory check, 32"
#output=`dmidecode -t memory`
#echo "$output" | grep Manufacturer: | nl
#dimm_count=`echo "$output" | grep Manufacturer: | egrep '(Micron|Samsung|SK)' -c`
#if [ "$dimm_count" != "32" ] ; then
#        error_info="Error: DIMM quantity $dimm_count doesn't match expected 32 !"
#        echo "$error_info"
#        error_log="$error_log \n$error_info"
#fi

#echo -e "\nAll HD check , 2+8+8+USB_HD"
#lsblk | grep disk | sort | nl

if [ "$error_log" == "" ] ; then
        echo "System check PASS"
        exit 0
else
        echo -e "$error_log"
        echo "System check FAIL"
        echo "Test Fail !!!"
        exit 1
fi


