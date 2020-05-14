BEGIN   {}

NR==6   {   blkLog=$5}
NR==4   {   blkFis=$5}
NR==21  {   fragcompress=$5}
NR==22  {   blkcompress=$5}
END     {
            printf "\t"blkLog"\t"blkFis"\t"fragcompress"\t"blkcompress
        }