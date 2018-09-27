<#
 .Synopsis
 Contains just for fun (jff) related functions
#>

Set-StrictMode -Version Latest
Import-LocalizedData -BindingVariable MsgTable -FileName OsmiumMessages.psd1

# only for testing purpose - get the path of the psm1 file
$MyModule = $ExecutionContext.SessionState.Module
$MyModuleBase = $MyModule.ModuleBase
$MyModulePath = $MyModule.Path

<#
.Synopsis
Display an ASCII banner
.Notes
Banner text contained in PSBanner.psd1
#>
function Show-PSBanner
{
    param([String]$Banner = "Posh")
    $Psd1Path = Join-Path -Path $PSScriptRoot -Child "ModuleData\PSBanner.psd1"
    $BannerDic = Import-PowerShellDataFile -Path $Psd1Path  
    # Split the lines so return an array
    $BannerDic.$Banner -split "`r`n"
}

<#
 .Synopsis
 Returns a famous quote via QOTD
 .Notes
 TODO: Add local psd1 file option
 #>
function Get-FamousQuote
{
    [CmdletBinding()]
    param([Switch]$TestMode)
    if ($PSBoundParameters.ContainsKey("TestMode"))
    {
        return $MsgTable.FunHelperDefaultQuote
    }
    try {
        $QOTDHost = "localhost"
        $UDPClient = New-Object -TypeName System.Net.Sockets.Udpclient
    
        $UDPClient.Connect($QOTDHost, 17)
        $UDPClient.Client.ReceiveTimeout = 1000
    
        # Send a random text message to the QOTD
        $ACSCII = New-Object -TypeName System.Text.ASCIIEncoding
        $ByteBuf = $ACSCII.GetBytes("The answer is 41")
        [void]$UDPClient.Send($ByteBuf, $ByteBuf.Length)
    
        # Connect to port 17
        $RemoteEnd = New-Object -TypeName System.Net.IPEndPoint -ArgumentList ([System.Net.IPAddress]::Any), 0
        try
        {
            # get the bytes
            $BytesReceived = $UDPClient.Receive([ref]$RemoteEnd)
            # convert bytes into text
            $Quote = $ACSCII.GetString($BytesReceived)
            # return the quote
            $Quote
        }
        catch
        {
            Write-Warning ($MsgTable.FunHelperError1 -f $_)
            return "No Quote"
        }
        Finally
        {
            # close the connection
            if ($UDPClient -ne $null)
            {
                $UDPClient.Close()
            }
        }
    }
    catch {
        Write-Error $MsgTable.FunHelperError2
        return "No Quote"
    }    
}


