<#
 .Synopsis
 Tests for the Funhelper GoL module
 #>

describe "general GoL tests" {
    # $Psm1Path = Join-Path -Path $PSScriptRoot -Child ..\FunHelper2.psm1
    $Psm1Path = Join-Path -Path (Get-Item -Path $PSScriptRoot).Parent.FullName -ChildPath Funhelper2.psm1
    
    Import-Module -Name $Psm1Path -Force

    $Psd1Path = Join-Path -Path $PSScriptRoot -Child ..\ModuleData\GoLPatterns1.psd1

    it "counts the number of cell neighbours # 1" {
        $GolField = [Byte[,]]::new(6,6)
        $GolField[1,1] = 1
        $GolField[1,2] = 1
        $GolField[1,3] = 1
        GetNeighbourCount -Field $GolField -Row 0 -Col 2 | Should be 3
    }

    it "counts the number of cell neighbours # 2" {
        $GolField = [Byte[,]]::new(6,6)
        $GolField[1,0] = 1
        $GolField[1,1] = 1
        $GolField[1,2] = 1
        GetNeighbourCount -Field $GolField -Row 0 -Col 0 | Should be 2
    }

    it "neither grows or shrinks after 10 generations" {
        $GoLField = New-GoLField -GolPattern Glider -PatternFilePath $Psd1Path
        (Start-Gol -GolField $GoLField -MaxGenerationen 10 -ShowGoLField:$false) -eq 5 | Should be $true
    }

    it "neither grows or shrinks after 10 generations" {
        $GoLField = New-GoLField -GolPattern Blinker -PatternFilePath $Psd1Path
        (Start-Gol -GolField $GoLField -MaxGenerationen 10 -ShowGoLField:$false) -eq 3 | Should be $true
    }

    it "dies after just 2 generations" {
        $GoLField = New-GoLField -GolPattern DieFast -PatternFilePath $Psd1Path
        (Start-Gol -GolField $GoLField -MaxGenerationen 2 -ShowGoLField:$false) -eq 0 | Should be $true
    }

}