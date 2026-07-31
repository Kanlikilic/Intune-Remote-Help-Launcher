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
| DeviceManagementManagedDevices.PrivilegedOperations.All |
| Directory.Read.All |

* * *

## Remote Help Requirements

Microsoft Remote Help must be licensed and configured in the tenant.

The Remote Help application must be installed on both the administrator device and the end-user device.

The signed-in administrator must also have the required Intune RBAC permissions to view managed devices, perform device actions, and initiate Remote Help sessions.

> Remote Help functionality in this tool uses Microsoft Graph beta endpoints. Microsoft Graph beta APIs are subject to change and may require future updates to the tool.

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

## Version

**Current Release:** v0.2.1

### What's New in v0.2.1

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