$JS = @()

$JS += Start-Job -Name "Exception0" -FilePath "$($MyInvocation.MyCommand.Definition)\..\Exception.ps1"
$JS += Start-Job -Name "Exception1" -FilePath "$($MyInvocation.MyCommand.Definition)\..\Exception.ps1"


Foreach($J in $JS) {
    while("Running" -eq $J.State) {
        Write-Output "Waiting for $($J.Name)"
        sleep 1
    }
}

Foreach($J in $JS) {
    Write-Output "$($J.Name) $($J.State)"
}

Foreach($J in $JS) {
      Receive-Job $J
}
