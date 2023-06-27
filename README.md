# Windows11Setup
Quickly get a new windows 11 setup the way I like it.

1. Install git
    ```powershell
    #install git
    winget install Git.Git
    #Refresh Path
    Invoke-Command -ScriptBlock {$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") }
    #clone this repository
    Invoke-Command -ScriptBlock {powershell.exe -Command "& {Push-Location $env:USERPROFILE ; & 'git.exe' clone https://github.com/ajdalholm/Windows11Setup;}"}
    #Prompt for gitconfig configuration
    Invoke-Command -ScriptBlock {powershell.exe -Command "& {Push-Location -Path (Join-Path -Path $env:USERPROFILE -ChildPath Windows11Setup); Copy-Item -Path ./Assets/.gitconfig -Destination $env:USERPROFILE; & 'notepad.exe' $env:USERPROFILE\.gitconfig}"}
    #Set execution policy to RemoteSigned
    Invoke-Command -ScriptBlock {$sh = new-object -com Shell.Application; $sh.ShellExecute('powershell', '-Command "Set-ExecutionPolicy RemoteSigned"', '', 'runas')}
    ```
1. Install common applications
   ```powershell
   Push-Location -Path (Join-Path -Path $env:USERPROFILE -ChildPath Windows11Setup)
   $CommonApps = get-content -path .\CommonApps.json | convertfrom-json
   $CommonApps | foreach-object {
    Write-Host "Installing $($_.Name)"
    & winget install $_.ID
   }
   ```
