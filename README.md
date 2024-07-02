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
    Invoke-Command -ScriptBlock {powershell.exe -Command "& {Push-Location -Path (Join-Path -Path $env:USERPROFILE -ChildPath Win11Setup_Part1) -ErrorAction Stop; Copy-Item -Path ./Assets/.gitconfig -Destination $env:USERPROFILE; & 'notepad.exe' $env:USERPROFILE\.gitconfig; Pop-Location}"}
    ```
