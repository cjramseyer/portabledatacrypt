
<#
Script: Setup-SecretData.ps1
Author: CJ Ramseyer
Date: 11/1/2023
Modified:
Version: v1.0.0

BREAKING CHANGES:
OTHER CHANGES:
- Initial draft

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
    Script to create self-signed document encryption certificate
.Description
    Script to create self-signed document encryption certificate
.Parameter ScriptDest
    Optional parameter to generate self-signed file encryption certificate
.Example
    .\Setup-ConfigProtect.ps1 -ScriptDest C:\Scripts\portabledatacrypt
.Example
    .\Setup-ConfigProtect.ps1
.NOTES
    Script will generate documentation encryption certificate and export (with password) the certificate with the private key to make it portable
    When the ScriptDest (Script Destination) parameter is specified, the generated encryption cert will be exported to the folder where scripts are run
    When the ScriptDest (Script Destination) parameter is NOT specified, the generated encryption cert will be exported to the current folder
    Setup will check for existing certificate and exit if one already exists.
#>

#Requires -Version 5.1
#Requires -RunAsAdministrator

[CmdletBinding()]
param
(
    [parameter(Mandatory=$false)][string]$ScriptDest
)

$CurDir = split-path -parent $MyInvocation.MyCommand.Definition
$SrcSys = $ENV:COMPUTERNAME
$CertName = "SecretData-$SrcSys"

#Before generating the encryption cert, check to see if one already exists.
$ProtectCert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Subject -eq "CN=$CertName"}

if([string]::IsNullOrEmpty($ProtectCert))
{
    #Create config encryption cert stored in the machine account, then export with the private key
    $Cert = New-SelfSignedCertificate -DnsName "$CertName" -CertStoreLocation "Cert:\LocalMachine\My" -KeyUsage KeyEncipherment,DataEncipherment, KeyAgreement -Type DocumentEncryptionCert
    $CertThumb = $Cert.Thumbprint

    $CertPass = Read-Host "Please specify the secrets encryption cert export password (this will be required to import the cert on another machine): " | ConvertTo-SecureString -Force -AsPlainText

    if([string]::IsNullOrEmpty($ScriptDest))
    {
        $TgtDir = "$CurDir"
    }
    else
    {
        $TgtDir = "$ScriptDest"
    }

    $CertParams = @{
        Cert = "Cert:\LocalMachine\My\$CertThumb"
        FilePath = "$TgtDir\$CertName.pfx"
        Password = $CertPass
    }

    Export-PfxCertificate @CertParams

    Write-Output "Encryption cert exported to $CurDir\RemoteCopy-$SrcSys.pfx"
}
else
{
    Write-Output "The secrets protection certificate is already installed on this system"
    Write-Output "Remove the existing certificate if a new one is needed and rerun setup"
}
