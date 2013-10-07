#!/usr/bin/perl

use Switch;

#Deberia pasarse al menos un parametro.
if ( $#ARGV <0 ) {
	print "Debe pasar al menos un parametro\n";
}

$val=$ARGV[0];

switch ($val) {

	#TODO: Agregar a las funciones que correspondan la opcion de escribir en archivo.
	$escribir=0;
	
	if ( $ARGV[1] eq "-w" ) { $escribir=1; }
	
	case "-a" { &imprimir_ayuda; }
	case "-i" { &generar_invitados; }
	case "-t" { &generar_tickets; }
	case "-d" { &generar_disponibilidades; }
	case "-r" { &generar_ranking; }
	
	case "-w" {
	    $escribir=1;
	    if ( $ARGV[1] eq "-d" ) { &generar_disponibilidades; }
	    else { print "Parametros invalidos. -a para visualizar ayuda\n" }
	}
	else { print "Parametros invalidos. -a para visualizar ayuda\n" }
	
}


sub generar_tickets {
    #TODO: Cambiar por PROCDIR/reservas.ok
    $archivo_reservasok="reservas.ok";
    if ( ! (-e $archivo_reservasok ) ) {
		print "No existe el archivo de entrada\n";
		return;
    }
    $encontrado=0;
    &tickets_pedirid;
    if ($idcombo == -1) { return; }
    open(ARC, $archivo_reservasok);
    while($linea = <ARC>) {
      chomp($linea);
      #TODO: Usar expresiones regulares para verificar que este bien formado.
      @data= split(";", $linea);
      #Si no hay suficientes datos, suponer archivo mal formado y saltar esa linea.
      if ($#data ne 12 ) { next; }
      $comboleido=$data[7];
      if ($comboleido==$idcombo) {
	  $encontrado=1;
	  $numconfirmadas=$data[6];
	  while($numconfirmadas>0) {
	      if ($numconfirmadas==1) { print ("Vale por 1 entrada;"); }
	      if ($numconfirmadas==2) { print ("Vale por 2 entradas;"); }
	      if ($numconfirmadas!=1 and $numconfirmadas!=2) { 
		  $numconfirmadas-=2;
		  print ("Vale por 2 entradas;");
	      }
	      else { $numconfirmadas=0 ; }
	      print ("$data[1];$data[2];$data[3];$data[5];$data[8];$data[10]\n");
	  }
      }
    }
    close (ARC);
    if ($encontrado==0) {
      print "No se encontro ninguna entrada con el id de combo pedido\n";
      &tickets_pedirid;
    }
    
}

#Funcion auxiliar de generar_tickets para que el usuario ingrese el id del combo.
sub tickets_pedirid {

	print "Ingrese el id del combo cuyo listado de tickets desea imprimir, o -1 para salir\n";
	$idcombo = <STDIN>;
	chomp($idcombo);
}
	
sub generar_ranking {
    #Utilizar la referencia interna del solicitante para distinguir entre solicitantes.
    #(Se podría utilizar el mail, pero se supone que una misma persona podria tener
    # dos mails distintos registrados, mientras que la referencia deberia ser unica).
    
    
    #TODO: Cambiar por PROCDIR/reservas.ok
    $archivo_reservasok="reservas.ok";
    if ( ! (-e $archivo_reservasok ) ) {
		print "No existe el archivo de entrada\n";
		return;
    }
    %hash_ranking=""; #Hash vacio.
    open(ARC, $archivo_reservasok);
    while($linea = <ARC>) {
      chomp($linea);
      #TODO: Usar expresiones regulares para verificar que este bien formado.
      @data= split(";", $linea);
      #Si no hay suficientes datos, suponer archivo mal formado y saltar esa linea.
      if ($#data ne 12 ) { next; }
      
      # Usa un hash. Los keys son las referencias internas del solicitante.
      # Los values son arrays, cuyo primer valor es la sumatoria de reservas
      # y el segundo es la direccion de mail.
      if ( exists( $hash_ranking{$data[8]}) ) { 
	  @laux=$hash_ranking{$data[8]}[0];
	  @lista_d= ( $laux[0] + $data[9],$data[10]);
	  $hash_ranking{$data[8]}=[@lista_d];
      }
      else {
	 @lista_d= ($data[9],$data[10]);
	 $hash_ranking{$data[8]}= [@lista_d];
      }
   }
   close(ARC);
  
  #Obtengo dos arrays, uno con los keys y otro con los values.
  #Estan ordenados segun el criterio que le paso al sort: que valor es mayor comparando
  # el primer elemento del array que es value de cada key
  # (Recordar: primer elemento del array=sumatoria de reservas)
  my @keys = sort { $hash_ranking{$b}[0] <=> $hash_ranking{$a}[0] } keys(%hash_ranking);
  my @values = @hash_ranking{@keys};
  
  $valores_iterar=$#keys;
  if (  $valores_iterar>10 ) { $valores_iterar=10; }
  
  for($i = 1; $i < $valores_iterar; $i++) {
	print ("$values[$i][1]-$values[$i][0]\n");
  }
    
}

sub generar_invitados {
    &pedir_id_evento;
    if ($eleccion == -1) { return; }
    #TODO: Cambiar por PROCDIR/reservas.ok
    $archivo_reservasok="reservas.ok";
    #TODO: cambiar por REPODIR (para REPODIR/<Referencia Interna Del Solicitante>.inv)
    $repodirinv="pruebas";
    
    if ( ! (-e $archivo_reservasok ) ) {
		print "No existe el archivo de entrada\n";
		return;
    }
    
    open(ARC, $archivo_reservasok);
    while($linea = <ARC>) {
      chomp($linea);
      #TODO: Usar expresiones regulares para verificar que este bien formado.
      @data= split(";", $linea);
      #Si no hay suficientes datos, suponer archivo mal formado y saltar esa linea.
      if ($#data ne 12 ) { next; }
      if ($eleccion==$data[0]) {
	  print "Evento: $data[7] Obra: $data[0]-$data[1], Fecha y Hora: $data[2]-$data[3] Hs. Sala: $data[4]-$data[5]\n";
	  $nombrearchivo="$repodirinv/$data[8].inv";

	  if ( ! (-e $nombrearchivo ) ) { print "sin listado de invitados \n"; }
	  else {
	      open(ARCINV, $nombrearchivo);
	      $aux=0;
	      while($registro = <ARCINV>) {
		 
		  chomp($registro);
		  #TODO: Usar expresiones regulares para verificar que este bien formado.
		  @datainv= split(";", $registro);
		  $aux=$aux+$datainv[2]+1;
		  print "$datainv[0],$datainv[2],$aux\n";
		  
	      }
	      close (ARCINV);
	  }
      }
    }
    close(ARC);
}


# Funcion auxiliar para generar listas de invitados:
# Accede al archivo maestro de obras y las lista. Al terminar, pide que se elija alguna de ellas
# el id de la elegida se guarda en $eleccion
sub pedir_id_evento {
  print "Lista de obras: \n";
  
  #TODO: Cambiar por MAEDIR/obras.mae
  $directorio_obras="obras.mae";
  if ( ! (-e $directorio_obras ) ) {
		print "No existe el archivo de entrada\n";
		return;
  }
  $contador=0;
  @ids;
  open(IN, $directorio_obras);
  while($linea = <IN>) {
    chomp($linea);
    #TODO: Usar expresiones regulares para verificar que este bien formado.
    @info= split(";", $linea);
    #Si no hay suficientes datos, suponer archivo mal formado y saltar esa linea.
    if ($#info ne 3 ) { next; }
    $contador+=1;
    print "Opcion nro: $contador ID: $info[0], Nombre: $info[1] \n";
    push(@ids,$info[0]);
  }
  close(IN);
  $numop=0;
  $eleccion=0;
  while ( $numop<=0 or $numop>$contador ) {
    print "Elija NUMERO DE OPCION de la obra elegida, o -1 para salir\n";
    $numop= <STDIN>;
    chomp($numop);
    if ( $numop == -1) { return };
    if ( ( $numop<=0 or $numop>$contador ) )  { 
	    print "Numero incorrecto ... \n"; }
    else { $eleccion= $ids[$numop-1]; }
    
  }
    
}

sub generar_disponibilidades {
	#TODO: Aca deberia buscar en otro directorio.
	if ( ! (-e "combos.dis") ) {
		print "No existe el archivo de entrada\n";
		return;
	}
	&disponibilidades_pedirdatos;
	
	$encontro=0;
	open(IN, "combos.dis");
	while($linea = <IN>) {
	  chomp($linea);
	   #TODO: Usar expresiones regulares para verificar que este bien formado.
	  @data= split(";", $linea);
	  
	  #Si no hay suficientes datos, suponer archivo mal formado y saltar esa linea.
	  if ($#data ne 7 ) { next; }
	  
	  if ( $entrada eq "-o" ) {
	    $idbus=$data[1];
	  }
	  elsif ( $entrada eq "-s" ) {
	    $idbus=$data[4];
	  }
	 
	  for ($i=0; $i<=$#valores; $i++) {
	      if ($valores[$i] eq $idbus) {
		$encontro=1;
		for ($k=0; $k<6; $k++) { print ( "$data[$k] - "); }
		print ( "$data[6]\n");
	      }
	  }
	}
	close(IN);
	if ($encontro ne 1) {
	    print "No se encontraron resultados para el o los valores ingresados.\n Vuelva a insertar datos.\n";
	    &generar_disponibilidades;
	}
}

#Funcion auxiliar de generar_disponibilidades para que el usuario ingrese datos.
sub disponibilidades_pedirdatos {

	print "¿Desea ingresar un ID de obra o un ID de sala?\nIngrese -o para id de obra, -s para id de sala.\n";
	$entrada = <STDIN>;
	chomp($entrada);
	
	if ( ($entrada ne "-o") and ($entrada ne "-s") ) {
	    print "Opcion incorrecta.. \n";
	    return;
	}
	print "Ingrese un numero para buscar un id, o un rango de ids con el siguiente formato: 'idinicial-idfinal'\n";
	$numid= <STDIN>;
	chomp($numid);
	$indiceguion=index($numid,"-");
	$rango=0;
	if ( $indiceguion ne -1 ) { $rango=1; }
	#Si tengo un rango de valores, rango=-1. Si tengo un sólo valor, rango=0.
	
	
	if ($rango eq 0) { @valores = ( $numid ); }
	else { 
	  #Valores inicial y final del rango.
	  $valorinicial=substr($numid,0,$indiceguion);
	  $valorfinal=substr($numid,$indiceguion+1);
	  if ( $valorinicial gt $valorfinal ) { 
	      print "Error en el rango introducido...\n"; 
	      return;
	  }
	  while ($valorinicial<=$valorfinal) {
	    push(@valores,$valorinicial);
	    $valorinicial+=1;
	  }
	}

}

sub imprimir_ayuda {
		print "Ayuda del comando.\n";
		print "Pueden pasarse los siguientes parametros:\n";
		print " -a : Muestra este manual.\n";
		print " -i : Muestra por pantalla un listado de invitados a un evento.\n";
		print " -d : Muestra por pantalla un listado de los espectaculos disponibles.\n";
		print " -r : Muestra por pantalla un ranking de solicitantes.\n";
		print " -t : Muestra por pantalla el listado de tickets a imprimir.\n";
		print " -w : Opcion solamente combinable con -i,-d,-r o -t. Todas esas opciones imprimen datos en pantalla. Si ademas se indica -w, los datos tambien se guardaran en un archivo de texto.\n";
}