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
cd Redist

# Process *.redistlist
redistsetup.exe Default
```

## Prepare storage device

Next, Prepare an empty directory or even better prepare a [virtual hard disk](https://docs.microsoft.com/en-us/windows-server/storage/disk-management/manage-virtual-hard-disks) (VHDX) to store the installation binaries.

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
c:\> mkdir %MOUNT%\License
c:\> robocopy /E "%ProgramData%\Embarcadero" %MOUNT%\License
```

## Prepare automated setup script

A portable `RAD Studio` requires some configuration to make it works in new machine.  A simple setup cmd and powershell scripts is available: `setup.cmd` and `setup.ps1`

The portable installation is done.

## Manage RAD Studio installation with WIM

Storing RAD Studio installation in virtual hard disk allow future re-use.  Each RAD Studio version will release few patches or updates in it's life time.  Using virtual hard disk to store RAD Studio installation shall result to many virtual disk files.

Most files remain unchanged among those patches or updates release for same RAD Studio version.  Storing images to a single [Windows Imaging File or WIM](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/capture-and-apply-an-image) is particularly suitable as file size won't over grow among patches or updates.

**Capture an image**

Execute the following command in privilege mode to capture a fresh RAD Studio installation to a WIM file:

```cmd
c:\> set WimFile=c:\radstudio.wim

c:\> dism /Capture-Image /ImageFile:%WimFile% /Compress:max /CaptureDir:%MOUNT% /Name:"RAD Studio" /Description:"RAD Studio"
```

**Append new image**

To archive subsequent release into same WIM file, use [Append-Image](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/append-a-volume-image-to-an-existing-image-using-dism--s14?view=windows-11):

    c:\>dism /Append-Image /ImageFile:%WimFile% /CaptureDir:%MOUNT% /Name:"RAD Studio Patch 1" /Description:"RAD Studio Patch 1"

**List images**

For example, this is a WIM image file storing 2 releases:

```
c:\> dism /Get-ImageInfo /ImageFile:%WimFile%

Deployment Image Servicing and Management tool
Version: 10.0.22000.1

Details for image : radstudio.wim

Index : 1
Name : Embarcadero® Delphi 11.0 Version 28.0.42600.6491
Description : Embarcadero® Delphi 11.0 Version 28.0.42600.6491
Size : 22,793,912,423 bytes

Index : 2
Name : Embarcadero® Delphi 11.0 Version 28.0.42600.6491 November Patch
Description : Embarcadero® Delphi 11.0 Version 28.0.42600.6491 November Patch
Size : 31,209,573,105 bytes

The operation completed successfully.
```

**Extract Image**

To extract an image (e.g.: Index 2) from WIM file:

    c:\> dism /Apply-Image /ImageFile:%WimFile% /Index:2 /ApplyDir:D:\

The WIM file image can extract with [7-Zip](https://www.7-zip.org/) too.

# Install Portable RAD Studio

Clone and mount `RAD Studio` storage device followed by `install.cmd`.

# Uninstall Portable RAD Studio

It is good practice clean up all registered DLLs in current installation before install new version of RAD Studio.
