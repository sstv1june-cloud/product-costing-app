with open("src/shared/costCalculationService.js", "r") as f:
    content = f.read()

haier_calc_func = """
export function calculateHaierCost({
  cavity = 2,
  netWeight = 197,
  runnerWeight = 40,
  rmRate = 136.20,
  masterbatchPct = 0,
  masterbatchRate = 250,
  machineTonnage = 450,
  shiftTariff = 3600,
  cycleTime = 56,
  bopCost = 0.14,
  haierOverheadPackage = 5.15
}) {
  const cav = Number(cavity) || 2;
  const net = Number(netWeight) || 197;
  const run = Number(runnerWeight) || 40;
  const shot = (net * cav) + run;
  
  // Exact Excel formula: Reconciliation Weight = (Net Weight * 1%) + Net Weight
  const reconcilWt = net * 1.01;
  const mbFrac = Number(masterbatchPct || 0) / 100.0;
  
  const rmMatCost = (reconcilWt / 1000.0) * (Number(rmRate || 0) * (1.0 - mbFrac));
  const mbMatCost = (reconcilWt / 1000.0) * (Number(masterbatchRate || 0) * mbFrac);
  const runnerRecov = -1.36;
  const totRmCost = rmMatCost + mbMatCost + runnerRecov;

  const ct = Number(cycleTime) || 56;
  const shotsShift = 28800.0 / (ct > 0 ? ct : 1);
  const shotsEff = shotsShift * 0.95;
  const compShift = shotsEff * cav;
  const prodCostPc = compShift > 0 ? (Number(shiftTariff || 3600) / compShift) : 0;
  const subTotal = totRmCost + prodCostPc;

  const ohPkg = Number(haierOverheadPackage !== undefined ? haierOverheadPackage : 5.15);
  const bop = Number(bopCost || 0.14);
  const iccReduce = -0.13;
  const scrapAdj = -1.36;
  const totalCost = subTotal + ohPkg + bop + iccReduce + scrapAdj;

  return {
    shotWeight: shot,
    reconciliationWeight: reconcilWt,
    rmMatCost,
    mbMatCost,
    totalRawMaterialCost: totRmCost,
    productionCostPerPc: prodCostPc,
    subTotal,
    overheadPackage: ohPkg,
    totalCost: Number(totalCost.toFixed(2))
  };
}
"""

import re
pattern = r"export function calculateHaierCost[\s\S]*?totalCost:\s*Number\(totalCost\.toFixed\(2\)\)\s*\};\s*\}"
if re.search(pattern, content):
    content = re.sub(pattern, haier_calc_func.strip(), content)
else:
    content += "\n" + haier_calc_func

with open("src/shared/costCalculationService.js", "w") as f:
    f.write(content)
print("costCalculationService.js updated with exact Reconciliation Weight and Overhead Package formulas!")
