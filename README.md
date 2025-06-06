# Windows11Setup

Quickly get a new windows 11 setup the way I like it.

1. Install WinGet and default packages

   ```powershell
   #(Invoke-WebRequest -Uri https://gist.github.com/ajdalholm/d5ec667f5ecf77dff5e85dbfa3ca15aa/raw).content | Invoke-Expression
   #Refresh Path
   #Invoke-Command -ScriptBlock {$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") }
   #Default packages
   winget install Git.Git 7zip.7zip Brave.Brave Microsoft.VisualStudioCode Microsoft.PowerShell WireGuard.WireGuard WinMerge.WinMerge RaspberryPiFoundation.RaspberryPiImager --accept-package-agreements --accept-source-agreements
   #Refresh Path
   #Invoke-Command -ScriptBlock {$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") }

   ```

1. Configure Powershell

   ```powershell
   Write-Information -InformationAction Continue -MessageData 'Setting execution policy to RemoteSigned'
   Invoke-Command -ScriptBlock {$sh = new-object -com Shell.Application; $sh.ShellExecute('powershell', '-Command "Set-ExecutionPolicy RemoteSigned"', '', 'runas')}
   Write-Information -InformationAction Continue -MessageData 'Installing Nuget'
   Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
   Write-Information -InformationAction Continue -MessageData 'Trusting PSGallery'
   Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
   Write-Information -InformationAction Continue -MessageData 'Adding myrepo as trusted'
   Register-PSRepository -Name myrepo -SourceLocation \\nas.dalholm.net\myrepo -PublishLocation \\nas.dalholm.net\myrepo -ScriptSourceLocation \\nas.dalholm.net\myrepo -ScriptPublishLocation \\nas.dalholm.net\myrepo -InstallationPolicy Trusted
   Write-Information -InformationAction Continue -MessageData 'Removing old builtin pester module'

   $PesterDefaultModulePath = "C:\Program Files\WindowsPowerShell\Modules\Pester"
    if (-not (Test-Path $PesterDefaultModulePath)) {
        Write-Information -InformationAction Continue -MessageData 'Pester module not present - will not try to remove it'
    } else {
        $ACL = Get-Acl -Path $PesterDefaultModulePath
        $Account = New-Object System.Security.Principal.NTAccount("Builtin\Administrators")
        $ACL.SetOwner($Account)
        Set-Acl -Path $PesterDefaultModulePath -AclObject $ACL
        icacls $PesterDefaultModulePath /reset
        #icacls $PesterDefaultModulePath /grant Administrators:'F' /inheritance:d /T
        Remove-Item -Path $PesterDefaultModulePath -Recurse -Force -Confirm:$false
    }
   Write-Information -InformationAction Continue -MessageData 'Installing module Pester'
   Install-Module -Name Pester -Repository PSGallery -Scope CurrentUser
   Write-Information -InformationAction Continue -MessageData 'Installing module Microsoft.Winget.Client'
   install-module -Name Microsoft.WinGet.Client -Scope CurrentUser
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

   #Hyper-V
   $OSEdition = (Get-ItemProperty -Path "HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion" -Name "EditionID").EditionID
   Switch ($OSEdition)
   {
      {$_ -in @('Professional','Enterprise')} {
         Write-Verbose "Enabling feature"
         Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -NoRestart
      }
      {$_ -in @('Home')} {
         Write-Verbose "Copying files"
      }
      Default {
         Write-Host "No matches"
      }
   }
   

   #WSL
   Invoke-Command -ScriptBlock {wsl.exe --install}

   #Docker Desktop
   #Install-WinGetPackage -Mode Silent -Id Docker.DockerDesktop 


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
    if ( -not (Test-Path "HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced\\TaskbarDeveloperSettings") ) {
        New-Item -Path "HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" -Name 'TaskbarDeveloperSettings'
    }
    if ( -not (Get-ItemProperty -Path "HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced\\TaskbarDeveloperSettings" -Name 'TaskbarEndTask' -ErrorAction SilentlyContinue) ) {
        $null = New-ItemProperty -Path "HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced\\TaskbarDeveloperSettings" -Name 'TaskbarEndTask' -Type 'string' -Value 1
    } else {
        Set-ItemProperty -Path "HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced\\TaskbarDeveloperSettings" -Name 'TaskbarEndTask' -Value 1
    }

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
    if ( -not (Test-Path "HKCU:\\Software\\Classes\\CLSID\\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}") ) {
        New-Item -Path "HKCU:\\Software\\Classes\\CLSID" -Name '{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}'
    }
    if ( -not (Test-Path -Path "HKCU:\\Software\\Classes\\CLSID\\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\\InprocServer32") ) {
        New-Item -Path "HKCU:\\Software\\Classes\\CLSID\\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Name 'InprocServer32' -Value ""
    }
    Write-Information "Legacy right-click context menu will be in effect after a restart" -InformationAction Continue

    #Disable IPv6
    Write-Verbose "Disabling IPv6" -Verbose
    Set-ItemProperty -Path "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\Tcpip6\\Parameters" -Name 'DisabledComponents' -Value '255' -Type 'DWord'

    #Disable search in taskbar
    Write-Verbose "Disabling search in taskbar" -Verbose
    Set-ItemProperty -Path "HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Search" -Name "SearchboxTaskbarMode" -Value "0"

    #Disable Bing search in startmenu
    Write-Verbose "Disabling Bing search in startmenu" -Verbose
    if ( -not (Test-Path "HKCU:\\SOFTWARE\\Policies\\Microsoft\\Windows\\Explorer") ) {
        New-Item -Path "HKCU:\\SOFTWARE\\Policies\\Microsoft\\Windows" -Name 'Explorer'
    }
    Set-ItemProperty -Path "HKCU:\\Software\\Policies\\Microsoft\\Windows\\Explorer" -Name "DisableSearchBoxSuggestions" -Type "DWord" -Value "1"
    Write-Information "Bing search in start menu will be disabled after a restart" -InformationAction Continue

    #Enable NumLock
    Write-Verbose "Enabling NumLock" -Verbose
    $InitialKeyboardIndicators = (Get-ItemProperty -Path "HKCU:\\Control Panel\\Keyboard" -Name 'InitialKeyboardIndicators').InitialKeyboardIndicators -bor 2
    Set-ItemProperty -Path "HKCU:\\Control Panel\\Keyboard" -Name 'InitialKeyboardIndicators' -Value $InitialKeyboardIndicators

    #Show file extensions
    Write-Verbose "Show file extensions in explorer" -Verbose
    Set-ItemProperty -Path 'HKCU:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced' -Name 'HideFileExt' -Value 0

    #Mouse acceleration
    Write-Verbose "Enabling mouse acceleration" -Verbose
    if ( -not (Get-ItemProperty -Path "HKCU:\\Control Panel\\Mouse" -Name 'MouseSpeed' -ErrorAction SilentlyContinue) ) {
        $null = New-ItemProperty -Path "HKCU:\\Control Panel\\Mouse" -Name 'MouseSpeed' -Type 'string' -Value 1
    } else {
        Set-ItemProperty -Path "HKCU:\\Control Panel\\Mouse" -Name 'MouseSpeed' -Value 1
    }

    #Disable Stick Key
    Write-Verbose "Disabling sticky key" -Verbose
    $StickyKeyFlag = (Get-ItemProperty -Path "HKCU:\\Control Panel\\Accessibility\\StickyKeys" -Name 'Flags').Flags -bxor 4
    Set-ItemProperty -Path "HKCU:\\Control Panel\\Accessibility\\StickyKeys" -Name 'Flags' -Value $StickyKeyFlag
    $KeyboardResponse = (Get-ItemProperty -Path "HKCU:\\Control Panel\\Accessibility\\Keyboard Response" -Name 'Flags').Flags -bxor 4
    Set-ItemProperty -Path "HKCU:\\Control Panel\\Accessibility\\Keyboard Response" -Name 'Flags' -Value $KeyboardResponse

    #Disable Taskbar widgets
    Write-Verbose "Disabling taskbar widgets" -Verbose
        if ( -not (Test-Path "HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced") ) {
        New-Item -Path "HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer" -Name 'Advanced'
    }
    if ( -not (Get-ItemProperty -Path "HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" -Name 'TaskbarDa' -ErrorAction SilentlyContinue) ) {
        $null = New-ItemProperty -Path "HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" -Name 'TaskbarDa' -Type 'string' -Value 0
    } else {
        Set-ItemProperty -Path "HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" -Name 'TaskbarDa' -Value 0
    }

    #Disable Task View on taskbar
    Write-Verbose "Disabling Task View on taskbar" -Verbose
    if ( -not (Get-ItemProperty -Path "HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" -Name 'ShowTaskViewButton' -ErrorAction SilentlyContinue) ) {
        $null = New-ItemProperty -Path "HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" -Name 'ShowTaskViewButton' -Type 'string' -Value 0
    } else {
        Set-ItemProperty -Path "HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" -Name 'ShowTaskViewButton' -Value 0
    }

   ```
