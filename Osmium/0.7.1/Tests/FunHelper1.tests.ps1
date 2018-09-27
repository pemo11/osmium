<#
 .Synopsis
 Tests for the Funhelper module
#>

describe "tests banner functions" {
    
    #$Psm1Path = Join-Path -Path $PSScriptRoot -Child ..\Funhelper1.psm1
    $Psm1Path = Join-Path -Path (Get-Item -Path $PSScriptRoot).Parent.FullName -ChildPath Funhelper1.psm1

    Import-Module -Name $Psm1Path -Force

        it "should return 9 lines" {
            (Show-PSBanner).Count | Should be 9
        }
}

 describe "tests quote function" {
    $Psm1Path = Join-Path -Path $PSScriptRoot -Child ..\Funhelper1.psm1
    Import-Module -Name $Psm1Path -Force

    it "should return a quote" {
        if ($env:Agent_Id)
        {
            # Needed a fix due to blanks at the start of the string
            (Get-FamousQuote -TestMode).TrimStart() | Should BeLike "Logic*"
        }
        else {
            $Quote = Get-FamousQuote
            # TODO: needs improvement
            $Quote = "No Quote" -or $Quote -ne "" |  Should be $true
        }
    }
}
