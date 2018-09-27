<#
 .Synopsis
 Contains several functions for accessing the File System
#>

Set-StrictMode -Version Latest
Import-LocalizedData -BindingVariable MsgTable -FileName OsmiumMessages.psd1

<#
.Synopsis
Fast file search using the Alpha Assembly
#>
function Find-File
{
    [CmdletBinding()]
    param([String]$Path, [String]$Pattern, [Switch]$NameOnly)
    # check for valid start path
    if (-not (Test-Path -Path $Path))
    {
        $MsgTable.FsHelperPathNotfound
        return
    }
    # check for Alpha Assembly
    $AssPath = Join-Path -Path $PSScriptRoot -ChildPath "bin\AlphaFS.dll"
    if (-not (Test-Path -Path $AssPath))
    {
        $MsgTable.FsHelperAlphaFSNotfound
        return
    }
    # try to load the assembly
    try
    {
        Add-Type -Path $AssPath
    }
    catch
    {
        Write-Warning $MsgTable.FsHelperAlphaFSNotLoaded
        return
    }
    $FileCount = 0
    $EnumOptions = [Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]"Recursive, Files, ContinueOnException"
    if ($PSBoundParameters.ContainsKey("NameOnly"))
    {
        [Alphaleonis.Win32.Filesystem.Directory]::EnumerateFiles($Path, $Pattern, $EnumOptions) | ForEach-Object {
            $_
            $FileCount++
        }
    }
    else
    {
        # Needs to call a generic method
        Invoke-GenericMethod -InstanceType ([Alphaleonis.Win32.Filesystem.Directory]) -GenericType ([Alphaleonis.Win32.Filesystem.FileSystemEntryInfo]) -Methodname EnumerateFileSystemEntryInfos `
            -ParameterTypeNames "String", "String", "Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions" -MethodParameters ($Path, $Pattern, $EnumOptions)  | ForEach-Object {
            $_
            $FileCount++
        }
    }
}