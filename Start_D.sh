#START_D
#Procedimiento en bash para el iniciar procesos.
#Parametros de ejecucion: "Start_D comandoAEjecutar comandoSolicitante". El segundo parametro es opcional.
#Bugs conocidos:

# ----------------------------------
#!/bin/bash
#Chequeamos los parametros:
	if [ $# -lt 1 -o $# -gt 2 ]; then
		echo -e "Invocacion incorrecta. \n\tLa manera correcta es: \n\tStart_D comandoAEjecutar comandoSolicitante"
		#Invocar al Log
		exit -1
	fi
	programaInvocado=`echo ${1##*/}`
	ejecuciones=`ps -e | grep "$programaInvocado$" | sed '/./!d' | wc -l`
	if [ ${ejecuciones:-0} -eq 0 ]; then
		#No esta en ejecucion.
		#Aqui entra toda la logica siguiente.
		#echo $ejecuciones
		$1& 2> /dev/null > /dev/null
	else 
		#Avisar al Log que no se puede ejecutar nada
		echo "El proceso ya se encuentra en ejecución."
		exit 0
	fi
	exit 0