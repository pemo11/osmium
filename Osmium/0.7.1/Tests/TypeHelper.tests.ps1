<#
 .Synopsis
 Testing the TypeHelper module
#>

describe "Type helper tests - part 1" {
    $Psm1Path = Join-Path -Path $PSScriptRoot -Child ..\TypeHelper.psm1
    Import-Module -Name $Psm1Path -Force

    it "finds a type" {
        Find-Type -Typename Random | Should not be $null 
    }

    it "finds not a type" {
        Find-Type -Typename RandomX | Should be $null 
    }

    it "gets constructors of type PSCredential" {
        $Constructors = Get-Constructor -Type "PSCredential"
        $Constructors.Count | Should be 2
    }

    it "gets constructors of type String" {
        $Constructors = Get-Constructor -Type "String"
        $Constructors.Count | Should be 8
    }

    it "finds a single method name DownloadString" {
        $Result = Find-MethodMember -Methodname "DownloadString" -FindExact
        @($Result).Count | Should be 1
    }

    it "find several method names containing Download" {
        $Result = (Find-MethodMember -Methodname "Download").Method.Count
        $Result -gt 1 | Should be $true
    }

    it "finds a single property name EndofStream" {
        $Result = Find-PropertyMember -Propertyname "EndOfStream" -FindExact
        @($Result).Count | Should be 1
    }

}

describe "Type helper tests - part 2" {

    # $Psm1Path = Join-Path -Path $PSScriptRoot -Child ..\TypeHelper.psm1
    $Psm1Path = Join-Path -Path (Get-Item -Path $PSScriptRoot).Parent.FullName -ChildPath TypeHelper.psm1
    Import-Module -Name $Psm1Path -Force

    it "finds an Interface IIdentity" {
        @(Find-Interface -Interfacename IIDentity).Count -gt 5 | Should be $true
    }
}
