


function update-VM
{
	param
	([string]$Host)
	
	Import-Module WindowsUpdate
	
	try
	{
		Enter-PSSession -ComputerName $Host
	}
	catch
	{
		Write-Host $Host "Failed to connect" -ForegroundColor Red
	}
}