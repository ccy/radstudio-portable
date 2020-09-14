$ErrorActionPreference = "Stop"

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  Exit (Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File $PSCommandPath" -Verb RunAs -Wait -PassThru).ExitCode
}

function Do-License {
  param (
    [ValidateScript({ Test-Path -Path $_ -PathType Container })]
    [string]$LicensePath
  )

  Get-ChildItem $LicensePath -Force | % {
    Copy-Item $_.FullName -destination "$Env:ProgramData\Embarcadero" -Recurse -Force
  }
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

function Do-RegisterServer {
  param (
    [ValidateScript({ Test-Path -Path $_ -PathType Container })]
    [string]$BinPath,
    [ValidateScript({ Test-Path -Path "$BinPath\$_" -PathType Leaf })]
    [string]$ServerFileName
  ) 

  $shell = New-Object -ComObject WScript.Shell
  $shell.Run("$BinPath\tregsvr.exe $BinPath\$ServerFileName")
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

#Do-Registry (($Root, "$BDSVersion.reg") -join '\')
Do-Shortcut (($BDSRoot, 'bin') -join '\') "Delphi 10.4" "-pDelphi"
Do-SystemPath (($BDSRoot, 'bin') -join '\')
Do-SystemPath (($BDSRoot, 'bin64') -join '\')
Do-RegisterServer (($BDSRoot, 'bin') -join '\') 'Borland.Build.Tasks.Common.tlb'
Do-RegisterServer (($BDSRoot, 'bin') -join '\') 'Borland.Studio.Interop.tlb'
Do-RegisterServer (($BDSRoot, 'bin') -join '\') 'Borland.Studio.ToolsAPI.tlb'
Do-RegisterServer (($BDSRoot, 'bin') -join '\') 'Embarcadero.Studio.Modeling.tlb'
Do-RegisterServer (($BDSRoot, 'bin') -join '\') 'midas.dll'
Do-RegisterServer (($BDSRoot, 'bin') -join '\') 'getithelper270.dll'
Do-License (($Root, 'License') -join '\')
#Do-ComputerName 'WINDOWS'
Pause