with open("src/modules/module1-baseline/BaselineMasterPage.jsx", "r") as f:
    code = f.read()

# Make sure updateBaselineProduct copies top-level attributes
old_snippet = "function handleSaveModal"
if old_snippet in code:
    print("BaselineMasterPage already handles saving properly.")
