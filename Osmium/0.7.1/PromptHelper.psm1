<#
 .Synopsis
 Defines serveral alternative prompts
 #>

 <#
 .Synopsis
 Prompt-Auswahl
 .Notes
 see about_prompts within PowerShell help
#>

<#
 .Synopsis
 The default prompt
#>
function promptDefault
{
  $(if (test-path variable:/PSDebugContext)
   { '[DBG]: ' }
   else
   { '' }) + 'PS ' + $(Get-Location) `
    + $(if ($NestedPromptLevel -ge 1) { '>>' }) + '> '
}

<#
 .Synopsis
 Displays [Admin] when powershell run with admin privelege
#>
function promptAdmin
 {
  $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = [Security.Principal.WindowsPrincipal] $identity

  $(if (test-path variable:/PSDebugContext) { '[DBG]: ' }
    elseif($principal.IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) { "[ADMIN]: " }
    else { '' }
  ) + 'PS ' + $(Get-Location) +
    $(if ($nestedpromptlevel -ge 1) { '>>' }) + '> '
}

<#
 .Synopsis
 Includes the history count in the prompt
#>
function promptHistoryCount
{
   # create an array in case only one history item exists.
   $history = @(get-history)
   if($history.Count -gt 0)
   {
      $lastItem = $history[$history.Count - 1]
      $lastId = $lastItem.Id
   }

   $nextCommand = $lastId + 1
   $currentDirectory = get-location
   "PS: $nextCommand $currentDirectory >"
}

<#
 .Synopsis
 Coloured Bash like prompt - only works inside the console host
#>
function promptSimpleBash
{
"$($env:username)@$(Hostname) $(cd)$ "

}

<#
 .Synopsis
 Random color prompt
#>
function promptRandomColor
{
    $Color = Get-Random -Min 1 -Max 16
    Write-Host ("PS " + $(Get-Location) +">") -NoNewLine `
     -ForegroundColor $Color
    return " "
}

<#
 .Synopsis
 Coloured Bash like prompt - only works inside the console host
#>
function promptColorBash
{
  $Host.UI.RawUI.ForegroundColor = "Green"
  Write-Host "$($env:username)@$(Hostname)" -NoNewline
  $Host.UI.RawUI.ForegroundColor = "Yellow" 
  Write-Host " $(pwd)" -NoNewline
  $Host.UI.RawUI.ForegroundColor = "White"
  Write-Host "$" -NoNewline
  return " "
}

<#
 .Synopsis
 a helper functions that shortens a path
 .Notes
 credits to an unknown powershell experts
#>
function ShortenPath
{
  param([string]$Path)
   $Loc = $Path.Replace($HOME, '~') 
   # Remove prefix for UNC paths 
   $Loc = $Loc -replace '^[^:]+::', '' 
   # handle paths starting with \\ and . correctly 
   ($Loc -replace '\\(\.?)([^\\])[^\\]*(?=\\)','\$1$2') 
}
<#
 .Synopsis
 Coloured Bash with abbreviated current directory path
#>
function promptColorBashShortPath
{
  $cDelim = [ConsoleColor]::DarkCyan 
  $cHost = [ConsoleColor]::Green 
  $cLoc = [ConsoleColor]::Cyan 
  # Alternative: 0x0A7
  Write-Host "$([Char]0x024) " -ForegroundColor $cLoc -NoNewline 
  Write-Host "$(HostName)@($env:UserName)" -ForegroundColor $cHost -NoNewline 
  Write-Host ' {' -ForegroundColor $cDelim -NoNewline 
  Write-Host (ShortenPath (Pwd).Path) -ForegroundColor $cLoc -NoNewline  
  Write-Host '}' -ForegroundColor $cDelim -NoNewline 
  return " "
}

<#
 .Synopsis
 Show the names all the available custom prompts
 .Notes
 a custom prompt is a function whos name starts with prompt
#>
function Show-Prompt
{

    # $Ps1Path = $MyInvocation.PSCommandPath
    # $Ps1Path = Join-Path -Path $PSScriptRoot -ChildPath "PromptHelper.psm1"
    # The the path of the psm1 file that contains the current function
    $Ps1Path = $MyInvocation.MyCommand.Module.Path
    $AST = [System.Management.Automation.Language.Parser]::ParseFile($Ps1Path, [ref]$null, [ref]$null)
    $AST.FindAll({param($Ast) $Ast -is [System.Management.Automation.Language.FunctionDefinitionAst]}, $true).ToArray().Where{ $_.Name -like "prompt*"}.ForEach{
      $_.Name.Substring("prompt".Length)
    }
}

<#
 .Synopsis
 Get the definition of a specific prompt
#>
function Get-Prompt
{
    param([String]$Functionname)
    # $Ps1Path = $MyInvocation.PSCommandPath
    $Ps1Path = $MyInvocation.MyCommand.Module.Path
    $AST = [System.Management.Automation.Language.Parser]::ParseFile($Ps1Path, [ref]$null, [ref]$null)
    $FunctionDef = $AST.Find({
     param($AstNode)
     $AstNode -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $AstNode.Name -eq $Functionname}, $true
   ).Body.extent.text
   if ($FunctionDef -eq $null)
   {
     throw "$Functionname does not exist"
   }
   $FunctionDef
}

<#
 .Synopsis
 Sets a specific prompt to a new prompt
#>
function Set-Prompt
{
    param([String]$Functionname)
    #$Ps1Path = $MyInvocation.PSCommandPath
    $Ps1Path = $MyInvocation.MyCommand.Module.Path
    $AST = [System.Management.Automation.Language.Parser]::ParseFile($Ps1Path, [ref]$null, [ref]$null)
    $FunctionDef = $AST.Find({
     param($AstNode)
     $AstNode -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $AstNode.Name -eq $Functionname}, $true
   ).Body.extent.text
   if ($FunctionDef -eq $null)
   {
     throw "$Functionname does not exist"
   }
   # function must be global - otherwise the prompt is only visible inside the function
   $PromptFunDef = "function global:prompt()" + $FunctionDef
   Invoke-Expression -Command $PromptFunDef
}

