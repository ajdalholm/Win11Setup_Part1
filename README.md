# Windows11Setup
Quickly get a new windows 11 setup the way I like it.

1. Install WinGet and default packages
    ```powershell
    (Invoke-WebRequest -Uri https://gist.github.com/ajdalholm/d5ec667f5ecf77dff5e85dbfa3ca15aa/raw).content | Invoke-Expression
    #Refresh Path
    Invoke-Command -ScriptBlock {$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") }
    #Default packages
    winget install Git.Git 7zip.7zip Google.Chrome Microsoft.VisualStudioCode Microsoft.PowerShell WireGuard.WireGuard WinMerge.WinMerge RaspberryPiFoundation.RaspberryPiImager --accept-package-agreements --accept-source-agreements
    #Refresh Path
    Invoke-Command -ScriptBlock {$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") }
    ```
1. Configure Powershell
    ```powershell
    #Set execution policy to RemoteSigned
    Invoke-Command -ScriptBlock {$sh = new-object -com Shell.Application; $sh.ShellExecute('powershell', '-Command "Set-ExecutionPolicy RemoteSigned"', '', 'runas')}
    ```
1. Clone git repository
    ```powershell 
    #clone this repository
    Invoke-Command -ScriptBlock {powershell.exe -Command "& {Push-Location $env:USERPROFILE ; & 'git.exe' clone https://github.com/ajdalholm/Win11Setup_Part1; Pop-Location}"}
    #Prompt for gitconfig configuration
    Invoke-Command -ScriptBlock {powershell.exe -Command "& {Push-Location -Path (Join-Path -Path $env:USERPROFILE -ChildPath Win11Setup_Part1) -ErrorAction Stop; Copy-Item -Path ./Assets/.gitconfig -Destination $env:USERPROFILE; Pop-Location}"}
    ```
1. Configuration
    ```powershell
    #Disables homegroup sharing
    get-service HomeGroupListener -ea SilentlyContinue | Set-Service -StartupType manual -ea SilentlyContinue
    get-service HomeGroupProvider -ea SilentlyContinue | Set-Service -StartupType manual -ea SilentlyContinue

    #Disable consumer features
    $CloudContent = Get-Item -Path "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\CloudContent" -ErrorAction SilentlyContinue
    if ( $null -eq $CloudContent ) {
        $CloudContent = New-Item -Path "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\CloudContent" -ErrorAction SilentlyContinue
    }
    $DisabledWindowsConsumerFeatures = $cloudContent | Get-ItemProperty -Name DisableWindowsConsumerFeatures -ErrorAction SilentlyContinue
    if ( $null -eq $DisabledWindowsConsumerFeatures ) {
        $null = $CloudContent | New-ItemProperty -Name DisableWindowsConsumerFeatures -PropertyType DWord -Value 1
    }

    #Telemetry
    Get-ItemProperty -Path "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\DataCollection" -Name AllowTelemetry -ErrorAction SilentlyContinue | Set-ItemProperty -Value 0 -Name AllowTelemetry

    Get-ItemProperty -Path "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\DataCollection" -Name AllowTelemetry -ErrorAction SilentlyContinue | Set-ItemProperty -Value 0 -Name AllowTelemetry

    #ContentDelivery
    Get-ItemProperty -Path "HKCU:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\ContentDeliveryManager" -Name ContentDeliveryAllowed -ErrorAction SilentlyContinue | Set-ItemProperty -Value 0 -Name ContentDeliveryAllowed
    Get-ItemProperty -Path "HKCU:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\ContentDeliveryManager" -Name OemPreInstalledAppsEnabled -ErrorAction SilentlyContinue | Set-ItemProperty -Value 0 -Name OemPreInstalledAppsEnabled
    Get-ItemProperty -Path "HKCU:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\ContentDeliveryManager" -Name PreInstalledAppsEnabled -ErrorAction SilentlyContinue | Set-ItemProperty -Value 0 -Name PreInstalledAppsEnabled
    Get-ItemProperty -Path "HKCU:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\ContentDeliveryManager" -Name PreInstalledAppsEverEnabled -ErrorAction SilentlyContinue | Set-ItemProperty -Value 0 -Name PreInstalledAppsEverEnabled
    Get-ItemProperty -Path "HKCU:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\ContentDeliveryManager" -Name SilentInstalledAppsEnabled -ErrorAction SilentlyContinue | Set-ItemProperty -Value 0 -Name SilentInstalledAppsEnabled
    Get-ItemProperty -Path "HKCU:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\ContentDeliveryManager" -Name 'SubscribedContent-338387Enabled' -ErrorAction SilentlyContinue | Set-ItemProperty -Value 0 -Name 'SubscribedContent-338387Enabled'
    Get-ItemProperty -Path "HKCU:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\ContentDeliveryManager" -Name 'SubscribedContent-338388Enabled' -ErrorAction SilentlyContinue | Set-ItemProperty -Value 0 -Name 'SubscribedContent-338388Enabled'
    Get-ItemProperty -Path "HKCU:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\ContentDeliveryManager" -Name 'SubscribedContent-338389Enabled' -ErrorAction SilentlyContinue | Set-ItemProperty -Value 0 -Name 'SubscribedContent-338389Enabled'
    Get-ItemProperty -Path "HKCU:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\ContentDeliveryManager" -Name 'SubscribedContent-353698Enabled' -ErrorAction SilentlyContinue | Set-ItemProperty -Value 0 -Name 'SubscribedContent-353698Enabled'
    Get-ItemProperty -Path "HKCU:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\ContentDeliveryManager" -Name 'SystemPaneSuggestionsEnabled' -ErrorAction SilentlyContinue | Set-ItemProperty -Value 0 -Name 'SystemPaneSuggestionsEnabled'

    
    ```
