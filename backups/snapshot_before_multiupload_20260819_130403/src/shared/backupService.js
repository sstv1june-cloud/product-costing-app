export const createSystemBackup = () => {
  const backupPayload = {
    version: "2.0",
    timestamp: new Date().toISOString(),
    formattedDate: new Date().toLocaleString(),
    data: {
      vendors: localStorage.getItem('cpc_vendors') ? JSON.parse(localStorage.getItem('cpc_vendors')) : null,
      baselineProducts: localStorage.getItem('cpc_baseline_products') ? JSON.parse(localStorage.getItem('cpc_baseline_products')) : null,
      rmMatrix: localStorage.getItem('cpc_rm_matrix') ? JSON.parse(localStorage.getItem('cpc_rm_matrix')) : null,
      mbMatrix: localStorage.getItem('cpc_mb_matrix') ? JSON.parse(localStorage.getItem('cpc_mb_matrix')) : null,
      salesRecords: localStorage.getItem('cpc_sales_records') ? JSON.parse(localStorage.getItem('cpc_sales_records')) : null
    }
  };

  const dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(backupPayload, null, 2));
  const downloadAnchor = document.createElement('a');
  downloadAnchor.setAttribute("href", dataStr);
  const fileName = `CPC_System_Backup_${new Date().toISOString().slice(0, 10)}.json`;
  downloadAnchor.setAttribute("download", fileName);
  document.body.appendChild(downloadAnchor);
  downloadAnchor.click();
  downloadAnchor.remove();
  return fileName;
};

export const restoreSystemBackup = (jsonString) => {
  try {
    const parsed = JSON.parse(jsonString);
    if (!parsed || !parsed.data) throw new Error("Invalid backup payload");
    const { vendors, baselineProducts, rmMatrix, mbMatrix, salesRecords } = parsed.data;
    if (vendors) localStorage.setItem('cpc_vendors', JSON.stringify(vendors));
    if (baselineProducts) localStorage.setItem('cpc_baseline_products', JSON.stringify(baselineProducts));
    if (rmMatrix) localStorage.setItem('cpc_rm_matrix', JSON.stringify(rmMatrix));
    if (mbMatrix) localStorage.setItem('cpc_mb_matrix', JSON.stringify(mbMatrix));
    if (salesRecords) localStorage.setItem('cpc_sales_records', JSON.stringify(salesRecords));
    return { success: true };
  } catch (err) {
    return { success: false, error: err.message };
  }
};
