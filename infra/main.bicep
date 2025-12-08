targetScope = 'subscription'

@description('Spec file that the post-provision hook should hand to run.ps1.')
param dagaSpecPath string = './spec.local.json'

@description('Tags (in run.ps1 format) that the hook should execute after provisioning.')
param dagaTags array = [
	'foundation'
	'dspm'
	'defender'
	'foundry'
]

@description('Set to true when Microsoft 365 portions of the run plan should execute during the hook.')
param dagaConnectM365 bool = false

@description('Interactive operator UPN for Exchange Online steps (optional).')
param dagaM365UserPrincipalName string = ''

@description('App registration (client) ID for certificate-based Microsoft 365 auth (optional).')
param dagaM365AppId string = ''

@description('Microsoft 365 organization/tenant (GUID or domain) for app-only auth (optional).')
param dagaM365Organization string = ''

@description('Thumbprint for the certificate stored on the execution host (optional).')
param dagaM365CertificateThumbprint string = ''

@description('Path to a PFX certificate that the automation can read (optional).')
param dagaM365CertificatePath string = ''

@description('Password for the file-based certificate (optional).')
param dagaM365CertificatePassword string = ''

output dagaSpecPath string = dagaSpecPath
output dagaTags array = dagaTags
output dagaConnectM365 bool = dagaConnectM365
output dagaM365UserPrincipalName string = dagaM365UserPrincipalName
output dagaM365AppId string = dagaM365AppId
output dagaM365Organization string = dagaM365Organization
output dagaM365CertificateThumbprint string = dagaM365CertificateThumbprint
output dagaM365CertificatePath string = dagaM365CertificatePath
output dagaM365CertificatePassword string = dagaM365CertificatePassword
