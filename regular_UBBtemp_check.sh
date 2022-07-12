#!/bin/bash

count=1
bmc_ip="10.36.49.2"
hostname="PVC-1"
path="/home/iris/log/reboot/$hostname"

function first_check {
	first_log_str="count |date (m/d H:M:S)| UBB_Inlet_Temp1 | UBB_Inlet_Temp2 | UBB_Outlet_Temp1 | UBB_Outlet_Temp2 "
        echo "This is the first check!!"
        echo "$first_log_str" | tee -a $path/regular_UBBtemp_check_log
}




function next_check {
        Temp1=`ipmitool -I lanplus -H $bmc_ip -U admin -P 11111111 sdr elist  | grep "UBB_Inlet_Temp1" | awk '{print$9,$10,$11}'`
        Temp2=`ipmitool -I lanplus -H $bmc_ip -U admin -P 11111111 sdr elist  | grep "UBB_Inlet_Temp2" | awk '{print$9,$10,$11}'`
        Temp3=`ipmitool -I lanplus -H $bmc_ip -U admin -P 11111111 sdr elist  | grep "UBB_Outlet_Temp1" | awk '{print$9,$10,$11}'`
        Temp4=`ipmitool -I lanplus -H $bmc_ip -U admin -P 11111111 sdr elist  | grep "UBB_Outlet_Temp2" | awk '{print$9,$10,$11}'`

        log_str="$count     | `date "+%m/%d %H:%M:%S"` |  $Temp1   |  $Temp2   |  $Temp3    |  $Temp4  "
        echo "$log_str" | tee -a $path/regular_UBBtemp_check_log
        ((count++))
}




if test -e $path/regular_UBBtemp_check_log ; then
        now_date=`date "+%m_%d_%H"`
        mv $path/regular_UBBtemp_check_log $path/regular_UBBtemp_check_log_$now_date
fi

first_check

while :
do
        next_check
	sleep 10m
done
