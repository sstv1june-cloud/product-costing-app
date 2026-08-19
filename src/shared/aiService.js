// Google Gemini Live AI Caller
export const callGeminiApi = async (apiKey, prompt, contextData, language = 'en') => {
  if (!apiKey) throw new Error("No API key provided");

  const langInstruction = {
    hi: "Answer purely in clear, professional Hindi (हिन्दी).",
    mr: "Answer purely in clear, professional Marathi (मराठी).",
    gu: "Answer purely in clear, professional Gujarati (ગુજરાતી).",
    en: "Answer in professional English."
  }[language] || "Answer in professional English.";

  const systemInstruction = `You are a Senior Product Costing, Tooling, and MIS Analysis Specialist for plastic injection molding and OEM manufacturing.
You have real-time access to the user's active baseline specifications, vendor contracts, RM price matrix, shopfloor logs, and cost gap analysis.

Live System Data Snapshot:
${JSON.stringify(contextData, null, 2)}

Instructions:
1. Answer the user's query directly and accurately based on the data provided above.
2. If the user asks about general RM prices without specifying a part, list all approved raw materials with their contract rates and validity windows.
3. If they ask about cost reductions, profit reasons, or cycle times, provide specific calculations and actionable engineering steps.
4. Use rupee symbols (₹) and clean Markdown formatting (bolding, bullet points, tables).
5. ${langInstruction}`;

  const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${apiKey}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      contents: [{
        parts: [{
          text: `${systemInstruction}\n\nUser Question: ${prompt}`
        }]
      }]
    })
  });

  if (!response.ok) {
    const errorBody = await response.json();
    throw new Error(errorBody.error?.message || `API Error: ${response.status}`);
  }

  const json = await response.json();
  return json.candidates?.[0]?.content?.parts?.[0]?.text || "No response received from AI model.";
};

// Fallback translations
const TRANSLATIONS = {
  en: { title: "Executive MIS Cost Variance & Risk Analysis" },
  hi: { title: "कार्यकारी एमआईएस लागत विचलन एवं जोखिम विश्लेषण" },
  mr: { title: "कार्यकारी एमआयएस खर्च तफावत आणि जोखीम विश्लेषण" },
  gu: { title: "એક્ઝિક્યુટિવ એમઆઈએસ ખર્ચ તફાવત અને જોખમ વિશ્લેષણ" }
};

export const generateLocalAiAnalysis = (dataSnapshot, language = 'en') => {
  const lang = TRANSLATIONS[language] || TRANSLATIONS.en;
  const parts = dataSnapshot.parts || [];
  const summary = dataSnapshot.summary || {};

  const savings = [...parts].filter(p => p.costGapVariance < 0).sort((a, b) => a.costGapVariance - b.costGapVariance);
  const costlier = [...parts].filter(p => p.costGapVariance > 0).sort((a, b) => b.costGapVariance - a.costGapVariance);

  const partInsights = parts.map(p => ({
    itemCode: p.itemCode,
    componentName: p.componentName,
    variance: p.costGapVariance,
    explanation: p.rmRateDiff !== 0 
      ? `Alternate RM (${p.activeAltRm}) rate ₹${p.altRmRate}/kg (${p.rmRateDiff < 0 ? 'saving' : 'increase'} of ₹${Math.abs(p.rmRateDiff)}/kg vs approved ₹${p.approvedRmRate}/kg).`
      : "Operating exactly on contract baseline specifications."
  }));

  return {
    headers: lang,
    summaryNarrative: `Evaluated ${summary.totalParts} components across vendor baseline parameters. Net portfolio shows a variance of ₹${summary.overallPortfolioVariance}/set.`,
    topSavings: savings.slice(0, 5),
    topRisks: costlier.slice(0, 5),
    partInsights
  };
};

export const generateContextualAnswer = (query, contextData) => {
  const q = query.toLowerCase();
  const parts = contextData.parts || [];

  if (q.includes("approved") && (q.includes("price") || q.includes("rm") || q.includes("material") || q.includes("rate"))) {
    return `### 📋 Approved Raw Material Contract Rates\n\n` +
      parts.map(p => `* **${p.approvedRm}** (\`${p.itemCode}\` - ${p.componentName}): **₹${p.approvedRmRate}/kg** (Vendor: ${p.vendor})`).join('\n') +
      `\n\n*To enable unrestricted natural conversation, paste a free Gemini API key above.*`;
  }

  return `### 🏭 Manufacturing Costing Summary\n\n` +
    `* **Tracked Components**: ${contextData.summary.totalParts}\n` +
    `* **Portfolio Net Variance**: ₹${contextData.summary.overallPortfolioVariance} / set\n\n` +
    `*Tip: Connect your free Gemini API key using the top button to ask open-ended questions in any format.*`;
};