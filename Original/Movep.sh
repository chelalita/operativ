if [ ! -f $1 ]
	then
	if [[ ! $3 = "" ]]
		then
		./Logep.sh  $3 " El archivo $1 no existe " ERR
	fi
	./Logep.sh Movep "El archivo $1 no existe " ERR
	exit
fi

if [ ! -d $2 ]
	then
	if [[ ! $3 = "" ]]
		then
		./Logep.sh  $3 " El directorio $2 no existe " ERR
	fi
	./Logep.sh Movep "El directorio $2 no existe " ERR
	exit
fi

nameFile=${1##*/}
ORIGEN=${1%/*}

if [ $1 = ORIGEN ]
	then
	if [ ! $3 ="" ]
		then
		./Logep.sh $3 "EL directorio origen es igual al destino " ERR
	fi
	./Logep Movep "El directorio origen es igual al destino " ERR
	exit
fi


if [ -f $2/$nameFile ]
	then
	if [[ ! $3 = "" ]] 
		then
		./Logep.sh $3 "El archivo $2/$nameFile ya existe , se almacenara en /dpl" WAR

	fi
	./Logep.sh Movep "El archivo $2/$nameFile ya existe , se almacenara en /dpl " WAR

	if [ ! -d $2/dpl ]
		then
		mkdir $2/dpl
	fi
	A="ls $2/dpl/$nameFile*"
	echo $A
	N=0
	for i in $( echo $A ):
	do
		N=$(( N+1 ))
	done

	mv $1 "$1.$N"
	mv "$1.$N" "$2/dpl/"

	
	
else
	mv $1 $2
	if [[ ! $3 = "" ]]
		then
		./Logep.sh $3 "se movio el archivo $1 a $2 " INFO
	fi
	./Logep.sh Movep "se movio el archivo $1 a $2 " INFO
fi





