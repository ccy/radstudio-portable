$ErrorActionPreference = "Stop"

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  Exit (Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File $PSCommandPath" -Verb RunAs -Wait -PassThru).ExitCode
}

function Do-Shortcut($WorkingDir, $ShortFileName, $Arguments) {
  $shell = New-Object -ComObject WScript.Shell
  $shortcut = $shell.CreateShortcut($Env:ProgramData + "\Microsoft\Windows\Start Menu\Programs\" + "$ShortFileName.lnk")
  $shortcut.TargetPath = ($WorkingDir, 'bds.exe') -join '\'
  $shortcut.Arguments = $Arguments
  $shortcut.WorkingDirectory = $WorkingDir
  $shortcut.Save()
}

function Do-Registry {
  param (
    [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
    [string]$RegFile
  )
  $ScriptPath = $(Split-Path -Path $PSCommandPath)
  $tmp = New-TemporaryFile
  ((Get-Content -path $RegFile -Raw) -replace 'C:\\\\Program Files \(x86\)\\\\Embarcadero\\\\Studio\\\\',($ScriptPath -replace '\\','\\')) | Set-Content -Path $tmp
  reg import $tmp
  Remove-Item -Path $tmp
}

function Do-SystemPath {
  param (
    [ValidateScript({ Test-Path -Path $_ -PathType Container })]
    [string]$newPath
  )
  $arrPath = [System.Environment]::GetEnvironmentVariable("Path","Machine") -split ';'
  if ($arrPath -NotContains $newPath) {
    [System.Environment]::SetEnvironmentVariable("Path", ($arrPath + $newPath) -join ';', "Machine")
  }
}

function Do-RegisterSvr {
  param (
    [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
    [string]$RegSvr,
    [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
    [string]$FileName
  )

  $shell = New-Object -ComObject WScript.Shell
  echo ($RegSvr, $FileName -join ' ')
  $shell.Run("$RegSvr $FileName")
}

function Do-ComputerName ($RegisteredName) {
  if ($Env:ComputerName -ne $RegisteredName) {
    $Confirm = Read-Host "Current computer name is $Env:ComputerName.`nPress Y to change to $RegisteredName to keep RAD Studio license active."

    if ($Confirm -ieq 'y') {
      echo "Chanage ComputerName to $RegisteredName"
      $RenameScript = "PowerShell {Rename-Computer -Restart -NewName $RegisteredName}"
      $shell = New-Object -ComObject WScript.Shell
      $shell.Run("PowerShell Start-Process -Verb RunAs $RenameScript")
    }
  }
}

$BDSVersion = "21.0"
$Root = $(Split-Path -Path $PSCommandPath).TrimEnd('\')
$BDSRoot = $(Split-Path -Path $PSCommandPath).TrimEnd('\'), "$BDSVersion" -join '\'
$BDSBin = $BDSRoot, 'bin' -join '\'
$BDSBin64 = $BDSRoot, 'bin64' -join '\'
$tregsvr = $BDSBin, "tregsvr.exe" -join '\'
$tregsvr64 = $BDSBin64, "tregsvr.exe" -join '\'
$RegAsm = $Env:SystemRoot, "Microsoft.NET\Framework\v4.0.30319\RegAsm.exe" -join '\'

#Do-Registry (($Root, "$BDSVersion.reg") -join '\')
Do-Shortcut (($BDSRoot, 'bin') -join '\') "Delphi 10.4" "-pDelphi"
Copy-Item -Recurse -Force -Path ($Root, "Public\$BDSVersion\Styles" -join '\') -Destination (New-Item -Force -Type Directory -Path "$Env:Public\Documents\Embarcadero\Studio\$BDSVersion")
Get-ChildItem -depth 1 -Path $BDSBin -Include *.cfg, rsvars.bat | foreach { (Get-Content -Raw -Path $_.FullName) -replace [regex]::escape('c:\program files (x86)\embarcadero\studio'), [regex]::escape($Root) | Set-Content -Path $_.FullName }
Do-SystemPath (($BDSRoot, 'bin') -join '\')
Do-SystemPath (($BDSRoot, 'bin64') -join '\')

Get-ChildItem -Depth 1 -Path $BDSBin -Include Borland.*.dll | foreach { Do-RegisterSvr $RegAsm $_.FullName }
Get-ChildItem -Depth 1 -Path $BDSBin -Include Embarcadero.*.dll | foreach { Do-RegisterSvr $RegAsm $_.FullName }
Get-ChildItem -Depth 1 -Path $BDSBin -Include *.tlb | foreach { Do-RegisterSvr $tregsvr $_.FullName }
Get-ChildItem -Depth 1 -Path $BDSBin -Include midas.dll, getithelper270.dll | foreach { Do-RegisterSvr $tregsvr $_.FullName }
Get-ChildItem -Depth 1 -Path $BDSBin64 -Include midas.dll | foreach { Do-RegisterSvr $tregsvr64 $_.FullName }
Copy-Item -Recurse -Force (($Root, 'License', '*') -join '\') -Destination (New-Item -Force -Type Directory -Path "$Env:ProgramData\Embarcadero")
#Do-ComputerName 'WINDOWS'
Pause