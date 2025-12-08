using './main.bicep'

// Customize these values per azd environment. The hook reads them and forwards the
// resolved configuration to run.ps1, so no additional environment variables are required.
param dagaSpecPath = './spec.local.json'
param dagaTags = [
  'foundation'
  'dspm'
  'defender'
  'foundry'
]
param dagaConnectM365 = true
param dagaM365UserPrincipalName = 'admin@MngEnv282784.onmicrosoft.com'
param dagaM365AppId = ''
param dagaM365Organization = ''
param dagaM365CertificateThumbprint = ''
param dagaM365CertificatePath = ''
param dagaM365CertificatePassword = ''
