with open("src/modules/module1-baseline/BaselineMasterPage.jsx", "r") as f:
    content = f.read()

# Replace Haier parser loop bindings
old_parser_snippet = """let bopCostVal = 0.00;
          let packingCostVal = 0.86;
          let transportCostVal = 0.62;"""

new_parser_snippet = """let bopCostVal = 0.00;
          let packingCostVal = 0.86;
          let transportCostVal = 0.62;
          let haierOhPackageVal = 5.15;"""

content = content.replace(old_parser_snippet, new_parser_snippet)

old_check_lines = """} else if (desc === 'inserts/bop cost' || desc === 'insert / hinge hole cap cost / other cost' || (desc.includes('insert') && !desc.includes('rm + bop'))) {
              if (isValidNum) bopCostVal = numVal;
            }"""

new_check_lines = """} else if (desc === 'inserts/bop cost' || desc === 'insert / hinge hole cap cost / other cost' || (desc.includes('insert') && !desc.includes('rm + bop'))) {
              if (isValidNum) bopCostVal = numVal;
            } else if (snVal === "24" || desc.includes('foam/polybag') || desc.includes('polyenda') || (desc.includes('oh+profit') && desc.includes('freight'))) {
              if (isValidNum) haierOhPackageVal = numVal;
            }"""

content = content.replace(old_check_lines, new_check_lines)

# Bind haierOhPackage to staged product
content = content.replace("bopCost: bopCostVal,", "bopCost: bopCostVal,\n            haierOverheadPackage: haierOhPackageVal,")
content = content.replace("runningBopCost: bopCostVal,", "runningBopCost: bopCostVal,\n              runningHaierOverheadPackage: haierOhPackageVal,")

with open("src/modules/module1-baseline/BaselineMasterPage.jsx", "w") as f:
    f.write(content)
print("BaselineMasterPage.jsx parser updated for Line 24 Overhead Package!")
