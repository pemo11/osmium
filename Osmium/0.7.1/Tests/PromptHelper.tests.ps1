<#
 .Synopsis
 Testing the PromptHelper module
 .Notes
 Only a very few tests due to the nature of this module
#>

describe "Promt helper tests" {
    # $Psm1Path = Join-Path -Path $PSScriptRoot -Child ..\PromptHelper.psm1
    $Psm1Path = Join-Path -Path (Get-Item -Path $PSScriptRoot).Parent.FullName -ChildPath PromptHelper.psm1
    Import-Module -Name $Psm1Path -Force

    it "returns prompts" {
        (Show-Prompt).Count -gt 3  | Should be $true
    }

    it "gets a specific prompt" {
        $Promptname = (Show-Prompt)[0]
        Get-Prompt -Functionname "prompt$Promptname"  | Should not be $null
    }

}