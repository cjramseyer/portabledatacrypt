
<#
Script: Set-Secrets.ps1
Author: CJ Ramseyer
Date: 11/1/2023
Modified: 11/3/2023
Version: v1.2.0

BREAKING CHANGES:
OTHER CHANGES:
- Added parameter for the target location of the config (ScriptDest)
- Added logic to prevent deleting source file if the target file was not created

DISCLAIMER: 2023 CJ Ramseyer, All rights reserved.
This sample script is not supported under any support program or service. The sample script is provided AS-IS without warranty of any kind.
CJ Ramseyer disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose.
The entire risk arising out of the use or performance of the sample script remains with you.
In no event shall CJ Ramseyer, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever
(including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out
of the use of or inability to use the sample script, even if CJ Ramseyer has been advised of the possibility of such damages. 
#>

<#
.Synopsis
    Script to protect (encode) and unprotect (decode) the SecretData configuration
.Description
    Script to protect (encode) and unprotect (decode) the SecretData configuration
.Parameter ScriptDest
    Required parameter to specify the script location
.Example
    .\Set-Config.ps1 -ScriptDest C:\Scripts\SecretData
.NOTES
    Set-Config.ps1 will NOT be copied to the same directory as the executing scripts. It is intended to be used during setup and when interim changes must be made
#>

#Requires -Version 5.1
#Requires -RunAsAdministrator

[CmdletBinding()]
param
(
    [parameter(Mandatory=$true)][string]$ScriptDest
)

$PathtoSecretsFile = "$ScriptDest\secrets.ini"
$PathtoSecretsLockFile = "$ScriptDest\secrets.lck"
$SrcSys = "$env:computername"
$CertName = "SecretData-$SrcSys"

if(Test-Path $PathtoSecretsFile)
{
    $Mode = "Encrypt"
}
elseif(Test-Path $PathtoSecretsLockFile)
{
    $Mode = "Decrypt"
}
else
{
    Write-Output "The script is unable to perform proper operation"
    Exit 1
}

#Encrypt config
switch($Mode)
{
    "Encrypt"
    {
        #Protect the configuration file
        Protect-CmsMessage -Path $PathtoSecretsFile -To cn=$CertName -OutFile $PathtoSecretsLockFile

        #Only remove the original config file if the lock file was successfully created
        if(Test-Path -Path $PathtoSecretsLockFile)
        {
            Remove-Item $PathtoSecretsFile
        }
    }
    "Decrypt"
    {
        #UnProtect the configuration file
        Unprotect-CmsMessage -Path $PathtoSecretsLockFile | Out-File $PathtoSecretsFile -Encoding utf8

        #Only remove the lock file if the config file was successfully created
        if(Test-Path -Path $PathtoSecretsFile)
        {
            Remove-Item $PathtoSecretsLockFile
        }
    }
}
