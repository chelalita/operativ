escribirLog(){
	echo $USER at $DIA $HORA: $RAZON $2 >>  $DIRLOG/$1
}

DIA=$(date +"%D")
HORA=$(date +"%H:%M:%S")

if [ $# -gt 3 ] || [ 2 -gt $# ]
	then
	echo " Mal uso del log "
	exit
fi

if [ ! $3 ]
	then 
	RAZON="-"
else
	RAZON=$3
fi

escribirLog

LINEAS=`wc -l $DIRLOG/$1`

if [ LINEAS -gt 10 ]
	then
	sed '1,5d' $DIRLOG/$1
	sed -i '$USER at $DIA $HORA: log reducido...' $DIRLOG/$1
fi




