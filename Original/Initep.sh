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
	#GRUPO= ` grep '^GRUPO' "$ARCHIVO" | cut -f2 -d=`
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
	export SETEADO
}

verificarPermisos(){

	permisoLectura "$DIRMAE/centros.csv"	
	if [ "$?" = "1" ]
	   then
	        return 1
	fi

	permisoLectura "$DIRMAE/provincias.csv"
	if [ "$?" = "1" ]
           then
                return 1
        fi


	permisoLectura "$DIRMAE/trimestres.csv"
	if [ "$?" = "1" ]
           then
                return 1
        fi

	permisoEjecucion "$DIRBIN/Demonep.sh"
	if [ "$?" = "1" ]
           then
                return 1
        fi

	permisoEjecucion "$DIRBIN/Logep.sh"
	if [ "$?" = "1" ]
           then
                return 1
        fi

	permisoEjecucion "$DIRBIN/Movep.sh"
	if [ "$?" = "1" ]
           then
                return 1
        fi

	permisoEjecucion "$DIRBIN/Procep.sh"
	if [ "$?" = "1" ]
           then
                return 1
        fi

	permisoEjecucion "$DIRBIN/Listep.pl"
	if [ "$?" = "1" ]
           then
                return 1
        fi

	echo " Estado del Sistema: INICIALIZADO "
	bash $DIRBIN/Logep.sh Initep "Estado del Sistema: INICIALIZADO " INFO

}

function permisoLectura(){
	if [ ! -f $1 ]
		then
		echo "No existe el $1 archivo , por favor reinstale el sitema..."
		bash $DIRBIN/Logep.sh Initep "No existe $1 archivo, por favor reinstal el sistema..." ERR
		return 1
	fi
	
	if [ ! -r $1 ]
		then
		chmod +r $1
		if [ 1 -r $1 ]
			then
			echo "No se pudo asignar permiso de lectura a $1, abortando..."
			bash $DIRBIN/Logep.sh Initep "No se pudo asignar permiso de lectura a $1, abortando..." ERR
			return 1
		fi
	fi
}

permisoEjecucion(){
		if [ ! -f $1 ]
		then
		echo "No existe el $1 archivo , por favor reinstale el sitema..."
		bash $DIRBIN/Logep.sh Initep "No existe el $1 archivo, por favor reinstale el sistema..." ERR
		return 1
	fi
	if [ ! -r $1 ] || [ ! -w $1 ] || [ ! -x $1 ]
		then
		chmod +rwx $1
		if [ 1 -r $1 ]
			then
			echo "No se pudieron asignar permisos a $1 , abortando..."
			bash $DIRBIN/Logep.sh Initep "No exixste el $1 archivo, por favor reinstale el sistema..." ERR
			return 1
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

function demonio {

	while :
	do
		echo "¿Desea efectuar la activación de RecPro? Si – No"
		read DECISION
		case "$DECISION" in
			Si | SI | sI | si )
				verificarDemCorriendo
				break
				;;
			NO | No | nO | no )
				explicacionManual
				break
				;;
			*)
				echo "Usage: {SI|NO}"
				;;
		esac
	done

	return 0

}


#Incio de Script
cd ../dirconfig
INSTALEP=$PWD
ARCHIVO="$INSTALEP/Instalep.conf"


if [[ $SETEADO = 1 ]]
	then
	echo "Ambiente ya inicializado, para reiniciar termine la sesion e ingrese nuevamente"
	bash $DIRBIN/Logep.sh Initep "Ambiente ya inicializado, para reiniciar termine la sesion e ingrese nuevamente" INFO
	cd ../bin
	return 1 
fi

setearVariables
inicializarVariables
if [ "$?" = "1" ]
   then
	SETEADO=0
	cd ../bin
        return 1
fi

verificarPermisos
SETEADO=1
demonio

cd ../bin


rm -f *.tmp
