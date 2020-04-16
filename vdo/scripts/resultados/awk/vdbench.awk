BEGIN   {}
NR==1               { 
                        split(FILENAME,b,"\/");
                        split(b[3],a,"_");

                        date = a[1]; hour = a[2]; benchmark = a[3]; 
                        dataset = a[4]; test = a[5]; access = a[6]; process = a[7]; iteration = a[8]
                    }
/[0-9]+\:[0-9]+\:[0-9]+\.[0-9]+\ +avg/ {
    latency = $7; throughput = $3
    }
END                 {
                        printf date"\t"hour"\t"benchmark"\t"dataset"\t"test"\t"access"\t"process"\t"iteration"\t" 
                        printf (latency)"\t"throughput"\t"
                    }