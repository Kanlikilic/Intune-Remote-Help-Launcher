# Intune Remote Help Launcher - v0.12 SDK test build
# UI-first design with basic Microsoft Graph backend.
# Windows PowerShell 5.1 compatible. Uses delegated device code authentication.

param(
    [switch]$DemoMode
)

if ([System.Threading.Thread]::CurrentThread.ApartmentState -ne "STA") {
    $arg = "-NoProfile -ExecutionPolicy Bypass -STA -File `"$PSCommandPath`""
    if ($DemoMode) { $arg += " -DemoMode" }
    Start-Process -FilePath "powershell.exe" -ArgumentList $arg
    exit
}

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Intune Remote Help Launcher v0.15"
        Width="1280" Height="780"
        MinWidth="1100" MinHeight="700"
        WindowStartupLocation="CenterScreen"
        Background="#07111F"
        FontFamily="Segoe UI">
    <Window.Resources>
        <SolidColorBrush x:Key="Bg" Color="#07111F"/>
        <SolidColorBrush x:Key="Panel" Color="#0D1828"/>
        <SolidColorBrush x:Key="Panel2" Color="#101D2F"/>
        <SolidColorBrush x:Key="Border" Color="#20344E"/>
        <SolidColorBrush x:Key="Text" Color="#F8FAFC"/>
        <SolidColorBrush x:Key="SubText" Color="#AFC0D4"/>
        <SolidColorBrush x:Key="Muted" Color="#73849A"/>
        <SolidColorBrush x:Key="Blue" Color="#2F6BFF"/>
        <SolidColorBrush x:Key="Green" Color="#35E888"/>

        <Style x:Key="Card" TargetType="Border">
            <Setter Property="Background" Value="{StaticResource Panel2}"/>
            <Setter Property="BorderBrush" Value="{StaticResource Border}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="CornerRadius" Value="16"/>
            <Setter Property="Padding" Value="24"/>
        </Style>

        <Style x:Key="PrimaryButton" TargetType="Button">
            <Setter Property="Background" Value="{StaticResource Blue}"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Padding" Value="20,12"/>
            <Setter Property="FontSize" Value="15"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}" CornerRadius="10" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="SecondaryButton" TargetType="Button" BasedOn="{StaticResource PrimaryButton}">
            <Setter Property="Background" Value="#14243A"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="BorderBrush" Value="{StaticResource Border}"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="10" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="SmallLabel" TargetType="TextBlock">
            <Setter Property="Foreground" Value="{StaticResource SubText}"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Margin" Value="0,0,0,6"/>
        </Style>

        <Style x:Key="ValueText" TargetType="TextBlock">
            <Setter Property="Foreground" Value="{StaticResource Text}"/>
            <Setter Property="FontSize" Value="15"/>
            <Setter Property="TextWrapping" Value="Wrap"/>
        </Style>
    </Window.Resources>

    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="265"/>
            <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>

        <!-- Sidebar -->
        <Border Grid.Column="0" Background="#050B15" BorderBrush="#14243A" BorderThickness="0,0,1,0">
            <Grid Margin="22,28,22,22">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <StackPanel Grid.Row="0">
                    <Border Width="56" Height="56" HorizontalAlignment="Left" Background="#172B63" CornerRadius="18">
                        <Grid Width="36" Height="36" HorizontalAlignment="Center" VerticalAlignment="Center">
                            <Border Width="31" Height="22" CornerRadius="5" BorderBrush="#DDE7F3" BorderThickness="2" HorizontalAlignment="Center" VerticalAlignment="Top" Margin="0,2,0,0"/>
                            <Rectangle Width="12" Height="2" Fill="#DDE7F3" HorizontalAlignment="Center" VerticalAlignment="Bottom" Margin="0,0,0,6"/>
                            <Rectangle Width="22" Height="2" Fill="#DDE7F3" HorizontalAlignment="Center" VerticalAlignment="Bottom" Margin="0,0,0,2"/>
                            <Ellipse Width="11" Height="11" Fill="#35E888" Stroke="#07111F" StrokeThickness="2" HorizontalAlignment="Right" VerticalAlignment="Bottom"/>
                        </Grid>
                    </Border>
                    <TextBlock Text="Intune Remote" Foreground="White" FontSize="24" FontWeight="Bold" Margin="0,26,0,0"/>
                    <TextBlock Text="Help Launcher" Foreground="#4B8BFF" FontSize="24" FontWeight="Bold"/>
                    <TextBlock Text="One search. One action. Less portal friction." Foreground="#AFC0D4" FontSize="13" TextWrapping="Wrap" Margin="0,11,0,0"/>
                </StackPanel>

                <StackPanel Grid.Row="1" Margin="0,34,0,0">
                    <Border Background="#12213A" CornerRadius="12" Padding="16,14">
                        <TextBlock Text="Device Lookup" Foreground="White" FontWeight="SemiBold" FontSize="15"/>
                    </Border>
                    <Border x:Name="SessionActivityNav" Background="Transparent" CornerRadius="10" Padding="16,10" Margin="0,14,0,0" Cursor="Hand">
                        <StackPanel>
                            <TextBlock Text="Session Activity" Foreground="#9BB1CA" FontSize="14"/>
                            <TextBlock Text="View activity in app" Foreground="#64748B" FontSize="11" Margin="0,4,0,0"/>
                        </StackPanel>
                    </Border>
                    <Button x:Name="OpenLocalHistoryButton" Content="Open Local History" Style="{StaticResource SecondaryButton}" Padding="12,9" FontSize="12" Margin="0,8,0,0"/>
                </StackPanel>

                <StackPanel Grid.Row="3">
                    <Border Background="#0D1828" BorderBrush="#20344E" BorderThickness="1" CornerRadius="16" Padding="18" Margin="0,0,0,12">
                        <StackPanel>
                            <TextBlock Text="Tenant Info" Foreground="White" FontWeight="SemiBold" FontSize="13"/>
                            <TextBlock x:Name="TenantInfoText" Text="Not connected" Foreground="#B9C8DA" FontSize="12" TextWrapping="Wrap" Margin="0,10,0,0"/>
                        </StackPanel>
                    </Border>
                    <Border Background="#0D1828" BorderBrush="#20344E" BorderThickness="1" CornerRadius="16" Padding="18">
                        <StackPanel>
                            <TextBlock Text="Security model" Foreground="White" FontWeight="SemiBold" FontSize="13"/>
                            <TextBlock Text="Delegated Graph auth only. No secrets, no stored tokens, no local DB." Foreground="#B9C8DA" FontSize="12" TextWrapping="Wrap" Margin="0,10,0,12"/>
                            <Border Height="1" Background="#20344E" Margin="0,0,0,12"/>
                            <TextBlock Text="v0.25 community build" Foreground="#B9C8DA" FontSize="12"/>
                        </StackPanel>
                    </Border>
                </StackPanel>
            </Grid>
        </Border>

        <!-- Main -->
        <Grid Grid.Column="1" Margin="38,34,38,20">
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>

            <!-- Header -->
            <Grid Grid.Row="0">
                <StackPanel>
                    <TextBlock Text="Device Lookup" Foreground="White" FontSize="32" FontWeight="Bold"/>
                    <TextBlock Text="Search a device by name or user principal name" Foreground="#AFC0D4" FontSize="15" Margin="0,8,0,0"/>
                </StackPanel>
                <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Top">
                    <Border Background="#101D2F" BorderBrush="#20344E" BorderThickness="1" CornerRadius="18" Padding="18,9" Margin="0,0,12,0">
                        <TextBlock x:Name="SignInStatus" Text="Not signed in" Foreground="White" FontSize="12" FontWeight="SemiBold"/>
                    </Border>
                    <Button x:Name="SignInButton" Content="Sign in" Style="{StaticResource PrimaryButton}" Padding="22,11"/>
                </StackPanel>
            </Grid>

            <!-- Search -->
            <Border Grid.Row="1" Style="{StaticResource Card}" Padding="22" Margin="0,28,0,18">
                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="150"/>
                    </Grid.ColumnDefinitions>
                    <Border Grid.Column="0" Background="#07111F" BorderBrush="#244466" BorderThickness="1" CornerRadius="12" Padding="18,0" Height="54" Margin="0,0,16,0">
                        <TextBox x:Name="SearchBox" Background="Transparent" BorderThickness="0" Foreground="White" CaretBrush="White" FontSize="17" VerticalContentAlignment="Center" Text=""/>
                    </Border>
                    <Button x:Name="SearchButton" Grid.Column="1" Content="Search" Style="{StaticResource PrimaryButton}"/>
                </Grid>
            </Border>

            <!-- Empty state -->
            <Border x:Name="EmptyStateCard" Grid.Row="2" Style="{StaticResource Card}" Height="245" Margin="0,0,0,18">
                <Grid>
                    <StackPanel HorizontalAlignment="Center" VerticalAlignment="Center">
                        <Border Width="74" Height="74" Background="#10203A" BorderBrush="#284D78" BorderThickness="1" CornerRadius="22" HorizontalAlignment="Center">
                            <TextBlock Text="--" Foreground="#7EA6FF" FontSize="24" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <TextBlock Text="No device selected" Foreground="White" FontSize="26" FontWeight="Bold" HorizontalAlignment="Center" Margin="0,9,0,0"/>
                        <TextBlock Text="Enter a device name or UPN, then click Search." Foreground="#AFC0D4" FontSize="15" HorizontalAlignment="Center" Margin="0,8,0,0"/>
                    </StackPanel>
                </Grid>
            </Border>

            <!-- Device card -->
            <Border x:Name="DeviceCard" Grid.Row="2" Style="{StaticResource Card}" Height="282" Margin="0,0,0,18" Visibility="Collapsed">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="170"/>
                        <ColumnDefinition Width="2*"/>
                        <ColumnDefinition Width="2*"/>
                        <ColumnDefinition Width="2*"/>
                    </Grid.ColumnDefinitions>

                    <Grid Grid.Row="0" Grid.ColumnSpan="4" Height="34" Margin="0,0,0,10">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>
                        <TextBlock x:Name="DeviceCounterText" Grid.Column="0" Text="1 device found" Foreground="#AFC0D4" FontSize="13" VerticalAlignment="Center" TextTrimming="CharacterEllipsis"/>
                        <StackPanel Grid.Column="1" Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="20,0,0,0">
                            <Button x:Name="PreviousDeviceButton" Content="&#x2039;" Width="38" Height="30" Margin="0,0,8,0" Background="#14243A" Foreground="White" BorderBrush="#20344E" FontSize="20" IsEnabled="False" ToolTip="Previous device"/>
                            <Button x:Name="NextDeviceButton" Content="&#x203A;" Width="38" Height="30" Background="#14243A" Foreground="White" BorderBrush="#20344E" FontSize="20" IsEnabled="False" ToolTip="Next device"/>
                        </StackPanel>
                    </Grid>

                    <Border Grid.Row="1" Grid.Column="0" Width="118" Height="118" Background="#10203A" BorderBrush="#2B63A5" BorderThickness="1" CornerRadius="16" HorizontalAlignment="Left" VerticalAlignment="Center">
                        <StackPanel HorizontalAlignment="Center" VerticalAlignment="Center">
                            <TextBlock x:Name="DeviceIconText" Text="PC" Foreground="#7EA6FF" FontSize="30" FontWeight="Bold" HorizontalAlignment="Center"/>
                            <TextBlock x:Name="DevicePlatformText" Text="Windows" Foreground="#8EA2BB" FontSize="12" HorizontalAlignment="Center"/>
                        </StackPanel>
                    </Border>

                    <StackPanel Grid.Row="1" Grid.Column="1" VerticalAlignment="Center" Margin="0,0,24,0">
                        <StackPanel Orientation="Horizontal">
                            <TextBlock x:Name="DeviceNameText" Text="--" Foreground="White" FontSize="25" FontWeight="Bold" Margin="0,0,12,0"/>
                            <Border x:Name="ComplianceBadge" Background="#143926" CornerRadius="10" Padding="10,5" VerticalAlignment="Center">
                                <TextBlock x:Name="ComplianceBadgeText" Text="Compliant" Foreground="#35E888" FontSize="13" FontWeight="SemiBold"/>
                            </Border>
                        </StackPanel>
                        <TextBlock x:Name="OsText" Text="--" Foreground="#DDE7F3" FontSize="16" Margin="0,9,0,0"/>
                        <TextBlock x:Name="ModelText" Text="--" Foreground="#AFC0D4" FontSize="14" Margin="0,9,0,0"/>
                        <StackPanel Orientation="Horizontal" Margin="0,11,0,0">
                            <TextBlock Text="Tag:" Foreground="#AFC0D4" FontSize="14" Margin="0,3,8,0"/>
                            <Border Background="#12396B" CornerRadius="6" Padding="9,4">
                                <TextBlock x:Name="TagText" Text="Managed" Foreground="#69A8FF" FontSize="13"/>
                            </Border>
                        </StackPanel>
                    </StackPanel>

                    <StackPanel Grid.Row="1" Grid.Column="2" VerticalAlignment="Center" Margin="0,0,24,0">
                        <TextBlock Text="Primary User" Style="{StaticResource SmallLabel}"/>
                        <TextBlock x:Name="UserText" Text="--" Style="{StaticResource ValueText}" Margin="0,0,0,16"/>
                        <TextBlock Text="Operating System" Style="{StaticResource SmallLabel}"/>
                        <TextBlock x:Name="OperatingSystemText" Text="--" Style="{StaticResource ValueText}" Margin="0,0,0,16"/>
                        <TextBlock Text="Last Sync" Style="{StaticResource SmallLabel}"/>
                        <TextBlock x:Name="LastSyncText" Text="--" Foreground="#35E888" FontSize="15"/>
                    </StackPanel>

                    <StackPanel Grid.Row="1" Grid.Column="3" VerticalAlignment="Center">
                        <TextBlock Text="Ownership" Style="{StaticResource SmallLabel}"/>
                        <TextBlock x:Name="OwnerText" Text="--" Style="{StaticResource ValueText}" Margin="0,0,0,16"/>
                        <TextBlock Text="Serial Number" Style="{StaticResource SmallLabel}"/>
                        <TextBlock x:Name="SerialText" Text="--" Style="{StaticResource ValueText}" Margin="0,0,0,16"/>
                        <TextBlock Text="Model" Style="{StaticResource SmallLabel}"/>
                        <TextBlock x:Name="MgmtText" Text="--" Style="{StaticResource ValueText}"/>
                    </StackPanel>
                </Grid>
            </Border>

            <!-- Actions and lower cards -->
            <Grid Grid.Row="3">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                </Grid.RowDefinitions>
                <StackPanel Grid.Row="0" Orientation="Horizontal" Margin="0,0,0,18">
                    <Button x:Name="RemoteHelpButton" Content="Start Remote Help" Style="{StaticResource PrimaryButton}" Width="205" IsEnabled="False"/>
                    <Button x:Name="SyncButton" Content="Sync" Style="{StaticResource SecondaryButton}" Width="115" Margin="12,0,0,0" IsEnabled="False"/>
                    <Button x:Name="RestartButton" Content="Restart" Style="{StaticResource SecondaryButton}" Width="125" Margin="12,0,0,0" IsEnabled="False"/>
                    <Button x:Name="OpenIntuneButton" Content="Open in Intune" Style="{StaticResource SecondaryButton}" Width="185" Margin="12,0,0,0" IsEnabled="False"/>
                    <Button x:Name="RefreshButton" Content="Refresh" Style="{StaticResource SecondaryButton}" Width="125" Margin="12,0,0,0" IsEnabled="False"/>
                </StackPanel>

                <Grid Grid.Row="1">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="2*"/>
                        <ColumnDefinition Width="1.05*"/>
                    </Grid.ColumnDefinitions>
                    <Border Grid.Column="0" Style="{StaticResource Card}" Margin="0,0,18,0">
                        <StackPanel>
                            <TextBlock Text="Activity log" Foreground="White" FontSize="18" FontWeight="Bold"/>
                            <Border Background="#07111F" CornerRadius="8" Padding="14" Margin="0,14,0,0" Height="220">
                                <ScrollViewer x:Name="LogScroll" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
                                    <TextBlock x:Name="LogText" Text="[UI] v0.2 mobile device carousel loaded. Ready." Foreground="#DDE7F3" FontFamily="Consolas" FontSize="12" TextWrapping="Wrap"/>
                                </ScrollViewer>
                            </Border>
                        </StackPanel>
                    </Border>
                    <Border Grid.Column="1" Style="{StaticResource Card}">
                        <StackPanel>
                            <TextBlock Text="Quick Info" Foreground="White" FontSize="18" FontWeight="Bold"/>
                            <TextBlock Text="Remote Help" Foreground="#AFC0D4" FontSize="13" Margin="0,18,0,4"/>
                            <TextBlock x:Name="RemoteHelpStatusText" Text="Waiting for sign-in" Foreground="#35E888" FontSize="13" TextWrapping="Wrap"/>
                            <TextBlock Text="Permissions" Foreground="#AFC0D4" FontSize="13" Margin="0,18,0,4"/>
                            <TextBlock x:Name="PermissionText" Text="Graph not connected" Foreground="#DDE7F3" FontSize="13" TextWrapping="Wrap"/>
                            <TextBlock Text="Connection" Foreground="#AFC0D4" FontSize="13" Margin="0,18,0,4"/>
                            <TextBlock x:Name="ConnectionText" Text="Not connected" Foreground="#DDE7F3" FontSize="13" TextWrapping="Wrap"/>
                        </StackPanel>
                    </Border>
                </Grid>
            </Grid>

            <Grid Grid.Row="4" Margin="0,14,0,0">
                <TextBlock x:Name="FooterText" Text="Last updated: waiting for search" Foreground="#8FA3BA" FontSize="12"/>
                <TextBlock Text="Ready" Foreground="#35E888" FontSize="12" HorizontalAlignment="Right"/>
            </Grid>
        </Grid>
    </Grid>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

function Find-Control($Name) { return $window.FindName($Name) }
function Set-Text($Name, $Value) { $c = Find-Control $Name; if ($c) { $c.Text = [string]$Value } }
function Add-Log($Message) {
    $log = Find-Control "LogText"
    if ($log) {
        $log.Text = $log.Text + "`n" + "[UI] " + $Message
        $scroll = Find-Control "LogScroll"
        if ($scroll) { $scroll.ScrollToEnd() }
    }
}


$script:IsSignedIn = $false
$script:CurrentDevice = $null
$script:MatchedDevices = @()
$script:CurrentDeviceIndex = -1
$script:TenantId = $null
$script:Scopes = @(
    "DeviceManagementManagedDevices.Read.All",
    "DeviceManagementManagedDevices.ReadWrite.All",
    "DeviceManagementManagedDevices.PrivilegedOperations.All"
)
$script:SessionHistoryPath = Join-Path $env:LOCALAPPDATA "IntuneRemoteHelpLauncher\session-history.jsonl"
$script:SignedInAccount = $null

function Ensure-AppDataFolder {
    $folder = Split-Path $script:SessionHistoryPath -Parent
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
    }
}


function Format-Ownership {
    param($Value)
    $v = [string](Coalesce $Value "Unknown")
    switch -Regex ($v) {
        "(?i)^company$|^corporate$" { return "Corporate" }
        "(?i)^personal$" { return "Personal" }
        default { return $v }
    }
}


function Format-DurationText {
    param([timespan]$Duration)
    if (-not $Duration) { return "Not tracked" }
    if ($Duration.TotalSeconds -lt 60) { return ("{0}s" -f [int]$Duration.TotalSeconds) }
    if ($Duration.TotalMinutes -lt 60) { return ("{0}m {1}s" -f [int]$Duration.TotalMinutes, $Duration.Seconds) }
    return ("{0}h {1}m" -f [int]$Duration.TotalHours, $Duration.Minutes)
}

function Save-SessionHistory {
    param(
        [string]$SessionType,
        [string]$SessionKey
    )
    try {
        Ensure-AppDataFolder
        $ctx = $null
        try { $ctx = Get-MgContext } catch {}

        # The Graph session type is only the initial Remote Help launch mode.
        # The real helper choice, View Screen or Full Control, is selected later inside the Remote Help app,
        # so the launcher should not claim it knows the final action.
        $entryId = [guid]::NewGuid().ToString()
        $entry = [pscustomobject]@{
            id          = $entryId
            started     = (Get-Date).ToString("s")
            startedUtc  = (Get-Date).ToUniversalTime().ToString("o")
            ended       = $null
            helper      = $(if ($ctx -and $ctx.Account) { $ctx.Account } else { $script:SignedInAccount })
            device      = $(if ($script:CurrentDevice) { $script:CurrentDevice.deviceName } else { $null })
            primaryUser = $(if ($script:CurrentDevice) { $script:CurrentDevice.userPrincipalName } else { $null })
            action      = "Remote Help"
            duration    = "In progress"
            sessionKey  = $SessionKey
        }
        ($entry | ConvertTo-Json -Compress) | Add-Content -Path $script:SessionHistoryPath -Encoding UTF8
        Add-Log ("Session activity saved locally: {0}" -f $script:SessionHistoryPath)
        return $entryId
    }
    catch {
        Add-Log ("Session activity could not be saved: {0}" -f $_.Exception.Message)
        return $null
    }
}

function Update-SessionHistoryDuration {
    param(
        [string]$EntryId,
        [timespan]$Duration
    )
    if ([string]::IsNullOrWhiteSpace($EntryId)) { return }

    try {
        Ensure-AppDataFolder
        if (-not (Test-Path $script:SessionHistoryPath)) { return }

        $updated = $false
        $items = Get-Content $script:SessionHistoryPath -ErrorAction SilentlyContinue |
            Where-Object { $_.Trim() -ne "" } |
            ForEach-Object {
                try { $_ | ConvertFrom-Json } catch { $null }
            } |
            Where-Object { $_ }

        foreach ($item in $items) {
            if ([string]$item.id -eq $EntryId) {
                $item.ended = (Get-Date).ToString("s")
                $item.duration = Format-DurationText $Duration
                $updated = $true
            }
        }

        if ($updated) {
            $items | ForEach-Object { $_ | ConvertTo-Json -Compress } | Set-Content -Path $script:SessionHistoryPath -Encoding UTF8
            Add-Log ("Session duration updated: {0}" -f (Format-DurationText $Duration))
        }
    }
    catch {
        Add-Log ("Session duration could not be updated: {0}" -f $_.Exception.Message)
    }
}

function Start-RemoteHelpDurationMonitor {
    param(
        [string]$EntryId,
        [datetime]$LaunchTime
    )

    if ([string]::IsNullOrWhiteSpace($EntryId)) { return }

    $state = [pscustomobject]@{
        EntryId = $EntryId
        LaunchTime = $LaunchTime
        ProcessId = $null
        Attempts = 0
    }

    $timer = New-Object System.Windows.Threading.DispatcherTimer
    $timer.Interval = [timespan]::FromSeconds(5)
    $timer.Tag = $state

    $timer.Add_Tick({
        param($sender, $args)
        $st = $sender.Tag
        $st.Attempts++

        try {
            if (-not $st.ProcessId) {
                $candidate = Get-Process -Name "RemoteHelp" -ErrorAction SilentlyContinue |
                    Where-Object {
                        try { $_.StartTime -ge $st.LaunchTime.AddSeconds(-10) } catch { $false }
                    } |
                    Sort-Object StartTime -Descending |
                    Select-Object -First 1

                if ($candidate) {
                    $st.ProcessId = $candidate.Id
                    Add-Log ("RemoteHelp.exe process detected for duration tracking. PID: {0}" -f $st.ProcessId)
                    return
                }

                if ($st.Attempts -ge 12) {
                    Add-Log "RemoteHelp.exe process was not detected for duration tracking. Leaving duration as In progress."
                    $sender.Stop()
                }
                return
            }

            $running = Get-Process -Id $st.ProcessId -ErrorAction SilentlyContinue
            if (-not $running) {
                $duration = (Get-Date) - $st.LaunchTime
                Update-SessionHistoryDuration -EntryId $st.EntryId -Duration $duration
                $sender.Stop()
            }
        }
        catch {
            Add-Log ("Duration monitor error: {0}" -f $_.Exception.Message)
            $sender.Stop()
        }
    })

    $timer.Start()
    Add-Log "Session duration tracking started. Duration will update when Remote Help is closed."
}

function Open-SessionHistoryFile {
    try {
        Ensure-AppDataFolder
        if (Test-Path $script:SessionHistoryPath) {
            Start-Process -FilePath $script:SessionHistoryPath
            Add-Log "Opened local session history file."
        }
        else {
            Start-Process -FilePath (Split-Path $script:SessionHistoryPath -Parent)
            Add-Log "No session history yet. Opened local history folder."
        }
    }
    catch {
        Add-Log ("Could not open local history: {0}" -f $_.Exception.Message)
    }
}

function Show-SessionActivityWindow {
    try {
        Ensure-AppDataFolder
        $items = @()
        if (Test-Path $script:SessionHistoryPath) {
            $items = Get-Content $script:SessionHistoryPath -ErrorAction SilentlyContinue | Where-Object { $_.Trim() -ne "" } | ForEach-Object {
                try { $_ | ConvertFrom-Json } catch { $null }
            } | Where-Object { $_ } | Select-Object -Last 50
        }

        $activityWindow = New-Object System.Windows.Window
        $activityWindow.Title = "Session Activity"
        $activityWindow.Width = 900
        $activityWindow.Height = 520
        $activityWindow.WindowStartupLocation = "CenterOwner"
        $activityWindow.Owner = $window
        $activityWindow.Background = "#07111F"
        $activityWindow.FontFamily = "Segoe UI"

        $grid = New-Object System.Windows.Controls.Grid
        $grid.Margin = "24"
        $row1 = New-Object System.Windows.Controls.RowDefinition; $row1.Height = "Auto"
        $row2 = New-Object System.Windows.Controls.RowDefinition; $row2.Height = "*"
        $grid.RowDefinitions.Add($row1); $grid.RowDefinitions.Add($row2)

        $header = New-Object System.Windows.Controls.TextBlock
        $header.Text = "Session Activity"
        $header.Foreground = "White"
        $header.FontSize = 26
        $header.FontWeight = "Bold"
        $header.Margin = "0,0,0,18"
        [System.Windows.Controls.Grid]::SetRow($header,0)
        $grid.Children.Add($header) | Out-Null

        $box = New-Object System.Windows.Controls.TextBox
        $box.Background = "#0D1828"
        $box.Foreground = "#DDE7F3"
        $box.BorderBrush = "#20344E"
        $box.FontFamily = "Consolas"
        $box.FontSize = 12
        $box.Padding = "14"
        $box.IsReadOnly = $true
        $box.AcceptsReturn = $true
        $box.VerticalScrollBarVisibility = "Auto"
        $box.HorizontalScrollBarVisibility = "Auto"

        if ($items.Count -eq 0) {
            $box.Text = "No local session activity yet.`r`n`r`nHistory file:`r`n$script:SessionHistoryPath"
        }
        else {
            $lines = New-Object System.Collections.Generic.List[string]
            $lines.Add(("{0,-19} {1,-28} {2,-28} {3,-16} {4}" -f "Started", "Device", "Primary user", "Action", "Duration"))
            $lines.Add(("-" * 120))
            foreach ($i in $items) {
                $lines.Add(("{0,-19} {1,-28} {2,-28} {3,-16} {4}" -f `
                    ([string]$i.started), `
                    ([string]$i.device), `
                    ([string]$i.primaryUser), `
                    ([string]$i.action), `
                    ([string]$i.duration)))
            }
            $lines.Add("")
            $lines.Add("Local file: $script:SessionHistoryPath")
            $box.Text = ($lines -join "`r`n")
        }

        [System.Windows.Controls.Grid]::SetRow($box,1)
        $grid.Children.Add($box) | Out-Null
        $activityWindow.Content = $grid
        $activityWindow.ShowDialog() | Out-Null
    }
    catch {
        Add-Log ("Could not show session activity: {0}" -f $_.Exception.Message)
    }
}

function Escape-ODataString {
    param([string]$Value)
    if ($null -eq $Value) { return "" }
    return $Value.Replace("'", "''")
}

function Ensure-GraphModule {
    $module = Get-Module -ListAvailable Microsoft.Graph.Authentication | Select-Object -First 1
    if (-not $module) {
        Add-Log "Microsoft.Graph.Authentication module was not found. Installing for current user..."
        try {
            if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
                Add-Log "Installing NuGet provider..."
                Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force -ErrorAction Stop | Out-Null
            }

            Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction SilentlyContinue
            Install-Module Microsoft.Graph.Authentication -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
            Add-Log "Microsoft.Graph.Authentication installed."
        }
        catch {
            Add-Log "Graph module install failed: $($_.Exception.Message)"
            [System.Windows.MessageBox]::Show(
                "Microsoft.Graph.Authentication module is missing and automatic install failed.`n`nManual command:`nInstall-Module Microsoft.Graph.Authentication -Scope CurrentUser",
                "Missing Graph module",
                "OK",
                "Warning"
            ) | Out-Null
            return $false
        }
    }

    Import-Module Microsoft.Graph.Authentication -ErrorAction Stop
    return $true
}

function Set-ConnectionState {
    param([string]$StateText)
    Set-Text "SignInStatus" $StateText
}

function Get-GraphScopeText {
    try {
        $ctx = Get-MgContext
        if ($ctx -and $ctx.Scopes) { return ($ctx.Scopes -join ", ") }
    }
    catch { }
    return "Unable to read current Graph scopes"
}

function Complete-GraphSignIn {
    try {
        $ctx = Get-MgContext
        if (-not $ctx) { throw "No Microsoft Graph context returned." }

        $script:IsSignedIn = $true
        $script:TenantId = $ctx.TenantId

        if ($ctx.Account) {
            $script:SignedInAccount = $ctx.Account
            Set-ConnectionState "Signed in: $($ctx.Account)"
            Set-Text "ConnectionText" "Graph connected"
            $tenantDomain = (($ctx.Account -split "@")[-1])
            Set-Text "TenantInfoText" $tenantDomain
            Set-Text "RemoteHelpStatusText" "Enabled for this tenant"
            if ($ctx.Scopes -contains "DeviceManagementManagedDevices.PrivilegedOperations.All") {
                Set-Text "PermissionText" "Privileged device operations granted"
            }
            else {
                Set-Text "PermissionText" "Read/write scopes granted"
            }
            Add-Log "Signed in as $($ctx.Account)"
        } else {
            Set-ConnectionState "Signed in"
            Set-Text "ConnectionText" "Graph connected"
            Set-Text "RemoteHelpStatusText" "Enabled for this tenant"
            Add-Log "Signed in."
        }
    }
    catch {
        throw $_
    }
}

function Connect-GraphBackend {
    if ($DemoMode) {
        Set-ConnectionState "Demo mode"
        Add-Log "Demo mode active. Graph sign-in skipped."
        return
    }

    try {
        if (-not (Ensure-GraphModule)) { return }

        Set-ConnectionState "Signing in..."
        Add-Log "Starting Microsoft Graph browser sign-in..."
        Add-Log "Requested scopes: $($script:Scopes -join ', ')"

        try {
            # Browser/WAM sign-in first. ContextScope CurrentUser allows the SDK to reuse the user's cached auth context where possible.
            Connect-MgGraph -Scopes $script:Scopes -ContextScope CurrentUser -NoWelcome -ErrorAction Stop | Out-Null
            Complete-GraphSignIn
            return
        }
        catch {
            $msg = $_.Exception.Message
            Add-Log "Browser sign-in failed: $msg"

            if ($msg -match "window handle|WAM|InteractiveBrowserCredential|parent-window") {
                Add-Log "Falling back to device code sign-in because WAM/browser auth could not attach to this WPF window."
                Connect-MgGraph -Scopes $script:Scopes -UseDeviceCode -ContextScope CurrentUser -NoWelcome -ErrorAction Stop | Out-Null
                Complete-GraphSignIn
                return
            }

            throw $_
        }
    }
    catch {
        Set-ConnectionState "Not signed in"
        Add-Log "Sign-in failed: $($_.Exception.Message)"
        [System.Windows.MessageBox]::Show(
            $_.Exception.Message,
            "Graph sign-in failed",
            "OK",
            "Error"
        ) | Out-Null
    }
}

function Format-TimeAgo {
    param($DateValue)
    if (-not $DateValue) { return "Unknown" }

    try {
        $utc = $null
        if ($DateValue -is [datetime]) {
            $dt = [datetime]$DateValue
            switch ($dt.Kind) {
                "Utc" { $utc = $dt }
                "Local" { $utc = $dt.ToUniversalTime() }
                default { $utc = [datetime]::SpecifyKind($dt, [System.DateTimeKind]::Utc) }
            }
        }
        else {
            $raw = ([string]$DateValue).Trim()
            if ($raw -match "Z$|[\+\-]\d{2}:?\d{2}$") {
                $dto = [System.DateTimeOffset]::Parse($raw, [System.Globalization.CultureInfo]::InvariantCulture)
                $utc = $dto.UtcDateTime
            }
            else {
                $dt = [datetime]::Parse($raw, [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::AssumeUniversal)
                $utc = $dt.ToUniversalTime()
            }
        }

        $span = [datetime]::UtcNow - $utc
        if ($span.TotalSeconds -lt 0) { return "Just now" }
        if ($span.TotalSeconds -lt 60) { return "Just now" }
        if ($span.TotalMinutes -lt 60) {
            $m = [int][math]::Floor($span.TotalMinutes)
            if ($m -le 1) { return "1 minute ago" }
            return ("{0} minutes ago" -f $m)
        }
        if ($span.TotalHours -lt 24) {
            $h = [int][math]::Floor($span.TotalHours)
            if ($h -le 1) { return "1 hour ago" }
            return ("{0} hours ago" -f $h)
        }
        $d = [int][math]::Floor($span.TotalDays)
        if ($d -le 1) { return "1 day ago" }
        return ("{0} days ago" -f $d)
    }
    catch {
        return [string]$DateValue
    }
}

function Coalesce {
    param($Value, $Fallback)
    if ($null -ne $Value -and "$Value".Trim() -ne "") { return $Value }
    return $Fallback
}

function Set-ComplianceBadge {
    param([string]$Compliance)

    $badge = Find-Control "ComplianceBadge"
    $text = Find-Control "ComplianceBadgeText"
    if (-not $badge -or -not $text) { return }

    $value = Coalesce $Compliance "unknown"
    $text.Text = $value

    switch -Regex ($value) {
        "^compliant$" {
            $badge.Background = "#143926"
            $text.Foreground = "#35E888"
        }
        "noncompliant|error|conflict" {
            $badge.Background = "#3A1D24"
            $text.Foreground = "#FB7185"
        }
        "inGracePeriod|unknown" {
            $badge.Background = "#3B2D16"
            $text.Foreground = "#FBBF24"
        }
        default {
            $badge.Background = "#1F2937"
            $text.Foreground = "#CBD5E1"
        }
    }
}


function Format-OSDisplay {
    param($Device)

    $os = Coalesce $Device.operatingSystem "Unknown OS"
    $ver = Coalesce $Device.osVersion ""

    # Intune managedDevice often returns OS as "Windows" and osVersion as a build number
    # such as 10.0.22631.x / 10.0.26100.x. For the UI, show a friendly family name
    # instead of the raw build. Edition is shown only if a usable SKU/edition field exists.
    $family = $os

    if ($os -match "Windows") {
        try {
            if ($ver -match "^10\.0\.(\d+)") {
                $build = [int]$Matches[1]
                if ($build -ge 22000) {
                    $family = "Windows 11"
                }
                elseif ($build -ge 10240) {
                    $family = "Windows 10"
                }
                else {
                    $family = "Windows"
                }
            }
            else {
                $family = "Windows"
            }
        }
        catch {
            $family = "Windows"
        }
    }

    $editionCandidates = @(
        $Device.skuFamily,
        $Device.operatingSystemEdition,
        $Device.osEdition,
        $Device.windowsSku
    )

    $edition = $null
    foreach ($candidate in $editionCandidates) {
        if ($candidate -and "$candidate".Trim() -ne "") {
            $edition = "$candidate".Trim()
            break
        }
    }

    if ($edition) {
        $cleanEdition = $edition
        $cleanEdition = $cleanEdition -replace "(?i)^windows\s*", ""
        $cleanEdition = $cleanEdition -replace "(?i)^microsoft\s*", ""
        if ($cleanEdition -match "(?i)enterprise") { return "$family Enterprise" }
        if ($cleanEdition -match "(?i)professional|\bpro\b") { return "$family Pro" }
        if ($cleanEdition -match "(?i)education") { return "$family Education" }
        if ($cleanEdition -match "(?i)home") { return "$family Home" }
        return "$family $cleanEdition"
    }

    return $family
}

function Select-ManagedDevice {
    param(
        [Parameter(Mandatory = $true)]
        [array]$Devices,
        [string]$SearchText
    )

    if ($Devices.Count -eq 1) { return $Devices[0] }

    [xml]$selectionXaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Select Managed Device"
        Width="780" Height="470"
        MinWidth="680" MinHeight="400"
        WindowStartupLocation="CenterOwner"
        Background="#07111F"
        FontFamily="Segoe UI">
    <Window.Resources>
        <Style TargetType="ListViewItem">
            <Setter Property="Foreground" Value="#F8FAFC"/>
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Padding" Value="8"/>
            <Setter Property="HorizontalContentAlignment" Value="Stretch"/>
        </Style>
    </Window.Resources>
    <Grid Margin="24">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        <TextBlock Text="Select a managed device" Foreground="White" FontSize="25" FontWeight="Bold"/>
        <TextBlock x:Name="SelectionSubText" Grid.Row="1" Foreground="#AFC0D4" FontSize="14" Margin="0,8,0,18"/>
        <Border Grid.Row="2" Background="#101D2F" BorderBrush="#20344E" BorderThickness="1" CornerRadius="12" Padding="8">
            <ListView x:Name="DeviceList" Background="Transparent" BorderThickness="0" SelectionMode="Single">
                <ListView.View>
                    <GridView>
                        <GridViewColumn Header="Device" Width="220" DisplayMemberBinding="{Binding deviceName}"/>
                        <GridViewColumn Header="Platform" Width="110" DisplayMemberBinding="{Binding operatingSystem}"/>
                        <GridViewColumn Header="Model" Width="180" DisplayMemberBinding="{Binding model}"/>
                        <GridViewColumn Header="Compliance" Width="110" DisplayMemberBinding="{Binding complianceState}"/>
                    </GridView>
                </ListView.View>
            </ListView>
        </Border>
        <StackPanel Grid.Row="3" Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,9,0,0">
            <Button x:Name="CancelSelectionButton" Content="Cancel" Width="110" Height="40" Margin="0,0,10,0" Background="#14243A" Foreground="White" BorderBrush="#20344E"/>
            <Button x:Name="UseDeviceButton" Content="Use selected device" Width="160" Height="40" Background="#2F6BFF" Foreground="White" BorderThickness="0" IsDefault="True"/>
        </StackPanel>
    </Grid>
</Window>
"@

    $reader = New-Object System.Xml.XmlNodeReader $selectionXaml
    $dialog = [Windows.Markup.XamlReader]::Load($reader)
    if ($window) { $dialog.Owner = $window }

    $list = $dialog.FindName("DeviceList")
    $subText = $dialog.FindName("SelectionSubText")
    $useButton = $dialog.FindName("UseDeviceButton")
    $cancelButton = $dialog.FindName("CancelSelectionButton")

    $subText.Text = ("{0} managed devices matched '{1}'." -f $Devices.Count, $SearchText)
    foreach ($device in $Devices) { [void]$list.Items.Add($device) }
    if ($list.Items.Count -gt 0) { $list.SelectedIndex = 0 }

    $script:SelectedManagedDevice = $null
    $useButton.Add_Click({
        if ($list.SelectedItem) {
            $script:SelectedManagedDevice = $list.SelectedItem
            $dialog.DialogResult = $true
            $dialog.Close()
        }
    })
    $cancelButton.Add_Click({ $dialog.DialogResult = $false; $dialog.Close() })
    $list.Add_MouseDoubleClick({
        if ($list.SelectedItem) {
            $script:SelectedManagedDevice = $list.SelectedItem
            $dialog.DialogResult = $true
            $dialog.Close()
        }
    })

    [void]$dialog.ShowDialog()
    return $script:SelectedManagedDevice
}

function Update-DeviceNavigation {
    $counter = Find-Control "DeviceCounterText"
    $previous = Find-Control "PreviousDeviceButton"
    $next = Find-Control "NextDeviceButton"

    $count = @($script:MatchedDevices).Count
    if ($count -le 0 -or $script:CurrentDeviceIndex -lt 0) {
        if ($counter) { $counter.Text = "No device selected" }
        if ($previous) { $previous.IsEnabled = $false }
        if ($next) { $next.IsEnabled = $false }
        return
    }

    if ($counter) {
        $counter.Text = ("Device {0} of {1}  -  use arrows to switch" -f ($script:CurrentDeviceIndex + 1), $count)
    }
    if ($previous) { $previous.IsEnabled = ($count -gt 1) }
    if ($next) { $next.IsEnabled = ($count -gt 1) }
}

function Show-DeviceAtIndex {
    param([int]$Index)

    $count = @($script:MatchedDevices).Count
    if ($count -le 0) { return }

    if ($Index -lt 0) { $Index = $count - 1 }
    if ($Index -ge $count) { $Index = 0 }

    $script:CurrentDeviceIndex = $Index
    Show-Device $script:MatchedDevices[$Index]
    Update-DeviceNavigation
}

function Show-PreviousDevice {
    Show-DeviceAtIndex ($script:CurrentDeviceIndex - 1)
}

function Show-NextDevice {
    Show-DeviceAtIndex ($script:CurrentDeviceIndex + 1)
}

function Show-Device {
    param($Device)

    $script:CurrentDevice = $Device

    $empty = Find-Control "EmptyStateCard"
    $card = Find-Control "DeviceCard"
    if ($empty) { $empty.Visibility = "Collapsed" }
    if ($card) { $card.Visibility = "Visible" }

    Set-Text "DeviceNameText" (Coalesce $Device.deviceName "Unknown device")
    Set-Text "UserText" (Coalesce $Device.userPrincipalName "No primary user")

    $platform = (Coalesce $Device.operatingSystem "Unknown").ToString()
    switch -Regex ($platform) {
        "(?i)android" { Set-Text "DeviceIconText" "MB"; Set-Text "DevicePlatformText" "Android" }
        "(?i)ios|ipad" { Set-Text "DeviceIconText" "MB"; Set-Text "DevicePlatformText" "iOS/iPadOS" }
        "(?i)mac" { Set-Text "DeviceIconText" "MC"; Set-Text "DevicePlatformText" "macOS" }
        default { Set-Text "DeviceIconText" "PC"; Set-Text "DevicePlatformText" $platform }
    }

    $osDisplay = Format-OSDisplay $Device
    Set-Text "OsText" $osDisplay
    Set-Text "OperatingSystemText" $osDisplay

    $manufacturer = Coalesce $Device.manufacturer ""
    $model = Coalesce $Device.model "Unknown model"
    Set-Text "ModelText" ("{0} {1}" -f $manufacturer, $model)

    $tagValue = Coalesce $Device.deviceCategoryDisplayName $null
    if (-not $tagValue) { $tagValue = Format-Ownership $Device.managedDeviceOwnerType }
    Set-Text "TagText" $tagValue

    Set-Text "LastSyncText" (Format-TimeAgo $Device.lastSyncDateTime)
    Set-Text "OwnerText" (Format-Ownership $Device.managedDeviceOwnerType)
    Set-Text "SerialText" (Coalesce $Device.serialNumber "Unknown")
    Set-Text "MgmtText" (Coalesce $Device.model "Unknown model")
    Set-Text "FooterText" ("Last updated: {0}" -f (Get-Date -Format "HH:mm:ss"))
    Set-ComplianceBadge (Coalesce $Device.complianceState "unknown")

    foreach ($name in @("SyncButton","OpenIntuneButton","RefreshButton")) {
        $b = Find-Control $name
        if ($b) { $b.IsEnabled = $true }
    }

    $isWindows = ($platform -match "(?i)^windows")
    $remoteButton = Find-Control "RemoteHelpButton"
    $restartButton = Find-Control "RestartButton"
    if ($remoteButton) { $remoteButton.IsEnabled = $isWindows }
    if ($restartButton) { $restartButton.IsEnabled = $isWindows }

    if (-not $isWindows) {
        Add-Log ("Mobile/non-Windows device selected: {0}. Remote Help and Restart are disabled in this version." -f $platform)
    }
}

function Show-DeviceDemo {
    $demo = [pscustomobject]@{
        id = "demo-id"
        deviceName = "PC-TEST-01"
        userPrincipalName = "user@contoso.com"
        operatingSystem = "Windows"
        osVersion = "10.0.22631.2861"
        skuFamily = "Pro"
        complianceState = "compliant"
        lastSyncDateTime = (Get-Date)
        manufacturer = "Microsoft"
        model = "Surface Laptop 5"
        managedDeviceOwnerType = "Corporate"
        serialNumber = "0123456789"
        managementAgent = "MDM"
        remoteAssistanceSessionUrl = $null
    }
    Show-Device $demo
    Add-Log "Demo device rendered."
}

function Search-Device {
    $box = Find-Control "SearchBox"
    $query = ""
    if ($box) { $query = $box.Text.Trim() }

    if ([string]::IsNullOrWhiteSpace($query)) {
        [System.Windows.MessageBox]::Show("Enter a device name or UPN first.", "Search", "OK", "Information") | Out-Null
        return
    }

    if ($DemoMode) {
        Add-Log "Demo search: $query"
        Show-DeviceDemo
        return
    }

    if (-not $script:IsSignedIn) {
        Add-Log "Not signed in. Starting sign-in first."
        Connect-GraphBackend
        if (-not $script:IsSignedIn) { return }
    }

    try {
        Add-Log "Searching Intune managed devices for: $query"

        $select = "id,deviceName,userPrincipalName,operatingSystem,osVersion,complianceState,lastSyncDateTime,manufacturer,model,managedDeviceOwnerType,serialNumber,managementAgent,remoteAssistanceSessionUrl,deviceCategoryDisplayName"
        $escaped = Escape-ODataString $query
        $matchedDevices = @()

        # Exact device name first. A device-name lookup normally resolves to one record.
        $deviceResult = Invoke-MgGraphRequest `
            -Method GET `
            -Uri "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices?`$filter=deviceName eq '$escaped'&`$select=$select" `
            -ErrorAction Stop

        if ($deviceResult.value) {
            $matchedDevices = @($deviceResult.value)
        }

        # UPN lookup intentionally returns every managed device assigned to the user,
        # including Windows, Android, iOS/iPadOS and macOS records.
        if ($matchedDevices.Count -eq 0) {
            $userResult = Invoke-MgGraphRequest `
                -Method GET `
                -Uri "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices?`$filter=userPrincipalName eq '$escaped'&`$select=$select" `
                -ErrorAction Stop

            if ($userResult.value) {
                $matchedDevices = @($userResult.value)
            }
        }

        # Partial fallback for device names or UPNs.
        if ($matchedDevices.Count -eq 0) {
            $allResult = Invoke-MgGraphRequest `
                -Method GET `
                -Uri "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices?`$top=999&`$select=$select" `
                -ErrorAction Stop

            if ($allResult.value) {
                $matchedDevices = @($allResult.value | Where-Object {
                    $_.deviceName -like "*$query*" -or $_.userPrincipalName -like "*$query*"
                })
            }
        }

        if ($matchedDevices.Count -eq 0) {
            Add-Log "No matching device found."
            [System.Windows.MessageBox]::Show("No matching Intune managed device found.", "Search result", "OK", "Information") | Out-Null
            return
        }

        $matchedDevices = @($matchedDevices | Sort-Object operatingSystem, deviceName)
        Add-Log ("Found {0} matching managed device(s)." -f $matchedDevices.Count)

        $script:MatchedDevices = @($matchedDevices)
        $script:CurrentDeviceIndex = 0
        Show-DeviceAtIndex 0

        if ($script:MatchedDevices.Count -gt 1) {
            Add-Log ("{0} devices loaded. Use the arrows on the device card to switch between them." -f $script:MatchedDevices.Count)
        }
        else {
            Add-Log ("Device selected: {0} ({1})" -f $script:CurrentDevice.deviceName, $script:CurrentDevice.operatingSystem)
        }
    }
    catch {
        Add-Log "Search failed: $($_.Exception.Message)"
        [System.Windows.MessageBox]::Show(
            $_.Exception.Message,
            "Search failed",
            "OK",
            "Error"
        ) | Out-Null
    }
}

function Sync-CurrentDevice {
    if (-not $script:CurrentDevice) { return }

    if ($DemoMode -or $script:CurrentDevice.id -eq "demo-id") {
        Add-Log "Demo mode: Sync clicked."
        return
    }

    if (-not $script:IsSignedIn) {
        Connect-GraphBackend
        if (-not $script:IsSignedIn) { return }
    }

    $button = Find-Control "SyncButton"
    try {
        if ($button) { $button.IsEnabled = $false }

        $id = $script:CurrentDevice.id
        $name = Coalesce $script:CurrentDevice.deviceName $id
        Add-Log "Sending Intune Sync command to: $name"

        Invoke-MgGraphRequest `
            -Method POST `
            -Uri "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/$id/syncDevice" `
            -ErrorAction Stop | Out-Null

        Add-Log "Sync command sent successfully. Intune returned 204 No Content."
        Add-Log "Device sync may take a few minutes depending on device connectivity and MDM channel availability."
        Set-Text "FooterText" ("Last sync command sent: {0}" -f (Get-Date -Format "HH:mm:ss"))
    }
    catch {
        $err = $_.Exception.Message
        Add-Log "Sync command failed: $err"
        try {
            if ($_.ErrorDetails -and $_.ErrorDetails.Message) {
                Add-Log ("Graph error detail: {0}" -f $_.ErrorDetails.Message)
            }
        } catch {}
        [System.Windows.MessageBox]::Show(
            $err,
            "Sync failed",
            "OK",
            "Error"
        ) | Out-Null
    }
    finally {
        if ($button -and $script:CurrentDevice) { $button.IsEnabled = $true }
    }
}


function Restart-CurrentDevice {
    if (-not $script:CurrentDevice) { return }

    if ($DemoMode -or $script:CurrentDevice.id -eq "demo-id") {
        Add-Log "Demo mode: Restart clicked."
        return
    }

    if (-not $script:IsSignedIn) {
        Connect-GraphBackend
        if (-not $script:IsSignedIn) { return }
    }

    $deviceName = Coalesce $script:CurrentDevice.deviceName $script:CurrentDevice.id
    $confirm = [System.Windows.MessageBox]::Show(
        "Are you sure you want to restart this device?`n`n$deviceName",
        "Restart device",
        "YesNo",
        "Warning"
    )

    if ($confirm -ne [System.Windows.MessageBoxResult]::Yes) {
        Add-Log "Restart command cancelled by user."
        return
    }

    $button = Find-Control "RestartButton"
    try {
        if ($button) { $button.IsEnabled = $false }

        $id = $script:CurrentDevice.id
        Add-Log "Sending Intune Restart command to: $deviceName"

        Invoke-MgGraphRequest `
            -Method POST `
            -Uri "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/$id/rebootNow" `
            -ErrorAction Stop | Out-Null

        Add-Log "Restart command sent successfully. Intune returned 204 No Content."
        Add-Log "The device will restart when it receives the command."
        Set-Text "FooterText" ("Last restart command sent: {0}" -f (Get-Date -Format "HH:mm:ss"))
    }
    catch {
        $err = $_.Exception.Message
        Add-Log "Restart command failed: $err"
        try {
            if ($_.ErrorDetails -and $_.ErrorDetails.Message) {
                Add-Log ("Graph error detail: {0}" -f $_.ErrorDetails.Message)
            }
        } catch {}
        [System.Windows.MessageBox]::Show(
            $err,
            "Restart failed",
            "OK",
            "Error"
        ) | Out-Null
    }
    finally {
        if ($button -and $script:CurrentDevice) { $button.IsEnabled = $true }
    }
}

function Open-CurrentDeviceInIntune {
    if (-not $script:CurrentDevice) { return }

    try {
        if ($script:CurrentDevice.id -eq "demo-id") {
            Add-Log "Demo mode: Open in Intune skipped."
            return
        }

        $url = "https://intune.microsoft.com/#view/Microsoft_Intune_Devices/DeviceSettingsMenuBlade/~/overview/mdmDeviceId/$($script:CurrentDevice.id)"
        Start-Process $url
        Add-Log "Opened Intune device page."
    }
    catch {
        Add-Log "Open Intune failed: $($_.Exception.Message)"
    }
}

function Get-FirstUrlFromObject {
    param($InputObject)

    if ($null -eq $InputObject) { return $null }

    $preferredNames = @(
        "remoteHelpSessionUrl",
        "remoteAssistanceSessionUrl,deviceCategoryDisplayName",
        "sessionUrl",
        "launchUrl",
        "url",
        "webUrl"
    )

    foreach ($name in $preferredNames) {
        try {
            $value = $InputObject.$name
            if ($value -and $value.ToString().StartsWith("http")) { return $value.ToString() }
        } catch {}
    }

    try {
        $json = $InputObject | ConvertTo-Json -Depth 20 -Compress
        $matches = [regex]::Matches($json, 'https?://[^"\]+')
        if ($matches.Count -gt 0) { return $matches[0].Value }
    } catch {}

    return $null
}

function Start-RemoteHelpForCurrentDevice {
    if (-not $script:CurrentDevice) { return }

    if ($DemoMode -or $script:CurrentDevice.id -eq "demo-id") {
        Add-Log "Demo mode: Start Remote Help clicked."
        return
    }

    if (-not $script:IsSignedIn) {
        Connect-GraphBackend
        if (-not $script:IsSignedIn) { return }
    }

    try {
        $id = $script:CurrentDevice.id
        Add-Log "Creating Remote Help session for device id: $id"
        Add-Log "Using Graph beta createRemoteHelpSession endpoint."

        # Portal trace shows that Intune uses createRemoteHelpSession with a SessionType payload.
        # Normal attended Remote Help uses: { "SessionType": "viewscreen" }
        # Some tenants/roles may allow takefullcontrol as well, so we try viewscreen first and then takefullcontrol.
        $session = $null
        $lastRemoteHelpError = $null
        $sessionPayloads = @(
            @{ Label = "viewscreen"; Body = '{"SessionType":"viewscreen"}' },
            @{ Label = "takefullcontrol"; Body = '{"SessionType":"takefullcontrol"}' }
        )

        foreach ($payload in $sessionPayloads) {
            try {
                Add-Log ("Trying Remote Help SessionType: {0}" -f $payload.Label)
                $session = Invoke-MgGraphRequest `
                    -Method POST `
                    -Uri "https://graph.microsoft.com/beta/deviceManagement/managedDevices/$id/createRemoteHelpSession" `
                    -Body $payload.Body `
                    -ContentType "application/json" `
                    -ErrorAction Stop

                Add-Log ("Remote Help session request completed with SessionType: {0}" -f $payload.Label)
                break
            }
            catch {
                $lastRemoteHelpError = $_
                $msg = $_.Exception.Message
                Add-Log ("Remote Help SessionType {0} failed: {1}" -f $payload.Label, $msg)
                try {
                    if ($_.ErrorDetails -and $_.ErrorDetails.Message) {
                        Add-Log ("Graph error detail: {0}" -f $_.ErrorDetails.Message)
                    }
                } catch {}
            }
        }

        if (-not $session) {
            if ($lastRemoteHelpError) { throw $lastRemoteHelpError }
            throw "Remote Help session creation failed. No response was returned."
        }

        try {
            $sessionJson = $session | ConvertTo-Json -Depth 10 -Compress
            Add-Log "Remote Help response: $sessionJson"
        } catch {
            Add-Log "Remote Help response received, but could not convert it to JSON."
        }

        $sessionKey = $session.sessionKey

        if (-not $sessionKey) {
            Add-Log "Remote Help session was created but no sessionKey was returned."
            return
        }

        Add-Log "Remote Help sessionKey/passcode received: $sessionKey"

        # v0.14: wait for the target device action queue to show remoteHelpLaunch as done.
        # The portal appears to wait for this device action before opening the helper-side Remote Help UI.
        Add-Log "Waiting for remoteHelpLaunch action to reach 'done' state on target device..."

        $maxWaitSeconds = 30
        $pollIntervalSeconds = 2
        $elapsed = 0
        $actionDone = $false

        while ($elapsed -lt $maxWaitSeconds) {
            Start-Sleep -Seconds $pollIntervalSeconds
            $elapsed += $pollIntervalSeconds

            try {
                $deviceState = Invoke-MgGraphRequest `
                    -Method GET `
                    -Uri "https://graph.microsoft.com/beta/deviceManagement/managedDevices('$id')?`$select=deviceActionResults" `
                    -ErrorAction Stop

                $actionResults = @()
                if ($deviceState.deviceActionResults) {
                    $actionResults = @($deviceState.deviceActionResults)
                }

                $launchAction = $actionResults |
                    Where-Object { $_.actionName -eq "remoteHelpLaunch" } |
                    Sort-Object lastUpdatedDateTime -Descending |
                    Select-Object -First 1

                if ($launchAction) {
                    $state = [string]$launchAction.actionState
                    $updated = [string]$launchAction.lastUpdatedDateTime
                    Add-Log ("remoteHelpLaunch state after {0}s: {1} LastUpdated: {2}" -f $elapsed, $state, $updated)

                    if ($state -ieq "done") {
                        $actionDone = $true
                        break
                    }
                }
                else {
                    Add-Log ("remoteHelpLaunch action not visible yet after {0}s." -f $elapsed)
                }
            }
            catch {
                Add-Log ("Polling error after {0}s: {1}" -f $elapsed, $_.Exception.Message)
                try {
                    if ($_.ErrorDetails -and $_.ErrorDetails.Message) {
                        Add-Log ("Polling Graph error detail: {0}" -f $_.ErrorDetails.Message)
                    }
                } catch {}
            }
        }

        if ($actionDone) {
            Add-Log "remoteHelpLaunch reached done. Launching helper Remote Help now."
        }
        else {
            Add-Log "remoteHelpLaunch did not reach done within timeout. Proceeding anyway, but target may not be ready."
        }

        # v0.18: Correct Remote Help protocol captured from the Intune portal.
        # Important differences from earlier builds:
        #   - ms-remote-help has a hyphen between remote and help
        #   - autolaunch is followed directly by ?passcode=, no slash before the query string
        $launchUri = "ms-remote-help://autolaunch?passcode=$sessionKey"

        Add-Log "Launch URI: $launchUri"
        Add-Log "Launching Remote Help using registered Windows protocol handler."
        Add-Log "Command: Start-Process -FilePath `"$launchUri`""

        try {
            $launchTime = Get-Date
            Start-Process -FilePath $launchUri -ErrorAction Stop
            $historyId = Save-SessionHistory -SessionType "Remote Help" -SessionKey $sessionKey
            Start-RemoteHelpDurationMonitor -EntryId $historyId -LaunchTime $launchTime
            Add-Log "Remote Help protocol launch command sent."
            return
        }
        catch {
            Add-Log "Protocol launch failed: $($_.Exception.Message)"
        }

        # Fallback only if the protocol handler fails. The primary path should be the protocol handler above.
        $remoteHelpExeCandidates = @(
            "$env:ProgramFiles\Remote Help\RemoteHelp.exe",
            "$env:ProgramFiles(x86)\Remote Help\RemoteHelp.exe",
            "C:\Program Files\Remote Help\RemoteHelp.exe"
        )
        $remoteHelpExe = $remoteHelpExeCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
        if (-not $remoteHelpExe) {
            throw "RemoteHelp.exe was not found and protocol launch failed. Please verify Remote Help is installed."
        }

        Add-Log "Falling back to RemoteHelp.exe direct launch with corrected URI."
        Add-Log "Command: `"$remoteHelpExe`" `"$launchUri`""
        $launchTime = Get-Date
        Start-Process -FilePath $remoteHelpExe -ArgumentList @($launchUri) -ErrorAction Stop
        $historyId = Save-SessionHistory -SessionType "Remote Help" -SessionKey $sessionKey
        Start-RemoteHelpDurationMonitor -EntryId $historyId -LaunchTime $launchTime
        Add-Log "RemoteHelp.exe fallback launch command sent."
    }
    catch {
        $err = $_.Exception.Message
        Add-Log "Remote Help failed: $err"
        if ($err -match "Forbidden|403") {
            Add-Log "403/Forbidden from createRemoteHelpSession. Portal uses this Graph beta endpoint, so check Remote Help RBAC/scope/licensing and Graph consent."
        }
        [System.Windows.MessageBox]::Show(
            $err,
            "Remote Help failed",
            "OK",
            "Error"
        ) | Out-Null
    }
}

$searchButton = Find-Control "SearchButton"
if ($searchButton) { $searchButton.Add_Click({ Search-Device }) }

$searchBox = Find-Control "SearchBox"
if ($searchBox) {
    $searchBox.Add_KeyDown({
        param($sender, $e)
        if ($e.Key -eq [System.Windows.Input.Key]::Enter) {
            Search-Device
            $e.Handled = $true
        }
    })
}

$signInButton = Find-Control "SignInButton"
if ($signInButton) { $signInButton.Add_Click({ Connect-GraphBackend }) }

$remote = Find-Control "RemoteHelpButton"
if ($remote) { $remote.Add_Click({ Start-RemoteHelpForCurrentDevice }) }

$sync = Find-Control "SyncButton"
if ($sync) { $sync.Add_Click({ Sync-CurrentDevice }) }

$restart = Find-Control "RestartButton"
if ($restart) { $restart.Add_Click({ Restart-CurrentDevice }) }

$open = Find-Control "OpenIntuneButton"
if ($open) { $open.Add_Click({ Open-CurrentDeviceInIntune }) }

$refresh = Find-Control "RefreshButton"
if ($refresh) { $refresh.Add_Click({ Search-Device }) }

$previousDevice = Find-Control "PreviousDeviceButton"
if ($previousDevice) { $previousDevice.Add_Click({ Show-PreviousDevice }) }

$nextDevice = Find-Control "NextDeviceButton"
if ($nextDevice) { $nextDevice.Add_Click({ Show-NextDevice }) }

$sessionActivityNav = Find-Control "SessionActivityNav"
if ($sessionActivityNav) { $sessionActivityNav.Add_MouseLeftButtonUp({ Show-SessionActivityWindow }) }

$openLocalHistory = Find-Control "OpenLocalHistoryButton"
if ($openLocalHistory) { $openLocalHistory.Add_Click({ Open-SessionHistoryFile }) }

if ($DemoMode) {
    Set-ConnectionState "Demo mode"
    Add-Log "Running in demo mode. Search returns sample data."
}

[void]$window.ShowDialog()
