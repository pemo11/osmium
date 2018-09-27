<#
 .Synopsis
 Installs the module on another computer
 .Description
 Just for testing purpose - not official part of the module
#>

$MyGetSourceUrl = "https://www.myget.org/F/poshrepo/api/v2"
$MyGetPublishUrl = "https://www.myget.org/F/poshrepo/api/v2/package"

# Unregister the repo just in case
Unregister-PSRepository -Name PoshRepo -ErrorAction Ignore

# Register PoshRepo
Register-PSRepository -Name PoshRepo `
     -SourceLocation $MyGetSourceUrl `
    -PublishLocation $MyGetPublishUrl `
    -InstallationPolicy Trusted 


    # List a modules from that repo
Find-Module -Repository PoshRepo

# Now comes the important part: install the osmium module on the local computer
Install-Module -Name Osmium -Repository PoshRepo -Verbose -Scope AllUsers

# Is it really there? Select all properties
Get-Module -ListAvailable Osmium | Select-Object -Property *

# Is it a valid psd1 file?
Test-ModuleManifest -Path "C:\Program Files\WindowsPowerShell\Modules\Osmium\0.5\Osmium.psd1"

# The the commands of the module
Get-Command -Module Osmium
