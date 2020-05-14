NR==1               { 
                        split(FILENAME,a,"_");

                        benchmark = a[3]; 
                        dataset = a[4]; test = a[5]; access = a[6]; process = a[7]; iteration = a[8];
                        printf benchmark"\t"dataset"\t"test"\t"access"\t"process"\t"iteration
                    }
NR > 1              {printf "\t"$NF}
END                 {printf "\n"}