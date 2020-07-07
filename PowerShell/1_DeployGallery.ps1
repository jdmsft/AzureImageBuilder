# Create Shared Image Gallery
$myGalleryName = 'MySharedImageGallery'
New-AzGallery -GalleryName $myGalleryName -ResourceGroupName $imageResourceGroup -Location $location

# Create défiinition
$imageDefName = 'winSvrImages'
$GalleryParams = @{
    GalleryName       = $myGalleryName
    ResourceGroupName = $imageResourceGroup
    Location          = $location
    Name              = $imageDefName
    OsState           = 'generalized'
    OsType            = 'Windows'
    Publisher         = 'myComapny'
    Offer             = 'Windows'
    Sku               = 'Win2019'
}
New-AzGalleryImageDefinition @GalleryParams