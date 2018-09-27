<#
 .Synopsis
 Tests for the MiscHelper module
#>

describe "tests misc helper functions" {
    
    $Psm1Path = Join-Path -Path (Get-Item -Path $PSScriptRoot).Parent.FullName -ChildPath MiscHelper.psm1
    Import-Module -Name $Psm1Path -Force -Verbose

    it "should return a string of 8 chars" {
      (Get-Password -Length 8).Length | Should be 8
    }
}
