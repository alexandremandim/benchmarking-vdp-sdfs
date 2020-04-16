BEGIN               { FS=" "; RS="\n"; throughput = 0; latency = 0; operations = 0; count = 0}

NR==1               { 
                        split(FILENAME,b,"\/");
                        split(b[3],a,"_");

                        date = a[1]; hour = a[2]; benchmark = a[3]; 
                        dataset = a[4]; test = a[5]; access = a[6]; process = a[7]; iteration = a[8]
                    }
/Throughput\:/      { throughput = throughput + $2 }
/Latency\:/         { count++; latency = latency + $2 }
/Total I\/O/        { operations = operations + $3 }

END                 {
                        printf date"\t"hour"\t"benchmark"\t"dataset"\t"test"\t"access"\t"process"\t"iteration"\t" 
                        print (latency/count)"\t"throughput"\t"((operations*4096)/(1024*1024*1024))
                    }