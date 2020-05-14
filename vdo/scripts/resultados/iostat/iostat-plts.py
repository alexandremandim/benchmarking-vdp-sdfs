import sys
import os
import numpy as np
import re
import matplotlib.pyplot as plt
import glob
from matplotlib.ticker import MaxNLocator

class IOStat_Results(object):
    def __init__(self, deviceName):
        self.device = deviceName
        self.tps = []
        self.kb_read = []
        self.kb_wrnt_s = []
        self.kb_read_s = []
        self.kb_wrnt = []
        self.kb_read = []
        self.seconds = []
        
datasets = ["dataset1", "dataset2"]
io_types = ["w"]
process_numbers = [1,4]
access_types = ["sequencial", "uniform"]
benchmarks = ["dedisbench1", "dedisbench2", "fio", "vdbench"]

def main():
    path = sys.argv[1]

    iostats = {}
    
    for dataset in datasets:
        for io_type in io_types:
            for access_type in access_types:
                for benchmark in benchmarks:
                    for process in ["1", "4"]:
                        if access_type == "hotspot" and benchmark == "fio":
                            globInput = path + "/**/*iostat*" + benchmark + "_" + dataset + "_" + io_type + "_" + "zipf" + "_" + process + "*"
                        elif access_type == "hotspot" and benchmark == "vdbench":
                            globInput = path + "**/*iostat*" + benchmark + "_" + dataset + "_" + io_type + "_" + "poisson" + "_" + process + "*"
                        else:
                            globInput = path + "**/*iostat*" + benchmark + "_" + dataset + "_" + io_type + "_" + access_type + "_" + process + "*"
                        
                        globFiles = glob.glob(globInput, recursive=True)
                        if len(globFiles) <= 0:
                            print("Erro ao abrir ficheiro iostat!")
                            sys.exit();
                            
                        iostats[benchmark + process + "sda"], iostats[benchmark + process + "dm"] = read_iostat_file(globFiles[0])
                plotIOStat(iostats, io_type + " " + dataset + " " + access_type)
                iostats = {}

def plotIOStat(iostat, title):
        
    figure_tps, axis = plt.subplots(1, figsize=(6.4, 4.8))
    ax = plt.subplot
    subPlotRow = 240
    for benchmark in benchmarks:
        subPlotRow += 1
        # chart = figure_tps.add_subplot(subPlotRow)
        plt.plot(iostat[benchmark + "1" + "sda"].seconds, iostat[benchmark + "1" + "sda"].kb_wrnt_s, label = benchmark + " sda")
        plt.plot(iostat[benchmark + "1" + "dm"].seconds, iostat[benchmark + "1" + "dm"].kb_wrnt_s, label = benchmark + " dm")
        axis.xaxis.set_major_locator(MaxNLocator())
        axis.yaxis.set_major_locator(MaxNLocator())

    plt.title(title)
    plt.legend()
    plt.show()
    
def read_iostat_file(filepath):
    sda = IOStat_Results("sda")
    dm = IOStat_Results("dm-0")
    count = 0
    
    with open(filepath) as fp:
        for line in fp:
            count += 1
            if count <= 7:# First 7 lines does not count
                continue
            line = re.split("\s+", line)
            if line[0] == "sda":
                sda.tps.append(line[1])
                sda.kb_read_s.append(line[2])
                sda.kb_wrnt_s.append(line[3])
                sda.kb_read.append(line[4])
                sda.kb_wrnt.append(line[5])
                sda.seconds.append(len(sda.tps) * 2)
            elif line[0] == "dm-0":
                dm.tps.append(line[1])
                dm.kb_read_s.append(line[2])
                dm.kb_wrnt_s.append(line[3])
                dm.kb_read.append(line[4])
                dm.kb_wrnt.append(line[5])
                dm.seconds.append(len(sda.tps) * 2)
                
    return sda, dm;

if __name__ == "__main__":
    main()