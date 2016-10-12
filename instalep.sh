GRUPO=$PWD
conf="dirconfig"
DIRBIN="bin"
DIRMAE="mae"
DIRREC="nov"
DIROK="ok"
DIRPROC="imp"
DIRLOG="log"
DIRINFO="rep"
DIRNOK="nok"
DATASIZE="100"

#FUNCIONES
#########################################################################################################

#Muestro las definiciones que hizo el usuario y le pregunto si quiere o no continuar
function showDefiniciones(){
echo "Directorio de Configuración: $GRUPO/$conf
Directorio de Ejecutables: $GRUPO/$DIRBIN
Directorio de Maestros y Tablas: $GRUPO/$DIRMAE
Directorio de Recepción de Novedades: $GRUPO/$DIRREC
Directorio de Archivos Aceptados: $GRUPO/$DIROK
Directorio de Archivos Procesados: $GRUPO/$DIRPROC
Directorio de Archivos de Reportes: $GRUPO/$DIRINFO
Directorio de Archivos de Log: $GRUPO/$DIRLOG
Directorio de Archivos Rechazados: $GRUPO/$DIRNOK
Estado de la instalación: LISTA
Desea continuar con la instalación? (Si – No) _"| tee -a $PWD/dirconfig/Instalep.log
read rta
}
#Consulto al usuario y creo los nombres de los director
function creoDirectorios(){
#Binario
echo "Defina el directorio de ejecutables  ($GRUPO/$DIRBIN):"| tee -a $GRUPO/dirconfig/Instalep.log
read DIRBIN1
if [[ $DIRBIN1 != "" ]]
	then
	DIRBIN=$DIRBIN1
fi

if [[ $DIRBIN = "dirconf" ]]
	then
	echo "Acceso denegado : Carpeta privada " | tee -a $GRUPO/dirconfig/Instalep.log
	finProceso
fi

echo $DIRBIN | tee -a  $GRUPO/dirconfig/Instalep.log

#Maestro
echo "Defina el directorio de Maestros y Tablas ($GRUPO/$DIRMAE):" | tee -a $GRUPO/dirconfig/Instalep.log
read DIRMAE1
if [[  $DIRMAE1 != "" ]]
	then
	DIRMAE=$DIRMAE1	
fi


if [[ $DIRMAE = "dirconf" ]]
	then
	echo "Acceso denegado : Carpeta privada " | tee -a $GRUPO/dirconfig/Instalep.log
	finProceso
fi

echo $DIRMAE | tee -a $GRUPO/dirconfig/Instalep.log


#Novedades
echo "Defina el directorio de recepción de novedades ($GRUPO/$DIRREC):" | tee -a $GRUPO/dirconfig/Instalep.log
read DIRREC1
if [[  $DIRREC1 != "" ]]
	then
	DIRREC=$DIRREC1
	
fi


if [[ $DIRREC = "dirconf" ]]
	then
	echo "Acceso denegado : Carpeta privada " | tee -a $GRUPO/dirconfig/Instalep.log
	finProceso
fi

echo $DIRREC | tee -a $GRUPO/dirconfig/Instalep.log

#Demonio
echo "Defina el directorio de Archivos Aceptados ($GRUPO/$DIROK):" | tee -a $GRUPO/dirconfig/Instalep.log
read DIROK1
if [[  $DIROK1 != "" ]]
	then
	DIROK=$DIROK1
	
fi

if [[ $DIROK = "dirconf" ]]
	then
	echo "Acceso denegado : Carpeta privada " | tee -a $GRUPO/dirconfig/Instalep.log
	finProceso
fi

echo $DIROK | tee -a $GRUPO/dirconfig/Instalep.log

#ArchivosProcesados
echo "Defina el directorio de Archivos Procesados ($GRUPO/$DIRPROC):" | tee -a $GRUPO/dirconfig/Instalep.log
read DIRPROC1
if [[  $DIRPROC1 != "" ]]
	then
	DIRPROC=$DIRPROC1
fi

if [[ $DIRPROC = "dirconf" ]]
	then
	echo "Acceso denegado : Carpeta privada " | tee -a $GRUPO/dirconfig/Instalep.log
	finProceso
fi

echo $DIRPROC | tee -a $GRUPO/dirconfig/Instalep.log

#Reporte
echo "Defina el directorio de Reportes ($GRUPO/$DIRINFO):" | tee -a $GRUPO/dirconfig/Instalep.log
read DIRINFO1
if [[  $DIRINFO1 != "" ]]
	then
	DIRINFO=$DIRINFO1
fi


if [[ $DIRINFO = "dirconf" ]]
	then
	echo "Acceso denegado : Carpeta privada " | tee -a $GRUPO/dirconfig/Instalep.log
	finProceso
fi

echo $DIRINFO | tee -a $GRUPO/dirconfig/Instalep.log

#Log
echo "Defina el directorio de log ($GRUPO/$DIRLOG):" | tee -a $GRUPO/dirconfig/Instalep.log
read DIRLOG1
if [[  $DIRLOG1 != "" ]]
	then
	DIRLOG=$DIRLOG1
fi


if [[ $DIRLOG = "dirconf" ]]
	then
	echo "Acceso denegado : Carpeta privada " | tee -a $GRUPO/dirconfig/Instalep.log
	finProceso
fi

echo $DIRLOG | tee -a $GRUPO/dirconfig/Instalep.log

#Rechazados
echo "Defina el directorio de rechazos ($GRUPO/$DIRNOK):" | tee -a $GRUPO/dirconfig/Instalep.log
read DIRNOK1
if [[  $DIRNOK1 != "" ]]
	then
	DIRNOK=$DIRNOK1
fi


if [[ $DIRNOK = "dirconf" ]]
	then
	echo "Acceso denegado : Carpeta privada " | tee -a $GRUPO/dirconfig/Instalep.log
	finProceso
fi

echo $DIRNOK | tee -a $GRUPO/dirconfig/Instalep.log
}


function finProceso(){
rm -f *.tmp
DIA=$(date +"%D")
HORA=$(date +"%H:%M:%S")
echo "Fin del proceso. $USER $DIA $HORA" >> $PWD/dirconfig/Instalep.log
mv $GRUPO/dirconfig/Instalep.log $GRUPO/$DIRLOG
exit
}

function instalacionDirectorios(){
echo 'Creando Estructuras de directorio. . . .' | tee -a $PWD/dirconfig/Instalep.log
mkdir $GRUPO/$DIRBIN
mkdir $GRUPO/$DIRMAE
mkdir $GRUPO/$DIRPROC
mkdir $GRUPO/$DIROK
mkdir $GRUPO/$DIRINFO
mkdir $GRUPO/$DIRNOK
mkdir $GRUPO/$DIRLOG
mkdir $GRUPO/$DIRREC

echo 'Instalando Programas y Funciones' | tee -a $PWD/dirconfig/Instalep.log

cp $GRUPO/Original/Demonep.sh $GRUPO/$DIRBIN
cp $GRUPO/Original/Logep.sh $GRUPO/$DIRBIN
cp $GRUPO/Original/Initep.sh $GRUPO/$DIRBIN
cp $GRUPO/Original/Procep.sh $GRUPO/$DIRBIN
cp $GRUPO/Original/Movep.sh $GRUPO/$DIRBIN
cp $GRUPO/Original/Listep.pl $GRUPO/$DIRBIN

echo 'Instalando Archivos Maestros y Tablas' | tee -a $PWD/dirconfig/Instalep.log
cp $GRUPO/Original/centros.csv $GRUPO/$DIRMAE
cp $GRUPO/Original/provincias.csv $GRUPO/$DIRMAE
cp $GRUPO/Original/trimestres.csv $GRUPO/$DIRMAE
cp $GRUPO/Original/actividades.csv $GRUPO/$DIRMAE
}

function verificarEspacio(){
echo 'Defina espacio mínimo libre para la recepción de archivos en Mbytes (100):'
read DATASIZE1
if [[ DATASIZE1 != "" ]]
	then
	DATASIZE=$DATASIZE1
fi

dir=$(df -k $PWD | tail -1 | tr -s ' ' | cut -d' ' -f4) #tail me saca la primer linea. tr entendi muy bien
total=$(($dir / 1000))

while [[ $DATASIZE -gt $total ]]
do
echo "Insuficiente espacio en disco.
Espacio disponible: $total Mb.
Espacio requerido $DATASIZE Mb
Inténtelo nuevamente." | tee -a $GRUPO/dirconfig/Instalep.log
echo 'Defina espacio mínimo libre para la recepción de archivos en Mbytes (100):'
read DATASIZE

done

echo "Suficiente espacio en disco. 
Espacio disponible: $total Mb.
Espacio requerido $DATASIZE Mb.
De enter para continuar." | tee -a $GRUPO/dirconfig/Instalep.log
read respuesta
while [[ $respuesta != "" ]]
do
echo "De enter para continuar."
read respuesta
done
}

function crearArchivoConfiguracion(){
	echo "GRUPO=$GRUPO=$USER=$(date +"%D")$(date +"%H:%M:%S")">> $PWD/dirconfig/Instalep.conf
	echo "DIRBIN=$GRUPO/$DIRBIN=$USER=$(date +"%D")$(date +"%H:%M:%S")">> $PWD/dirconfig/Instalep.conf
	echo "DIRMAE=$GRUPO/$DIRMAE=$USER=$(date +"%D")$(date +"%H:%M:%S")">> $PWD/dirconfig/Instalep.conf
	echo "DIRREC=$GRUPO/$DIRREC=$USER=$(date +"%D")$(date +"%H:%M:%S")">> $PWD/dirconfig/Instalep.conf
	echo "DIROK=$GRUPO/$DIROK=$USER=$(date +"%D")$(date +"%H:%M:%S")">> $PWD/dirconfig/Instalep.conf
	echo "DIRPROC=$GRUPO/$DIRPROC=$USER=$(date +"%D")$(date +"%H:%M:%S")">> $PWD/dirconfig/Instalep.conf
	echo "DIRINFO=$GRUPO/$DIRINFO=$USER=$(date +"%D")$(date +"%H:%M:%S")">> $PWD/dirconfig/Instalep.conf
	echo "DIRLOG=$GRUPO/$DIRLOG=$USER=$(date +"%D")$(date +"%H:%M:%S")">> $PWD/dirconfig/Instalep.conf
	echo "DIRNOK=$GRUPO/$DIRNOK=$USER=$(date +"%D")$(date +"%H:%M:%S")">> $PWD/dirconfig/Instalep.conf
}

#######################################################################################################
#COMIENZO DE SCRIPT
#Si encuentro el archivo , ya existe y solo loggeo.
if [ -r $GRUPO/dirconfig/Instalep.conf ]
then
echo "Directorio de Configuración: $GRUPO/$conf
Directorio de Ejecutables: $GRUPO/$DIRBIN
Directorio de Maestros y Tablas: $GRUPO/$DIRMAE
Directorio de Recepción de Novedades: $GRUPO/$DIRREC
Directorio de Archivos Aceptados: $GRUPO/$DIROK
Directorio de Archivos Procesados: $GRUPO/$DIRPROC
Directorio de Archivos de Reportes: $GRUPO/$DIRINFO
Directorio de Archivos de Log: $GRUPO/$DIRLOG
Directorio de Archivos Rechazados: $GRUPO/$DIRNOK"| tee -a $GRUPO/dirconfig/Instalep.log


finProceso
else

DIA=$(date +"%D")
HORA=$(date +"%H:%M:%S")
echo "Inicio del proceso. $USER $DIA $HORA" >> $GRUPO/dirconfig/Instalep.log 

creoDirectorios
verificarEspacio
clear

showDefiniciones

while [ $rta != si ]
do
clear
creoDirectorios
showDefiniciones
done

echo "Iniciando Instalación. Esta Ud. seguro? (Si-No)" | tee -a $GRUPO/dirconfig/Instalep.log
read rta
if [[ $rta != "si" ]]
	then
	e
	finProceso
fi

instalacionDirectorios
crearArchivoConfiguracion
finProceso
fi