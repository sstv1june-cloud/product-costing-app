with open("src/modules/module1-baseline/BaselineMasterPage.jsx", "r") as f:
    content = f.read()

old_start = "const handleFileUpload = (e) => {"
upload_idx = content.find(old_start)

if upload_idx != -1:
    end_fn_idx = content.find("const updateStagedParam", upload_idx)
    if end_fn_idx == -1:
        end_fn_idx = content.find("const confirmStagingImport", upload_idx)

    new_upload_fn = """const handleFileUpload = (e) => {
    const file = e.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (evt) => {
      try {
        const bstr = evt.target.result;
        const workbook = XLSX.read(bstr, { type: 'binary' });
        const wsname = workbook.SheetNames[0];
        const ws = workbook.Sheets[wsname];
        const data = XLSX.utils.sheet_to_json(ws, { header: 1 });

        if (!data || data.length < 5) {
          alert("Invalid or empty Excel template format.");
          return;
        }

        const headerRow = data[0];
        const parsedProducts = [];

        for (let colIdx = 3; colIdx < headerRow.length; colIdx++) {
          const compName = headerRow[colIdx];
          if (!compName || compName.toString().trim() === "") continue;

          let itemCode = `ITEM-${Math.floor(10000 + Math.random() * 90000)}`;
          let model = "Standard Model";
          let rmGrade = selectedVendor.toLowerCase().includes('haier') ? "ABS 300 Pre Colour" : "PP H110MA";
          let mbPct = selectedVendor.toLowerCase().includes('haier') ? 0.0 : 4.0;
          let cavity = 2;
          let runnerWt = selectedVendor.toLowerCase().includes('haier') ? 40 : 1;
          let netWt = selectedVendor.toLowerCase().includes('haier') ? 197 : 37;
          let cycleTime = selectedVendor.toLowerCase().includes('haier') ? 56 : 47;
          let tonnage = selectedVendor.toLowerCase().includes('haier') ? 450 : 200;
          let shiftRateVal = selectedVendor.toLowerCase().includes('haier') ? 4600 : 2000;
          let bopCostVal = 0.00;
          let packingCostVal = 0.86;
          let transportCostVal = 0.62;

          let parsedLine34 = null;
          let parsedLine35 = null;
          let parsedLine36 = null;

          for (let rowIdx = 1; rowIdx < data.length; rowIdx++) {
            const row = data[rowIdx];
            if (!row || row.length === 0) continue;
            
            const snVal = (row[0] || "").toString().trim();
            const desc = (row[1] || "").toString().trim().toLowerCase();
            const val = row[colIdx];
            const numVal = Number(val);
            const isValidNum = val !== undefined && val !== null && val !== "" && !isNaN(numVal);

            if (desc.includes('item no') || desc.includes('part code')) {
              if (val) itemCode = val.toString().trim();
            } else if (desc.includes('model')) {
              if (val) model = val.toString().trim();
            } else if (desc.includes('raw material required') || desc.includes('rm grade')) {
              if (val) rmGrade = val.toString().trim();
            } else if (desc === 'master batch required (%)' || desc === 'mb %' || desc.includes('master batch required')) {
              if (isValidNum) mbPct = numVal > 0 && numVal < 1 ? numVal * 100 : numVal;
            } else if (desc.includes('cavity')) {
              if (isValidNum) cavity = numVal;
            } else if (desc.includes('runner weight')) {
              if (isValidNum) runnerWt = numVal;
            } else if (desc.includes('net weight') || desc.includes('part weight')) {
              if (isValidNum) netWt = numVal;
            } else if (desc.includes('cycle time')) {
              if (isValidNum) cycleTime = numVal;
            } else if (desc.includes('machine used') || desc.includes('m/c tonnage')) {
              if (isValidNum) tonnage = numVal;
            } else if (desc.includes('shift rate') || desc.includes('machine tariff') || desc.includes('machine trariff')) {
              if (isValidNum) shiftRateVal = numVal;
            } else if (desc === 'inserts/bop cost' || desc === 'insert / hinge hole cap cost / other cost' || (desc.includes('insert') && !desc.includes('rm + bop'))) {
              if (isValidNum) bopCostVal = numVal;
            } 
            
            // Capture specific lines 34, 35, 36
            if (snVal === "34" || desc === "packing cost") {
              if (isValidNum) parsedLine34 = numVal;
            } else if (snVal === "35" || desc === "transport cost" || desc === "transpost cost") {
              if (isValidNum) parsedLine35 = numVal;
            } else if (snVal === "36" || desc === "mould maintenance cost") {
              if (isValidNum) parsedLine36 = numVal;
            }
          }

          // Handle layout in Atomberg sheet where Packing=0.86 and Transport=0.62 are placed at Lines 35 & 36
          if (parsedLine34 === 0 && parsedLine35 === 0.86 && parsedLine36 === 0.62) {
            packingCostVal = 0.86;
            transportCostVal = 0.62;
          } else {
            if (parsedLine34 !== null) packingCostVal = parsedLine34;
            if (parsedLine35 !== null) transportCostVal = parsedLine35;
          }

          parsedProducts.push({
            id: `staged-${Date.now()}-${colIdx}`,
            vendor: selectedVendor,
            itemCode,
            componentName: compName.toString().trim(),
            model,
            approvedRm: rmGrade,
            masterbatchPct: mbPct,
            cavity,
            runnerWeight: runnerWt,
            netWeight: netWt,
            cycleTimeApproved: cycleTime,
            cycleTime: cycleTime,
            machineTonnage: tonnage,
            shiftTariff: shiftRateVal,
            shiftRate: shiftRateVal,
            bopCost: bopCostVal,
            packingCost: packingCostVal,
            transportCost: transportCostVal,
            parameters: {
              runningNetWeight: netWt,
              runningRunnerWeight: runnerWt,
              runningMbPct: mbPct,
              runningBopCost: bopCostVal,
              runningPackingCost: packingCostVal,
              runningTransportCost: transportCostVal,
              runningCycleTime: cycleTime,
              runningCavity: cavity,
              runningTonnage: tonnage,
              runningShiftTariff: shiftRateVal
            }
          });
        }

        if (parsedProducts.length === 0) {
          alert("No valid products found in the uploaded file columns.");
          return;
        }

        setStagedData(parsedProducts);
        setSelectedStagedIdx(0);
        setShowStagingModal(true);
      } catch (err) {
        console.error(err);
        alert("Error parsing uploaded Excel file.");
      }
    };
    reader.readAsBinaryString(file);
    e.target.value = null;
  };

  """
    content = content[:upload_idx] + new_upload_fn + content[end_fn_idx:]
    with open("src/modules/module1-baseline/BaselineMasterPage.jsx", "w") as f:
        f.write(content)
    print("BaselineMasterPage.jsx parser patched!")
