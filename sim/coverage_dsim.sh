#!/bin/bash
# Script to generate Coverage HTML files

#Acá se debe especificar la ruta a su directorio de trabajo

SIM_HOME="$HOME/Documents/UCR/2024/Verif/verif_darkrisc (copy)_com_to_m2/sim"
#SIM_HOME="$HOME/Desktop/Project_Dsim/darkrisc_tropical_cr/sim"
#SIM_HOME="$HOME/Desktop/Project_Dsim/darkrisc_tropical_cr/sim"
#SIM_HOME="$HOME/Desktop/Project_Dsim/darkrisc_tropical_cr/sim"
#SIM_HOME="$HOME/Desktop/Project_Dsim/darkrisc_tropical_cr/sim"

SIM_DIR="$SIM_HOME"
#METRICS_DB="$SIM_DIR/metrics.db"

#Para abrir una base de datos diferente solo cambiar el nombre con la base de datos que quiere ver

METRICS_DB="$SIM_DIR/metrics_U.db"
OUT_DIR="$SIM_DIR/dir"
INDEX_HTML="$OUT_DIR/index.html"

# Se debe exportar al PATH los ejecutables de dsim: Ejemplo:
# export PATH=$PATH:/home/ricardo/metrics-ca/dsim/20240422.0.0/bin

# Commands to generate coverage html files
echo "Creating Coverage HTML Files"
rm -r "$OUT_DIR"
dcreport -out_dir "$OUT_DIR" "$METRICS_DB"
open "$INDEX_HTML"

#Forma alternativa abrir en la carpeta sim los directorios de cada simulación guardadas en html