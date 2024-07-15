#!/bin/bash
# Script to generate Coverage HTML files

# SIM_HOME="$HOME/Documents/UCR/2024/Verif/verif_darkrisc (copy)_com_to_m2/sim"
SIM_HOME="$HOME/Desktop/Project_Dsim/darkrisc_tropical_cr/sim"
#SIM_HOME="$HOME/Desktop/Project_Dsim/darkrisc_tropical_cr/sim"
#SIM_HOME="$HOME/Desktop/Project_Dsim/darkrisc_tropical_cr/sim"
#SIM_HOME="$HOME/Desktop/Project_Dsim/darkrisc_tropical_cr/sim"

SIM_DIR="$SIM_HOME"
METRICS_DB="$SIM_DIR/metrics.db"
OUT_DIR="$SIM_DIR/dir"
INDEX_HTML="$OUT_DIR/index.html"

# Commands to generate coverage html files
echo "Creating Coverage HTML Files"
rm -r "$OUT_DIR"
dcreport -out_dir "$OUT_DIR" "$METRICS_DB"
open "$INDEX_HTML"