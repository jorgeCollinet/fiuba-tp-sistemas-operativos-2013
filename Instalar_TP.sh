#!/bin/bash
#Script que se encarga de la instalacion del TP.
# Ver el readme para mas informacion.
#	COMANDO: Instalar_TP.sh
#------------------------------------------------------------
grupo="`pwd`/grupo8"
export CONFDIR="$grupo/conf"
Instlog="$CONFDIR/Instalar_TP.log" #ruta a el log del script
declare -i DATASIZE
Instconf="$CONFDIR/Instalar_TP.conf" #ruta al conf del script
backup="$CONFDIR/backup"


function backup {
Log "Realizando backup"
./Mover_B.sh ./Iniciar_B.sh "$backup" '-c'
./Mover_B.sh ./Grabar_L.sh "$backup" '-c'
./Mover_B.sh ./Reservar_B.sh "$backup" '-c'
./Mover_B.sh ./Stop_D.sh "$backup" '-c'
./Mover_B.sh ./Start_D.sh "$backup" '-c'
./Mover_B.sh ./Imprimir_B.pl "$backup" '-c'
./Mover_B.sh ./EstaCorriendo.sh "$backup" '-c'
./Mover_B.sh ./EstaInicializado.sh "$backup" '-c' 
./Mover_B.sh ./Recibir_B.sh "$backup" '-c'

./Mover_B.sh ./Readme_Instalar "$backup" '-c'
./Mover_B.sh ./Readme_Start_D "$backup" '-c'
./Mover_B.sh ./Readme_Iniciar "$backup" '-c'
./Mover_B.sh ./Readme_Reservar "$backup" '-c'
./Mover_B.sh ./Readme_Imprimir "$backup" '-c'
./Mover_B.sh ./Readme_Recibir "$backup" '-c'
./Mover_B.sh ./Readme_Grabar_L "$backup" '-c'
./Mover_B.sh ./Readme_Stop_D "$backup" '-c'
./Mover_B.sh ./Readme_Iniciar "$backup" '-c'
./Mover_B.sh ./datos/obras.mae "$backup" '-c'
./Mover_B.sh ./datos/salas.mae "$backup" '-c'
./Mover_B.sh ./datos/combos.dis "$backup" '-c'

./Mover_B.sh ./Mover_B.sh "$backup" '-c'
}

#Funcion para grabar al Log
function Log {
	./Grabar_L.sh "$0" '-ins' "$1"
	echo "$1"
}

#Funcion para grabar al .conf
function grabarAlConf2 {
echo "$1=$2=`whoami`=`date`" >> "$Instconf"
}

#Funcion prototipo para la carga de valores desde el conf
function CargarDelConf {
miArreglo1=()
miArreglo2=()

let a=0
IFS='='
while read -r -a nombre      
do
	miArreglo1[a]=$nombre
	miArreglo2[a]=${nombre[1]}
	let a+=1
done < $Instconf
unset IFS
export grupo="${miArreglo2[0]}"
export CONFDIR="${miArreglo2[1]}"
export BINDIR="${miArreglo2[2]}"
export MAEDIR="${miArreglo2[3]}"
export ARRIDIR="${miArreglo2[4]}"
export ACEPDIR="${miArreglo2[5]}"
export RECHDIR="${miArreglo2[6]}"
export REPODIR="${miArreglo2[7]}"
export PROCDIR="${miArreglo2[8]}"
export LOGDIR="${miArreglo2[9]}"
export LOGEXT="${miArreglo2[10]}"
export DATASIZE="${miArreglo2[11]}"
export LOGSIZE="${miArreglo2[12]}"
}

#Por defecto asumo estos directorios 
function ParametrosDefault {
export BINDIR="$grupo/bin"
export MAEDIR="$grupo/mae"
export ARRIDIR="$grupo/arribos"
export ACEPDIR="$grupo/aceptados"
export RECHDIR="$grupo/rechazados"
export REPODIR="$grupo/listados"
export PROCDIR="$grupo/procesados"
export LOGDIR="$grupo/log"
export LOGEXT='.log'
export DATASIZE='100'
export LOGSIZE='400'
}

#(Pasos 19 - )Funcion auxiliar que muestra el estado de la instalacion
function MostrarMensajeEstado {
clear
Log "TP SO7508 Segundo Cuatrimestre 2013. Tema B Copyright Grupo 08"
Log "Libreria del Sistema: $CONFDIR"
if [ -d "$CONFDIR" ];
then
	ls "$CONFDIR"
fi
Log "Ejecutables:$BINDIR"
if [ -d "$BINDIR" ];
then
	ls "$BINDIR"
fi
Log "Archivos Maestros: $MAEDIR"
if [ -d "$MAEDIR" ];
then
	ls "$MAEDIR"
fi
Log "Directorio de arribo de archivos externos: $ARRIDIR"
if [ -d "$ARRIDIR" ];
then
	ls "$ARRIDIR"
fi
Log "Archivos externos aceptados: $ACEPDIR"
if [ -d "$ACEPDIR" ];
then
	ls "$ACEPDIR"
fi
Log "Archivos externos rechazados: $RECHDIR"
if [ -d "$RECHDIR" ];
then
	ls "$RECHDIR"
fi
Log "Reportes de salida:$REPODIR"
if [ -d "$REPODIR" ];
then
	ls "$REPODIR"
fi
Log "Archivos procesados:$PROCDIR"
if [ -d "$PROCDIR" ];
then
	ls "$PROCDIR"
fi
Log "Logs de aditoria del Sistema:$LOGDIR/<$COMANDO>.$LOGEXT"
if [ -d "$LOGDIR" ];
then
	ls "$LOGDIR"
fi
Log "Estado de la instalacion:$1"

}

#Funcion auxiliar para la carga de un Si-No
function FSiNo {
local var1
while [ "$var1" != "Si" ] && [ "$var1" != "No" ] && [ "$var1" != "n" ] && [ "$var1" != "s" ] && [ "$var1" != "no" ] && [ "$var1" != "si" ]
do 
	read  var1
	Log "El usuario ingresó: $var1" 1> /dev/null
done #Hasta que no contesta si o no sale del bucle

if [ "$var1" = "Si" ] || [ "$var1" = "s" ] || [ "$var1" = "si" ]
then
	return "1"
else
	return "0"
fi
}

#(Paso1) Funcion que inicia el log. Lo crea si no estaba.
function InicioLogInstalacion {
if [ -f "$Instlog" ];
then
	echo "Existe "$Instlog""
else
	touch "$Instlog"
fi

Log "Inicio de Ejecución" 
Log "Log del comando Instalar_TP:$Instlog"
Log "Directorio de configuracion:$CONFDIR"
}
#(aux Paso4) Funcion auxiliar que segun con que opcion se llame , detalla los directorios que deberian estar creados o los crea
#$1 es la opcion
#$2 es el directorio
function listarCrearDir {
if [ ! -d "$1" ]
then
	Log "directorio: $1 esta FALTANDO"
fi
}
#$1 es el parametro que recibe la opcion -l para listar -c para crear
function ChequearDirectorios {
listarCrearDir "$CONFDIR"
listarCrearDir "$BINDIR"
listarCrearDir "$MAEDIR"
listarCrearDir "$ARRIDIR"
listarCrearDir "$ACEPDIR"
listarCrearDir "$RECHDIR"
listarCrearDir "$REPODIR"
listarCrearDir "$PROCDIR"
listarCrearDir "$LOGDIR"
}
function listarArch {
if [ ! -f "$1" ]
then
	Log "Archivo: $1 esta FALTANDO"
fi
}
function ChequearArchivos {
declare local temp1
declare local temp2
declare local temp3
if [ "$1" = '-b' ]
then
	temp1="$CONFDIR/backup"
	temp2="$CONFDIR/backup"
	temp3="$CONFDIR/backup"
else
	temp1="$BINDIR"
	temp2="$MAEDIR"
	temp3="$PROCDIR"
fi
listarArch "$temp1/Iniciar_B.sh"
listarArch "$temp1/Grabar_L.sh"
listarArch "$temp1/Reservar_B.sh"
listarArch "$temp1/Stop_D.sh"
listarArch "$temp1/Start_D.sh"
listarArch "$temp1/Imprimir_B.pl"
listarArch "$temp1/EstaCorriendo.sh"
listarArch "$temp1/EstaInicializado.sh"
listarArch "$temp1/Recibir_B.sh"
listarArch "$temp1/Mover_B.sh"

listarArch "$temp2/obras.mae"
listarArch "$temp2/salas.mae"

listarArch "$temp3/combos.dis"
}

function RestaurarArchivos {
cp "$CONFDIR/backup/Iniciar_B.sh" "$BINDIR"
cp "$CONFDIR/backup/Grabar_L.sh" "$BINDIR"
cp "$CONFDIR/backup/Reservar_B.sh" "$BINDIR"
cp "$CONFDIR/backup/Stop_D.sh" "$BINDIR"
cp "$CONFDIR/backup/Start_D.sh" "$BINDIR"
cp "$CONFDIR/backup/Imprimir_B.pl" "$BINDIR"
cp "$CONFDIR/backup/EstaCorriendo.sh" "$BINDIR"
cp "$CONFDIR/backup/EstaInicializado.sh" "$BINDIR"
cp "$CONFDIR/backup/Recibir_B.sh" "$BINDIR"
cp "$CONFDIR/backup/Mover_B.sh" "$BINDIR"
cp "$CONFDIR/backup/Readme_Instalar" "$BINDIR"
cp "$CONFDIR/backup/Readme_Start_D" "$BINDIR"
cp "$CONFDIR/backup/Readme_Iniciar" "$BINDIR"
cp "$CONFDIR/backup/Readme_Reservar" "$BINDIR"
cp "$CONFDIR/backup/Readme_Imprimir" "$BINDIR"
cp "$CONFDIR/backup/Readme_Recibir" "$BINDIR"
cp "$CONFDIR/backup/Readme_Grabar_L" "$BINDIR"
cp "$CONFDIR/backup/Readme_Stop_D" "$BINDIR"
cp "$CONFDIR/backup/Readme_Iniciar" "$BINDIR"

cp "$CONFDIR/backup/obras.mae" "$MAEDIR"
cp "$CONFDIR/backup/salas.mae" "$MAEDIR"

cp "$CONFDIR/backup/combos.dis" "$PROCDIR"

# permiso de ejecución
for file in `ls "$BINDIR"`; do
	chmod +x "$BINDIR/$file"
done

}
#(Paso 4) Funcion que se encarga de reinstalar/continuar la instalacion
function ReInstalar {
Log "Chequeando si la instalacion esta completa o no"
declare local faltanDirs=$(ChequearDirectorios)
declare local faltanArchs=$(ChequearArchivos)

if [ "$faltanDirs" = "" ] && [ "$faltanArchs" = "" ];
then
	MostrarMensajeEstado 'COMPLETA'
	Log "Proceso de instalacion Cancelado"
else
	Log "Instalacion con faltantes"
	MostrarMensajeEstado 'INCOMPLETA'
	Log "Componentes faltantes:"
	Log "$faltanDirs"
	Log "$faltanArchs"
	Log "Desea continuar la instalacion? (SI - No)"
	if FSiNo;
	then
		Log "Proceso de instalacion cancelado"
	else
		Log "Chequeando si se encuentran los faltantes ...."
		#Comprobar si estan TODOS los archivos de backup
		existenFaltantes=$(ChequearArchivos '-b')
		if [ "$existenFaltantes" = "" ];
		then
			PerlInstalado
			MostrarMensajeEstado 'LISTA'
			Log "Iniciando Instalación. Esta Ud. seguro? (Si-No)"
			if ! FSiNo;
			then
				InstalacionDirectorios
				RestaurarArchivos
				Log "Instalación SATISFACTORIAMENTE CONCLUIDA"
			fi
		else
			Log "No existen los faltantes en el sistema para poder realizar la instalacion"
			Log "$existenFaltantes"
			Log "Instalacion ABORTADA"
		fi
	fi
fi
}

#(Paso 5) (Aceptacion de terminos) Retorna 1 si acepto los terminos, 0 si no.
function AceptaTerminos {

Log "TP SO7508 Segundo Cuatrimestre 2013. Tema B Copyright Grupo 08"
Log " ATENCION: Al instalar el TP SO7508 Segundo Cuatrimestre 2013 UD. expresa aceptar los terminos y condiciones del ACERDO DE LICENCIA DE SOFTWARE incluido en este paquete."
Log "¿Acepta? Si - No "
FSiNo

}
#(Paso 6) Funcion que Chequea que Perl esté instalado
function PerlInstalado {
#-x /usr/bin/perl otra forma de buscar ejecutable de perl
if [ `which "perl"` ];
then
	
declare versionmin=5
declare versioninst=`perl -v | sed -n 's/.*v\([0-9]*\)\.[0-9]*\.[0-9]*.*/\1/p'`
#busco en la primeri linea v(5.14.xx)
	if [ "$versioninst" -lt "$versionmin" ]
	then
	Log "Para instalar el TP es necesario contar con Perl 5 o superior instalado. Efectue su instalacion e intentelo nuevamente.Proceso de instalacion Cancelado."
	else
	Log "Perl Version=$versioninst"
	fi
else
	Log "No esta instalado en su maquina Perl. Instalacion finalizada."
	FIN
fi
}

#Para finalizar el script
function FIN {
exit 0
}

#(Paso 7) Funcion que define el directorio de instalación de los ejecutables
function DefinirEjecutables {
local direct
Log "Defina el directorio de instalacion de los archivos ejecutables ($BINDIR)"
Log "Desea conservar el directorio por defecto?: Si - No"
if FSiNo;
then
	Log "Proponga su directorio para los ejecutables"
	read direct
	Log "El usuario ingresó: $direct" 1> /dev/null
	direct=`echo "$direct" | sed  's#^/\(.*\)#\1#'` #saca la primer / si es que tiene
	BINDIR="$grupo/$direct"
fi
}

#(Paso 8) Funcion que define el directorio de instalación de los archivos maestros
function DefinirMaestros {
local direct
Log "Defina el directorio de instalacion de los archivos maestros ($MAEDIR)"
Log "Desea conservar el directorio por defecto?: Si - No"
if FSiNo;
then
	Log "Proponga su directorio para los archivos maestros"
	read direct
	Log "El usuario ingresó: $direct" 1> /dev/null
	direct=`echo "$direct" | sed  's#^/\(.*\)#\1#'` #saca la primer / si es que tiene
	MAEDIR="$grupo/$direct"
fi
}

#(Paso 9) Funcion que define el directorio de arribo de archivos externos
function DefinirExternos {
local direct
Log "Defina el directorio de instalacion de los archivos externos ($grupo/arribos)"
Log "Desea conservar el directorio por defecto?: Si - No"
if FSiNo;
then
	Log "Proponga su directorio para los archivos maestros"
	read direct
	Log "El usuario ingresó: $direct" 1> /dev/null
	direct=`echo "$direct" | sed  's#^/\(.*\)#\1#'` #saca la primer / si es que tiene
	ARRIDIR="$grupo/$direct" #Si supongo que me dan del estilo tp/arribos
fi
}

#(Paso 10) Funcion que define el espacio mínimo libre para el arribo de archivos externos
function EspacioMinimoArribos {
local cantidad
Log "Defina el espacio minimo libre para el arribo de archivos externos en MBYtes ($DATASIZE):"
Log "Desea conservar el Tamaño por defecto?: Si - No"
if FSiNo;
then
	while [[ $cantidad != [0-9]* ]] #leve comprovacion de que se ingresa un entero
	do
		read cantidad
		Log "El usuario ingresó: $cantidad" 1> /dev/null
	done
	DATASIZE="$cantidad"
fi
}

#(Paso 11) Funcion que verifica el espacio en disco
function ComprobarEspacio {
mkdir -p "$ARRIDIR" #parche auxiliar !!!!!!!!!!!!!!!

local espa=`df "$ARRIDIR"`
declare -i local taman=` echo $espa | sed 's#.* \([^ ]*\) [^ ]* [^ ]*$#\1#' `

if [ "$taman" -lt "$DATASIZE" ];
then
	Log "ESPACIO INSUFICIENTE POR FAVOR LIBERE ESPACIO Y VUELVA A INSTALAR"
	Log "Se necesitan $DATASIZE y se tiene $taman"
	FIN
fi
}

#(Paso 12) Funcion que define el directorio de grabación de los archivos aceptados
function DefinirAceptados {
local direct
Log "Defina el directorio de instalacion de los archivos maestros ($ACEPDIR)"
Log "Desea conservar el directorio por defecto?: Si - No"
if FSiNo;
then
	Log "Proponga su directorio para los archivos maestros"
	read direct
	Log "El usuario ingresó: $direct" 1> /dev/null
	direct=`echo "$direct" | sed  's#^/\(.*\)#\1#'` #saca la primer / si es que tiene
	ACEPDIR="$grupo/$direct" #Si supongo que me dan del estilo tp/aceptados
fi
}

#(Paso 13) Funcion que define el directorio de grabación de los archivos rechazados
function DefinirRechazados {
local direct
Log "Defina el directorio de instalacion de los archivos rechazados ($RECHDIR)"
Log "Desea conservar el directorio por defecto?: Si - No"
if FSiNo;
then
	Log "Proponga su directorio para los archivos rechazados"
	read direct
	Log "El usuario ingresó: $direct" 1> /dev/null
	direct=`echo "$direct" | sed  's#^/\(.*\)#\1#'` #saca la primer / si es que tiene
	RECHDIR="$grupo/$direct" #Si supongo que me dan del estilo tp/recha
fi
}

#(Paso 14) Funcion que define el directorio de grabación de los LISTADOS de salida
function DefinirSalida {
local direct
Log "Defina el directorio de instalacion de los listados de salida($REPODIR)"
Log "Desea conservar el directorio por defecto?: Si - No"
if FSiNo;
then
	Log "Proponga su directorio para los archivos de salida"
	read direct
	Log "El usuario ingresó: $direct" 1> /dev/null
	direct=`echo "$direct" | sed  's#^/\(.*\)#\1#'` #saca la primer / si es que tiene
	REPODIR="$grupo/$direct" #Si supongo que me dan del estilo tp/lista
fi
}

#(Paso 15) Funcion que define el directorio de trabajo principal del proceso Reservar_B
function DefinirProcesados {
local direct
Log "Defina el directorio de grabación de los archivos procesados ($PROCDIR):"
Log "Desea conservar el directorio por defecto?: Si - No"
if FSiNo;
then
	Log "Proponga su directorio para los archivos de salida"
	read direct
	Log "El usuario ingresó: $direct" 1> /dev/null
	direct=`echo "$direct" | sed  's#^/\(.*\)#\1#'` #saca la primer / si es que tiene
	PROCDIR="$grupo/$direct" #Si supongo que me dan del estilo tp/lista
fi
}

#(Paso 16) Funcion que define el directorio de logs para los comandos
function DefinirLogs {
local direct
Log "Defina el directorio de logs ($LOGDIR):"
Log "Desea conservar el directorio por defecto?: Si - No"
if FSiNo;
then
	Log "Proponga su directorio para los archivos de salida"
	read direct
	Log "El usuario ingresó: $direct" 1> /dev/null
	direct=`echo "$direct" | sed  's#^/\(.*\)#\1#'` #saca la primer / si es que tiene
	LOGDIR="$grupo/$direct" #Si supongo que me dan del estilo tp/lista
fi
}

#(Paso 18) Funcion que define el tamaño máximo para los archivos de log
function EspacioMaxLogs {
local cantidad
Log "Defina el tamaño máximo para los archivos $LOGEXT en Kbytes ($LOGSIZE):"
Log "Desea conservar el Tamaño por defecto?: Si - No"
if FSiNo;
then
	while [[ $cantidad != [0-9]* ]] #leve comprovacion de que se ingresa un entero
	do
		read cantidad
		Log "El usuario ingresó: $cantidad" 1> /dev/null
	done
	LOGSIZE="$cantidad"
fi

}

#(Paso 17) Funcion que define la extension de los archivos de log
function LogExtension {
Log "Ingrese la extension para los archivos de log: ($LOGEXT)"
Log "Desea conservar el Tamaño por defecto?: Si - No"
if FSiNo;
then
	read extension
	Log "El usuario ingresó: $extension" 1> /dev/null
	LOGEXT=$extension
fi
}

#(Paso 21.1) Funcion que crea los directorios
function InstalacionDirectorios {
mkdir -p "$BINDIR"
mkdir -p "$MAEDIR"
mkdir -p "$ARRIDIR"
mkdir -p "$RECHDIR"
mkdir -p "$ACEPDIR"
mkdir -p "$REPODIR"
mkdir -p "$PROCDIR"
mkdir -p "$LOGDIR"
}

#(Paso 21.2) Funcion que mueve los archivos maestros al directorio MAEDIR
function MoverMaestros {
Log "Instalando Archivos Maestros"

./Mover_B.sh datos/salas.mae "$MAEDIR"
./Mover_B.sh datos/obras.mae "$MAEDIR"
}

#(Paso 21.3) Funcion que mueve el archivo de disponibilidad al directorio PROCDIR
function MoverDisponibilidad {
Log "Instalando Archivo de Disponibilidad"

./Mover_B.sh datos/combos.dis "$PROCDIR"
}


#(Paso 21.4) Funcion que mueve los ejecutables y funciones  al directorio BINDIR
function MoverProgramasFunciones {
Log "Instalando Programas y Funciones"

./Mover_B.sh ./Iniciar_B.sh "$BINDIR"
./Mover_B.sh ./Grabar_L.sh "$BINDIR" '-c'
./Mover_B.sh ./Reservar_B.sh "$BINDIR"
./Mover_B.sh ./Stop_D.sh "$BINDIR"
./Mover_B.sh ./Start_D.sh "$BINDIR"
./Mover_B.sh ./Imprimir_B.pl "$BINDIR"
./Mover_B.sh ./EstaCorriendo.sh "$BINDIR"
./Mover_B.sh ./EstaInicializado.sh "$BINDIR" '-c'
./Mover_B.sh ./Recibir_B.sh "$BINDIR"

# permiso de ejecución
for file in `ls "$BINDIR"`; do
	chmod +x "$BINDIR/$file"
done

#muevo readmes
./Mover_B.sh ./Readme_Instalar "$BINDIR"
./Mover_B.sh ./Readme_Start_D "$BINDIR"
./Mover_B.sh ./Readme_Iniciar "$BINDIR"
./Mover_B.sh ./Readme_Reservar "$BINDIR"
./Mover_B.sh ./Readme_Imprimir "$BINDIR"
./Mover_B.sh ./Readme_Recibir "$BINDIR"
./Mover_B.sh ./Readme_Grabar_L "$BINDIR"
./Mover_B.sh ./Readme_Stop_D "$BINDIR"
./Mover_B.sh ./Readme_Mover_B "$BINDIR"

#muevo mover jeje
./Mover_B.sh ./Mover_B.sh "$BINDIR"
chmod +x "$BINDIR/Mover_B.sh"

}

#(Paso 21.5) Funcion que Actualiza el archivo de configuración
function ActualizarArchivos {
Log "Actualizando la configuración del sistema"

if [ -f "$Instconf" ];
then
	Log "Archivo de configuracion ya existente"
	echo -n "" > "$Instconf" && touch "$Instconf" # se trunca 

	grabarAlConf2 'GRUPO' "$grupo"
        grabarAlConf2 'CONFDIR' "$CONFDIR"
        grabarAlConf2 'BINDIR' "$BINDIR"
        grabarAlConf2 'MAEDIR' "$MAEDIR"
        grabarAlConf2 'ARRIDIR' "$ARRIDIR"
        grabarAlConf2 'ACEPDIR' "$ACEPDIR"
        grabarAlConf2 'RECHDIR' "$RECHDIR"
	grabarAlConf2 'REPODIR' "$REPODIR"
	grabarAlConf2 'PROCDIR' "$PROCDIR"
        grabarAlConf2 'LOGDIR' "$LOGDIR"
        grabarAlConf2 'LOGEXT' "$LOGEXT"
 	grabarAlConf2 'DATASIZE' "$DATASIZE"
        grabarAlConf2 'LOGSIZE' "$LOGSIZE"

else
	touch "$Instconf"
	grabarAlConf2 'GRUPO' "$grupo"
        grabarAlConf2 'CONFDIR' "$CONFDIR"
        grabarAlConf2 'BINDIR' "$BINDIR"
        grabarAlConf2 'MAEDIR' "$MAEDIR"
        grabarAlConf2 'ARRIDIR' "$ARRIDIR"
        grabarAlConf2 'ACEPDIR' "$ACEPDIR"
        grabarAlConf2 'RECHDIR' "$RECHDIR"
	grabarAlConf2 'REPODIR' "$REPODIR"
	grabarAlConf2 'PROCDIR' "$PROCDIR"
        grabarAlConf2 'LOGDIR' "$LOGDIR"
        grabarAlConf2 'LOGEXT' "$LOGEXT"
 	grabarAlConf2 'DATASIZE' "$DATASIZE"
        grabarAlConf2 'LOGSIZE' "$LOGSIZE"
fi
}

#INICIO DE EJECUCION-----------------------------------------------------------
#Aplico permisos de ejecucion
chmod +x './Mover_B.sh'
chmod +x './Grabar_L.sh'
chmod +x './EstaInicializado.sh'
#Cargo a las variables los parametros default
ParametrosDefault

# Paso 1, 2 y 3
mkdir -p "$CONFDIR"
#Se crea el directorio para bakcup
mkdir -p "$CONFDIR/backup"

#Paso 4.
if [ -f "$Instconf" ];
then 
	cp "$CONFDIR/backup/Grabar_L.sh" './'
	cp "$CONFDIR/backup/EstaInicializado.sh" './'
	InicioLogInstalacion
	CargarDelConf
	Log "instalacion incompleta o ya hecha"
	ReInstalar
	Log "borrando archivos temporarios"
	rm 'Grabar_L.sh'
	rm 'EstaInicializado.sh'
	FIN
else 
	InicioLogInstalacion
	temp="$LOGDIR"
	LOGDIR="$backup"
	backup
	LOGDIR="$temp"
	Log "Instalacion por primera vez"
fi

#Paso 5
if AceptaTerminos;
then 
	Log "USUARIO RECHAZO TERMINOS"
	FIN
else 
	Log "USUARIO ACEPTO TERMINOS"
fi

#Paso 6
PerlInstalado

#NOTA: se que queda medio sucio poner esta funcion aca pero creo que se ve mas "secuencial" la instalacion si la dejo aca
function Definiciones {
#Paso7: Definir el directorio de instalación de los ejecutables
DefinirEjecutables

#Paso 8: Definir el directorio de instalación de los archivos maestros
DefinirMaestros

#Paso 9: Definir el directorio de arribo de archivos externos
DefinirExternos

#Paso 10: Definir el espacio mínimo libre para el arribo de archivos externos
EspacioMinimoArribos

#Paso 11: Verificar espacio en disco 
ComprobarEspacio

#Paso 12: Definir el directorio de grabación de los archivos aceptados
DefinirAceptados

#Paso 13: Definir el directorio de grabación de los archivos rechazados
DefinirRechazados

#Paso 14: Definir el directorio de grabación de los LISTADOS de salida
DefinirSalida

#Paso 15: Definir el directorio de trabajo principal del proceso Reservar_B
DefinirProcesados

#Paso 16: Definir el directorio de logs para los comandos
DefinirLogs

#Paso 17: Definir la extensión para los archivos de log
LogExtension

#Paso 18: Definir el tamaño máximo para los archivos de log
EspacioMaxLogs

#Paso 19: Mostrar estructura de directorios resultante y valores de parámetros configurados
MostrarMensajeEstado ' LISTO'

Log "Desea continuar con la instalacion?: Si - No"
if FSiNo;
then
	clear
	Definiciones	
fi
}
Definiciones

#Paso 20: Confirmar Inicio de Instalación
Log "Iniciando Instalación. Esta Ud. seguro? (Si-No)"
if FSiNo;
then
	FIN
fi

#Paso 21: Instalacion
Log "Creando Estructuras de directorio ..."
InstalacionDirectorios
MoverMaestros 
MoverDisponibilidad 
MoverProgramasFunciones 

#Actualizacion del archivo de configuracion
ActualizarArchivos

#Paso 22: Borrar archivos temporarios, si los hubiese generado
Log "borrando archivos temporarios"
rm 'Grabar_L.sh'
rm 'EstaInicializado.sh'

#Paso 23: Mostrar mensaje de fin de instalación
echo "Instalación SATISFACTORIAMENTE CONCLUIDA"

#Paso 24: FIN
FIN
#the fuking end yeahh !!!

