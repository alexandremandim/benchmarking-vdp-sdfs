BEGIN   {FS=",";c=0;ram_used=0;cpu_usr=0;cpu_sys=0;cpu_wait=0} 

NR >=7 {
        c++; 
        ram_used = ram_used + $6;
        cpu_usr = cpu_usr + $1;
        cpu_sys = cpu_sys + $2;
        cpu_wait = cpu_wait + $4;
        }

END {
        ram_used = ram_used/c;
        cpu_usr = cpu_usr/c;
        cpu_sys = cpu_sys/c;
        cpu_wait = cpu_wait/c;

        print "\t"cpu_usr"\t"cpu_sys"\t"cpu_wait"\t"ram_used
    }