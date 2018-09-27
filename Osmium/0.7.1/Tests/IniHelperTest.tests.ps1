<#
 .Synopsis
 Tests for the IniHelper module
 #>

describe "general Ini file tests" {
    # $Psm1Path = Join-Path -Path $PSScriptRoot -Child ..\IniHelper.psm1
    $Psm1Path = Join-Path -Path (Get-Item -Path $PSScriptRoot).Parent.FullName -ChildPath IniHelper.psm1
    Import-Module -Name $Psm1Path -Force

    BeforeAll {
        $IniData = @"
        [Section 1]
        Eintrag1 = 1234
        Eintrag2 = Where no man has gone before

        [Section 99]
        who = are you?
        where = are we?
"@
        $IniPath = Join-Path -Path $env:TEMP -ChildPath "IniFile.ini"
        $IniData | Set-Content -Path $IniPath -Encoding Default
    }

    it "should return two sections" {
        (Get-IniSection -IniPath $IniPath -All).Count  | Should be 2
    }

    it "should return entries of a section name" {
        (Get-IniSection -IniPath $IniPath -Section "Section 1").Count  | Should be 2
    }

    it "should return a simple entry value" {
        Get-IniValue -IniPath $IniPath -Section "Section 1" -EntryName "Eintrag1" | Should be 1234
    }

    it "should return an entry value with a blank" {
        Get-IniValue -IniPath $IniPath -Section "Section 99" -EntryName "who" | Should be "are you?"
    }

    it "should change an entry value" {
        Set-IniValue -IniPath $IniPath -Section "Section 1" -EntryName "Eintrag1" -Value 5678
        Get-IniValue -IniPath $IniPath -Section "Section 1" -EntryName "Eintrag1" | Should be 5678
    }


}