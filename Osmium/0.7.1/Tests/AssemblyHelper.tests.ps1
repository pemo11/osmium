<#
 .Synopsis
 Testing the AssemblyHelper module
#>

describe "Assembly helper tests" {
    # $Psm1Path = Join-Path -Path $PSScriptRoot -Child ..\AssemblyHelper.psm1
    $Psm1Path = Join-Path -Path (Get-Item -Path $PSScriptRoot).Parent.FullName -ChildPath AssemblyHelper.psm1
    Import-Module -Name $Psm1Path -Force

    it "returns assemblies" {
        Get-Assembly -All | Should not be $null 
    }

    it "checks for an existing assembly" {
        Get-Assembly -Name "System.Management.Automation" | Should be $true
    }

    it "loads an custom assembly" {
        $Ps1Path = Join-Path $PSScriptRoot -ChildPath "AssemblyLib.ps1"
        .$Ps1Path

        if (New-AssemblyLib)
        {
            $AssPath = Resolve-Path ".\QuotesLib.dll"
            Add-Assembly -AssemblyPath $AssPath
            Get-Assembly -Name "Quotes" | Should be $true
        }
    }

    it "returns Assembly info details" {
        $AssPath = Resolve-Path ".\QuotesLib.dll"
        $AssInfo = Get-AssemblyInfo -Path $AssPath 
        $AssInfo.Version | Should be "0.0.0.0"
    }

    it "returns Assembly namespace" {
        $AssPath = Resolve-Path ".\QuotesLib.dll"
        $AssInfo = Get-AssemblyInfo -Path $AssPath 
        $AssInfo.Namespace | Should be "Testlib"
    }

    it "returns a lot of Assemblies from the GAC" {
        @(Get-GAC -All | Select-Object -First 10).Count | Should be 10
    }

    it "returns specific Assemblies from the GAC" {
        @(Get-GAC -Name Microsoft.Powershell).Count -gt 10 | Should be $true
    }

    it "adds a custom assembly with its full name" {
        $AssPath = Join-Path -Path $PSScriptRoot -ChildPath "..\bin\AlphaFS.dll"
        Add-Assembly -AssemblyPath $AssPath -PassThru | Should not be $null
    }

}