param
(
  $IP,
  $User,
  $Password,
  $Services
)

$passwd  = ConvertTo-SecureString -AsPlainText $Password -Force
$cred    = New-Object System.Management.Automation.PSCredential -ArgumentList $User,$passwd
$session = New-PSSession -ComputerName $IP -Credential $cred

Invoke-Command -Session $session -ArgumentList $Services -ScriptBlock {
    param($services)

	[System.Collections.ArrayList]$found_services = @()
	
    ForEach ($service in $services.Split(','))
    {
        $service = $service.Trim()
        $results = Get-Service | Where-Object { $_.Name -eq $service }
		
		if ($results.Count -eq 1)
		{
			$found_services.Add($results[0])
		}
    }
	
	$table = @{Expression={$_.Name};Label="Service Name";width=20}, `
	@{Expression={$_.Status};Label="Status";width=10}

	$found_services | Format-Table $table
}
Remove-PSSession $session