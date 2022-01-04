# Introduction

Embarcadero [RAD Studio](https://www.embarcadero.com/products/rad-studio/) usually install via ISO file or Web based installer.  The default installation path is `%ProgramFiles(x86)%\Embarcadero\Studio`.

The whole installation process consume quite some times.  This guide shows how to prepare RAD Studio installation as portable application to avoid time consuming installation process.

# Prepare Portable Installation

## Install RAD Studio

First, install `RAD Studio` in default location.  Select all available platforms and libraries when possible.

**Interbase Developer Editon** is an individual package that can install by user anytime.  It is not necessary to include in the portable preparation.

## Install Patch

If Zip archive patch is available the RAD Studio, it usually patch files in `bin*` folder but won't patch `Redist`.

To update files in `Redist` folder:

```
# Navigate to Redist folder
cd Redist`

# Process *.redistlist
redistsetup.exe Default
```

## Prepare storage device

Next, Prepare an empty directory or even better prepare a [virtual hard disk](https://docs.microsoft.com/en-us/windows-server/storage/disk-management/manage-virtual-hard-disks) (VHDX) to store the installtion binaries.

Mount the VHDX to a mount point. e.g.: `E:\`

    c:\> set MOUNT=E:\

## Copy Files

Next, copy all files and folders to the storage device:

    c:\> robocopy /E "%ProgramFiles(x86)%\Embarcadero\Studio" %MOUNT%

And the `public` folders:

    c:\> robocopy /E "%Public%\Documents\Embarcadero" %MOUNT%\Public

## Backup default registry entries

RAD Studio installer add entries to registry in `HKEY_LOCAL_MACHINE`, backup the registry:

Backup `HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Embarcadero` registry item:

    c:\> reg export HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Embarcadero %MOUNT%\22.0.reg

## Copy license files

RAD Studio requires valid license slip to work properly.  Make backup of the license files:

```cmd
c:\> mkdir <mount-point>\License
c:\> robocopy /E "%ProgramData%\Embarcadero" %MOUNT%\License
```

## Prepare automated setup script

A portable `RAD Studio` requires some configuration to make it works in new machine.  A simple setup cmd and powershell scripts is available: `setup.cmd` and `setup.ps1`

The portable installation is done.

# Install Portable RAD Studio

Clone and mount `RAD Studio` storage device followed by `install.cmd`.

# Uninstall Portable RAD Studio

It is good practice clean up all registered DLLs in current installation before install new version of RAD Studio.
