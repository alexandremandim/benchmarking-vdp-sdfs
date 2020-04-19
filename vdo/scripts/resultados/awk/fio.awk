BEGIN               { FS=","; RS="\n"; throughput = 0; latency = 0; operations = 0; count = 0}

NR==1               { 
                        split(FILENAME,b,"\/");
                        split(b[3],a,"_");

                        date = a[1]; hour = a[2]; benchmark = a[3]; 
                        dataset = a[4]; test = a[5]; access = a[6]; process = a[7]; iteration = a[8]
                    }
/lat \(usec\)\:/    {   split($3,a,"="); latency = latency + a[2] / 1000; count++    }
/iops\ +\:/         {   split($3,a,"="); throughput = throughput + a[2]  }
/io\=[0-9]+(\.[0-9]+)?GiB/              {   split($3,a,"="); split(a[2],b,"G"); operations = b[1]    } #Está em GiB
/io\=[0-9]+(\.[0-9]+)?MiB/              {   split($3,a,"="); split(a[2],b,"M"); operations = (b[1]/1024)    } #Está em GiB
END                 {
                        printf date"\t"hour"\t"benchmark"\t"dataset"\t"test"\t"access"\t"process"\t"iteration"\t" 
                        print (latency/count)"\t"throughput"\t"operations
                    }