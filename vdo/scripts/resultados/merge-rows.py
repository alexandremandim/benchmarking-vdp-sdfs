import sys
import os
import numpy as np
import matplotlib.pyplot as plt

chartFolder = "charts"

# awk '{c++; if(c%4 == 0){ print $0; printf("\n");} else print $0}' aux > aux2

def main():
    
    if(len(sys.argv) < 3):
        print("More arguments...")
        sys.exit()
    
    filepath = sys.argv[1]
    if not os.path.isfile(filepath):
       print("File path {} does not exist. Exiting...".format(filepath))
       sys.exit()
    
    benchmark = sys.argv[2]
    
    if(benchmark == "DEDIS1"):
        print("test" + "\t" + "access" + "\t" + "processes" + "\t" + "benchmark" + "\t" + "dataset" + "\t" + "operation" + "\t" + "latency" + "\t" + "throughput" + "\t" + "logicalBlocksUsed" + "\t" + "physicalBlocksUsed" + "\t" + "compressedFragments" + "\t" + "compressedBlocks" + "\t" + "CPU_USR" + "\t" +  "CPU_SYS" + "\t" +  "CPU_WAIT" + "\t" +  "RAM_USED")
        
    getAverageAndStdDedis(filepath,True)

def getAverageAndStdDedis(filepath,printCSV):
    latencies = []
    troughputs = []
    operations = []
    logicalBlocksUsed = []
    physicalBlocksUsed = []
    compressedFragments = []
    compressedBlocks = []
    cpu_usr = []
    cpu_sys = []
    cpu_wait = []
    mem_used = []
    
    dedisResults = {}

    with open(filepath) as fp:
        line = fp.readline() # First line does not count
        cnt = 1

        for line in fp:
            line = line.strip().split("\t")

            latencies.append(float(line[8]))
            troughputs.append(float(line[9]))
            operations.append(float(line[10]))
            logicalBlocksUsed.append(float(line[11]))
            physicalBlocksUsed.append(float(line[12]))
            compressedFragments.append(float(line[13]))
            compressedBlocks.append(float(line[14]))
            cpu_usr.append(float(line[15])) 
            cpu_sys.append(float(line[16]))
            cpu_wait.append(float(line[17]))
            mem_used.append(float(line[18]))
            
            if cnt % 4 == 0:
                benchmark = line[2]
                dataset = line[3]
                test = line[4]
                access = line[5]
                processes = line[6]
                latency = np.average(latencies)
                sdL = np.std(latencies, dtype=np.float64)
                throughput = np.average(troughputs)
                sdT = np.std(troughputs, dtype=np.float64)
                operation = np.average(operations)
                sdO = np.std(operations, dtype=np.float64)
                
                
                logBlocksUsed = np.average(logicalBlocksUsed)
                physBlocksUsed = np.average(physicalBlocksUsed)
                compFragments = np.average(compressedFragments)
                compBlocks = np.average(compressedBlocks)
                # desvio padrao cpu e mem
                cpu_user_dp =np.std(cpu_usr, dtype=np.float64)
                cpu_sys_dp = np.std(cpu_sys, dtype=np.float64)
                cpu_wait_dp = np.std(cpu_wait, dtype=np.float64)
                mem_used_dp = np.std(mem_used, dtype=np.float64)
                
                cpu_usr = np.average(cpu_usr)
                cpu_sys = np.average(cpu_sys)
                cpu_wait = np.average(cpu_wait)
                mem_used = np.average(mem_used)
                
                id = benchmark.lower() + "_d" + dataset[-1] + "_" + test + "_" + access[0] + "_" + processes

                dedisResults[id] = [benchmark, dataset, test, access, processes, latency, sdL, throughput, sdT, operation, sdO]
                
                if(access=="zipf" or access=="poisson"):
                    access="hotspot"
                
                if(printCSV == True):
                    print(test + "\t" + access + "\t" + processes + "\t" + benchmark, end ="")
                    print("\t" + dataset + "\t" + "{:.0f}".format(operation).replace('.', ',') + "\t", end ="")
                    print("{:,.3f}".format(latency).replace(',',' ').replace('.', ',') + " ± " + "{:,.3f}".format(sdL).replace('.', ',') + "\t", end ="")
                    print("{:,.0f}".format(throughput).replace(',',' ').replace('.', ',') + " ± " + "{:,.0f}".format(sdT).replace('.', ',') + "\t", end ="")
                    print("{:,.0f}".format(logBlocksUsed).replace(',',' ').replace('.', ',') + "\t" + "{:,.0f}".format(physBlocksUsed).replace(',',' ').replace('.', ',') + "\t", end ="")
                    print("{:,.0f}".format(compFragments).replace(',',' ') + "\t" + "{:.0f}".format(compBlocks).replace(',',' ').replace('.', ',') + "\t", end ="")
                    print("{:,.1f}".format(cpu_usr).replace('.',',') + " ± " + "{:.1f}".format(cpu_user_dp).replace('.', ',') + "\t", end ="")
                    print("{:,.1f}".format(cpu_sys).replace(',',' ').replace('.',',') + " ± " + "{:,.1f}".format(cpu_sys_dp).replace('.', ',') + "\t", end ="")
                    print("{:,.1f}".format(cpu_wait).replace(',',' ').replace('.',',') + " ± " + "{:,.1f}".format(cpu_wait_dp).replace('.', ',') + "\t", end ="")
                    print("{:,.0f}".format(mem_used).replace(',',' ').replace('.',',') + " ± " + "{:,.0f}".format(mem_used_dp).replace(',',' ').replace('.', ',') )

                latencies = []
                troughputs = []
                operations = []
                logicalBlocksUsed = []
                physicalBlocksUsed = []
                compressedFragments = []
                compressedBlocks = []
                cpu_usr = []
                cpu_sys = []
                cpu_wait = []
                mem_used = []

            cnt += 1
    
    return dedisResults
    
if __name__ == "__main__":
    main()