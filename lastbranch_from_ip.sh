# Model Specific Registers
MSR_LASTBRANCH_0_FROM_IP=680
MSR_LASTBRANCH_0_TO_IP=6c0
MSR_IA32_DEBUGCTL=1d9
MSR_LBR_TOS=1c9
MSR_LBR_SELECT=1c8

# Do not modify this
ADDR=$MSR_LASTBRANCH_0_FROM_IP

# Configuration
CORE=1   # Run the target workload on core 1 (taskset -c 1 workload)
N_LBR=32 # Number of LBR records (32 in skylake, 16 in broadwell or haswell)

# enable MSR kernel module
sudo modprobe msr

# enable LBR
sudo wrmsr -a 0x${MSR_IA32_DEBUGCTL} 0x1

# do not capture branches in ring 0
sudo wrmsr -a 0x${MSR_LBR_SELECT} 0x1

# wait a bit for the workload to issue enough branches
sleep 0.1

# read all LBR records
for i in `seq 1 ${N_LBR}`; do
    sudo rdmsr -p ${CORE} 0x${ADDR}

    # increament ADDR (in hex) by 1 
    ADDR=`echo "obase=16; ibase=16; ${ADDR} + 1;" | bc`
done
