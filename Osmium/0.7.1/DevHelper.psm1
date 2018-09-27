<#
 .Synopsis
 Contains several general helpers aimed for developers
#>

Set-StrictMode -Version Latest
Import-LocalizedData -BindingVariable MsgTable -FileName OsmiumMessages.psd1

<#
 .Synopsis
 Calls ILSpy.exe with a given Assembly or type
 .Notes
 Requires an installed version of Ilspy from http://ilspy.net
#>
function Show-ILSpy
{
    [CmdletBinding(DefaultParameterSetname="")]
    param([Parameter(Mandatory=$true, ParametersetName="Path")][String]$AssemblyPath,
          [Parameter(Mandatory=$true, ParametersetName="Type")][Type]$Type,
          [Switch]$UseWait
         )
    # Check if Assemblypath exists first
    if ($PSBoundParameters.ContainsKey("AssemblyPath"))
    {
        if (!(Test-Path -Path $AssemblyPath))
        {
            Write-Error ($MsgTable.DevHelperAssPathNotFound -f $AssemblyPath)
            return
        }
    }    
    # Check if Ilspy is installed either 32- or 64 bit version
    $IlSpyPath64 = "$env:ProgramFiles\ILSpy\ILSpy.exe"
    $IlSpyPath86 = "$env:ProgramFiles(x86)\ILSpy\ILSpy.exe"
    $IlSpyPath = ""
    if (Test-Path -Path $IlSpyPath64)
    {
        $IlSpyPath = $IlSpyPath64
    } elseif (Test-Path -Path $IlSpyPath86)
    {
        $IlSpyPath = $IlSpyPath86
    }
    if ($IlSpyPath -ne "")
    {
        if ($PSBoundParameters.ContainsKey("Type"))
        {
            $AssemblyPath = $Type.Assembly.Location
        }
    }
    else
    {
        Write-Error $MsgTable.IlspyPathNotFound
        return
    }
    Start-Process -FilePath $IlSpyPath -ArgumentList $AssemblyPath -Wait:$UseWait
} 

<#
.Synopsis
Extends the path variable
#>
function Set-DevEnvironment
{
    $EnvPathList = @(
        "C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.6.1 Tools",
        "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Tools\MSVC\14.14.26428\bin\Hostx86\x86"
    )
    $EnvPathList.ForEach{
        if (Test-Path -Path $_)
        {
            if (($env:path -split ";") -eq $_)
            {
                $env:path += ";$_"
            }
        }
    }
}

<#
 .Synopsis
 Gets a list of all COM prog ids
#>
function Get-ProgID
{
    [CmdletBinding()]
    param()
    # Use absolute path because no drive exists
    $RegKeys = @("REGISTRY::HKEY_CLASSES_ROOT\CLSID")            
    if ($env:Processor_Architecture -eq "amd64")
    {            
        $RegKeys += "REGISTRY::HKEY_CLASSES_ROOT\Wow6432Node\CLSID"            
    }
    $Script:ProgIdCount = 0             
    Get-ChildItem -Path $RegKeys -Include VersionIndependentPROGID -Recurse |            
      Select-Object -Property @{
                                n = "ProgID"
                                e = {$Script:ProgIdCount++;$_.GetValue("")
                               }
                               },
                              @{            
                                 n="32Bit"
                                 e = {
                                  if ($env:Processor_Architecture -eq "amd64")
                                  {
                                    $_.PSPath.Contains("Wow6432Node")
                                  }
                                  else { $true } }            
                              } 
    Write-Verbose "ProgId-Count: $Script:ProgIdCount"           
}

<#
 .Synopsis
 Gets the Prog id for a specific application
#>
function Get-AppProgId
{
    [CmdletBinding()]
    param([String]$ApplicationName)
    $SBCompare = { $null -ne $_.ProgId }
    if ($ApplicationName -ne "")
    {
        $SBCompare = { $null -ne $_.ProgId  -and
            $_.InprocServer32 -like "*$ApplicationName*"  }
    }
    Get-CimInstance -ClassName Win32_ClassicCOMClassSetting | Where-Object $SBCompare | Select-Object -Property ProgId, InprocServer32
}