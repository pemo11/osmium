<#
 .Synopsis
 Source for a assembly library in C# just for testing purposes
#>

$CSCode = @'
    using System;
    using System.Net;
    using System.Net.Sockets;
    using System.Text;

    namespace Testlib
    {
        public class QuoteLib
        {
            private static string[] quotes = {
                "When the going gets tough the tough gets going",
                "If you fail try again",
                "Beam me up, Scotty",
                "Its never to late for another try"
            };
    
            private static string GetUdpQuote()
            {
                string quote = "";
                try
                {
                    using (UdpClient client = new UdpClient())
                    {
                        client.Client.ReceiveTimeout = 100;
                        client.Connect("localhost", 17);
                        Byte[] sendBuffer = ASCIIEncoding.ASCII.GetBytes("Test1234");
                        IPEndPoint endpoint = new IPEndPoint(IPAddress.Any, 0);
                        client.Send(sendBuffer, sendBuffer.Length);
                        Byte[] receiveBuffer = client.Receive(ref endpoint);
                        quote = ASCIIEncoding.ASCII.GetString(receiveBuffer);
                    }
                    return quote;
                }
                catch(SystemException ex)
                {
                    throw ex;
                }
            }
    
            public static string GetQuote()
            {
                try
                {
                    return GetUdpQuote();
                }
                catch
                {
                    return quotes[new Random().Next(0, quotes.Length)];
                }
            }
        }
    }

'@

<#
 .Synopsis
 Creates an Assembly library for testing purposes
 #>
function New-AssemblyLib
{
    [CmdletBinding()]
    param([String]$AssName="Quoteslib.dll")
    try {
        Add-Type -Typedefinition $CSCode -OutputType Library -OutputAssembly $AssName -ErrorAction Stop
        Test-Path -Path .\$AssName
    }
    catch {
        return $false        
    }
}

