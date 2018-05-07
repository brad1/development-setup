param
(
	[String]$target,
	[String]$password,
	
	# Path to dll on target node
	[String]$filepath
)

if(!$target -or !$password -or !$filepath) {
	Throw "GetDLLVersion.ps1 '127.0.0.1' 'secure' 'C:\mylib.dll'"
}

function Get-PSSession($ip, $c) {
  Write-Host "Getting remote powershell session..."

  $session_established = $false
  $retries = 10
  $session = $null
  while(!$session_established)
  {
    $retries--
    Try
    {
      $session = New-PSSession -ComputerName $ip -Credential $c
      $session_established = $true
    }
    Catch
    {
      $session = $null
      $session_established = $false
      Write-Host $_
      Start-Sleep -Seconds 5
    }
    if (!$session_established -And $retries -le 0)
    {
      Throw "failed to establish session"
    }
  }
  return $session
}

$cred = New-Object System.Management.Automation.PSCredential -ArgumentList "Administrator", (ConvertTo-SecureString -AsPlainText $password -Force)
$session = Get-PSSession $target $cred
Invoke-Command -Session $session -ArgumentList $filepath -ScriptBlock {
  param
  (
	$filepath
  )
  (Get-Command "$filepath").FileVersionInfo
}
Remove-PSSession $session