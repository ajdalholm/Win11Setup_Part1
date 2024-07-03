# Windows11Setup
Quickly get a new windows 11 setup the way I like it.

1. Install WinGet and default packages
1. Install WinGet and default packages
    ```powershell
    (Invoke-WebRequest -Uri https://gist.github.com/ajdalholm/d5ec667f5ecf77dff5e85dbfa3ca15aa/raw).content | Invoke-Expression
    #Refresh Path
    Invoke-Command -ScriptBlock {$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") }
    #Default packages
    winget install Git.Git 7zip.7zip Google.Chrome Microsoft.VisualStudioCode Microsoft.PowerShell WireGuard.WireGuard WinMerge.WinMerge RaspberryPiFoundation.RaspberryPiImager --accept-package-agreements --accept-source-agreements
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
1. Windows configuration
   ```powershell
   #Powersettings 
   Write-Verbose "Setting timeout intervals" -Verbose
   Start-Process -FilePath powercfg -ArgumentList "/change standby-timeout-ac 0" -NoNewWindow -Wait
   Start-Process -FilePath powercfg -ArgumentList "/change standby-timeout-dc 30" -NoNewWindow -Wait
   Start-Process -FilePath powercfg -ArgumentList "/change monitor-timeout-ac 30" -NoNewWindow -Wait
   Start-Process -FilePath powercfg -ArgumentList "/change monitor-timeout-dc 25" -NoNewWindow -Wait
   Write-Verbose "Diabling hibernation" -Verbose
   Start-Process -FilePath powercfg -ArgumentList "/hibernate off" -NoNewWindow -Wait

   #HomeGroup
   Write-Verbose "Disabling HomeGroup" -Verbose
   Get-Service -name HomeGroupListener -ErrorAction SilentlyContinue |  Set-Service -StartupType Manual
   Get-Service -name HomeGroupProvider -ErrorAction SilentlyContinue |  Set-Service -StartupType Manual

    #Disable consumer features
    Write-Verbose "Disabling Consumer features" -Verbose

    $CloudContent = Get-Item -Path "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\CloudContent" -ErrorAction SilentlyContinue
    if ( $null -eq $CloudContent ) {
        $CloudContent = New-Item -Path "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\CloudContent" -ErrorAction SilentlyContinue
    }
    $DisabledWindowsConsumerFeatures = $cloudContent | Get-ItemProperty -Name DisableWindowsConsumerFeatures -ErrorAction SilentlyContinue
    if ( $null -eq $DisabledWindowsConsumerFeatures ) {
        $null = $CloudContent | New-ItemProperty -Name DisableWindowsConsumerFeatures -PropertyType DWord -Value 1
    }

    #Enable End Task with right click
    Write-Verbose "Enabling rigth-click End Task" -Verbose
    Set-ItemProperty -Path "HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced\\TaskbarDeveloperSettings" -Name "TaskbarEndTask" -Type "DWord" -Value "1"

    #Disable Storage Sense
    Write-Verbose "Disabling Storage Sense" -Verbose
    Set-ItemProperty -Path "HKCU:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\StorageSense\\Parameters\\StoragePolicy" -Name "01" -Value 0 -Type "Dword" -Force

    #Disable Intel(R) Management and Security Application Local Management Service
    Write-Verbose "Disabling Intel(R) Management and Security Application Local Management Service" -Verbose
    Get-Service -Name lms -ErrorAction SilentlyContinue | Stop-Service
    Get-Service -Name lms -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled

    #Disable Notification Tray/Calendar
    Write-Verbose "Disable Notification Tray/Calendar" -Verbose
    if ( -not (Test-Path "HKCU:\\Software\\Policies\\Microsoft\\Windows\\Explorer") ) {
        New-Item -Path "HKCU:\\Software\\Policies\\Microsoft\\Windows" -Name 'Explorer'
    }
    Set-ItemProperty -Path "HKCU:\\Software\\Policies\\Microsoft\\Windows\\Explorer" -Name "DisableNotificationCenter" -Type "DWord" -Value "1"
    Set-ItemProperty -Path "HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\PushNotifications" -Name "ToastEnabled" -Type "DWord" -Value "0"

    #Legacy Right-Click Menu
    Write-Verbose "Enabling legacy right-click context Menu" -Verbose
    if ( -not (Test-Path -Path "HKCU:\\Software\\Classes\\CLSID\\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\\InprocServer32") ) {
        New-Item -Path "HKCU:\\Software\\Classes\\CLSID\\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Name 'InprocServer32'
    }
    Write-Information "Legacy right-click context menu will be in effect after a restart" -InformationAction Continue
    
   ```
