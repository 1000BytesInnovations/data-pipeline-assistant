# GitHub Copilot Compliance Guide for ODI to dbt Conversion

## 🎯 How to Ensure Copilot Follows the Methodology Strictly

### **1. Reference the Prompt Consistently**
Always include this instruction when working with ODI to dbt conversions:

```
Please follow the ODI_to_DBT_Conversion_Prompt.md methodology EXACTLY. Complete all validation checkpoints before proceeding.
```

### **2. Use Enforcement Keywords**
When interacting with Copilot, use these specific phrases to trigger compliance:

**For Starting Conversions:**
- "Complete the mandatory validation checklist first"
- "Follow the 5-phase execution protocol"
- "Do not skip any validation checkpoints"

**For Preventing Shortcuts:**
- "Do not create placeholder models"
- "Decompose this complex ODI package into multiple models"
- "Ask for missing dependencies instead of assuming"

**For Ensuring Testing:**
- "Execute DDL before testing incremental models"
- "Test models in dependency order"
- "Complete the final compliance verification"

### **3. Monitor for Compliance Violations**
Watch for these red flags that indicate Copilot is not following the methodology:

🚫 **VIOLATION INDICATORS:**
- Creating a single large model for complex ODI packages
- Proceeding without asking for schema confirmations
- Creating models without DDL execution
- Making assumptions about missing tables/views
- Skipping the validation checklists

### **4. Intervention Strategies**
If you notice violations, use these correction phrases:

**For Model Decomposition Issues:**
```
"Stop. This ODI package is complex and must be decomposed into multiple models or macros. Complete the decomposition validation checklist first."
```

**For Missing Dependencies:**
```
"Stop. Do not create placeholder models. Ask for the actual logic for [TABLE_NAME] before proceeding."
```

**For Schema Assumptions:**
```
"Stop. Do not assume schemas from the ODI SQL. Ask for explicit schema confirmation for all source tables."
```

**For Testing Issues:**
```
"Stop. DDL must be executed before testing incremental models. Create the DDL files first."
```

### **5. Quality Gates**
Use these checkpoints to ensure compliance:

**After Analysis Phase:**
```
"Have you completed all 4 validation checklists? Show me the checklist results before proceeding."
```

**Before Implementation:**
```
"Show me your model decomposition plan. How many staging, intermediate, and final models will you create?"
```

**Before Testing:**
```
"Confirm that DDL has been executed for all incremental models before running dbt commands."
```

**Before Completion:**
```
"Complete the final compliance verification checklist and show me the results."
```

### **6. Prompt Reinforcement Strategies**

#### **Option A: Direct Reference**
```
Using the ODI_to_DBT_Conversion_Prompt.md file in this workspace, convert this ODI package to dbt models. Follow ALL validation checkpoints.
```

#### **Option B: Phase-by-Phase Approach**
```
Phase 1: Complete the analysis and validation checklists from ODI_to_DBT_Conversion_Prompt.md
Phase 2: Ask for all required team consultations
Phase 3: Create DDL files and confirm execution
Phase 4: Implement models in dependency order
Phase 5: Test and validate all models
```

#### **Option C: Rule Enforcement**
```
Apply these non-negotiable rules from ODI_to_DBT_Conversion_Prompt.md:
1. Execute DDL before testing incremental models
2. Decompose complex packages into multiple models
3. Ask for missing dependencies - never create placeholders
4. Confirm all source schemas explicitly
```

### **7. Success Verification**
Use this final check to confirm Copilot followed the methodology:

```
"Show me the final compliance verification checklist with all items marked as completed. Provide the success declaration format with actual deliverables listed."
```

## **🔧 Troubleshooting Non-Compliance**

### **If Copilot Skips Validation:**
```
"You skipped the mandatory validation checkpoint. Go back and complete Section 🔍 MANDATORY VALIDATION CHECKPOINT from the ODI_to_DBT_Conversion_Prompt.md"
```

### **If Copilot Creates Monolithic Models:**
```
"This violates Rule #2. Decompose this into separate staging, intermediate, and final models as required by the methodology."
```

### **If Copilot Makes Assumptions:**
```
"This violates multiple rules. Ask the team for explicit confirmation of [specific missing information] before proceeding."
```

### **If Copilot Skips Testing:**
```
"This violates the mandatory execution protocol. Execute DDL first, then test models in dependency order as specified in Phase 3 and 4."
```

## **📋 Quick Reference Commands**

### **Start Conversion:**
```
"Convert this ODI package following ODI_to_DBT_Conversion_Prompt.md. Start with the mandatory validation checkpoint."
```

### **Check Compliance:**
```
"Show me which validation checkpoints you've completed and which team confirmations you need."
```

### **Enforce Decomposition:**
```
"This ODI package has [X] interfaces. Create separate models for each following the decomposition strategy."
```

### **Verify Completion:**
```
"Complete the final compliance verification and provide the success declaration with all deliverables listed."
```

By using these strategies, you can ensure that GitHub Copilot strictly follows the ODI to dbt conversion methodology and delivers high-quality, compliant results.
