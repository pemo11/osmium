<#
 .Synopsis
 Contains functions for reading ini files
#>

Set-StrictMode -Version Latest
Import-LocalizedData -BindingVariable MsgTable -FileName OsmiumMessages.psd1

<#
.Synopsis
Reads ini file into a hashtable
#>
function ReadIni
{
    [CmdletBinding()]
    param([String]$IniPath)
    $IniHash = @{}
    Get-Content -Path $IniPath | ForEach-Object {
        # Is it a section?
        if ($_ -match "\[([\w\s]+)\]")
        {
            $Section = $Matches[1]
            # Does section exists?
            if (-not $IniHash.ContainsKey($Section))
            {
                $IniHash += @{$Section=@{}}
            }
        }
        elseif ($_ -match "(\w+)\s*=\s*(.+)")
        {
            if ($Section -eq "")
            {
                throw "No Section defined"
            }
            # Add entry to hashtable
            $IniHash[$Section] += @{$Matches[1] = $Matches[2]}
        }
        elseif (-not [String]::IsNullOrEmpty($_))
        {
            throw $MsgTable.IniHelperLineNoKeyPair
        }
    }
    $IniHash
}

<#
 .Synopsis
 Writes hashtable into ini file
 #>
 function WriteIni
 {
    [CmdletBinding()]
    param([String]$IniPath)
    $IniLines = @()
    foreach($Key in $IniHash.Keys)
    {
        $IniLines += "[$Key]"
        foreach($Entry in $IniHash.$Key.Keys)
        {
            $IniLines += "$Entry = $($IniHash.$Key.$Entry)"
        }
        $IniLines += ""
    }
    try {
        $IniLines | Set-Content -Path $IniPath
    }
    catch {
        Write-Error "WriteIni: Cannot write ini file ($_)"        
    }
 }

<#
 .Synopsis
 Gets a single value from an ini file
#>
function Get-IniValue
{
    [CmdletBinding()]
    param([String]$IniPath, [String]$SectionName, $EntryName)
    $IniHash = ReadIni -IniPath $IniPath
    if ($IniHash.ContainsKey($SectionName))
    {
        if ($IniHash[$SectionName].ContainsKey($EntryName))
        {
            $IniHash[$SectionName][$EntryName]
        }
    }
}

<#
 .Synopsis
 Gets either all or a single section from an ini file
#>
function Get-IniSection
{
    [CmdletBinding(DefaultParametersetName="")]
    param([Parameter(Mandatory=$true)][String]$IniPath,
          [Parameter(ParametersetName="Path")][String]$SectionName, 
          [Parameter(ParametersetName="All")][Switch]$All)
    # Read the ini file
    $IniHash = ReadIni -IniPath $IniPath
    if ($PSBoundParameters.ContainsKey("All"))
    {
        $IniHash.Keys
    }
    else
    {
        if ($IniHash.ContainsKey($SectionName))
        {
            $IniHash.$SectionName
        }
    }
}

<#
 .Synopsis
 Writes a value to an ini file and creates section and entry if necessary
#>
function Set-IniValue
{
    [CmdletBinding()]
    param([String]$IniPath, [String]$SectionName, [String]$EntryName, [String]$Value)
    # Read the ini file
    $IniHash = ReadIni -IniPath $IniPath
    # Find the section
    if ($IniHash.ContainsKey($SectionName))
    {
        if ($IniHash.$SectionName.ContainsKey($EntryName))
        {
            $IniHash.$SectionName.$EntryName = $Value
        }
        else
        {
            $IniHash.$SectionName += @{$EntryName = $Value}
        }
    }
    else
    {
        $IniHash += @{$SectionName = @{$EntryName=$Value}}
    }
    WriteIni -IniPath $IniPath
}
