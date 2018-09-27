@{
    ModuleVersion = '0.7.1'
    CompatiblePSEditions = @('Desktop', 'Core')
    PowerShellVersion = '5.1'
    Guid = '30659df5-f4c6-413e-82f0-257f7f8a8b1a'
    Description = 'Contains a few helpful functions aimed at Developers all over the world'
    Author = 'Peter Monadjemi'
    Copyright = '(c) 2018 Peter Monadjemi. MIT license of course.'
    FormatsToProcess = 'AssemblyHelper.format.ps1xml'
    NestedModules = @("AssemblyHelper.psm1","DevHelper.psm1","FileSystemHelper.psm1","Funhelper1.psm1","Funhelper2.psm1","IniHelper.psm1","MiscHelper.psm1","PromptHelper.psm1","TypeHelper.psm1")
    FunctionsToExport = @("Get-Assembly","Add-Assembly","Get-AssemblyInfo","Get-GAC","Show-ILSpy","Set-DevEnvironment","Get-ProgID","Get-AppProgId","Find-File","Show-PSBanner","Get-FamousQuote","Start-GoL","New-GolField","Get-IniValue","Get-IniSection","Set-IniValue","Convert-FirstToUpper","Test-Admin","Show-2DArray","Convert-HashtableToString","Get-Password","Show-Prompt","Get-Prompt","Set-Prompt","Find-Type","Find-Interface","Get-Constructor","Find-MethodMember","Find-PropertyMember","Invoke-PrivateGenericMethod","Invoke-GenericMethodEx","Invoke-GenericMethod")
    PrivateData = @{
        RequireLicenseAcceptance = 'True'
        PSData = @{
            Tags = 'Developer'
            LicenseUri = 'http://github.com/pemo11/osmium/license.txt'
            ProjectUri = 'http://github.com/pemo11/osmium'
        } 
     }
}
