###############################################################################
#											  Funciones											   #
###############################################################################
function procesarArchivo(){
nombreArchivo="$1"

#chequeo si esta duplicado
if [ -f "$DIRPROC/proc/$nombreArchivo" ]
	then
	bash $DIRBIN/Logep.sh Procep "Archivo Duplicado. Se rechaza el archivo $nombreArchivo" WAR
	bash $DIRBIN/Movep.sh "$DIROK/$nombreArchivo" $DIRNOK "Procep"
	return 1
fi
#chequeo cantidad de columnas
if [ $(head -1 "$DIROK/$nombreArchivo" | sed 's/[^;]//g' | wc -c) != 6 ]
	then
	bash $DIRBIN/Logep.sh Procep "Estructura inesperada. Se rechaza el archivo $nombreArchivo" WAR
	bash $DIRBIN/Movep.sh "$DIROK/$nombreArchivo" $DIRNOK "Procep"
	return 1
fi

bash $DIRBIN/Logep.sh Procep "Archivo a procesar $nombreArchivo" INFO

cantRegValidos=0
cantRegInvalidos=0
#el header no cuenta como registro
n=-1
while IFS=$'\n' read -r linea
do
	#ignoro el header
	if [ $n != -1 ]
		then
		procesarLinea "$linea" "$nombreArchivo"
	fi
	((n++))
done < "$DIROK/$nombreArchivo"

#termina proceso de archivo
bash $DIRBIN/Movep.sh "$DIROK/$nombreArchivo" "$DIRPROC/proc" "Procep"

bash $DIRBIN/Logep.sh Procep "Cantidad de registros leidos: $n" INFO
bash $DIRBIN/Logep.sh Procep "Cantidad de registros validos: $cantRegValidos" INFO
bash $DIRBIN/Logep.sh Procep "Cantidad de registros invalidos: $cantRegInvalidos" INFO
return 0
}

function procesarLinea(){
registro="$1"
archivo="$2"
IFS=";"
#asumo que todos los campos tienen valores no nulos
read ide fecha centro actividad trimestre gasto <<< "$registro"
anioCorriente=$(echo "$trimestre" | cut -d' ' -f 3)
#asumo que los archivos maestros existen
#valido centro
if [ $(grep -c "^$centro;" "$DIRMAE/centros.csv") -eq 0 ]
	then
	grabarRegistroInvalido $archivo "Centro inexistente" "$registro" 
	return 1
fi
#valido actividad
if [ $(grep -c ";$actividad$" "$DIRMAE/actividades.csv") = 0 ]
	then
	grabarRegistroInvalido $archivo "Actividad inexistente." "$registro" 	
	return 1
fi
#asumo que $trimestre no coincide con otro campo que no sea nom_tri de trimestres.csv
#valido trimestre
if [ -z $anioCorriente ] || [ $anioCorriente != 2016 ] || [ $(grep -c ";$trimestre;" "$DIRMAE/trimestres.csv") = 0 ]
	then
	grabarRegistroInvalido $archivo "Trimestre invalido." "$registro" 	
	return 1
fi
#valido fecha valida
date -d "$fecha" +%s > /dev/null 2>&1
esFechaValida=$?
if [ $esFechaValida != 0 ]
	then
	grabarRegistroInvalido $archivo "Fecha invalida." "$registro"
	return 1
fi
#valido fecha dentro del rango determinado por trimestres y nombre del archivo
fechaSeg=$(date -d "$fecha" +%s)
diaArchivo=$(echo "$archivo" | cut -d'_' -f 4 | cut -d'.' -f 1)
diaArchivoSeg=$(date -d "$diaArchivo" +%s)
#asumo que la informacion de los archivos maestros es correcta
regTrimestre=$(grep ";$trimestre;" "$DIRMAE/trimestres.csv")
fDesdeTri=$(echo "$regTrimestre" | cut -d';' -f 3)
fDesdeTri=${fDesdeTri:3:3}${fDesdeTri:0:3}${fDesdeTri:6:4}
segDesdeTri=$(date -d "$fDesdeTri" +%s)
fHastaTri=$(echo "$regTrimestre" | cut -d';' -f 4)
fHastaTri=${fHastaTri:3:3}${fHastaTri:0:3}${fHastaTri:6:4}
segHastaTri=$(date -d "$fHastaTri" +%s)
if [ $fechaSeg -gt $diaArchivoSeg ]
	then
	grabarRegistroInvalido $archivo "Fecha invalida." "$registro"
	return 1
fi
if [ $fechaSeg -lt $segDesdeTri ] || [ $fechaSeg -gt $segHastaTri ]
	then
	grabarRegistroInvalido $archivo "La fecha no se corresponde con el trimestre indicado" "$registro"
	return 1
fi
#valido gasto positivo
gasto=$(echo "$gasto" | sed 's/,/./')
if [ $(echo $gasto'<='0 | bc -l) -ne 0 ]
	then
	grabarRegistroInvalido $archivo "Importe invalido." "$registro"
	return 1
fi
#si llegamos aca es que el registro es valido
grabarRegistroValido "$ide" "$fecha" "$centro" "$actividad" "$trimestre" "$gasto" "$archivo" 
return 0
}

function grabarRegistroValido(){
ide="$1"
fecha="$2"
centro="$3"
actividad="$4"
trimestre="$5"
gasto="$6"
archivo="$7"

((cantRegValidos++))
anioPresup=$(echo "$archivo" | cut -d'_' -f 2)
#si no existe el archivo de reg aceptados lo creo con su header
if [ ! -f "$DIRPROC/aceptado_$anioPresup.csv" ]
	then
	echo "id;Fecha;Cod_centro;Nombre_act;Nombre_tri;Gasto;Archivo_origen;COD_ACT;NOM_PROV;NOM_CEN" >> "$DIRPROC/aceptado_$anioPresup.csv"
fi
#concateno el registro al archivo
codActividad=$(grep ";$actividad$" "$DIRMAE/actividades.csv" | cut -d';' -f 1)
codProv=$(echo "$archivo" | cut -d'_' -f 3)
nomProv=$(grep "^$codProv;" "$DIRMAE/provincias.csv" | cut -d';' -f 2)
nomCentro=$(grep "^$centro;" "$DIRMAE/centros.csv" | cut -d';' -f 2)
echo "$ide;$fecha;$centro;$actividad;$trimestre;$gasto;$archivo;$codActividad;$nomProv;$nomCentro" >> "$DIRPROC/aceptado_$anioPresup.csv"
return 0
}

function grabarRegistroInvalido(){
archivo=$1
motivo=$2
registro="$3"

((cantRegInvalidos++))
anioPresup=$(echo "$archivo" | cut -d'_' -f 2)
#si no existe el archivo de reg rechazados lo creo con su header
if [ ! -f "$DIRPROC/rechazado_$anioPresup.csv" ]
	then
	echo "Fuente;Motivo;Reg_oferta;usuario;fecha" >> "$DIRPROC/rechazado_$anioPresup.csv"
fi
#cambio el delimitador del registro a un '	' para no confundir con el ; del archivo de rechazados
registro=$(echo "$registro" | sed 's/;/\t/g')
#concateno el registro al archivo
ahora=$(date +"%D-%H:%M:%S")
echo "$archivo;$motivo;$registro;$USER;$ahora" >> "$DIRPROC/rechazado_$anioPresup.csv"
return 0
}
###############################################################################
#											     Main											   #
###############################################################################
if [[ $SETEADO != 1 ]]
	then
	echo "No fue inicializado el ambiente.Abortando.."
	exit
fi

cantArchivos=$(ls $DIROK | wc -l)
bash $DIRBIN/Logep.sh Procep "Cantidad de archivos a procesar: $cantArchivos" INFO

#si nunca se proceso nada se crea el directorio donde iran los archivos procesados
if [ ! -d "$DIRPROC/proc" ]
	then
	mkdir "$DIRPROC/proc"
fi

ls $DIROK > archivos_a_procesar.tmp
while read -r nombreArchivo
do
	procesarArchivo $nombreArchivo
done < archivos_a_procesar.tmp
rm archivos_a_procesar.tmp

exit 0
