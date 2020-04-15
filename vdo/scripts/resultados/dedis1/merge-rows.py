import sys
import os
import numpy as np
import matplotlib.pyplot as plt

def main():
    
    dedis1Results = getDedis1Results(False)
    
    #chartDebitoWrite(dedis1Results)
    #chartDebitoRead(dedis1Results)
    chartDebito1Proc(dedis1Results)

def getDedis1Results(printCSV):
    filepath = sys.argv[1]

    if not os.path.isfile(filepath):
       print("File path {} does not exist. Exiting...".format(filepath))
       sys.exit()

    latencies = []
    troughputs = []
    operations = []
    dedisResutls = {}

    with open(filepath) as fp:
        line = fp.readline() # First line does not count
        cnt = 1

        if(printCSV == True):
            print("id","benchmark","dataset","test","access","processes","latency","sdL","throughput","sdT","operation","sdO")
        for line in fp:
            line = line.strip().split("\t")

            latencies.append(float(line[8]))
            troughputs.append(float(line[9]))
            operations.append(float(line[10]))
            
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

                id = "ded1_d" + dataset[-1] + "_" + test + "_" + access[0] + "_" + processes

                dedisResutls[id] = [benchmark, dataset, test, access, processes, latency, sdL, throughput, sdT, operation, sdO]
                
                if(printCSV == True):
                    print(id,benchmark, dataset, test, access, processes, latency, sdL, throughput, sdT, operation, sdO)

                latencies = []
                troughputs = []
                operations = []

            cnt += 1
    
    return dedisResutls

def chart(xValues, yValues, yDP, yLabel, title, imageName):

    x_pos = np.arange(len(xValues))
    CTEs = yValues
    error = yDP

    fig, ax = plt.subplots()
    ax.bar(x_pos, CTEs, yerr=error, align='center', alpha=0.5, ecolor='black', capsize=10)
    ax.set_ylabel(yLabel)
    ax.set_xticks(x_pos)
    ax.set_xticklabels(xValues)
    ax.set_title(title)
    ax.yaxis.grid(True)

    # Save the figure and show
    plt.setp(ax.get_xticklabels(), rotation=30, horizontalalignment='right')
    plt.tight_layout()
    plt.savefig(imageName)
    plt.show()

def chartDebitoWrite(dedis1Results):
    writeWL = { key:value for (key,value) in dedis1Results.items() if value[2] == 'w'}

    debitosWriteWL = list(map(lambda id: id[7], writeWL.values()))
    debitosDPWriteWL = list(map(lambda id: id[8], writeWL.values()))
    
    chart(writeWL.keys(), debitosWriteWL, debitosDPWriteWL,
          'Débito Operações/Seg','Débito - DEDIS1 - Writes', 'ded1_w_debito.png')

def chartDebitoRead(dedis1Results):
    readWL = { key:value for (key,value) in dedis1Results.items() if value[2] == 'r'}

    debitosreadWL = list(map(lambda id: id[7], readWL.values()))
    debitosDPreadWL = list(map(lambda id: id[8], readWL.values()))
    
    chart(readWL.keys(), debitosreadWL, debitosDPreadWL,
          'Débito Operações/Seg','Débito - DEDIS1 - Reads', 'ded1_w_debito.png')

def chartDebito1Proc(dedis1Results):
    workloadResults = { key:value for (key,value) in dedis1Results.items() if value[4] == '1'}

    xValues = list(map(lambda id: id[7], workloadResults.values()))
    xValuesDP = list(map(lambda id: id[8], workloadResults.values()))
    
    chart(workloadResults.keys(), xValues, xValuesDP,
          'Débito Operações/Seg','Débito - DEDIS1 - 1 Proc', 'ded1_w_debito.png')


if __name__ == "__main__":
    main()