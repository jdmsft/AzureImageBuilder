# Install required PowerShell modules
Install-Module Az.ImageBuilder -Repository PSGallery -AllowPrerelease -AllowClobber
Install-Module Az.ManagedServiceIdentity -Repository PSGallery -AllowPrerelease -AllowClobber

# Register required ARM providers
Register-AzResourceProvider -ProviderNamespace Microsoft.VirtualMachineImages
Register-AzProviderFeature -ProviderNamespace Microsoft.VirtualMachineImages -FeatureName VirtualMachineTemplatePreview

# Verify that required module is registered
Get-AzProviderFeature -ProviderNamespace Microsoft.VirtualMachineImages -FeatureName VirtualMachineTemplatePreview 

## Define variables
$subscriptionID = (Get-AzContext).Subscription.Id
$imageResourceGroup = 'TEST-IMAGES-1'
$location = 'westeurope'
$imageTemplateName = 'MyWindowsImage'

# Distribution properties of the managed image upon completion
$runOutputName = 'myDistResults'

# Create a resource group
New-AzResourceGroup -Name $imageResourceGroup -Location $location

# Create managed identity used by Azure Image Builder service
[int]$timeInt = $(Get-Date -UFormat '%s')
$identityName = "AzureImageBuilder"
New-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName
$identityNameResourceId = (Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName).Id
$identityNamePrincipalId = (Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName).PrincipalId

# Assign permissions for identity to distribute images
$imageRoleDefName = "Azure Image Builder"
$myRoleImageCreationUrl = 'https://raw.githubusercontent.com/jdmsft/AzureImageBuilder/master/CustomRole/AzureImageBuilderContributor.json'
$myRoleImageCreationPath = "$env:TEMP\myRoleImageCreation.json"
Invoke-WebRequest -Uri $myRoleImageCreationUrl -OutFile $myRoleImageCreationPath -UseBasicParsing
$Content = Get-Content -Path $myRoleImageCreationPath -Raw
$Content = $Content -replace '<subscriptionID>', $subscriptionID
$Content = $Content -replace '<rgName>', $imageResourceGroup
$Content = $Content -replace 'Azure Image Builder Service Image Creation Role', $imageRoleDefName
$Content | Out-File -FilePath $myRoleImageCreationPath -Force

# Create the role definition
New-AzRoleDefinition -InputFile $myRoleImageCreationPath

# Grand the role definition to the image builder
$RoleAssignParams = @{
    ObjectId           = $identityNamePrincipalId
    RoleDefinitionName = $imageRoleDefName
    Scope              = "/subscriptions/$subscriptionID/resourceGroups/$imageResourceGroup"
}
New-AzRoleAssignment @RoleAssignParams