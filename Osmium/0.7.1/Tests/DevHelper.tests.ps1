<#
 .Synopsis
 Testing the DevHelper module
#>

describe "calls IL Spy" {
    # $Psm1Path = Join-Path -Path $PSScriptRoot -Child ..\DevHelper.psm1
    $Psm1Path = Join-Path -Path (Get-Item -Path $PSScriptRoot).Parent.FullName -ChildPath DevHelper.psm1

    Import-Module -Name $Psm1Path -Force

    # using a mock for Show-ILSpy if Ilspy.exe cannot be available
    mock Show-ILSpy { }

    # Are we patrons of VSTS?
    if ($env:Agent_Id)
    {
        # using a mock for Show-ILSpy if Ilspy.exe cannot assumed to be available
        it "mocking ilspy" {
            Show-ILSpy -AssemblyPath "bla"
            Assert-MockCalled Show-ILSpy -Times 1
        }
    }
    else
    {
        # not a good way of testing - not sure if Start-Process should be part of a test
        it "calls IL Spy with a type" {
            Show-ILSpy -Type ([PSCredential]) | Should not throw "not found"
            # Wait a few seconds
            Start-Sleep -Seconds 3
            $p = Get-Process -Name Ilspy -ErrorAction Ignore
            $p | Stop-Process -ErrorAction Ignore
        }

        it "calls IL Spy with an Assembly" {
            $AssPath = [PSCredential].Assembly.Location
            Show-ILSpy -AssemblyPath $AssPath | Should not throw "not found"
            # Wait a few seconds
            Start-Sleep -Seconds 3
            $p = Get-Process -Name Ilspy  -ErrorAction Ignore
            $p | Stop-Process -ErrorAction Ignore
        }
    
    }

 
}

describe "tests Get-ProgId" {

    it "returns a lot of Prog Ids" {
        Get-ProgId | Should Not be $null
    }

    it "returns the progid for an application" {
        Get-AppProgId -ApplicationName VBScript | Should not be $null
    }
     
}