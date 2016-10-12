
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
	
	#Valido que el formato sea el correcto.
	if [ -z $ejecutado ] || [ -z $anio_pres ] || [ -z $cod_prov ] || [ -z "$fecha" ]
	then
		IFS="$aux"
		bash $DIRBIN/Movep.sh "$direccionCompleta" "$DIRNOK" "DEMONEP"
		return 1
	fi


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
