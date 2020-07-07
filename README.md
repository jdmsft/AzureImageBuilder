# Azure Image Builder

Dev project to use Azure Image Builder service throught different methods. 

## Getting Started

___Currently this project propose the PowerShell method___ to deploy, build and distribute an Azure image with __Azure Image Builder (AIB)__ and __Shared Image Gallery (SIG)__. 

### Prerequisites

You need to execute following script. 
Please set your own variables values before proceed. 

```
.\PowerShell\0_prerequisites.ps1
```

### Deploy resources

You need to execute following script. 
Please set your own variables values before proceed. 

```
.\PowerShell\1_DeployGallery.ps1
```

### Build and distribute image

You need to execute following script. 
Please set your own variables values before proceed. 

```
.\PowerShell\2_BuildImage.ps1
```

## Built With

* [Visual Studio Code](https://code.visualstudio.com/) - The code editor redifined


## Authors

* [JDMSFT](https://github.com/jdmsft)

___Based on the work of [Daniel Sol](https://github.com/danielsollondon)___


## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details