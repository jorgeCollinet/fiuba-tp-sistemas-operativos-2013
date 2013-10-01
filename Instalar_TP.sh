#!/bin/bash
#Script que se encarga de la instalacion del TP.
# Ver el readme para mas informacion.
#	COMANDO: Instalar_TP.sh
#------------------------------------------------------------

#Variables de mi script
usuario='whoami'
ruta_usuario="/home/$usuario"
grupo="./grupo8" #deberia ser el directorio creado para el grupo8 a mano
CONFDIR="$grupo/conf" 
Instlog="$CONFDIR/Instalar_TP$LOGEXT" #ruta a el log del script
estado="COMPLETO" #variable para controlar el estado de la instalacion
DATASIZE=100 #variable para el tamaño en MB de los arribos
LOGEXT=".log" #extension por defecto de los archivos de log
COMANDO="Instalar_Tp" #comando de mi script


mkdir -p "$CONFDIR" #creo el directorio ./grupo8/conf 


#Por defecto asumo estos directorios 
function DirectoriosDefault {

BINDIR="$grupo/bin"
MAEDIR="$grupo/mae"
ARRIDIR="$grupo/arribos"
ACEPDIR="$grupo/aceptados"
RECHDIR="$grupo/rechazados"
REPODIR="$grupo/listados"
PROCDIR="$grupo/procesados"
LOGDIR="$grupo/log"

}



#Para finalizar mi script
function FIN {
exit
}


function InstalacionHecha {

cantcarpetas= ls -1 $grupo | wc -l

if [ "$cantcarpetas" == 1 ]
then
echo "Nunca se instalo nada en el sistema"
else
echo "Instalacion incompleta"
fi

}

InstalacionHecha

# Paso 1, 2 y 3
# Funcion que inicia el log. Lo crea si no estaba.

function InicioLogInstalacion {
if [ -f "$Instlog" ];
then
echo "Existe "$Instlog""
else
touch "$Instlog" #aca hay que darle permisos de escritura??VER
fi

echo "Inicio de Ejecución" 
echo "Log del comando Instalar_TP:$Instlog"
echo "DIrectorio de configuracion:$CONFDIR"
# aca se debe grabar en el log tambien, con la funcion grabar
}



#Paso 4. FALTA (comprobacion de el paquete este todo instalado)



# Paso 4.1
# Muestra el estado del sistema. Llamar si esta completo el paquete.

function MostrarMensajeInicial {
echo "TP SO7508 Segundo Cuatrimestre 2013. Tema B Copyright Grupo 08"
echo "Libreria del Sistema: $CONFDIR"
ls "$CONFDIR"
echo "Ejecutables:$BINDIR"
ls "$BINDIR"
echo "Archivos Maestros: $MAEDIR"
ls "$MAEDIR"
echo "Directorio de arribo de archivos externos: $ARRIDIR"
ls "$ARRIDIR"
echo "Archivos externos aceptados: $ACEPDIR"
ls "$ACEPDIR"
echo "Archivos externos rechazados: $RECHDIR"
ls "$RECHDIR"
echo " Reportes de salida:$REPODIR"
ls "$REPODIR"
echo "Archivos procesados:$PROCDIR"
ls "$PROCDIR"
echo "Logs de aditoria del Sistema:$LOGDIR/<$COMANDO>.$LOGEXT"
ls "$LOGDIR"
echo "Estado de la instalacion:$estado"
echo" Proceso de Instalacion Cancelado"

#FALTA GRABAR EN EL LOG LO MISMO
}



#Paso 4.3.3 y Paso 6
#Funcion para ver si esta instalado PERL
function estaperl {
declare versionmin=5
declare versioninst=`perl -v | sed -n 's/.*v\([0-9]*\)\.[0-9]*\.[0-9]*.*/\1/p'`
#busco en la primeri linea v(5.14.xx)
if [ "$versioninst" -lt "$versionmin" ]
then 
echo "Para instalar el TP es necesario contar con Perl 5 o superior instalado. Efectue su instalacion e intentelo nuevamente.Proceso de instalacion Cancelado."
else
echo "Perl Version=$versioninst"
fi
}

estaperl

#Paso 5 Aceptacion de terminos
#Retorna 1 si acepto los terminos, 0 si no.
function AceptaTerminos {

echo "TP SO7508 Segundo Cuatrimestre 2013. Tema B Copyright Grupo 08"
echo " A T E N C I O N: Al instalar el TP SO7508 Segundo Cuatrimestre 2013 UD. expresa aceptar los terminos y condiciones del ACERDO DE LICENCIA DE SOFTWARE incluido en este paquete."

echo "¿Acepta? Si - NO "
while ["$var1" != "Si" && "$var1" != "No"]
do 
read var1
done #Hasta que no contesta si o no sale del bucle

if ["$var1" = "Si"]
then
return 1
else return 0
fi
}


# Paso 7
#funcion para definir los ejecutables 
function DefinirEjecutables {

echo "Defina el directorio de instalacion de los archivos ejecutables ($grupo/bin"
echo "Desea conservar el directorio por defecto?: Si - No"

while ["$var2" != "Si" && "$var2" != "No"]
do
read var2
done #Hasta que no contesta si o no sale del bucle

if ["$var2" = "Si"]
then
BINDIR=$BINDIR
else 
echo "Proponga su directorio para los ejecutables"
read direct
BINDIR="$grupo/$direct" #Si supongo que me dan del estilo tp/bin
fi

}

# Paso 8
# Funcion para definir el directorio de los maestros
function DefinirMaestros {

echo "Defina el directorio de instalacion de los archivos maestros ($grupo/mae)"
echo "Desea conservar el directorio por defecto?: Si - No"

while ["$var2" != "Si" && "$var2" != "No"]
do
read var2
done #Hasta que no contesta si o no sale del bucle

if ["$var2" = "Si"]
then
MAEDIR=$MAEDIR
else
echo "Proponga su directorio para los archivos maestros"
read direct
MAEDIR="$grupo/$direct" #Si supongo que me dan del estilo tp/mae
fi

}


# Paso 9
# Funcion para definir el directorio de los archivos externos
function DefinirEternos {

echo "Defina el directorio de instalacion de los archivos externos ($grupo/arribos)"
echo "Desea conservar el directorio por defecto?: Si - No"

while ["$var2" != "Si" && "$var2" != "No"]
do
read var2
done #Hasta que no contesta si o no sale del bucle

if ["$var2" = "Si"]
then
ARRIDIR=$ARRIDIR
else
echo "Proponga su directorio para los archivos maestros"
read direct
ARRIDIR="$grupo/$direct" #Si supongo que me dan del estilo tp/arribos
fi

}


# Paso 10. Pedido al usuario  espacio para directorio ARRIDIR
function EspacioMinimoArribos {

echo "Defina el espacio minimo libre para el arribo de archivos externos en MBYtes (100):"

read cantidad	#espero la orden del teclado
DATASIZE=$cantidad	#guardo en la variable datasize la cantidad pasada

}


# Paso 12
# Funcion para definir el directorio de los archivos aceptados
function DefinirAceptados {

echo "Defina el directorio de instalacion de los archivos maestros ($grupo/aceptados)"
echo "Desea conservar el directorio por defecto?: Si - No"

while ["$var2" != "Si" && "$var2" != "No"]
do
read var2
done #Hasta que no contesta si o no sale del bucle

if ["$var2" = "Si"]
then
ACEPDIR=$ACEPDIR
else
echo "Proponga su directorio para los archivos maestros"
read direct
ACEPDIR="$grupo/$direct" #Si supongo que me dan del estilo tp/aceptados
fi

}

# Paso 13
# Funcion para definir el directorio de los archivos rechazados
function DefinirRechazados {

echo "Defina el directorio de instalacion de los archivos rechazados ($grupo/rechazados)"
echo "Desea conservar el directorio por defecto?: Si - No"

while ["$var2" != "Si" && "$var2" != "No"]
do
read var2
done #Hasta que no contesta si o no sale del bucle

if ["$var2" = "Si"]
then
RECHDIR=$RECHDIR
else
echo "Proponga su directorio para los archivos rechazados"
read direct
RECHDIR="$grupo/$direct" #Si supongo que me dan del estilo tp/recha
fi

}

# Paso 14
# Funcion para definir el directorio de los listados de salida
function DefinirRechazados {

echo "Defina el directorio de instalacion de los listados de salida($grupo/listados)"
echo "Desea conservar el directorio por defecto?: Si - No"

while ["$var2" != "Si" && "$var2" != "No"]
do
read var2
done #Hasta que no contesta si o no sale del bucle

if ["$var2" = "Si"]
then
REPODIR=$REPODIR
else
echo "Proponga su directorio para los archivos de salida"
read direct
REPODIR="$grupo/$direct" #Si supongo que me dan del estilo tp/lista
fi

}



# Paso 17
# Define la extension de los archivos de log

function LogExtension {

echo "Ingrese la extension para los archivos de log: (.log)"
read extension
LOGEXT=$extension

}



# Paso 21.1
#Instalacion de los directorios

function InstalacionDirectorios {
echo "Creando Estructuras de directorio ..."
mkdir "$BINDIR"
mkdir "$MAEDIR"
mkdir "$ARRIDIR"
mkdir "$RECHDIR"
mkdir "$ACEPDIR"
mkdir "$REPODIR"
mkdir "$PROCDIR"
mkdir "$LOGDIR"


}



function EsportarVariables {

export BINDIR="$BINDIR"
export MAEDIR="$MAEDIR"
export ARRIDIR="$ARRIDIR"
export RECHDIR="$RECHDIR"
export ACEPDIR="$ACEPDIR"
export REPODIR="$REPODIR"
export PROCDIR="$PROCDIR"
export LOGDIR="$LOGDIR"
export DATASIZE="$DATASIZE"
export LOGEXT="$LOGEXT"

}




