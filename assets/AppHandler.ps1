Push-Location -Path (Join-Path -Path $env:USERPROFILE -ChildPath Win11Setup_Part1)
$Apps = get-content -path .\assets\Apps.json | convertfrom-json
$Apps | foreach-object {
    $CurrentApp = $_
    $Argumentlist = @('install','--id', $CurrentApp.ID,'--accept-package-agreements','--accept-source-agreements','--exact','--silent')
    if ($CurrentApp.Override -ne $null) {
        $Argumentlist += '--override'
        $Argumentlist += "$($ExecutionContext.InvokeCommand.ExpandString($CurrentApp.Override))"
    }
    #$Argumentlist = "install --accept-package-agreements --accept-source-agreements --exact --silent$Override --id $($CurrentApp.ID)"
    switch ($CurrentApp.Category) {
        "common" {
            #These are the apps I would like to have on any machine
            Write-Information "Installing common app $($CurrentApp.Name)" -InformationAction Continue
            #& winget install --accept-package-agreements --accept-source-agreements --exact --silent --id $CurrentApp.ID
            & winget $Argumentlist
            break
        }
        "unwanted" {
            Write-Information "Removing unwanted app $($CurrentApp.Name)" -InformationAction Continue
            & winget uninstall $CurrentApp.ID
            break
        }
        "developer" {
            #These are the apps I would like to have on any machine
            Write-Information "Installing developer app $($CurrentApp.Name)" -InformationAction Continue
            Write-Information "winget $Argumentlist" -InformationAction Continue
            & winget $Argumentlist
            break
        }
        "tolerated" {
            #These are apps I tolerate having on the system.
            #For now nothing is to be done with this.. But in the future
            #this list should be compared to actualle installed apps
            Write-Information "Tolerated app $($CurrentApp.Name)" -InformationAction Continue
            break;
        }
        "additional" {
            #These are apps I tolerate having on the system.
            #For now nothing is to be done with this.. But in the future
            #this list should be compared to actualle installed apps
            Write-Information "Installing additional app $($CurrentApp.Name)" -InformationAction Continue
            Write-Information "winget $Argumentlist" -InformationAction Continue
            & winget $Argumentlist
            break;
        }
        Default {
            Write-Error "Unhandled category: $($CurrentApp.Category) - please fix in code or configuration" -ErrorAction Continue
        }
    }
}
#Refresh Path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")  
Pop-Location