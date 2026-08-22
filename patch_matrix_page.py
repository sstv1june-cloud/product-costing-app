with open("src/modules/module2-rm-matrix/RMPriceMatrixPage.jsx", "r") as f:
    content = f.read()

# Replace Alternate dropdown handlers with automatic WA calculation
old_alt1_handler = """onChange={e => updateRmMappingRow(mat.id, { alt1Code: e.target.value })}"""
new_alt1_handler = """onChange={e => {
                            const chosenGrade = e.target.value;
                            import('../../shared/masterStore').then(({ computeGradeWeightedAverage }) => {
                              const autoWa = computeGradeWeightedAverage(chosenGrade);
                              updateRmMappingRow(mat.id, { 
                                alt1Code: chosenGrade,
                                alt1Price: autoWa > 0 ? autoWa : (mat.approvedPrice || 0)
                              });
                            });
                          }}"""

old_alt2_handler = """onChange={e => updateRmMappingRow(mat.id, { alt2Code: e.target.value })}"""
new_alt2_handler = """onChange={e => {
                            const chosenGrade = e.target.value;
                            import('../../shared/masterStore').then(({ computeGradeWeightedAverage }) => {
                              const autoWa = computeGradeWeightedAverage(chosenGrade);
                              updateRmMappingRow(mat.id, { 
                                alt2Code: chosenGrade,
                                alt2Price: autoWa
                              });
                            });
                          }}"""

old_alt3_handler = """onChange={e => updateRmMappingRow(mat.id, { alt3Code: e.target.value })}"""
new_alt3_handler = """onChange={e => {
                            const chosenGrade = e.target.value;
                            import('../../shared/masterStore').then(({ computeGradeWeightedAverage }) => {
                              const autoWa = computeGradeWeightedAverage(chosenGrade);
                              updateRmMappingRow(mat.id, { 
                                alt3Code: chosenGrade,
                                alt3Price: autoWa
                              });
                            });
                          }}"""

content = content.replace(old_alt1_handler, new_alt1_handler)
content = content.replace(old_alt2_handler, new_alt2_handler)
content = content.replace(old_alt3_handler, new_alt3_handler)

with open("src/modules/module2-rm-matrix/RMPriceMatrixPage.jsx", "w") as f:
    f.write(content)
print("RMPriceMatrixPage.jsx patched with automatic purchase WA calculator on alternate selection!")
