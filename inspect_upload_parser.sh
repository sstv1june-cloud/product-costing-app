#!/usr/bin/env bash
set -e

echo "================================================================="
echo "1. LOCATING EXCEL IMPORT PARSER IN BASELINE MODULE:"
echo "================================================================="
grep -rn "readAsArrayBuffer\|readAsBinaryString\|XLSX.read" src/ || true

echo "================================================================="
echo "2. PARSER LOGIC IN BaselineMasterPage.jsx / StagingModal.jsx:"
echo "================================================================="
grep -A 40 -B 10 "handleFileUpload" src/modules/module1-baseline/BaselineMasterPage.jsx || grep -A 40 -B 10 "onDrop" src/modules/module1-baseline/BaselineMasterPage.jsx || true

echo "================================================================="
echo "3. HOW STAGED OBJECTS ARE MAPPED ON IMPORT:"
echo "================================================================="
grep -A 35 "bopCost" src/modules/module1-baseline/BaselineMasterPage.jsx || grep -A 35 "bopCost" src/modules/module1-baseline/StagingModal.jsx || true
