function Get-ServiceInventory {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        
    }
    
    process {
        $serviceProps = @('Name', 'DisplayName')
        $AllServices = Get-Service | Select-Object -Property $serviceProps
        $numServices = $AllServices.Count
        Write-Information "Found $numServices services" -InformationAction Continue
        $cimProps = @('State', 'StartMode')
        #$AllServices | foreach-object {Get-CimInstance -Query "SELECT $($cimProps -join ',') FROM Win32_Service WHERE Name='$($_.Name)'"} | Select-Object -Property $cimProps
        [int]$i = 0
        $result = foreach ( $service in $AllServices ) {
            Write-Progress -Activity "Getting additional service info for $($service.Name)" -PercentComplete $($i++ * 100 / $numServices)
            Write-Information "$($service.Name)" -InformationAction Continue
            #Addition CIM properties
            $cimProps = @('Caption', 'Description', 'State', 'StartMode')
            $cimResult = Get-CimInstance -Query "SELECT $($cimProps -join ',') FROM Win32_Service WHERE Name='$($service.Name)'"
            [PSCustomObject]@{
                Caption     = $cimResult.Caption
                Description = $cimResult.Description
                DisplayName = $service.DisplayName
                Name        = $service.Name
                StartupMode = $cimResult.StartMode
            }
        }


    }
    
    end {
        
    }
}
