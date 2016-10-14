
function ProcesarArchivos() {
	ls "$1/" > "procesar.tmp"
	while read -r nombre_archivo      
	do
		Procesar_un_Archivo "$nombre_archivo"
	done < "procesar.tmp"
	rm "procesar.tmp"	
}

function Procesar_un_Archivo() {
	echo -e "\n--------------------"
	echo "Procesando $1"
	echo -e "--------------------"

	nombreCompleto="$1"
	direccionCompleta="$DIRREC/$1"
	bash $DIRBIN/Logep.sh Demonep "Archivo detectado:  $nombreCompleto " INFO
	IFS="."
	read nombre extension <<< "$nombreCompleto"
	IFS="$aux"
	#Valido que sea de texto.
	case "$extension" in 
	"dat" | "csv" | "txt" | "doc")
		;;
	 * )

		bash $DIRBIN/Logep.sh Demonep "Archivo rechazado,motivo: $nombreCompleto no es un archivo de texto " WAR
		bash $DIRBIN/Movep.sh $direccionCompleta $DIRNOK "Demonep"
		return 1
		 ## rechazado por no ser archivo de texto
	esac
	#Valido que no este vacio.
	cantlineas=$( wc -l $direccionCompleta )
	IFS=" "
	read cant ss <<< "$cantlineas"
	IFS="$aux"
	if [ $cant = 0 ]
	then
		bash $DIRBIN/Logep.sh Demonep "Archivo rechazado,motivo: $nombreCompleto archivo vacio " WAR
		bash $DIRBIN/Movep.sh $direccionCompleta $DIRNOK "Demonep"
		return 1
	fi


	IFS='_'
	read ejecutado anio_pres cod_prov fecha<<< "$nombre"		
	IFS="$aux"
	#Valido que el formato sea el correcto.
	if [ -z $ejecutado ] || [ -z $anio_pres ] || [ -z $cod_prov ] || [ -z "$fecha" ]
	then
		bash $DIRBIN/Logep.sh Demonep "Archivo rechazado,motivo: formato de nombre incorrecto" WAR
		bash $DIRBIN/Movep.sh "$direccionCompleta" "$DIRNOK" "DEMONEP"
		return 1
	fi
	#valido que sea el formato correcto
	if [ 'ejecutado' != $ejecutado ]
	then
		bash $DIRBIN/Logep.sh Demonep "Archivo rechazado,motivo: formato de nombre incorrecto" WAR
		bash $DIRBIN/Movep.sh "$direccionCompleta" "$DIRNOK" "DEMONEP"
		return 1
	fi
	#valido anio presupuestario
	if [ $(date +"%Y") != $anio_pres ]
	then
		bash $DIRBIN/Logep.sh Demonep "Archivo rechazado,motivo: año $anio_pres incorrecto" WAR
		bash $DIRBIN/Movep.sh "$direccionCompleta" "$DIRNOK" "DEMONEP"
		return 1
	fi
	#valido codigo de prov
	val_cod_prov=` grep "^$cod_prov;" "$DIRMAE/provincias.csv" `
	IFS=";"
	read cod basura1 basura2 <<< "$val_cod_prov"
	IFS="$aux"
	if [ -z $val_cod_prov ]
	then
		bash $DIRBIN/Logep.sh Demonep "Archivo rechazado,motivo: provincia $cod_prov incorrecto" WAR
		bash $DIRBIN/Movep.sh "$direccionCompleta" "$DIRNOK" "DEMONEP"
		return 1
	fi
	#valido fecha
	anio=`expr substr $fecha 1 4`
	mes=`expr substr $fecha 5 2`
	dia=`expr substr $fecha 7 2`
	val_anio=`echo $anio | grep ^[0-2][0][1][5-6]$`
	val_mes=`echo $mes | grep ^[0-1][0-9]$`
	val_dia=`echo $dia | grep ^[0-3][0-9]$`
	if [ -z $val_anio ] || [ -z $val_mes ] || [ -z $val_dia ]
	then
		bash $DIRBIN/Logep.sh Demonep "Archivo rechazado,motivo: fecha $fecha invalida" WAR
		bash $DIRBIN/Movep.sh "$direccionCompleta" "$DIRNOK" "DEMONEP"
		return 1
	fi
	#valido rango de fecha
	echo "$anio$mes$dia jaja"
	if [ "$anio$mes$dia" \< "20151212" ] || [ "$anio$mes$dia" \> $(date +"%Y%m%d") ]
	then
		bash $DIRBIN/Logep.sh Demonep "Archivo rechazado,motivo: fecha $fecha invalida" WAR
		bash $DIRBIN/Movep.sh "$direccionCompleta" "$DIRNOK" "DEMONEP"
		return 1
	fi
	bash $DIRBIN/Logep.sh Demonep "Archivo aceptado" INFO
	bash $DIRBIN/Movep.sh "$direccionCompleta" "$DIROK" "DEMONEP"
}
#**********MAin***********
CANT_CICLOS=0
if [[ $SETEADO != 1 ]]
then
	echo "No fue inicializado el ambiente.Abortando.."
	exit
fi

if [ -f "$DIRBIN/.ejecutado" ]
		then
		bash $DIRBIN/Logep.sh Demonep "El demonio se esta ejecutando" ERR
		exit
fi

touch $DIRBIN/.ejecutado
IDPROC=`ps -aef | grep "$BINDIR/Demonep.sh" | awk 'NR==1 {print $2}' `
bash $DIRBIN/Logep.sh Demonep "Demonep corriendo bajo el no.: $IDPROC" INFO

while [ true ]
do
	CANT_CICLOS=$(expr $CANT_CICLOS + 1)
	bash $DIRBIN/Logep.sh Demonep "Ciclo numero $CANT_CICLOS " INFO
	ARCHIVOS=$(ls $DIRREC | wc -l)
	if [  $ARCHIVOS != 0 ]
	then
		ProcesarArchivos $DIRREC
	fi
	sleep 5

done
exit 0
