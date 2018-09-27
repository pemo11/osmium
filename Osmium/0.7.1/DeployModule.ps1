<#
 .Synopsis
 Deploy module to Myget.org
 blabla...
#>

# Put everything into a module
# $VerbosePreference = "Continue"

Set-StrictMode -Version Latest

# Step 1: Create a new module directory
$ModuleVersion = "0.7.1"
$BaseModulePath = Join-Path -Path $env:TEMP -ChildPath "Osmium"
$ModulePath =  Join-Path -Path $BaseModulePath -ChildPath $ModuleVersion

# Create the temporary module path
md $ModulePath -Force  | Out-Null

Write-Verbose "$ModulePath wurde angelegt." -Verbose

# Copy all files into the new module directory
$ExcludeFiles = @('BuildInit.ps1', 'Analyze.ps1', 'DeployMyget.ps1')
Copy-Item *.ps1,*.psm1,*.psd1,*.ps1xml, Tests -Destination $ModulePath -Recurse -Exclude $ExcludeFiles -Force

# Copy the resource directories
Copy-Item de-de,en-us -Destination $ModulePath -Recurse

# Copy the ModuleData directory
Copy-Item ModuleData -Destination $ModulePath -Recurse

# Copy the bin directory
Copy-Item bin -Destination $ModulePath -Recurse

# Step 2: Create an optional catalog file for the module directory
# TODO: Sign the cat file with Set-AuthenticodeSignature and a certifate
New-FileCatalog -CatalogFilePath Osmium.cat -Path $ModulePath -CatalogVersion 1 | Out-Null

# Step 3: Update manifest file with the name of all exported functions

# Very nice - get the name of all functions from all psm1 files as comma separated list
$FuncList = [Scriptblock]::Create((Get-Content -Path $ModulePath\*.psm1 -Raw)).Ast.FindAll({param($Ast) $Ast -is [System.Management.Automation.Language.FunctionDefinitionAst]}, $true).Name
# Export only Functions that follow the verb-noun rule
$FuncNames = $FuncList.Where{$_ -match "^(\w+)-(\w+)$"}.ForEach{ """$_"""} -join ","

$Psm1List=  (Get-Childitem -Path $ModulePath\*.psm1 | Select-Object -ExpandProperty Name)
$Psm1Names = $Psm1List.ForEach{ """$_"""} -join ","

$ModuleGuid = "30659df5-f4c6-413e-82f0-257f7f8a8b1a"
$Psd1Path = Join-Path -Path $ModulePath -ChildPath "Osmium.psd1"

# Create a new manifest file in the module directory
$Psd1Text = @"
@{
    ModuleVersion = '$ModuleVersion'
    CompatiblePSEditions = @('Desktop', 'Core')
    PowerShellVersion = '5.1'
    Guid = '$ModuleGuid'
    Description = 'Contains a few helpful functions aimed at Developers all over the world'
    Author = 'Peter Monadjemi'
    Copyright = '(c) 2018 Peter Monadjemi. MIT license of course.'
    FormatsToProcess = 'AssemblyHelper.format.ps1xml'
    NestedModules = @($Psm1Names)
    FunctionsToExport = @($FuncNames)
    PrivateData = @{
        RequireLicenseAcceptance = 'True'
        PSData = @{
            Tags = 'Developer'
            LicenseUri = 'http://github.com/pemo11/osmium/license.txt'
            ProjectUri = 'http://github.com/pemo11/osmium'
        } 
     }
}
"@

# Overwriting the existing psd1 file
$Psd1Text | Set-Content -Path $Psd1Path

# List the content of the module directory
dir -path $ModulePath

# Not good because it writes all unnecessary entries again
# Update-ModuleManifest -Path $Psd1Path -FunctionsToExport $FuncList

# Step 4: Publish the module to Myget

$MyGetSourceUrl = "https://www.myget.org/F/poshrepo/api/v2"
$MyGetPublishUrl = "https://www.myget.org/F/poshrepo/api/v2/package"
$MyGetKey = "d1aa07e8-d006-410a-b040-acf131460a2f"

# Unregister the repo just in case
Unregister-PSRepository -Name PoshRepo -ErrorAction Ignore

# Register PoshRepo
Register-PSRepository -Name PoshRepo `
    -SourceLocation $MyGetSourceUrl `
    -PublishLocation $MyGetPublishUrl `
    -InstallationPolicy Trusted 

# And finally: Publish the module first to Myget

try
{
    Publish-Module -Name $ModulePath -Repository PoshRepo -NuGetApiKey $MyGetKey -ErrorAction Stop -Verbose -Force
    Write-Verbose "Module successfully published to MyGet.org" -Verbose
}
catch
{
   Write-Warning "Error publishing to Myget.org ($_)"
}

# And now to the PowerShell Gallery and that means to the whole world!
$PoshGalleryKey = "oy2jsnhgxc2fc6ggeaialzy4uld2qeuelmmfhjfwnl47he"

try
{
    Publish-Module -Name $ModulePath -Repository PSGallery -NuGetApiKey $PoshGalleryKey -ErrorAction Stop -Verbose -Force
    Write-Verbose "Module successfully published to the PowerShell Gallery" -Verbose
}
catch
{
    Write-Warning "Error publishing to PowerShell Gallery ($_)"
    
}

# Important: Store the ModulePath variable in a VSTS environment variable
# Strip version number from module path
$ModulePath = Split-Path -Path $ModulePath

Write-Host "##vso[task.setvariable variable=OsmiumModulePath]$ModulePath"

$VerbosePreference = "SilentlyContinue"
