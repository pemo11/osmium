<#
 .Synopsis
 Testing the FilesystemHelper module
#>

describe "FileSystem helper tests" {
    $Psm1Path = Join-Path -Path $PSScriptRoot -Child ..\TypeHelper.psm1
    Import-Module -Name $Psm1Path -Force
    $Psm1Path = Join-Path -Path $PSScriptRoot -Child ..\FileSystemHelper.psm1
    Import-Module -Name $Psm1Path -Force

    it "finds ini files and returns strings" {
        (Find-File -Path "C:\Windows" -Pattern *.ini -NameOnly).Count -gt 0 | Should be $true
    }

    it "finds ini files and returns FileSystemEntryInfo objects" {
        $File = (Find-File -Path "C:\Windows" -Pattern *.ini ) | Select-Object -First 1
        $File.GetType().Name | Should be "FileSystemEntryInfo"
    }

}