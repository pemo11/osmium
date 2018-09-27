
Set-StrictMode -Version Latest

Import-LocalizedData -BindingVariable msgTable -FileName OsmiumMessages.psd1

function Get-Assembly
{
    [CmdletBinding(DefaultParametersetName="Default")]
    param([Parameter(Parametersetname="ByAssemblyName")][String]$Name,
    [Parameter(Parametersetname="AllAssembly")] [Switch]$All)
    if ($PSBoundParameters.ContainsKey("All"))
    {
        [AppDomain]::CurrentDomain.GetAssemblies()
    }
    if ($PSBoundParameters.ContainsKey("Name"))
    {
        [AppDomain]::CurrentDomain.GetAssemblies().Where{
            $_.Location -match $Name
        }
    }
 }

function Add-Assembly
{
    [CmdletBinding()]
    param([Alias("PSPath")][Parameter(ValueFromPipelineByPropertyName=$true)][String]$AssemblyPath,
          [String]$Fullname,
          [Switch]$Passthru)
    process
    {
        if ($PSBoundParameters.ContainsKey("AssemblyPath"))
        {
            $Ass = [Reflection.Assembly]::LoadFile($AssemblyPath)
        }
        if ($PSBoundParameters.ContainsKey("Fullname"))
        {
            $Ass = [Reflection.Assembly]::Load($Fullname)          
        }
        if ($Passthru)
        {
            $Ass
        }
    }
  }

function Get-AssemblyInfo
{
    [CmdletBinding()]
    param([Alias("Fullname")][Parameter(ValueFromPipelineByPropertyName=$true)]$Path)
    process
    {
        if (-not (Test-Path -Path $Path))
        {
            Write-Warning (msgTable.AssHelper.AssPathNotfound -f $Path)
        }
        else
        {
            $Ass = [Reflection.Assembly]::LoadFile($Path)
            $Ass | Select-Object @{n="name";e={$Ass.GetName().Name}},
                      @{n="Version";e={$Ass.GetName().Version.ToString()}},
                      @{n="CPUType";e={$Ass.GetName().ProcessorArchitecture}},
                      @{n="Path";e={$Ass.Location}},
                      @{n="GAC";e={$Ass.GlobalAssemblyCache}},
                      @{n="Namespace";e={$Ass.ExportedTypes.Namespace}}
        }
    }
}

function Get-GAC
{
    [CmdletBinding(DefaultParameterSetName="")]
    param([Parameter(ParameterSetName="Name")][String]$Name,
          [Parameter(ParameterSetName="All")][Switch]$All)
    $NameProp = @{n="Name";e={$_.Name}} 
    $LocationProp = @{n="Location";e={"GAC32"}}
    $VersionProp = @{n="Version";e={$_.VersionInfo.ProductVersion.ToString()}}
    $AssemblyList = @()
    $AssemblyList += (Get-ChildItem -Path "C:\Windows\Microsoft.NET\Assembly\GAC_32\*.dll" -Recurse | 
     Select-Object $LocationProp, $NameProp, $VersionProp | Sort-Object -Property Name)
    $LocationProp = @{n="Location";e={"GAC64"}}
    $AssemblyList += (Get-ChildItem -Path  "C:\Windows\Microsoft.NET\Assembly\GAC_64\*.dll" -Recurse | 
     Select-Object $LocationProp, $NameProp, $VersionProp | Sort-Object -Property Name)
    $LocationProp = @{n="Location";e={"MSIL"}}
    $AssemblyList += (Get-ChildItem -Path  "C:\Windows\Microsoft.NET\Assembly\GAC_MSIL\*.dll" -Recurse | 
     Select-Object $LocationProp, $NameProp, $VersionProp | Sort-Object -Property Name)
    if ($PSBoundParameters.ContainsKey("All"))
    {
        $AssemblyList
    } 
    else
    {
        $AssemblyList | Where-Object Name -match $Name
    }
}