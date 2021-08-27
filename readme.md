# Introduction

Embarcadero [RAD Studio](https://www.embarcadero.com/products/rad-studio/) usually install via ISO file or Web based installer.  The default installation path is `%ProgramFiles(x86)%\Embarcadero\Studio`.

The whole installation process consume quite some times.  This guide shows how to prepare RAD Studio installation as portable application to avoid time consuming installation process.

# Prepare Portable Installation

## Install RAD Studio

First, install `RAD Studio` in default location.  Select all available platforms and libraries when possible.

**Interbase Developer Editon** is an individual package that can install by user anytime.  It is not necessary to include in the portable preparation.

## Install additional packages

Next, launch RAD Studio and install additional package from [GetIt Package Manager](http://docwiki.embarcadero.com/RADStudio/Sydney/en/GetIt_Package_Manager).  For example: [Ribbon Classic Control](http://docwiki.embarcadero.com/RADStudio/Sydney/en/Ribbon_Controls)

## Prepare storage device

Next, Prepare an empty directory or even better prepare a [virtual hard disk](https://docs.microsoft.com/en-us/windows-server/storage/disk-management/manage-virtual-hard-disks) (VHDX) to store the installtion binaries.

## Copy Files

Next, copy all files and folders to the storage device:

    c:\> robocopy /E "%ProgramFiles(x86)%\Embarcadero\Studio" <mount-point>

And the `public` folders:

    c:\> robocopy /E "%Public%\Documents\Embarcadero\Studio" <mount-point>\Public

## Backup default registry entries

RAD Studio installer add entries to registry in `HKEY_LOCAL_MACHINE`, backup the registry:

Backup `HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Embarcadero` registry item:

    c:\> reg export HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Embarcadero <mount-point>\21.0.reg

## Copy license files

RAD Studio requires valid license slip to work properly.  Make backup of the license files:

```cmd
c:\> mkdir <mount-point>\License
c:\> robocopy /E "%ProgramData%\Embarcadero" <mount-point>\License
```

## Prepare automated setup script

A portable `RAD Studio` requires some configuration to make it works in new machine.  A simple setup cmd and powershell scripts is available: `setup.cmd` and `setup.ps1`

The portable installation is done.

# Install Portable RAD Studio

Clone and mount `RAD Studio` storage device followed by `install.cmd`.

# Uninstall Portable RAD Studio

It is good practice clean up all registered DLLs in current installation before install new version of RAD Studio.
