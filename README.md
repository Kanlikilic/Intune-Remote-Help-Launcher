# Intune Remote Help Launcher

Intune Remote Help Launcher is a PowerShell WPF application that helps IT administrators search Intune-managed devices, launch Microsoft Remote Help sessions, and perform common device actions from a single interface.

Instead of navigating through multiple screens in the Intune admin center, simply search for a device or user and perform the action you need.

* * *

## What can it do?

- Search Intune-managed devices by device name or primary user
- Display all managed devices assigned to the searched primary user
- Navigate between multiple matching devices directly from the device card
- Supports Windows, Android, iOS and macOS managed devices
- View device information
  - Operating System
  - Compliance Status
  - Ownership
  - Model
  - Last Sync
- Launch Microsoft Remote Help sessions (Windows)
- Send Sync commands
- Send Restart commands
- Open the selected device directly in the Intune admin center
- View locally stored Remote Help session history

* * *

## Authentication

The tool uses Microsoft Graph delegated authentication.

No application registration, client secret, or stored credentials are required.

If the required Microsoft Graph PowerShell module is not installed, the tool automatically attempts to install it for the current user before authentication.

> Windows PowerShell or PowerShell 7 is recommended.
>
> PowerShell ISE is not recommended because Microsoft Graph authentication may not behave correctly.

* * *

## Required Microsoft Graph Permissions

| Permission |
| ---------- |
| DeviceManagementManagedDevices.Read.All |
| DeviceManagementManagedDevices.ReadWrite.All |
| DeviceManagementManagedDevices.PrivilegedOperations.All |
| Directory.Read.All |

* * *

## Getting Started

Run the script:

```powershell
.\IntuneRemoteHelpLauncher.ps1
```

If the Microsoft Graph Authentication module cannot be installed automatically, install it manually:

```powershell
Install-Module Microsoft.Graph.Authentication -Scope CurrentUser
```

* * *

## Session History

Remote Help sessions are stored locally and can also be viewed directly from within the application.

Default location:

```text
%LOCALAPPDATA%\IntuneRemoteHelpLauncher\
```

* * *

## Version

**Current Release:** v0.2.0

### What's New in v0.2.0

- Added support for displaying multiple managed devices for the searched primary user
- Added previous/next navigation between matching devices
- Improved device card layout
- Improved user search experience

* * *

## License

MIT License - see LICENSE for details.

* * *

## Author

Built by **Mert Efe Kanlıkılıç**

Intune Remote Help Launcher is an independent community project and is not affiliated with or endorsed by Microsoft.
