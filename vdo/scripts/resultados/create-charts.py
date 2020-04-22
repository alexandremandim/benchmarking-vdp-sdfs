import sys
import os
import numpy as np
import matplotlib.pyplot as plt
from operator import itemgetter

chartFolder = "charts"

def main():
    filepath = sys.argv[1] # results.csv
    if not os.path.isfile(filepath):
       print("File path {} does not exist. Exiting...".format(filepath))
       sys.exit()
       
    # ------------ Read results ------------
    results = getResults(filepath)
    
    # ----------- CHARTS ---------
    if not os.path.exists(chartFolder):
        os.mkdir(chartFolder)
    
    # [id,proc,benchmark,dataset,iops,percSaved]
    # dataset1 - 1 proc
    createIOPSandSavedCharts("dataset1","1",results)
    createIOPSandSavedCharts("dataset1","4",results)
    createIOPSandSavedCharts("dataset2","1",results)
    createIOPSandSavedCharts("dataset2","4",results)
    
def createIOPSandSavedCharts(dataset, proc, results):
    # filtrar por dataset e proc
    dataset_proc = list(filter(lambda x: (x[3] == dataset and x[1] ==proc), results))
    
    # filtrar pelo benchmark
    dedis1 = list(filter(lambda x: x[2] == "dedisbench1", dataset_proc))
    dedis2 = list(filter(lambda x: x[2] == "dedisbench2", dataset_proc))
    fio = list(filter(lambda x: x[2] == "fio", dataset_proc))
    vdbench = list(filter(lambda x: x[2] == "vdbench", dataset_proc))
    
    dedis1 = sorted(dedis1, key=itemgetter(0))
    dedis2 = sorted(dedis2, key=itemgetter(0))
    fio = sorted(fio, key=itemgetter(0))
    vdbench = sorted(vdbench, key=itemgetter(0))
    
    # chart iops
    createChart(dataset+"_"+proc+"_iops","IOPS (4kB/sec) - "+ dataset+ " - "+ proc +" Processo",list(map(lambda y: float(y[4]), dedis1)), list(map(lambda x: float(x[4]), dedis2)), list(map(lambda x: float(x[4]), fio)), list(map(lambda x: float(x[4]), vdbench)))
    # chart % saved
    createChart(dataset+"_"+proc+"_saved","% Saved - "+ dataset+ " - "+ proc +" Processo",list(map(lambda y: float(y[5]), dedis1)), list(map(lambda x: float(x[5]), dedis2)), list(map(lambda x: float(x[5]), fio)), list(map(lambda x: float(x[5]), vdbench)))
    

def getResults(filepath):
    dedisResults = []    
    
    with open(filepath) as fp:
        line = fp.readline() # First line does not count
        cnt = 1

        for line in fp:
            line = line.replace(',', '.')
            line = line.strip().split(" ")
            key = str(line[0]) + "_" + str(line[1])+ "_" + str(line[2])+ "_" + str(line[3])+ "_" + str(line[1])
            id = str(line[0]) + "_" + str(line[1]) # r_sequential, ...
            proc = line[2] # 1, 4
            benchmark = line[3] #dedisbench1, dedisbench2, fio, vdbench
            dataset = line[4] # dataset1, dataset2
            iops = line[7]
            if(float(line[8]) == 0):
                percSaved = 0
            else:    
                percSaved = (float(line[8]) - float(line[9])) / float(line[8]) # (logBlk - physBlk) / logBlk

            dedisResults.append([id,proc,benchmark,dataset,iops,percSaved])
    return dedisResults
    
def createChart(imagename,title,dedis1IOPS,dedis2IOPS,fioIOPS,vdbenchIOPS):
    
    N = 6 # 2*3 = 6 (read_hotspot, read_sequencial, read_read_uniform, write_hotspot, ...)

    dedis1IOPS_std = np.std(dedis1IOPS, dtype=np.float64)
    dedis2IOPS_std = np.std(dedis2IOPS, dtype=np.float64)
    fioIOPS_std = np.std(fioIOPS, dtype=np.float64)
    vdbenchIOPS_std = np.std(vdbenchIOPS, dtype=np.float64)
    
    fig, ax = plt.subplots()
    ind = np.arange(N)    # the x locations for the groups
    width = 0.20         # the width of the bars
    
    ax.bar(ind, dedis1IOPS, width, bottom=0,  
           label='DEDISbench')
    ax.bar(ind + width, dedis2IOPS, width, bottom=0, 
        label='DEDISbench++')
    ax.bar(ind + width * 2, fioIOPS, width, bottom=0, 
        label='FIO++')
    ax.bar(ind + width * 3, vdbenchIOPS, width, bottom=0, 
        label='VDBenhch')

    ax.set_title(title)
    ax.set_xticks(ind + width*1.5)
    ax.set_xticklabels(('read_hotspot', 'read_sequencial', 'read_uniform', 'write_hotspot', 'write_sequencial', 'write_uniform'))

    ax.legend()
    ax.autoscale_view()
    plt.xticks(rotation=15)
    
    plt.savefig("./"+chartFolder+"/"+imagename)
 
if __name__ == "__main__":
    main()