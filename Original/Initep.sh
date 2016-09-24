cd ../dirconfig
INSTALEP=$PWD
ARCHIVO="$INSTALEP/Instalep.conf"

SETEADO=0

verificarExistenciaConf(){
	if [ ! -f $ARCHIVO ]
		then
		echo "No existe el archivo de configuracion , abortando instalacion..."
		bash $DIRBIN/Logep.sh Initep "No existe el archivo de configuracion , abortando instalacion..." ERR
		exit
	fi
}


inicializarVariables(){
	GRUPO="/home/juancho/FIUBA/SistemasOperativos/TP"
	#GRUPO= `grep '^GRUPO' "$ARCHIVO" | cut -f2 -d'='` no entiendo pq falla solo este...
	DIRBIN=` grep '^DIRBIN' "$ARCHIVO" | cut -f2 -d= `
	DIRMAE=` grep '^DIRMAE' "$ARCHIVO" | cut -f2 -d= `
	DIRREC=` grep '^DIRREC' "$ARCHIVO" | cut -f2 -d= `
	DIROK=` grep '^DIROK' "$ARCHIVO" | cut -f2 -d= `
	DIRPROC=` grep '^DIRPROC' "$ARCHIVO" | cut -f2 -d= `
	DIRLOG=` grep '^DIRLOG' "$ARCHIVO" | cut -f2 -d= `
	DIRINFO=` grep '^DIRINFO' "$ARCHIVO" | cut -f2 -d= `
	DIRNOK=` grep '^DIRNOK' "$ARCHIVO" | cut -f2 -d= `	
}

setearVariables(){
	#PATH
	export GRUPO
	export DIRBIN
	export DIRMAE
	export DIRREC
	export DIROK
	export DIRPROC
	export DIRLOG
	export DIRINFO
	export DIRNOK
	export SETEADO=1
}

verificarPermisos(){

	permisoLectura "$DIRMAE/centros.csv"
	permisoLectura "$DIRMAE/provincias.csv"
	permisoLectura "$DIRMAE/trimestres.csv"
	permisoEjecucion "$DIRBIN/Demonep.sh"
	permisoEjecucion "$DIRBIN/Logep.sh"
	permisoEjecucion "$DIRBIN/Movep.sh"
	permisoEjecucion "$DIRBIN/Procep.sh"
	permisoEjecucion "$DIRBIN/Listep.pl"

	echo " Estado del Sistema: INICIALIZADO "

	bash $DIRBIN/Logep.sh Initep "Estado del Sistema: INICIALIZADO " INFO
}

function permisoLectura(){
	if [ ! -f $1 ]
		then
		echo "No existe el $1 archivo , por favor reinstale el sitema..."
		bash $DIRBIN/Logep.sh Initep "No existe $1 archivo, por favor reinstal el sistema..." ERR
		exit
	fi
	
	if [ ! -r $1 ]
		then
		chmod +r $1
		if [ 1 -r $1 ]
			then
			echo "No se pudo asignar permiso de lectura a $1, abortando..."
			bash $DIRBIN/Logep.sh Initep "No se pudo asignar permiso de lectura a $1, abortando..." ERR
			exit
		fi
	fi
}

permisoEjecucion(){
		if [ ! -f $1 ]
		then
		echo "No existe el $1 archivo , por favor reinstale el sitema..."
		bash $DIRBIN/Logep.sh Initep "No existe el $1 archivo, por favor reinstale el sistema..." ERR
		exit
	fi
	if [ ! -r $1 ] || [ ! -w $1 ] || [ ! -x $1 ]
		then
		chmod +rwx $1
		if [ 1 -r $1 ]
			then
			echo "No se pudieron asignar permisos a $1 , abortando..."
			bash $DIRBIN/Logep.sh Initep "No exixste el $1 archivo, por favor reinstale el sistema..." ERR
			exit
		fi
	fi
}

verificarDemCorriendo(){
	if [ -f "$DIRBIN/ejecucion" ]
		then
		echo " el demonio se esta ejecutando"
		bash $DIRBIN/Logep.sh Initep "El demonio se esta ejecutando" INFO
	else
		bash $DIRBIN/Demonep.sh &
		IDPROC=`ps -aef | grep "$BINDIR/Demonep.sh" | awk 'NR==1 {print $2}' `
		echo "Demonep corriendo bajo el no.: $IDPROC"
		bash $DIRBIN/Logep.sh Initep "Demonep corriendo bajo el no.: $IDPROC"
	fi
}

explicacionManual(){
	echo "Para inicializar el Deamonep ejecute $BINDIR/Deamonep.sh &"
	bash $DIRBIN/Logep.sh Initep "Para inicializar el Deamonep ejecute $BINDIR/Deamonep.sh &" INFO
	bash $DIRBIN/Logep.sh Initep "Para terminar la ejecucion utilice el comando >kill <idprocess>" INFO
	 echo " Para terminar la ejecucion utilice el comando >kill <idprocess>"
}


#Incio de Script

if [[ SETEADO = 1 ]]
	then
	echo "Ambiente ya inicializado, para reiniciar termine la sesion e ingrese nuevamente"
	bash $DIRBIN/Logep.sh Initep "Ambiente ya inicializado, para reiniciar termine la sesion e ingrese nuevamente" INFO
	exit
fi
inicializarVariables
setearVariables
verificarPermisos

echo "¿Desea efectuar la activación de Demonep? Si – No "
bash $DIRBIN/Logep.sh Initep "¿Desea efectuar la activación de Demonep? Si – No " INFO
read rta 
bash $DIRBIN/Logep.sh Initep "La respuesta del usuario fue $rta" INFO
if [ $rta = "si " ] || [ $rta = "Si" ]
	then
	verificarDemCorriendo
else
	explicacionManual
fi
rm -f *.tmp