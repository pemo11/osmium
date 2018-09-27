<#
 .Synopsis
 Testing calling a private generic method
#>

$CSCode = @'
using System; using System.Collections.Generic;
public class GTest
{

  private static void GetData<T>(T Arg)
  {
    Console.WriteLine("Value: {0}, Type: {1}", Arg, Arg.GetType().FullName);
  }

  // This is a little tricky even for experienced C# devs - wouldn't have been able to solve this without help from SO
  private static bool Compare<T>(T x, T y)
  {
     return EqualityComparer<T>.Default.Equals(x, y);
  }
  
  private static bool TestData1<T>(T Arg)
  {
    int v = Convert.ToInt32(Arg);
    return (Arg.GetType() == typeof(Int32) && Compare<int>(v, 1234));
  }

  // Parameters are all of the same generic type
  public static Int32 TestData2<T>(T Arg1, T Arg2, T Arg3)
  {
    // assumes that T is always Int32 - pretty lame, I know
    int v1 = Convert.ToInt32(Arg1);
    int v2 = Convert.ToInt32(Arg2);
    int v3 = Convert.ToInt32(Arg3);
    return v1 + v2 + v3;
  }

} 
'@

Add-Type -TypeDefinition $CSCode -Language CSharp 

describe "Generic method call tests" {

    $Psm1Path = Join-Path -Path $PSScriptRoot -Child ..\TypeHelper.psm1
    Import-Module -Name $Psm1Path -Force

    it "calls a private generic method with a magic cookie" {
        Invoke-PrivateGenericMethod -Type ([GTest]) -MethodName TestData1 -ParamType ([Int32]) -ParamValue 1234 | Should be $true
    }

    it "calls a generic method with three arguments of the same type" {
      $InstanceType = [GTest]
      $GenericType = [Int32]
      $MethodName = "TestData2"
      $MethodParameters = 11,22,33
      Invoke-GenericMethodEx -InstanceType $InstanceType -GenericType $GenericType `
       -MethodName $MethodName -MethodParameters $MethodParameters | Should be 66
  }

}