# Create an Azure Image Builder object
$SrcObjParams = @{
  SourceTypePlatformImage = $true
  Publisher = 'MicrosoftWindowsServer'
  Offer = 'WindowsServer'
  Sku = '2019-Datacenter'
  Version = 'latest'
}
$srcPlatform = New-AzImageBuilderSourceObject @SrcObjParams

# Create an Azure Image Builder - DITRIBUTOR object
$disObjParams = @{
    SharedImageDistributor = $true
    ArtifactTag            = @{tag = 'dis-share' }
    GalleryImageId         = "/subscriptions/$subscriptionID/resourceGroups/$imageResourceGroup/providers/Microsoft.Compute/galleries/$myGalleryName/images/$imageDefName"
    ReplicationRegion      = $location
    RunOutputName          = $runOutputName
    ExcludeFromLatest      = $false
}
$disSharedImg = New-AzImageBuilderDistributorObject @disObjParams

# Create an Azure Image Builder - CUSTOMIZATION object
$ImgCustomParams = @{
    PowerShellCustomizer = $true
    CustomizerName       = 'settingUpMgmtAgtPath'
    RunElevated          = $false
    Inline               = @("mkdir c:\\buildActions", "echo Azure-Image-Builder-Was-Here  > c:\\buildActions\\buildActionsOutput.txt")
}
$Customizer = New-AzImageBuilderCustomizerObject @ImgCustomParams

# Create an Azure Image Builder template
$ImgTemplateParams = @{
    ImageTemplateName      = $imageTemplateName
    ResourceGroupName      = $imageResourceGroup
    Source                 = $srcPlatform
    Distribute             = $disSharedImg
    Customize              = $Customizer
    Location               = $location
    UserAssignedIdentityId = $identityNameResourceId
}
New-AzImageBuilderTemplate @ImgTemplateParams

# Get the status (should be "provisionned")
Get-AzImageBuilderTemplate -ImageTemplateName $imageTemplateName -ResourceGroupName $imageResourceGroup | Select-Object -Property Name, LastRunStatusRunState, LastRunStatusMessage, ProvisioningState

# Build image from template (This shoukd create a temporary RG "IT_<RGname>_<ImageName>_<guid>" - could take 1h to finish - Packer)
Start-AzImageBuilderTemplate -ResourceGroupName $imageResourceGroup -Name $imageTemplateName