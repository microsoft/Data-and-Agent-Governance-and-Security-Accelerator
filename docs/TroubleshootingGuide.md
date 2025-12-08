# Troubleshooting Guide

Use this guide to resolve common issues when running the Data Agent Governance and Security Accelerator.

---

## Quick Fixes for New Users

| Symptom | Quick Fix |
|---------|-----------|
| \"Connect-AzAccount\" prompts for login during azd up | Run `az login`, `azd auth login`, `Connect-AzAccount`, and `Set-AzContext` in same terminal before `azd up` |
| \"spec.local.json not found\" | Run `Copy-Item ./spec.dspm.template.json ./spec.local.json` and populate values |
| \"Cannot find property 'tenantId'\" | Your spec.local.json has invalid JSON syntax - validate with `Get-Content ./spec.local.json | ConvertFrom-Json` |
| Scripts skip with \"No X configured\" | The corresponding spec section is empty/missing - this is OK if you don't need that feature |
| \"Authorization denied\" on audit exports | You need Audit Reader or Compliance Administrator role in Purview |
| Exchange Online commands fail | Run `m365` tag from desktop with MFA, not from containers/Codespaces |

---

## Detailed Troubleshooting

### 1. Post-provision hook re-prompts for login
- **Symptoms:** `Connect-AzAccount` opens a browser during `azd up` or fails with `InteractiveBrowserCredential` errors.
- **Fix:** Ensure you ran `az login`, `azd auth login`, `Connect-AzAccount -Tenant ... -Subscription ...`, and `Set-AzContext` in the same terminal before invoking `azd up`. The hook only reuses existing contexts.

## 2. Management Activity API returns 401
- **Symptoms:** `20-Subscribe-ManagementActivity.ps1` or `21-Export-Audit.ps1` fails with `Authorization has been denied for this request`.
- **Fix:**
  1. Assign the operator to the **Audit Reader** or **Compliance Administrator** role under Microsoft Purview permissions.
  2. Confirm the user has an Exchange Online / Microsoft 365 E5 license and that auditing is enabled (`Get-AdminAuditLogConfig`).
  3. Run `Disconnect-AzAccount`, `az logout`, and sign in again so new tokens include the `ActivityFeed.Read` role.

## 3. Missing spec blocks (activityExport, azurePolicies)
- **Symptoms:** Scripts complain that `contentTypes` or `azurePolicies` cannot be found.
- **Fix:**
  - Update to the latest main branch (scripts now skip gracefully when those blocks are missing), or
  - Reintroduce the section into `spec.local.json` using `spec.dspm.template.json` as a reference.

## 4. Content Safety endpoint skipped
- **Symptoms:** `31-Foundry-ConfigureContentSafety.ps1` logs `foundry.contentSafety.endpoint not provided`.
- **Fix:** Provide the Content Safety endpoint and either a Key Vault secret reference or confirm Entra ID access works for the AI subscription. This message is informational; populate the block only when you are ready to configure Content Safety.

## 5. `azd up` fails after changes to README or docs
- **Symptoms:** `postprovision.ps1` fails with backtick or markdown tokens in the error message.
- **Fix:** Ensure PowerShell scripts do not contain stray Markdown fences (````` ```). Run `git status` to confirm only README/docs changed.

## 6. Defender for AI diagnostics not flowing
- **Symptoms:** No logs appear in Log Analytics after running `07-Enable-Diagnostics.ps1`.
- **Fix:**
  - Verify the `defenderForAI.logAnalyticsWorkspaceId` value in the spec points to an existing workspace with the correct permissions.
  - Confirm the Defender plan (`enableDefenderForCloudPlans`) includes `CognitiveServices` and that Defender for Cloud is enabled in the subscription.

If your issue is not listed here, open a new issue in the repository with the failing script name, the exact error text, and the relevant snippet from `spec.local.json` (redacting secrets).

---

## 7. Spec file JSON syntax errors
- **Symptoms:** `ConvertFrom-Json: Invalid JSON primitive` or scripts fail immediately with parsing errors.
- **Fix:**
  1. Validate your spec: `Get-Content ./spec.local.json | ConvertFrom-Json`
  2. Common issues: trailing commas, missing quotes around values, unescaped characters in paths
  3. Use VS Code with JSON extension for syntax highlighting and error detection

## 8. \"Module not found\" errors
- **Symptoms:** `The term 'Get-AzContext' is not recognized` or similar module errors.
- **Fix:**
  ```powershell
  # Install required modules
  Install-Module Az -Scope CurrentUser -Force -AllowClobber
  Install-Module Az.Security -Scope CurrentUser -Force
  Install-Module ExchangeOnlineManagement -Scope CurrentUser -Force  # for m365 tag
  
  # Verify installation
  Get-Module Az -ListAvailable
  ```

## 9. Wrong subscription/tenant context
- **Symptoms:** Scripts create resources in wrong subscription or fail with \"resource not found\".
- **Fix:**
  ```powershell
  # Check current context
  Get-AzContext
  
  # Switch to correct subscription
  Set-AzContext -Subscription \"<subscription-id-from-spec>\"
  
  # Verify tenant matches
  (Get-AzContext).Tenant.Id  # Should match tenantId in spec
  ```

## 10. Purview account not found
- **Symptoms:** `02-Ensure-PurviewAccount.ps1` fails with \"resource not found\".
- **Fix:**
  - Verify `purviewAccount`, `purviewResourceGroup`, and `purviewSubscriptionId` in spec match exactly (case-sensitive)
  - Confirm the Purview account exists: Azure Portal → Microsoft Purview accounts
  - Ensure you have at least Reader access to the Purview resource

---

## How to Verify Successful Configuration

After running the accelerator, validate that services are correctly configured:

### Check DSPM for AI is enabled
1. Sign in to [Microsoft Purview portal](https://web.purview.azure.com)
2. Navigate to **Data Security Posture Management for AI**
3. Verify **Secure interactions for enterprise AI apps** shows as **Enabled**
4. Check **Recommendations** tab for any outstanding items

### Check Defender for AI is enabled
1. Sign in to [Azure Portal](https://portal.azure.com)
2. Navigate to **Microsoft Defender for Cloud** → **Environment settings**
3. Select your subscription → **Defender plans**
4. Verify **AI Services** shows as **On**
5. Click **Settings** → Confirm **Enable data security for AI interactions** is **On**

### Check diagnostics are flowing
1. Navigate to **Log Analytics workspace** specified in spec
2. Run query: `AzureDiagnostics | where ResourceProvider == "MICROSOFT.COGNITIVESERVICES" | take 10`
3. If results appear, diagnostics are configured correctly (may take 15-30 minutes after initial setup)

### Check DLP/Labels are published (m365 tag)
1. Sign in to [Microsoft Purview compliance portal](https://compliance.microsoft.com)
2. Navigate to **Data loss prevention** → **Policies**
3. Verify your DLP policy appears and shows **On** status
4. Navigate to **Information protection** → **Labels** to verify sensitivity labels

---

## Getting Help

If you're still stuck:

1. **Check existing issues:** [GitHub Issues](https://github.com/microsoft/Data-Agent-Governance-and-Security-Accelerator/issues)
2. **Open a new issue** with:
   - Script name that failed
   - Exact error message
   - Relevant `spec.local.json` snippet (redact secrets!)
   - PowerShell version (`$PSVersionTable`)
   - Az module version (`Get-Module Az -ListAvailable`)
3. **Community discussions:** Use GitHub Discussions for questions and best practices
