
#Requires -Version 5.1
#Requires -RunAsAdministrator

$CurDir = split-path -parent $MyInvocation.MyCommand.Definition
$SrcSys = "$env:computername"
$CertName = "SecretData-$SrcSys"

#Protect the configuration file
Protect-CmsMessage -Path $CurDir\secrets.ini -To cn=$CertName -OutFile $CurDir\secrets.txt
Remove-Item $CurDir\secrets.ini

Unprotect-CmsMessage -Path $CurDir\secrets.txt | Out-File $CurDir\secrets.ini
Remove-Item $CurDir\secrets.txt
