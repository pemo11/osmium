<#
 .Synopsis
 Contains several miscellaneous helpers
#>

Set-StrictMode -Version Latest
Import-LocalizedData -BindingVariable Msg -FileName OsmiumMessages.psd1
# Export-ModuleMember -Function Convert-FirstToUpper, Test-Admin

<#
.Synopsis
Converts the first char of a text to an upper case
#>
function Convert-FirstToUpper
{
    [CmdletBinding()]
    param([Parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$Text)
    $Text[0].ToString().ToUpper()+$Text.Substring(1)
}

<#
.Synopsis
Returns $true if the current PowerShell session runs with admin privilege
#>
function Test-Admin
{
        $SID = "S-1-5-32-544"
        $AdminGroupName = (Get-CIMinstance -ClassName Win32_Group -Filter "SID='$SID'").Name
    ([System.Security.Principal.WindowsIdentity]::GetCurrent() -as [System.Security.Principal.WindowsPrincipal]).IsInRole($AdminGroupName)

}

<#
.Synopsis
Output the content of an 2d Array in the console
#>
function Show-2DArray
{
   [CmdletBinding()]
   param([Parameter(Mandatory=$true)][Byte[,]]$Field)
   for($i = 0; $i -lt $Field.GetLength(0); $i++)
   {
       $OutputLine = " {0:00}: " -f ($i+1)
       for($j = 0; $j -lt $Field.GetLength(1); $j++)
       {
           $OutputLine += " {0} " -f $Field[$i, $j]
       }
       $Outputline
   }
}

# TODO: No tests for that function yet
<#
 .Synopsis
 Converts a hashtable into a string representation of all its values
#>
function Convert-HashtableToString
{
    param([System.Collections.Hashtable]$Hashtable, [Switch]$Recurse)
    # Add @{ only once to the text
    if (!$PSBoundParameters.ContainsKey("Recurse"))
    {
        $hashtext = "@{"
    }
    # cannot use foreach because I have to catch the last loop for adding }
    for($i=0;$i -lt $Hashtable.Keys.Count;$i++)
    {
        # get the current key
        $k = @($Hashtable.Keys)[$i]
        # get the current value
        $v = $Hashtable[$k]
        # check if value is a hashtable
        if ($v -is [System.Collections.Hashtable])
        {
            $hashtext += "$k=@{"
            # call function recursively
            $hashtext += Convert-HashToString -Hashtable $v -Recurse
            $hashtext += ";"
        }
        # check if value is an array
        elseif ($v -is [System.Array])
        {
            $hashtext += "$k=@("
            $hashtext += $v.ForEach{"'$_'"} -join ","
            $hashtext += ");"
        }
        else
        {
            $hashtext += $k + "=" + "`"$v`"" + ";"
        }
        # if last loop add } to the output
        if ($i -eq $Hashtable.Keys.Count -1 )
        {
            $hashtext += "}"
        }
    }
    # return the text - no need for a return statement
    $hashtext
}

<#
 .Synopsis
 Generates a new password
 #>
function Get-Password
{
    [CmdletBinding()]
    param([ValidateRange(1,100)][Int]$Length=8)
    ((48..57),(65..91),(97..122) | Get-Random -Count $Length).ForEach{[Char]$_} -join ""
}