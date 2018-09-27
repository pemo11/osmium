<#
 .Synopsis
 Another simple implementation of Conway`s game of live (AIOCGOL)
 .Notes
 Author: Peter Monadjemi, last update: 13/08/18
#>

Set-StrictMode -Version Latest
Import-LocalizedData -BindingVariable MsgTable -FileName OsmiumMessages.psd1

<#
 .Synopsis
 Handy function to test an expression and runs a different scriptblock if the cond is either true or false
#>
function Iif
{
    [CmdletBinding()]
    param([Parameter(Mandatory=$true, ValueFromPipeline=$true)][Bool]$Cond, [Scriptblock]$TrueOpt, [Scriptblock]$FalseOpt)

    if ($Cond)
    { &$TrueOpt }
    else
    { &$FalseOpt }
}

<#
 .Synopsis
 Returns the number of neighbours of a cell
#>
function GetNeighbourCount
{
    [CmdletBinding()]
    param([Byte[,]]$Field, [Int]$Row, [Int]$Col)
    $NeighbourCount = 0
    # test 1: cell in the upper left
    if (($Row - 1 -gt 0) -and ($Col - 1 -gt 0))
    {
        $NeighbourCount += $Field[($Row-1), ($Col-1)]
    }
    # test 2: cell from above
    if ($Row - 1 -gt 0)
    {
        $NeighbourCount += $Field[($Row-1), $Col]
    }
    # test 3: cell in upper right
    if (($Row - 1 -gt 0) -and ($Col -lt $Field.GetLength(1)-1))
    {
        $NeighbourCount += $Field[($Row-1), ($Col+1)] 
    }
    # test 4: cell from right
    if ($Col + 1 -lt $Field.GetLength(1)-1)
    {
        $NeighbourCount += $Field[$Row, ($Col+1)]
    }
    # test 5: cell below on the right
    if (($Row + 1 -lt $Field.GetLength(0)) -and ($Col + 1 -lt $Field.GetLength(1)-1))
    {
        $NeighbourCount += $Field[($Row+1), ($Col+1)]     
    }
    # test 6: cell below
    if (($Row + 1 -lt $Field.GetLength(0)))
    {
        $NeighbourCount += $Field[($Row+1), $Col] 
    }
    # test 7: cell below on the left
    if ($Row + 1 -lt $Field.GetLength(0)-1 -and $Col -gt 0)
    {
        $NeighbourCount += $Field[($Row+1), ($Col-1)] 
    }
    # test 8: cell from left
    if ($Col - 1 -gt 0)
    {
        $NeighbourCount += $Field[$Row, ($Col-1)]
    }
    
    # Return the neighbour count
    return $NeighbourCount
}

<#
 .Synopsis
 Outputs the whole field as text
#>
function ShowGoLField
{
    [CmdletBinding()]
    param([Parameter(Mandatory=$true)][Byte[,]]$Field, [Int]$Generation)
    $Population = 0
    switch($Field.GetLength(1))
    {
      { $_ -ge 20} { $Banner = "Generation Nr. $Generation"; break}
      { $_ -ge 10} { $Banner = "Gen $Generation"; break }
      default { $Banner = $Generation }
    }  
    # Really annoying the need for another round of parantheses
    Write-Host ([String]::new("=", $Field.GetLength(1) + 4))
    $SpaceCount = ($Field.GetLength(1) - $Banner.Length) / 2
    Write-Host ("=$([String]::new(' ', $SpaceCount))") -NoNewline
    Write-Host $Banner -NoNewline
    Write-Host ("$([String]::new(' ', $SpaceCount+2))=") 
    Write-Host ([String]::new("=", $Field.GetLength(1) + 4))
    for($i = 0;$i -lt $Field.GetLength(0);$i++)
    {
        $RowOutput = ""
        for($j = 0;$j -lt $Field.GetLength(1);$j++)
        {
            # Won't work with positional parameters ??? (SO help!)
            $RowOutput += $Field[$i,$j] -eq 1 | Iif -TrueOpt {"X"} -FalseOpt {"."}
            $Population += $Field[$i,$j]
        }
        Write-Host $RowOutput
    }
    Write-Host "Population: $Population"
    Write-Host "`n"
    return $Population
}

<#
 .Synopsis
 Outputs the whole field in the console window
#>
function ShowGoLFieldConsole
{
    [CmdletBinding()]
    param([Parameter(Mandatory=$true)][Byte[,]]$Field, [Int]$Generation, [String]$Cellcolor)
    $Population = 0
    $XPos = 0
    $YPos = 2
    switch($Field.GetLength(1))
    {
      { $_ -ge 20} { $Banner = "Generation Nr. $Generation"; break}
      { $_ -ge 10} { $Banner = "Gen $Generation"; break }
      default { $Banner = $Generation }
    }  
    [Console]::Clear()
    [Console]::SetCursorPosition($XPos, $YPos)
    [Console]::ForegroundColor = "Green"
    [Console]::WriteLine([String]::new("=", $Field.GetLength(1) + 4))
    # Really annoying the need for another round of parantheses
    $SpaceCount = ($Field.GetLength(1) - $Banner.Length) / 2
    $GenSpaceOffset = $Generation -gt 9 | Iif -TrueOpt { 1 } -FalseOpt { 2 }
    [Console]::WriteLine("=$([String]::new(' ', $SpaceCount))$Banner$([String]::new(' ', $SpaceCount+$GenSpaceOffset))=")
    [Console]::WriteLine([String]::new("=", $Field.GetLength(1) + 4))
    [Console]::ForegroundColor = "White"
    for($i = 0;$i -lt $Field.GetLength(0);$i++)
    {
        $RowOutput = ""
        for($j = 0;$j -lt $Field.GetLength(1);$j++)
        {
            # Won't work with positional parameters ??? (SO help!)
            $RowOutput += $Field[$i,$j] -eq 1 | Iif -TrueOpt {"X"} -FalseOpt {"."}
            $Population += $Field[$i,$j]
        }
        # [Console]::WriteLine($RowOutput)
        $RowOutput.ToCharArray().ForEach{
            [Console]::ForegroundColor = $_ -eq "X" | Iif -TrueOpt { $Cellcolor } -FalseOpt { "White"}
            [Console]::Write($_)
        }
    [Console]::ForegroundColor = "White"
    [Console]::WriteLine()
    }
    [Console]::WriteLine("Population: $Population")
    # return command is not really necessary
    return $Population
}

<#
<#
 .Synopsis
 Internal function
#>
function TestGoLRule
{
    param([Int]$FieldValue, [Int]$NeighbourCount)
    if ($FieldValue)
    {
        $NeighbourCount -eq 2 -or $NeighbourCount -eq 3
    }
    else
    {
        $NeighbourCount -eq 3
    }
}

<#
 .Synopsis
 Starts a GoL run
#>
function Start-GoL
{
    [CmdletBinding()]
    param([Parameter(ValueFromPipeline=$true)][Byte[,]]$GoLField,
          [Int]$MaxGenerationen=0,
          [Switch]$ShowGoLField=$true,
          [Int]$CycleSpeed=500,
          [String]$CellColor = "Yellow"
    )
    $Generation = 1
    $FieldRowSize = $GoLField.GetLength(0)
    $FieldColSize = $GoLField.GetLength(1)
    while($true)
    {
        if ($ShowGoLField)
        {
            $Population = ShowGoLFieldConsole -Field $GoLField -Generation $Generation -CellColor $CellColor
            # Wait a few cycles
            Start-Sleep -Milliseconds $CycleSpeed
        }
        else
        {
            $Population = @($GoLField | Where-Object { $_ -eq 1 }).Count
        }
        if ($Population -eq 0)
        {
            Write-Warning ($MsgTable.GoLPopulationTerminated -f $Generation)
            if ($ShowGoLField)
            {
                return
            }
            else
            {
                return 0
            }
            break
        }
        $NeighbourField = [Byte[,]]::new($FieldRowSize, $FieldColSize)
        for($i = 0;$i -lt $GoLField.GetLength(0);$i++)
        {
            for($j = 0;$j -lt $GoLField.GetLength(1);$j++)
            {
                $NeighbourField[$i, $j] = GetNeighbourCount -Field $GoLField -Row $i -Col $j
            }
        }
        if ($Generation -eq $MaxGenerationen)
        {
            if ($ShowGoLField)
            {
                return
            }
            else
            {
                return $Population
            }
        }
        $Generation++
        for($i = 0;$i -lt $GoLField.GetLength(0);$i++)
        {
            for($j = 0;$j -lt $GoLField.GetLength(1);$j++)
            {
                $GoLField[$i, $j] = TestGolRule -FieldValue $GoLField[$i, $j] -NeighbourCount $NeighbourField[$i, $j] | iif -TrueOpt { 1 } -FalseOpt { 0 }
            }
        }
    }
}

<#
 .Synopsis
 Creates a new GoL field with a predefined pattern
 .Notes
 DefaultParametersetName is really helpful - thanks to James Brundage and his 'Fun with parametersets' blog post many years ago
#>
function New-GolField
{
    [CmdletBinding(DefaultParametersetname="")]
    param([Parameter(Parametersetname="FilePath")][String]$GolPattern,
          [Parameter(Mandatory=$true)][String]$PatternFilePath,
          [Parameter(Parametersetname="FilePath")][Int]$FieldRowSize=20,
          [Parameter(Parametersetname="FilePath")][Int]$FieldColSize=20,
          [Parameter(Parametersetname="Patterns")][Switch]$ShowPatterns)
    $GolField = [Byte[,]]::new($FieldRowSize,$FieldColSize)
    $GolPatterns = Import-PowerShellDataFile -Path $PatternFilePath
    if ($PSBoundParameters.ContainsKey("ShowPatterns"))
    {
        $GolPatterns.Keys.ForEach{
         $_
        }
        return
    }
    if (!$GolPatterns.ContainsKey($GolPattern))
    {
        throw ($MsgTable.GotPatternNotExist -f $GolPattern)      
    }
    $GolLines = $GolPatterns.$GolPattern -split "`n"
    $RowCount = $GolLines.Length
    $MaxCol = $GolLines | ForEach-Object -Begin { $Max = 0 } -Process { $Max = [Math]::Max($Max, $_.Length)} -End { $Max }

    [int]$StartCol = ($FieldColSize - $MaxCol) / 2
    [int]$StartRow = ($FieldRowSize - $RowCount) / 2

    for($r = 0;$r -lt $RowCount;$r++)
    {
        $c = 0
        $GolLines[$r].ToCharArray().ForEach{
            $GolField[($StartRow + $r), ($StartCol + $c)] = $GolLines[$r].ToCharArray()[$c] -eq "X" | Iif -TrueOpt { 1 } -FalseOpt { 0}
            $c++
        }
    }
    # this can be tricky - the return value has to be an 2D array not just a sequence of values
    ,$GolField
}
