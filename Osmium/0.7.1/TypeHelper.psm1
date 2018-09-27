<#
 .Synopsis
 Helper functions for dealing with types
#>

Set-StrictMode -Version Latest

<#
 .Synopsis
 Find a specific type with all loaded assemblies
#>
function Find-Type
{
    [CmdletBinding()]
    param([Parameter(ParameterSetName="SearchByName")][String]$Typename,
          [Parameter(ParameterSetName="SearchByType", ValueFromPipeline=$true)][Type]$Type,
          [Switch]$IncludeInterface
          )
    $PropHash = @()
    $PropHash += @{n="Name";e={$_.Name}}
    $PropHash += @{n="Namespace";e={$_.Name}}
    if ($PSBoundParameters.ContainsKey("IncludeInterface"))
    {
        $PropHash += @{n="Interfaces";e={$_.GetInterfaces().Name -join ","}}
    }
    if ($PSBoundParameters.ContainsKey("Typename"))
    {
        # go through all loaded assemblies public types in classes only
        try {
            [System.AppDomain]::CurrentDomain.GetAssemblies().GetTypes().Where{
                $_.IsPublic -and $_.IsClass -and $_.Name -eq $Typename
            } | Select-Object $PropHash
        }
        catch
        {
            Write-Warning "Find-Type with Typename parameter: $_"    
        }
    }
    if ($PSBoundParameters.ContainsKey("Type"))
    {
        # go through all loaded assemblies public types in classes only
        try {
            [System.AppDomain]::CurrentDomain.GetAssemblies().GetTypes().Where{
                $_.FullName -eq $Type.FullName
            } | Select-Object $PropHash
        }
        catch
        {
            Write-Warning "Find-Type with Type parameter: $_"    
        }
    }
}

<#
 .Synopsis
 Finds all types that implements a specific interface
#>
function Find-Interface
{
    [CmdletBinding()]
    param([String]$Interfacename)
    $PropHash = @()
    $PropHash += @{n="Name";e={$_.Name}}
    $PropHash += @{n="Namespace";e={$_.Namespace}}
    # go through all loaded assemblies public types in classes only
    try {
        [System.AppDomain]::CurrentDomain.GetAssemblies().GetTypes().Where{
            $_.IsPublic -and $_.IsClass -and $_.GetInterfaces().Count -gt 0 -and
            $_.GetInterfaces().Name -eq $Interfacename
        } | Select-Object $PropHash | Sort-Object Name
    }
    catch
    {
        Write-Warning "Find-Interface: $_"    
    }
}

<#
 .Synopsis
 Get the constructors of a type
#>
function Get-Constructor
{
    param([Parameter(ValueFromPipeline=$true)][Type]$Type)

    $Type.GetConstructors().ForEach{
        [PSCustomObject]@{
            Name = $_.Name
            ParameterCount = $_.GetParameters().Count
            Parameters = $_.GetParameters().ForEach{
                "{0}:{1}" -f $_.Name, $_.ParameterType
            }
        }
    }
}

<#
.Synopsis
Finds all methods with a given name
#>
function Find-MethodMember
{
    [CmdletBinding()]
    param([String]$Methodname, [Switch]$FindExact)
    [AppDomain]::CurrentDomain.GetAssemblies().GetTypes().Where{
        $_.IsClass -and $_.IsPublic
    } | Where-Object {
        $Method = ""
        if ($PSBoundParameters.ContainsKey("FindExact"))
        {
            if ($_.GetMethods().Count -gt 0 -and $_.GetMethods().Name -eq $Methodname)
            {
                $Method = @($Methodname)
            }
        }
        else
        {
            if ($_.GetMethods().Count -gt 0 -and $_.GetMethods().Name -match $Methodname)
            {
                $Method = @($_.GetMethods().Name -match $Methodname)
            }
        }
        # Check if the potential array contains the method name
        # ignore the rule violation IncorrectComparison with null because its stupid (in this specific case)
        $Method -ne ""
    } | Select-Object -Property @{n="Method";e={$Method}},
                                @{n="Class";e={$_.Name}}, FullName, Module | Sort-Object -Property Method
}

<#
.Synopsis
Finds all properties with a given name
#>
function Find-PropertyMember
{
    [CmdletBinding()]
    param([String]$Propertyname, [Switch]$FindExact)
    [AppDomain]::CurrentDomain.GetAssemblies().GetTypes().Where{
        $_.IsClass -and $_.IsPublic
    } | Where-Object {
        $Property = ""
        if ($PSBoundParameters.ContainsKey("FindExact"))
        {
            if ($_.GetProperties().Count -gt 0 -and $_.GetProperties().Name -eq $Propertyname)
            {
                $Property =  $Propertyname 
            }
        }
        else
        {
            if ($_.GetProperties().Count -gt 0 -and $_.GetProperties().Name -match $Propertyname)
            {
                $Property = $Propertyname
            }
        }
        # Check if the potential array contains the property name
        # ignore the rule violation IncorrectComparison with null because its stupid (in this specific case)
        $Property -ne ""
    } | Select-Object -Property @{n="Property";e={$Property}},
                                @{n="Class";e={$_.Name}}, FullName, Module | Sort-Object -Property Property
}

<#
.Synopsis
Invoke a private generic method
.Notes
Requires that there is only one method with that name
#>
function Invoke-PrivateGenericMethod
{
    [CmdletBinding()]
    param([Type]$Type, [String]$Methodname, [Type]$ParamType, [Object]$ParamValue)
    # Call the method with a little bit of indirect reflection magic
    # Amazing how PowerShell simplifies the use of enum params
    # But beware: Works only with there is method overloading - otherwise parametertypes matters
    $Method = $Type.GetMethod($Methodname, @("Static","NonPublic"))
    # Get the generic version of that method
    $GenMethod = $Method.MakeGenericMethod($ParamType) 
    # Invoke it
    $GenMethod.Invoke($null, $ParamValue) 
}

<#
.Synopsis
Invoke a generic method with arguments
.Notes
Requires that the method parameters are non generic :(
#>

function Invoke-GenericMethodEx
{
    param([Type]$InstanceType, [Type]$GenericType, [String]$Methodname, [Object[]]$MethodParameters)
    $ParameterTypes = @($MethodParameters.ForEach{$_.GetType() })
    # Assuming there is only one method with that name    
    $m = @($InstanceType.GetMethods().Where{$_.Name -eq $Methodname})
    if ($m.Length -gt 1)
    {
        throw "Multiple methods with $MethodName name found - try Invoke-GenericMethod"
    }
    # Convert every argument into a generic argument
    $GenParameters = $ParameterTypes.ForEach{ $m.GetGenericArguments()}
    # BindingFlags can be simplified in this method overloading
    # $Method = $InstanceType.GetMethod($MethodName, "Static,Public", $null, $ParameterTypes, $null)
    $Method = $InstanceType.GetMethod($MethodName, "Static,Public", $null, $GenParameters, $null)
    if ($Method -ne $null)
    {
        $GenMethod = $Method.MakeGenericMethod($GenericType)
        $GenMethod.Invoke($InstanceType, $MethodParameters)
   }
   else
   {
       throw "Method $MethodName not found on $InstanceType"
   }
}

<#
.Synopsis
Calls a generic method with only one overload and no generic arguments
#>
function Invoke-GenericMethod
{
    param([Type]$InstanceType, [Type]$GenericType, [String]$Methodname, [Object[]]$MethodParameters)
    $ParameterTypes = @($MethodParameters.ForEach{$_.GetType() })
    # Assuming there is only one method with that name    
    $m = @($InstanceType.GetMethods().Where{$_.Name -eq $Methodname})
    # BindingFlags can be simplified in this method overloading
    $Method = $InstanceType.GetMethod($MethodName, "Static,Public", $null, $ParameterTypes, $null)
    if ($Method -ne $null)
    {
        $GenMethod = $Method.MakeGenericMethod($GenericType)
        $GenMethod.Invoke($InstanceType, $MethodParameters)
   }
   else
   {
       throw "Method $MethodName not found on $InstanceType"
   }
}
