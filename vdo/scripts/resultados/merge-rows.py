import sys
import os
import numpy as np
import matplotlib.pyplot as plt

chartFolder = "charts"

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
        print("id","benchmark","dataset","test","access","processes","latency","sdL","throughput","sdT","operation","sdO")
        
    results = getAverageAndStdDedis(filepath,True)
    
    # ----------- CHARTS ---------
    if not os.path.exists(chartFolder):
        os.mkdir(chartFolder)

    # if(benchmark == "DEDIS1"):
    #     dedisCharts(results,benchmark)
        
    # if( benchmark == "DEDIS2"):
    #     dedisCharts(results,benchmark)

    # if(benchmark == "FIO"):
    #     fioCharts(results,benchmark)
        
    # if(benchmark == "VDBENCH"):
    #     vdbenchCharts(results,benchmark)

def getAverageAndStdDedis(filepath,printCSV):
    latencies = []
    troughputs = []
    operations = []
    dedisResutls = {}

    with open(filepath) as fp:
        line = fp.readline() # First line does not count
        cnt = 1

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

                id = benchmark.lower() + "_d" + dataset[-1] + "_" + test + "_" + access[0] + "_" + processes

                dedisResutls[id] = [benchmark, dataset, test, access, processes, latency, sdL, throughput, sdT, operation, sdO]
                
                if(printCSV == True):
                    print(id,benchmark, dataset, test, access, processes, str(latency).replace('.', ','), str(sdL).replace('.', ','), str(throughput).replace('.', ','), str(sdT).replace('.', ','), str(operation).replace('.', ','), str(sdO).replace('.', ','))

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
    ax.bar(x_pos, CTEs, yerr=error, align='center', alpha=0.5, ecolor='black', capsize=0.25)
    ax.bar(x_pos+0.25, CTEs, yerr=error, align='center', alpha=0.5, ecolor='red', capsize=0.25)
    ax.set_ylabel(yLabel)
    ax.set_xticks(x_pos)
    ax.set_xticklabels(xValues)
    ax.set_title(title)
    ax.yaxis.grid(True)

    # Save the figure and show
    plt.setp(ax.get_xticklabels(), rotation=30, horizontalalignment='right')
    plt.tight_layout()
    plt.savefig("./"+chartFolder+"/"+imageName)
    plt.close()
    # plt.show()

def chart3(workloadResults, title, filename):
    # Debito
    debito = list(map(lambda id: id[7], workloadResults.values()))
    debitoDP = list(map(lambda id: id[8], workloadResults.values()))
    chart(workloadResults.keys(), debito, debitoDP,
          'IOPS',"IOPS - " + title, filename + "_debito.png")
    # Latencia
    latencia = list(map(lambda id: id[5], workloadResults.values()))
    latenciaDP = list(map(lambda id: id[6], workloadResults.values()))
    chart(workloadResults.keys(), latencia, latenciaDP,
          'Latência miliseconds',"Latência - " + title, filename + "_latencia.png")
    # Operacoes
    operacoes = list(map(lambda id: id[9], workloadResults.values()))
    operacoesDP = list(map(lambda id: id[10], workloadResults.values()))
    chart(workloadResults.keys(), operacoes, operacoesDP,
          'IO (GiB)',"IO - " + title, filename + "_operacoes.png")

def chart3Bars(x, y1, y1Label, y1std, y2, y2Label, y2std, y3, y3Label, y3std, title):

    fig, ax = plt.subplots()

    ind = np.arange(len(x))    # the x locations for the groups
    width = 0.35                # the width of the bars
    ax.bar(ind, y1, width, bottom=0*cm, yerr=y1std, label=y1Label)
    ax.bar(ind + width, y2, width, bottom=0*cm, yerr=y2std,label=y2Label)
    #ax.bar(ind - width, y3, width, bottom=0*cm, yerr=y3std,label=y3Label)

    ax.set_title(title)
    ax.set_xticks(ind + width / 2)
    ax.set_xticklabels(x)

    ax.legend()
    ax.yaxis.set_units(inch)
    ax.autoscale_view()

    plt.show()


def dedisCharts(results, benchmark):
    
    writeWL = { key:value for (key,value) in results.items() if value[2] == 'w'}
    chart3(writeWL, benchmark + " - Write", benchmark.lower() + "_write")
    
    readWL = { key:value for (key,value) in results.items() if value[2] == 'r'}
    chart3(readWL, benchmark + " - Read", benchmark.lower() + "_read")
    
    hotWL = { key:value for (key,value) in results.items() if value[3] == 'hotspot'}
    chart3(hotWL, benchmark + " - Hotspot", benchmark.lower() + "_hotspot")
    
    seqWL = { key:value for (key,value) in results.items() if value[3] == 'sequencial'}
    chart3(seqWL, benchmark + " - Sequencial", benchmark.lower() + "_sequencial")
    
    uniformWL = { key:value for (key,value) in results.items() if value[3] == 'uniform'}
    chart3(uniformWL, benchmark + " - Uniform", benchmark.lower() + "_uniform")
    
    oneProc = { key:value for (key,value) in results.items() if value[4] == '1'}
    chart3(oneProc, benchmark + " - 1Process", benchmark.lower() + "_1proc")
    
    fourProc = { key:value for (key,value) in results.items() if value[4] == '4'}
    chart3(fourProc, benchmark + " - 4Process", benchmark.lower() + "_4proc")

def fioCharts(results, benchmark):
    writeWL = { key:value for (key,value) in results.items() if value[2] == 'w'}
    chart3(writeWL, benchmark + " - Write", benchmark.lower() + "_write")
    
    readWL = { key:value for (key,value) in results.items() if value[2] == 'r'}
    chart3(readWL, benchmark + " - Read", benchmark.lower() + "_read")
    
    hotWL = { key:value for (key,value) in results.items() if value[3] == 'poisson'}
    chart3(hotWL, benchmark + " - poisson", benchmark.lower() + "_poisson")
    
    seqWL = { key:value for (key,value) in results.items() if value[3] == 'sequencial'}
    chart3(seqWL, benchmark + " - Sequencial", benchmark.lower() + "_sequencial")
    
    uniformWL = { key:value for (key,value) in results.items() if value[3] == 'uniform'}
    chart3(uniformWL, benchmark + " - Uniform", benchmark.lower() + "_uniform")
    
    oneProc = { key:value for (key,value) in results.items() if value[4] == '1'}
    chart3(oneProc, benchmark + " - 1Process", benchmark.lower() + "_1proc")
    
    fourProc = { key:value for (key,value) in results.items() if value[4] == '4'}
    chart3(fourProc, benchmark + " - 4Process", benchmark.lower() + "_4proc")
    
def vdbenchCharts(results, benchmark):
    writeWL = { key:value for (key,value) in results.items() if value[2] == 'w'}
    chart3(writeWL, benchmark + " - Write", benchmark.lower() + "_write")
    
    readWL = { key:value for (key,value) in results.items() if value[2] == 'r'}
    chart3(readWL, benchmark + " - Read", benchmark.lower() + "_read")
    
    hotWL = { key:value for (key,value) in results.items() if value[3] == 'poisson'}
    chart3(hotWL, benchmark + " - poisson", benchmark.lower() + "_poisson")
    
    seqWL = { key:value for (key,value) in results.items() if value[3] == 'sequencial'}
    chart3(seqWL, benchmark + " - Sequencial", benchmark.lower() + "_sequencial")
    
    uniformWL = { key:value for (key,value) in results.items() if value[3] == 'uniform'}
    chart3(uniformWL, benchmark + " - Uniform", benchmark.lower() + "_uniform")
    
    oneProc = { key:value for (key,value) in results.items() if value[4] == '1'}
    chart3(oneProc, benchmark + " - 1Process", benchmark.lower() + "_1proc")
    
    fourProc = { key:value for (key,value) in results.items() if value[4] == '4'}
    chart3(fourProc, benchmark + " - 4Process", benchmark.lower() + "_4proc")
    
if __name__ == "__main__":
    main()