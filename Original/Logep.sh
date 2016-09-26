LOG=".log"

DIA=$(date +"%D")
HORA=$(date +"%H:%M:%S")

if [ $# -gt 3 ] || [ 2 -gt $# ]
	then
	echo " Mal uso del log "
	exit
fi

if [ ! $3 ]
	then 
	RAZON="INFO"
else
	RAZON=$3
fi
echo "$DIA$HORA-$USER-$1-$3-$2" >> $DIRLOG/$1$LOG

if [ -f $1$LOG ]
	then
	LINEAS=`wc -l $DIRLOG/$1`
else
	LINEAS=0
fi

if [[ LINEAS -gt 10 ]]
	then
	sed '1,5d' $DIRLOG/$1
	sed -i '$USER at $DIA $HORA: log reducido...' $DIRLOG/$1
fi




