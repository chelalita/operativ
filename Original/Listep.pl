
$DIRMAE=mae;
$DIRINFO=rep;
$DIRPROC=imp;
sub mostrarBienvenida{
	print "<><><><><><><Bienvenido a Listep><><><><><><>"."\n".
	   "Inserte (1,2,3 o h) seguido de un enter para:"."\n".
	   " · 1) Listar presupuesto sancionado."."\n".
	   " · 2) Listar presupuesto ejecutado."."\n".
	   " · 3) Listar control del presupuesto ejecutado."."\n".
	   " · h) Mostrar la ayuda del comando Listep."."\n".
		" · q) Salir."."\n";
}
sub mostrarOpcionesSancionado{
	print "Inserte (ct,tc) seguido de un enter para:"."\n".
	   	" · ct) Listar presupuesto sancionado ordenado primero por centro y luego por trimestre."."\n".
	   	" · tc) Listar presupuesto sancionado ordenado primero por trimestre y luego por centro."."\n";
}
sub mostrarInstruccionesEjecutado{
	print "Inserte los nombres de las actividades que desea listar seguidas de un enter. Para finalizar"."\n".
			" inserte un 0 y luego presione enter nuevamente, de no haberse insertado ningun nombre se"."\n".
			" listaran todas las actividades ejecutadas para el anio presupuestario corriente."."\n";
}
sub mostrarGrabacion{
	print "Desea grabar el informe a un archivo? (s/n):";
}
sub grabarArchivo{
	my ($nombre, @file) = @_;
	my $contador = 0;
#	while (-f "$ENV{DIRINFO}/informe_$nombre"."_"."$contador.csv"){
#		$contador++;
#	}
#	open (INFORME , ">"."$ENV{DIRINFO}/informe_$nombre"."_"."$contador.csv");
	while (-f "$DIRINFO/informe_$nombre"."_"."$contador.csv"){
		$contador++;
	}
	open (INFORME , ">"."$DIRINFO/informe_$nombre"."_"."$contador.csv");
	foreach $linea (@file){
		print INFORME $linea;
	}
	close (INFORME);
	print "\nFinalizo grabacion del archivo informe_$nombre"."_"."$contador.csv\n";
}
sub terminarListado{
	my ($nombre, @file) = @_;
	mostrarGrabacion;
	my $decision = <STDIN>;
	chomp($decision);
	while($decision ne "s" && $decision ne "n"){
		print "Opcion incorrecta. Pruebe de nuevo:"."\n";
		$decision = <STDIN>;
		chomp($decision);
	}
	if($decision eq "s"){
		grabarArchivo($nombre,@file);
	}
	if($decision eq "n"){
		&salir;
	}
}
sub obtenerNombreCentro{
	my $codCentro = $_[0];
#	open(CENTROS, "<$ENV{DIRMAE}/centros.csv") or die "No se encontro el archivo centros.csv";	
	open(CENTROS, "<$DIRMAE/centros.csv") or die "No se encontro el archivo centros.csv";	
	my @registros = <CENTROS>;
	my	$encontrado = 0;
	my $i = 0;
	my $nombre_centro;
	while(!$encontrado && $i <= $#registros){
		chomp($registros[$i]);
		if ($registros[$i] =~ /^$codCentro;/){
			$encontrado = 1;
			$nombre_centro = (split(";",$registros[$i]))[1];
		}
		$i++;
	}
	close(CENTROS);
	$nombre_centro;
}
sub crearRegistro{
	my $registro;
	foreach my $valor (@_){
		$registro = $registro.";".$valor;
	}
	$registro =~ s/^.//;
	$registro;
}

sub mostrarRegistro{
	my $registro = $_[0];
	my $cantCol = $_[1];
	my $imprSep = $_[2];
	if($imprSep){
		print "----------------------------------------";
		print "----------------------------------------\n";
	}
	my $espacioCol = 80/$cantCol;
	my @valores = split(";",$registro);
	my $otraFila = 0;
	my $valorAux;
	my @valoresAux;
	my $contador = 1;
	my $escritos = 0;
	foreach my $valor (@valores){
		my $espacios = $espacioCol - length($valor);
		my $valorAux;
		for(my $i=0; $i < $espacios/2; $i++){
			print " ";
			$escritos++;
		}
		$valorAux = substr($valor,$espacioCol);
		if($valorAux eq ""){
			$valorAux = " ";
		}
		push(@valoresAux,$valorAux);
		$valor = substr($valor, 0, $espacioCol);
		if ($espacios < 0){
			$otraFila = 1;
		}
		print $valor;
		$escritos += length($valor);
		for(; $escritos < $espacioCol*$contador; $escritos++){
			print " ";
		}
		print "|";
		$escritos++;
		$contador++;
	}
	print "\n";
	if ($otraFila){
		my $registroAux = crearRegistro(@valoresAux);
		mostrarRegistro($registroAux, $cantCol, 0);	
	}
}
sub existeActividad {
	my $nomAct = @_[0];
#	open(ACTIVIDADES,"<$ENV{DIRMAE}/actividades.csv") or die "No se pudo abrir el archivo actividades.csv";
	open(ACTIVIDADES,"<$DIRMAE/actividades.csv") or die "No se pudo abrir el archivo actividades.csv";
	my @registros = <ACTIVIDADES>;
	my	$encontrado = 0;
	my $i = 0; 
	while(!$encontrado && $i <= $#registros){
		chomp($registros[$i]);
		if ($registros[$i] =~ /;$nomAct$/){
			$encontrado = 1;
		}
		$i++;
	}
	close(ACTIVIDADES);
	$encontrado;
}
sub listarPrepSancionadoCt{
	#	open(SANCIONADO, "<$ENV{DIRMAE}/sancionado-$ANIO_PRESUPUESTARIO.csv") or die "No se encontro el archivo de sanciones";
	open(SANCIONADO, "<$DIRMAE/sancionado-$ANIO_PRESUPUESTARIO.csv") or die "No se encontro el archivo de sanciones";
	my @registros = <SANCIONADO>;
	my %sanciones;
	my @centros;
	for(my $i=1;$i<=$#registros;$i++){
		my $registro = $registros[$i];
		chomp($registro);
		my ($centro,$trimestre,$f11,$f22) = split(";",$registro);
		$f11 =~ s/,/./;
		$f22 =~ s/,/./;
		my $sancionado = $f11 + $f22;
		if(!exists($sanciones{"$centro"})){
			my @gastos = ($sancionado);
			$sanciones{"$centro"} = \@gastos;
			push(@centros,$centro);
		}else{
			push($sanciones{"$centro"},$sancionado);
		}
	}
	my @trimestres = ("Primer Trimestre $ANIO_PRESUPUESTARIO", "Segundo Trimestre $ANIO_PRESUPUESTARIO", 
							"Tercer Trimestre $ANIO_PRESUPUESTARIO", "Cuarto Trimestre $ANIO_PRESUPUESTARIO");
	my @file;
	my $header = crearRegistro("Centro","Anio Presupuestario $ANIO_PRESUPUESTARIO","Total sancionado");
	push(@file,"$header\n");
	mostrarRegistro($header, 3, 1);
	my $totalAnual = 0;
	for(my $i=0;$i<=$#centros;$i++){
		my $centro = $centros[$i];
		my $nombreCentro = obtenerNombreCentro($centro);
		my $totalCentro = 0;
		for(my $j=0;$j<=$#trimestres;$j++){
			my $regTrim;
			if($j == 0){
				$regTrim = crearRegistro("$nombreCentro", $trimestres[$j], $sanciones{$centro}[$j]);		
			}else{
				$regTrim = crearRegistro(" ", $trimestres[$j], $sanciones{$centro}[$j]);		
			}
			push(@file,"$regTrim\n");
			mostrarRegistro($regTrim, 3, 1);
			$totalCentro += $sanciones{$centro}[$j];
		}
		my $footerCentro = crearRegistro("Total $nombreCentro"," ",$totalCentro);
		push(@file,"$footerCentro\n");
		mostrarRegistro($footerCentro, 3, 1);		
		$totalAnual += $totalCentro;
	}
	my $footer = crearRegistro("Total anual"," ",$totalAnual);
	push(@file,"$footer");
	mostrarRegistro($footer, 3, 1);
	close(SANCIONADO);
	terminarListado("sancionadoct",@file);
}
sub listarPrepSancionadoTc{
#	open(my SANCIONADO, "$ENV{DIRMAE}/sancionado-$ANIO_PRESUPUESTARIO.csv");
	open(SANCIONADO, "<$DIRMAE/sancionado-$ANIO_PRESUPUESTARIO.csv") or die "No se encontro el archivo de sanciones";
	my @registros = <SANCIONADO>;
	my %sanciones;
	my @centros;
	for(my $i=1;$i<=$#registros;$i++){
		my $registro = $registros[$i];
		chomp($registro);
		my ($centro,$trimestre,$f11,$f22) = split(";",$registro);
		$f11 =~ s/,/./;
		$f22 =~ s/,/./;
		my $sancionado = $f11 + $f22;

		if(!exists($sanciones{"$centro"})){
			my @gastos = ($sancionado);
			$sanciones{"$centro"} = \@gastos;
			push(@centros,$centro);
		}else{
			push($sanciones{"$centro"},$sancionado);
		}
	}
	my @trimestres = ("Primer Trimestre $ANIO_PRESUPUESTARIO", "Segundo Trimestre $ANIO_PRESUPUESTARIO", 
							"Tercer Trimestre $ANIO_PRESUPUESTARIO", "Cuarto Trimestre $ANIO_PRESUPUESTARIO");
	my @file;
	my $header = crearRegistro("Trimestre","Anio Presupuestario $ANIO_PRESUPUESTARIO","Total sancionado");
	push(@file,"$header\n");
	mostrarRegistro($header, 3, 1);
	my $totalAnual = 0;
	for(my $i=0;$i<=$#trimestres;$i++){
		my $totalTrimestre = 0;
		for(my $j=0;$j<=$#centros;$j++){
			my $centro = $centros[$j];
			my $nombreCentro = obtenerNombreCentro($centro);
			my $regCentro;
			if ($j == 0){
				$regCentro = crearRegistro("$trimestres[$i]","$nombreCentro", $sanciones{$centro}[$i]);
			}else{
				$regCentro = crearRegistro(" ","$nombreCentro", $sanciones{$centro}[$i]);
			}
			$totalTrimestre += $sanciones{$centro}[$i];
			push(@file, "$regCentro\n");
			mostrarRegistro($regCentro, 3, 1);
		}
		$totalAnual += $totalTrimestre;
		my $footerTrim = crearRegistro("Total $trimestres[$i]"," ",$totalTrimestre);
		push(@file, "$footerTrim\n");
		mostrarRegistro($footerTrim, 3, 1);
	}	
	my $footer = crearRegistro("Total anual"," ",$totalAnual);
	push(@file,"$footer");
	mostrarRegistro($footer, 3, 1);
	close(SANCIONADO);
	terminarListado("sancionadotc",@file);
}
sub listarPrepSancionado{
	system(clear);
	mostrarOpcionesSancionado;
	my $decision = <STDIN>;
	chomp($decision);
	while($decision ne "ct" && $decision ne "tc"){
		print "Opcion incorrecta. Pruebe de nuevo:"."\n";
		$decision = <STDIN>;
		chomp($decision);
	}
	if($decision eq "ct"){
		listarPrepSancionadoCt;
	}
	if($decision eq "tc"){
		listarPrepSancionadoTc;
	}
}
sub listarPrepEjecutado{
	system(clear);
	mostrarInstruccionesEjecutado;
	my $actFiltro = <STDIN>;
	chomp($actFiltro);
	my %filtrosAct;
	while($actFiltro ne "0"){
		if(! exists($filtrosAct{$actFiltro}) ){
			if( existeActividad($actFiltro) ){
				$filtrosAct{$actFiltro} = 1;
			}else{
				print "El filtro no fue insertado, actividad invalida\n";
			}
		}
		$actFiltro = <STDIN>;
		chomp($actFiltro);
	}
	if (scalar(keys(%filtrosAct)) == 0){
		#	open(ACTIVIDADES,"<$ENV{DIRMAE}/actividades.csv") or die "No se pudo abrir el archivo actividades.csv";
		open(ACTIVIDADES,"<$DIRMAE/actividades.csv") or die "No se pudo abrir el archivo actividades.csv";
		my @registros = <ACTIVIDADES>;
		shift(@registros);
		foreach my $registro (@registros){
			chomp($registro);
			my $nombreAct = (split(";",$registro))[3];
			$filtrosAct{$nombreAct} = 1;
		}
		close(ACTIVIDADES);
	}
	#asumo que el archivo de centros tiene los centros ordenados
	my @centros;
#	open(CENTROS,"<$ENV{DIRMAE}/centros.csv") or die "No se pudo abrir el archivo centros.csv";
	open(CENTROS,"<$DIRMAE/centros.csv") or die "No se pudo abrir el archivo centros.csv";
	my @registros = <CENTROS>;
	shift(@registros);
	foreach my $registro (@registros){
		chomp($registro);
		my $codCentro = (split(";",$registro))[0];
		push(@centros,$codCentro);
	}
	close(CENTROS);
	
	my %centrosXFechas;
	my %fechaCenActTriXGasto;
#	open(EJECUTADOS,"<$ENV{DIRPROC}/aceptados_$ANIO_PRESUPUESTARIO.csv") or die "No se pudo abrir el 
#																								archivo aceptados_$ANIO_PRESUPUESTARIO.csv";
	open(EJECUTADOS,"<$DIRPROC/aceptados_$ANIO_PRESUPUESTARIO.csv") or die "No se pudo abrir el 
																								archivo aceptados_$ANIO_PRESUPUESTARIO.csv";
	my @registros = <EJECUTADOS>;
	shift(@registros);
	foreach my $registro (@registros){
		chomp($registro);
		my ($id, $fecha, $codCentro, $nomAct, $trim, $gasto) = split(";",$registro);
		if (exists($filtrosAct{$nomAct})){
			my $nomProv = (split(";",$registro))[8];
			if(! exists($centrosXFechas{$codCentro})){
				my @fechas = ($fecha);
				$centrosXFechas{$codCentro} = \@fechas;
			}else{
				push($centrosXFechas{$codCentro}, $fecha);
			}
			my $newKey = "$fecha/$codCentro/$nomAct/$trim/$nomProv";
			if(! exists($fechaCenActTriXGasto{$newKey})){
				$fechaCenActTriXGasto{$newKey} = $gasto;
			}else{
				$fechaCenActTriXGasto{$newKey} += $gasto;
			}
	
		}
	}
	close(EJECUTADOS);
	
	my @trimestres = ("Primer Trimestre $ANIO_PRESUPUESTARIO", "Segundo Trimestre $ANIO_PRESUPUESTARIO", 
							"Tercer Trimestre $ANIO_PRESUPUESTARIO", "Cuarto Trimestre $ANIO_PRESUPUESTARIO");
	my @file;
	my $header = crearRegistro("Fecha","Nom cen","Actividad","Trimestre","Gasto","Prov","Control");
	push(@file,"$header\n");
	mostrarRegistro($header, 7, 1);
	foreach my $actividad (keys(%filtrosAct)){
		foreach my $centro (@centros){
			my @fechasOrd = sort($centrosXFechas{$centro});
			my $nombreCentro = obtenerNombreCentro{$centro};
			foreach my $fechaReg (@fechasOrd){
				my $registroFecha = crearRegistro($fechaReg,$nombreCentro,$actividad,
			}
		}
	}

}
sub listarControlPrepEjecutado{
	print "control de presupuesto ejecutado!!!";
}
sub mostrarAyuda{
	print "ayuda!!!";
}
sub salir{
	print "chau!!!\n";
}
########################################################################
#											  Main										  #
########################################################################
$ANIO_PRESUPUESTARIO=$ARGV[0];
mostrarBienvenida;
my $decision = <STDIN>;
chomp($decision);
while($decision ne "1" && $decision ne "2" 
							  && $decision ne "3" 
							  && $decision ne "h"
							  && $decision ne "q"){
	print "Opcion incorrecta. Pruebe de nuevo:"."\n";
	$decision = <STDIN>;
	chomp($decision);
}
if($decision eq "1"){
	listarPrepSancionado;
}
if($decision eq "2"){
	listarPrepEjecutado;
}
if($decision eq "3"){
	listarControlPrepEjecutado;
}
if($decision eq "h"){
	mostrarAyuda;
}
if($decision eq "q"){
	salir;
}
