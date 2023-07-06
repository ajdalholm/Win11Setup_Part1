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
1. Apps
   ```powershell
   Push-Location -Path (Join-Path -Path $env:USERPROFILE -ChildPath Windows11Setup)
   $Apps = get-content -path .\assets\Apps.json | convertfrom-json
   $Apps | foreach-object {
        Write-Information $_.Name -InformationAction Continue
        $Override = $null
        if ($_.Override -ne $null) {
            $Override = " --override $($ExecutionContext.InvokeCommand.ExpandString($_.Override))"
            Write-Information "Override configured to '$Override'" -InformationAction Continue
        }
        switch ($_.Category) {
            "common" {
                #These are the apps I would like to have on any machine
                Write-Information "Installing common app $($_.Name)" -InformationAction Continue
                & winget install --accept-package-agreements --accept-source-agreements --exact --silent $_.ID
                break
            }
            "unwanted" {
                Write-Information "Removing unwanted app $($_.Name)" -InformationAction Continue
                & winget uninstall $_.ID
                break
            }
            "developer" {
                #These are the apps I would like to have on any machine
                Write-Information "Installing common app $($_.Name)" -InformationAction Continue
                & winget install --accept-package-agreements --accept-source-agreements --exact --silent $Override $_.ID
                break
            }
            "tolerated" {
                #These are apps I tolerate having on the system.
                #For now nothing is to be done with this.. But in the future
                #this list should be compared to actualle installed apps
                Write-Information "Tolerated app $($_.Name)" -InformationAction Continue
                break;
            }
            Default {
                Write-Error "Unhandled category: $($_.Category) - please fix in code or configuration" -ErrorAction Continue
            }
        }
   }
   #Refresh Path
   $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")  
   Pop-Location

   ```
